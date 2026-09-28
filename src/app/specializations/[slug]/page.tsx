import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
import {
  Card,
  CardTitle,
  Section,
  RowCard,
  ListRow,
  Pill,
  MetricRow,
  HeroVisual,
  dedupe,
  dedupeBy,
  formatOpenings,
  tint,
} from "@/components/detail/DetailKit";
import { getSpecialization, getManySpecializations } from "@/data/specializations";
import { getManyCareers } from "@/data/careers";
import { getManyExams } from "@/data/exams";
import { getManySkills } from "@/data/skills";
import { getManyIndustries } from "@/data/industries";
import { getManyColleges } from "@/data/colleges";
import { getManyJobRoles } from "@/data/jobRoles";
import { getManyResources, getResourcesByCareer } from "@/data/resources";
import { getDegrees } from "@/data/degrees";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";
import type { Career, Education } from "@/lib/types";

// The SPECIALIZATION page: one focused area within a career. Same layout as
// the career page on purpose -- a reader moving between them should recognise
// the shape and only notice that the scope narrowed.
//
// Every section is driven by a relation, so the same markup serves all 263
// rows; Artificial Intelligence is not special-cased anywhere.
//
// WHERE THE DATA COMES FROM, and why some of it is borrowed.
//
// A specialization owns its own degrees, skills, industries, exams, colleges,
// resources and salary. Almost none of the 263 have them filled in, and
// bulk-copying each parent career's rows down onto its specializations would
// have asserted things nobody checked -- that every college teaching CSE
// teaches Blockchain, that every CSE exam is a Game Development exam.
//
// So where a specialization has nothing of its own, the page falls back to its
// parent career's data AND SAYS SO in the section's subtitle ("Routes into
// Computer Science & Engineering", not "...into this specialization"). Filling
// the specialization's own relation silently replaces the fallback -- no code
// change, no flag to flip.

const DEMAND_STYLES: Record<string, string> = {
  HIGH: "bg-green-soft text-green",
  MEDIUM: "bg-amber-soft text-amber",
  LOW: "bg-slate-soft text-slate",
};

const DEMAND_LABELS: Record<string, string> = {
  HIGH: "High Demand",
  MEDIUM: "Medium Demand",
  LOW: "Low Demand",
};

const HIGHLIGHT_ICONS = ["trend", "rocket", "flask", "compass", "bulb"] as const;

// The catalog uses Guide / Website / Article, plus Course from V109's AI
// resources. An unknown type falls back to `doc` rather than rendering nothing.
const RESOURCE_ICONS: Record<string, string> = {
  Article: "doc",
  Guide: "book",
  Website: "external",
  Course: "cap",
  Video: "monitor",
  PDF: "doc",
};

// No generateStaticParams: the catalog lives in Postgres and can change at any
// time, so specialization pages render dynamically per request.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const specialization = await getSpecialization(slug);
  if (!specialization) return {};
  return {
    title: `${specialization.name} — CareerGuide`,
    description: specialization.description,
  };
}

export default async function SpecializationDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const specialization = await getSpecialization(slug);
  if (!specialization) notFound();

  // Wave 1: the parent careers, because every fallback below is drawn from
  // them and the page cannot know what to fetch until it has them.
  const careers = await getManyCareers(specialization.careerSlugs);
  // The canonical parent, not simply the first one returned (V117).
  const parent = careers.find((c) => c.slug === specialization.primaryCareerSlug) ?? careers[0];
  const parentNames = careers.map((c) => c.title).join(" & ");

  // Union across parents, order preserved, duplicates dropped -- a
  // specialization can sit under more than one career (Cloud Computing is
  // under both CSE and IT) and the two parents' lists overlap heavily.
  const fromCareers = (pick: (c: Career) => string[]) => dedupe(careers.flatMap(pick));

  const ownEducation = specialization.education;
  const educationRefs: Education[] = ownEducation.length
    ? ownEducation
    : dedupeBy(
        careers.flatMap((c) => c.education),
        (e) => `${e.degreeSlug}|${e.subjectSlug ?? ""}`
      );

  const ownSkills = [
    ...specialization.relatedHardSkillSlugs,
    ...specialization.relatedSoftSkillSlugs,
  ];
  const skillSlugs = ownSkills.length ? ownSkills : fromCareers((c) => c.relatedSkillSlugs);

  // Industries answer two questions -- which FIELDS this is applied in
  // (is_sector) and which COMPANIES hire for it -- so the two halves fall back
  // INDEPENDENTLY. A specialization that lists its own sectors but no
  // employers should still show the career's recruiters rather than hide the
  // section, which is what a single all-or-nothing fallback did.
  const careerIndustrySlugs = fromCareers((c) => c.relatedIndustrySlugs);
  const industrySlugs = dedupe([...specialization.industrySlugs, ...careerIndustrySlugs]);

  const examSlugs = specialization.relatedExamSlugs.length
    ? specialization.relatedExamSlugs
    : fromCareers((c) => c.relatedExamSlugs);

  const collegeSlugs = specialization.collegeSlugs.length
    ? specialization.collegeSlugs
    : fromCareers((c) => c.relatedCollegeSlugs);

  // NO FALLBACK to the parent career's roles, unlike every other section
  // here. The model is a strict hierarchy -- Career owns Specializations,
  // Specialization owns Roles -- so a role reached from a specialization must
  // be that specialization's own. Borrowing the career's list would put roles
  // from sibling specializations on this page, which is exactly the overlap
  // the hierarchy exists to prevent.
  //
  // 13 specializations have no roles yet and simply render no section. That
  // is a content gap to fill, not a hole to paper over with the career's list.
  const jobRoleSlugs = specialization.relatedJobRoleSlugs;

  // Related specializations are the siblings -- the other specializations of
  // the same career(s). career_specializations already records that, so it is
  // read from there rather than stored a second time on each specialization.
  const siblingSlugs = fromCareers((c) => c.relatedSpecializationSlugs).filter(
    (s) => s !== specialization.slug
  );

  // Wave 2.
  const [skills, industries, exams, colleges, jobRoles, resources, siblings, degrees, categories] =
    await Promise.all([
      getManySkills(skillSlugs),
      getManyIndustries(industrySlugs),
      getManyExams(examSlugs),
      getManyColleges(collegeSlugs),
      getManyJobRoles(jobRoleSlugs),
      specialization.resourceSlugs.length
        ? getManyResources(specialization.resourceSlugs)
        : parent
          ? getResourcesByCareer(parent.slug)
          : Promise.resolve([]),
      getManySpecializations(siblingSlugs),
      getDegrees(),
      getCategories(),
    ]);

  const degreesBySlug = indexBySlug(degrees);
  const categoriesBySlug = indexBySlug(categories);

  const own = new Set(specialization.industrySlugs);
  const ownSectors = industries.filter((i) => i.isSector && own.has(i.slug));
  const ownEmployers = industries.filter((i) => !i.isSector && own.has(i.slug));
  const sectors = ownSectors.length ? ownSectors : industries.filter((i) => i.isSector);
  const employers = ownEmployers.length ? ownEmployers : industries.filter((i) => !i.isSector);

  // A degree row that no longer exists would otherwise render a blank card.
  const education = educationRefs
    .map((e) => ({ ...e, degree: degreesBySlug.get(e.degreeSlug) }))
    .filter((e) => e.degree);

  // Tags: the parent career, then the fields this sits in -- derived rather
  // than stored. The career's category says where the WORK sits, the education
  // subjects' categories say where the STUDY sits; deduped, so a
  // specialization whose study and work land in the same category shows one.
  const categoryTags = dedupe([
    ...careers.map((c) => c.categorySlug),
    ...education.map((e) => e.degree?.categorySlug).filter((s): s is string => Boolean(s)),
  ])
    .map((s) => categoriesBySlug.get(s))
    .filter((c) => c);

  // Salary: the specialization's own figure if anyone recorded one, otherwise
  // the parent career's -- labelled, so the career's number is never passed
  // off as the specialization's.
  const ownSalary = specialization.salaryMinLpa !== null && specialization.salaryMaxLpa !== null;
  const salaryMin = ownSalary ? specialization.salaryMinLpa : (parent?.salaryMinLpa ?? null);
  const salaryMax = ownSalary ? specialization.salaryMaxLpa : (parent?.salaryMaxLpa ?? null);

  const metrics: { icon: string; label: string; value: string }[] = [];
  if (salaryMin !== null && salaryMax !== null) {
    metrics.push({
      icon: "bank",
      label: ownSalary ? "Average Salary (India)" : `Average Salary · ${parentNames}`,
      value: `₹${salaryMin}–${salaryMax} LPA`,
    });
  }
  if (specialization.demand) {
    metrics.push({
      icon: "trend",
      label: "Job Demand",
      value: DEMAND_LABELS[specialization.demand] ?? specialization.demand,
    });
  }
  if (parent?.experienceMinYears != null && parent?.experienceMaxYears != null) {
    metrics.push({
      icon: "clock",
      label: `Typical Experience · ${parentNames}`,
      value: `${parent.experienceMinYears}–${parent.experienceMaxYears} years`,
    });
  } else if (education.length > 0) {
    metrics.push({ icon: "cap", label: "Entry Routes", value: String(education.length) });
  }
  if (parent?.jobOpenings != null) {
    metrics.push({
      icon: "users",
      label: `Job Openings · ${parentNames}`,
      value: formatOpenings(parent.jobOpenings),
    });
  } else if (jobRoles.length > 0) {
    metrics.push({ icon: "users", label: "Job Roles", value: String(jobRoles.length) });
  }

  const heroLabels = (
    skills.length >= 3 ? skills.map((s) => s.name) : siblings.map((s) => s.name)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Careers", href: "/careers" },
            ...(parent ? [{ label: parent.title, href: `/careers/${parent.slug}` }] : []),
            { label: specialization.name },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name={specialization.icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[30px] sm:text-[40px] leading-[1.08] tracking-tight">
                  {specialization.name}
                </h1>
                {parent && (
                  <p className="text-ink/70 text-[14.5px] mt-1.5">
                    A specialization within{" "}
                    <Link
                      href={`/careers/${parent.slug}`}
                      className="font-semibold text-blue hover:underline"
                    >
                      {parent.title}
                    </Link>
                  </p>
                )}
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-2.5 mt-5">
              {parent && (
                <Link
                  href={`/careers/${parent.slug}`}
                  className="text-[13px] font-semibold px-4 py-2 rounded-full bg-blue-soft text-blue hover:opacity-80 transition-opacity"
                >
                  {parent.title}
                </Link>
              )}
              {specialization.demand && (
                <span
                  className={`text-[13px] font-bold px-4 py-2 rounded-full ${
                    DEMAND_STYLES[specialization.demand] ?? "bg-slate-soft text-slate"
                  }`}
                >
                  {DEMAND_LABELS[specialization.demand] ?? specialization.demand}
                </span>
              )}
              {categoryTags.map((c, i) => (
                <Link
                  key={c!.slug}
                  href={`/categories/${c!.slug}`}
                  className={`text-[13px] font-semibold px-4 py-2 rounded-full transition-opacity hover:opacity-80 ${tint(i + 2)}`}
                >
                  {c!.name}
                </Link>
              ))}
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {specialization.description}
            </p>

            {metrics.length > 0 && (
              <div className="mt-7">
                <MetricRow metrics={metrics} />
              </div>
            )}
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={specialization.icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="flex flex-col gap-6">
          <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
            {(specialization.overview || specialization.description) && (
              <Card className="md:col-span-3">
                <CardTitle icon="book">What You Will Learn</CardTitle>
                <div className="bg-bg-soft rounded-2xl p-5">
                  <p className="text-[14px] text-ink/75 leading-relaxed">
                    {specialization.overview ?? specialization.description}
                  </p>
                </div>
              </Card>
            )}

            {specialization.highlights.length > 0 && (
              <Card className="md:col-span-2">
                <CardTitle icon="star">Key Highlights</CardTitle>
                <ul className="flex flex-col gap-3.5">
                  {specialization.highlights.map((h, i) => (
                    <li key={h} className="flex items-start gap-3">
                      <Icon
                        name={HIGHLIGHT_ICONS[i % HIGHLIGHT_ICONS.length]}
                        className="w-[18px] h-[18px] text-blue shrink-0 mt-0.5"
                      />
                      <span className="text-[13.5px] text-ink/75 leading-snug">{h}</span>
                    </li>
                  ))}
                </ul>
              </Card>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {skills.length > 0 && (
              <Card>
                <CardTitle
                  icon="gear"
                  viewAll={{ href: "/skills", count: skills.length }}
                  subtitle={ownSkills.length ? undefined : `Skills used across ${parentNames}`}
                >
                  Core Skills
                </CardTitle>
                <div className="flex flex-wrap gap-2">
                  {skills.slice(0, 12).map((s, i) => (
                    <Pill key={s.slug} href={`/skills/${s.slug}`} tint={tint(i)}>
                      {s.name}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {jobRoles.length > 0 && (
              <Card>
                <CardTitle
                  icon="brief"
                  viewAll={{ href: "/job-roles", count: jobRoles.length }}
                  subtitle={`Roles within ${specialization.name}`}
                >
                  Popular Job Roles
                </CardTitle>
                <ul className="flex flex-col">
                  {jobRoles.slice(0, 6).map((r, i) => (
                    <ListRow
                      key={r.slug}
                      href={`/job-roles/${r.slug}`}
                      label={r.name}
                      icon="user"
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}
          </div>

          {education.length > 0 && (
            <Section
              icon="cap"
              title="Related Degrees"
              subtitle={ownEducation.length ? undefined : `Education routes into ${parentNames}`}
              viewAll={{ href: "/degrees", count: education.length }}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                {education.map((e, i) => (
                  <RowCard
                    key={`${e.degreeSlug}|${e.subjectSlug ?? ""}`}
                    href={`/degrees/${e.degreeSlug}`}
                    icon={e.degree!.icon}
                    tint={tint(i)}
                    title={e.title}
                    meta={e.degree!.level}
                  />
                ))}
              </div>
            </Section>
          )}

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {exams.length > 0 && (
              <Card>
                <CardTitle
                  icon="doc"
                  viewAll={{ href: "/exams", count: exams.length }}
                  subtitle={
                    specialization.relatedExamSlugs.length
                      ? undefined
                      : `Entrance routes into ${parentNames}`
                  }
                >
                  Relevant Exams
                </CardTitle>
                <ul className="flex flex-col">
                  {exams.slice(0, 6).map((e) => (
                    <ListRow key={e.slug} href={`/exams/${e.slug}`} label={e.name} />
                  ))}
                </ul>
              </Card>
            )}

            {colleges.length > 0 && (
              <Card>
                <CardTitle
                  icon="bank"
                  viewAll={{ href: "/colleges", count: colleges.length }}
                  subtitle={
                    specialization.collegeSlugs.length
                      ? undefined
                      : `Colleges offering ${parentNames}`
                  }
                >
                  {specialization.collegeSlugs.length
                    ? "Top Colleges Offering This"
                    : "Top Colleges"}
                </CardTitle>
                <ul className="flex flex-col">
                  {colleges.slice(0, 8).map((c, i) => (
                    <ListRow
                      key={c.slug}
                      href={`/colleges/${c.slug}`}
                      label={c.name}
                      icon="bld"
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}

            {siblings.length > 0 && (
              <Card>
                <CardTitle
                  icon="layers"
                  viewAll={{ href: "/specializations", count: siblings.length }}
                  subtitle={parent ? `Within ${parentNames}` : undefined}
                >
                  Related Specializations
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.slice(0, 8).map((s, i) => (
                    <ListRow
                      key={s.slug}
                      href={`/specializations/${s.slug}`}
                      label={s.name}
                      icon={s.icon}
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {sectors.length > 0 && (
              <Card className="md:col-span-2">
                <CardTitle
                  icon="bld"
                  viewAll={{ href: "/industries", count: sectors.length }}
                  subtitle={ownSectors.length ? undefined : `Where ${parentNames} is practised`}
                >
                  Key Industries
                </CardTitle>
                <div className="flex flex-wrap gap-2">
                  {sectors.slice(0, 12).map((s, i) => (
                    <Pill key={s.slug} href={`/industries/${s.slug}`} tint={tint(i + 1)}>
                      {s.name}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {employers.length > 0 && (
              <Card>
                <CardTitle
                  icon="building"
                  viewAll={{ href: "/industries" }}
                  subtitle={ownEmployers.length ? undefined : `Recruiting for ${parentNames}`}
                >
                  Top Companies Hiring
                </CardTitle>
                <ul className="flex flex-col">
                  {employers.slice(0, 6).map((e, i) => (
                    <ListRow
                      key={e.slug}
                      href={`/industries/${e.slug}`}
                      label={e.name}
                      icon="building"
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {resources.length > 0 && (
              <Card>
                <CardTitle
                  icon="book"
                  viewAll={{ href: "/resources" }}
                  subtitle={
                    specialization.resourceSlugs.length
                      ? undefined
                      : `General reading for ${parentNames}`
                  }
                >
                  Resources
                </CardTitle>
                <ul className="flex flex-col">
                  {resources.slice(0, 6).map((r, i) => (
                    <ListRow
                      key={r.slug}
                      href={`/resources/${r.slug}`}
                      label={`${r.title}${r.resourceType ? ` (${r.resourceType})` : ""}`}
                      icon={RESOURCE_ICONS[r.resourceType] ?? "doc"}
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}

            {specialization.responsibilities.length > 0 && (
              <Card>
                <CardTitle icon="check">Day-to-Day Responsibilities</CardTitle>
                <ul className="flex flex-col gap-2.5">
                  {specialization.responsibilities.map((item) => (
                    <li key={item} className="flex items-start gap-2.5 text-[13.5px] text-ink/75">
                      <Icon name="check" className="w-4 h-4 text-green shrink-0 mt-0.5" />
                      {item}
                    </li>
                  ))}
                </ul>
              </Card>
            )}
          </div>
        </div>

        {parent && (
          <div className="flex flex-wrap gap-3 mt-10">
            <Link
              href={`/careers/${parent.slug}`}
              className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
            >
              Back to {parent.title}
            </Link>
            <Link
              href="/specializations"
              className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
            >
              Browse all specializations
            </Link>
          </div>
        )}
      </Container>
    </>
  );
}
