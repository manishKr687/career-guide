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
  tint,
} from "@/components/detail/DetailKit";
import { getDegree, getDegrees } from "@/data/degrees";
import { getManyExams } from "@/data/exams";
import { getManySkills } from "@/data/skills";
import { getManyResources } from "@/data/resources";
import { getManySubjects } from "@/data/subjects";
import { getCareers } from "@/data/careers";
import { getManySpecializations } from "@/data/specializations";
import { getColleges } from "@/data/colleges";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";

// The DEGREE page: one qualification, and everything reachable through it.
//
// Three of its sections are DERIVED rather than stored, and all three go
// through career_degrees, which is the relation this catalog actually keeps
// filled (36 of 76 degrees) -- unlike specialization_degrees (V108), which
// records a specialization's own entry routes and is seeded for one row:
//
//   Specializations -- degree -> careers -> their specializations. B.Tech
//                      reaches 118 across the 16 careers it qualifies you for.
//   Careers         -- degree -> careers, directly.
//   Eligibility     -- the entrance exams' own minimum qualification, deduped.
//                      B.Tech's exams say "12th Pass (PCM)", which is exactly
//                      what a degree-level eligibility line should say, and it
//                      cannot drift from the exams it came from.
//
// NOT SHOWN: typical fees. Fees vary by college and by programme -- IIT
// Delhi's B.Tech fee is not NIT Trichy's, and neither is its M.Tech fee -- so
// a single figure on the degree would average away the thing being asked.
// V113 declined to put fees on colleges for the same reason; they belong on
// college_degrees, which is the college-programme row, if a source appears.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const degree = await getDegree(slug);
  if (!degree) return {};
  return {
    title: `${degree.title}${degree.fullTitle ? ` (${degree.fullTitle})` : ""} — CareerGuide`,
    description: degree.description,
  };
}

export default async function DegreeDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const degree = await getDegree(slug);
  if (!degree) notFound();

  const [entranceExams, skills, resources, subjects, careers, colleges, allDegrees, categories] =
    await Promise.all([
      getManyExams(degree.entranceExamSlugs),
      getManySkills(degree.skillSlugs),
      getManyResources(degree.resourceSlugs),
      getManySubjects(degree.subjectSlugs),
      getCareers(),
      getColleges(),
      getDegrees(),
      getCategories(),
    ]);

  const categoriesBySlug = indexBySlug(categories);

  // Careers this degree is a listed education route into.
  const relatedCareers = careers.filter((c) =>
    c.education.some((e) => e.degreeSlug === degree.slug)
  );

  // Colleges that award it. `degreeOfferings` is a (degree, subject) pair, so
  // the same college can appear once per subject -- matched on the degree and
  // deduped by college.
  const offeringColleges = colleges.filter((c) =>
    c.degreeOfferings.some((o) => o.degreeSlug === degree.slug)
  );

  const specializationSlugs = dedupe(relatedCareers.flatMap((c) => c.relatedSpecializationSlugs));
  const specializations = await getManySpecializations(specializationSlugs.slice(0, 12));

  // What the entrance exams require, deduped and most common first. Null for a
  // degree with no exams mapped, in which case the row is omitted rather than
  // guessed at.
  const eligibilityCounts = new Map<string, number>();
  for (const e of entranceExams) {
    const q = e.eligibilityMinQualification;
    if (q) eligibilityCounts.set(q, (eligibilityCounts.get(q) ?? 0) + 1);
  }
  const eligibility = [...eligibilityCounts.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([q]) => q);

  // Other qualifications at the same level in the same field -- the comparison
  // someone on this page is most likely to want next. Derived from columns the
  // degree already has rather than a curated "related degrees" list.
  const siblings = allDegrees
    .filter(
      (d) =>
        d.slug !== degree.slug &&
        d.level === degree.level &&
        d.categorySlug !== null &&
        d.categorySlug === degree.categorySlug
    )
    .slice(0, 6);

  const metrics = [
    { icon: "cap", label: "Degree Level", value: degree.level },
    ...(degree.durationLabel
      ? [{ icon: "clock", label: "Duration", value: degree.durationLabel }]
      : []),
    ...(specializationSlugs.length > 0
      ? [{ icon: "layers", label: "Specializations", value: String(specializationSlugs.length) }]
      : []),
    ...(offeringColleges.length > 0
      ? [{ icon: "bank", label: "Colleges", value: String(offeringColleges.length) }]
      : []),
  ];

  // At a Glance repeats the hero's figures on purpose -- it is the scannable
  // summary someone scrolls back to -- and adds the ones that need a sentence
  // rather than a number.
  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    { icon: "cap", label: "Degree Level", value: degree.level },
    ...(degree.durationLabel
      ? [{ icon: "clock", label: "Duration", value: degree.durationLabel }]
      : []),
    ...(degree.categorySlug
      ? [
          {
            icon: "compass",
            label: "Field",
            value: categoriesBySlug.get(degree.categorySlug)?.name ?? degree.categorySlug,
          },
        ]
      : []),
    ...(specializationSlugs.length > 0
      ? [{ icon: "layers", label: "Specializations", value: `${specializationSlugs.length}+` }]
      : []),
    ...(eligibility.length > 0
      ? [{ icon: "check", label: "Eligibility", value: eligibility.join(" · ") }]
      : []),
    ...(entranceExams.length > 0
      ? [
          {
            icon: "doc",
            label: "Entrance Exams",
            value: (
              <span className="flex flex-wrap gap-x-1.5">
                {entranceExams.map((e, i) => (
                  <Link
                    key={e.slug}
                    href={`/exams/${e.slug}`}
                    className="text-blue hover:underline"
                  >
                    {e.name}
                    {i < entranceExams.length - 1 ? "," : ""}
                  </Link>
                ))}
              </span>
            ),
          },
        ]
      : []),
    ...(degree.requiresSubject && subjects.length > 0
      ? [{ icon: "book", label: "Offered in", value: `${subjects.length} subjects` }]
      : []),
  ];

  const heroLabels = (
    specializations.length >= 3
      ? specializations.map((s) => s.name)
      : relatedCareers.map((c) => c.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Degrees", href: "/degrees" },
            { label: degree.title },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name={degree.icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {degree.title}
                </h1>
                {degree.fullTitle && (
                  <p className="text-ink/70 text-[16px] font-semibold mt-1.5">{degree.fullTitle}</p>
                )}
              </div>
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {degree.description}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={degree.icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            <Card>
              <CardTitle icon="book">Overview</CardTitle>
              <p className="text-[14px] text-ink/75 leading-relaxed">{degree.description}</p>
              {degree.preparationStrategy && (
                <div className="bg-bg-soft rounded-2xl p-5 mt-4">
                  <div className="text-[12.5px] font-bold text-navy mb-1.5">How to get in</div>
                  <p className="text-[13.5px] text-ink/75 leading-relaxed">
                    {degree.preparationStrategy}
                  </p>
                </div>
              )}
            </Card>

            {specializations.length > 0 && (
              <Section
                icon="layers"
                title="Popular Specializations"
                subtitle={`Reached through the ${relatedCareers.length} career${relatedCareers.length === 1 ? "" : "s"} this degree qualifies you for`}
                viewAll={{ href: "/specializations", count: specializationSlugs.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {specializations.slice(0, 6).map((s, i) => (
                    <RowCard
                      key={s.slug}
                      href={`/specializations/${s.slug}`}
                      icon={s.icon}
                      tint={tint(i)}
                      title={s.name}
                    />
                  ))}
                </div>
              </Section>
            )}

            {offeringColleges.length > 0 && (
              <Section
                icon="bank"
                title={`Top Colleges Offering ${degree.title}`}
                viewAll={{ href: "/colleges", count: offeringColleges.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  {offeringColleges.slice(0, 8).map((c, i) => (
                    <RowCard
                      key={c.slug}
                      href={`/colleges/${c.slug}`}
                      icon="bld"
                      tint={tint(i)}
                      title={c.name}
                      meta={c.location}
                    />
                  ))}
                </div>
              </Section>
            )}

            {relatedCareers.length > 0 && (
              <Section
                icon="brief"
                title="Careers This Leads To"
                viewAll={{ href: "/careers", count: relatedCareers.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {relatedCareers.slice(0, 6).map((c, i) => (
                    <RowCard
                      key={c.slug}
                      href={`/careers/${c.slug}`}
                      icon={c.icon}
                      tint={tint(i)}
                      title={c.title}
                      meta={c.tagline}
                    />
                  ))}
                </div>
              </Section>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {subjects.length > 0 && (
                <Card>
                  <CardTitle
                    icon="book"
                    subtitle="This qualification is awarded in each of these fields of study"
                  >
                    Offered In
                  </CardTitle>
                  <div className="flex flex-wrap gap-2">
                    {subjects.map((s, i) => (
                      <Pill key={s.slug} href={`/degrees?q=${encodeURIComponent(s.title)}`} tint={tint(i)}>
                        {s.title}
                      </Pill>
                    ))}
                  </div>
                </Card>
              )}

              {skills.length > 0 && (
                <Card>
                  <CardTitle icon="gear" viewAll={{ href: "/skills", count: skills.length }}>
                    Skills You Build
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
            </div>
          </div>

          {/* ------------------------------------------------------- Right rail */}
          <aside className="lg:col-span-4 flex flex-col gap-6">
            <Card>
              <CardTitle icon="chart">At a Glance</CardTitle>
              <dl className="flex flex-col">
                {glance.map((g) => (
                  <div
                    key={g.label}
                    className="flex items-start gap-3 py-3 border-b border-line last:border-0"
                  >
                    <span className="w-7 h-7 rounded-lg bg-bg-soft text-navy flex items-center justify-center shrink-0">
                      <Icon name={g.icon} className="w-3.5 h-3.5" />
                    </span>
                    <dt className="text-[13px] text-muted w-[38%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">
                      {g.value}
                    </dd>
                  </div>
                ))}
              </dl>
            </Card>

            {entranceExams.length > 0 && (
              <Card>
                <CardTitle icon="doc" viewAll={{ href: "/exams", count: entranceExams.length }}>
                  Entrance Exams
                </CardTitle>
                <ul className="flex flex-col">
                  {entranceExams.map((e, i) => (
                    <ListRow
                      key={e.slug}
                      href={`/exams/${e.slug}`}
                      label={e.name}
                      icon={e.icon}
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}

            {siblings.length > 0 && (
              <Card>
                <CardTitle
                  icon="compass"
                  subtitle={`Other ${degree.level.toLowerCase()} qualifications in the same field`}
                >
                  Compare With
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((d, i) => (
                    <ListRow
                      key={d.slug}
                      href={`/degrees/${d.slug}`}
                      label={d.fullTitle ? `${d.title} — ${d.fullTitle}` : d.title}
                      icon={d.icon}
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}

            {resources.length > 0 && (
              <Card>
                <CardTitle icon="book" viewAll={{ href: "/resources" }}>
                  Resources
                </CardTitle>
                <ul className="flex flex-col">
                  {resources.map((r, i) => (
                    <ListRow
                      key={r.slug}
                      href={`/resources/${r.slug}`}
                      label={`${r.title}${r.resourceType ? ` (${r.resourceType})` : ""}`}
                      icon="doc"
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/degrees"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all degrees
          </Link>
          <Link
            href="/colleges"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Find colleges
          </Link>
        </div>
      </Container>
    </>
  );
}
