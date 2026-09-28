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
  MetricRow,
  HeroVisual,
  dedupe,
  tint,
} from "@/components/detail/DetailKit";
import { getExam, getExams } from "@/data/exams";
import { getManyCareers } from "@/data/careers";
import { getManyJobRoles } from "@/data/jobRoles";
import { getManyColleges, getColleges } from "@/data/colleges";
import { getDegrees } from "@/data/degrees";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";

// The EXAM page: what the exam is, what it gets you, and where it is accepted.
//
// TWO THINGS THE USUAL EXAM PAGE SHOWS ARE ABSENT, both on purpose.
//
// A typical exam month ("Usually Feb"). V112 declined to store one: exam
// calendars shift year to year, and a stale month on a page a student plans
// around is worse than no month. Dates belong in a per-year sessions model.
//
// A subject/paper count ("30+ Subjects"). GATE really does have ~30 papers,
// but this catalog does not model exam papers at all, so the number would be
// typed in rather than counted. What it shows instead is the branches the
// exam actually admits to, which is the same question answered from
// exam_career_degrees.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const exam = await getExam(slug);
  if (!exam) return {};
  return { title: `${exam.name} — ${exam.fullName} — CareerGuide`, description: exam.description };
}

export default async function ExamDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const exam = await getExam(slug);
  if (!exam) notFound();

  const offeringDegreeSlugs = dedupe(exam.careerDegreeOfferings.map((o) => o.degreeSlug));

  const [careers, jobRoles, listedColleges, allColleges, degrees, allExams, categories] =
    await Promise.all([
      getManyCareers(exam.careerSlugs),
      getManyJobRoles(exam.jobRoleSlugs),
      getManyColleges(exam.collegeSlugs),
      getColleges(),
      getDegrees(),
      getExams(),
      getCategories(),
    ]);

  const careersBySlug = indexBySlug(careers);
  const degreesBySlug = indexBySlug(degrees);
  const categoriesBySlug = indexBySlug(categories);

  // Colleges. `college_exams` is the direct relation but is thin -- GATE lists
  // 2 of the 54 colleges that actually admit through it. Where the direct list
  // is too short to be useful, the page falls back to the colleges offering
  // the degrees this exam admits to, UNDER A LABEL THAT SAYS SO, rather than
  // presenting an inference as a recorded fact.
  const derivedColleges =
    offeringDegreeSlugs.length > 0
      ? allColleges.filter((c) =>
          c.degreeOfferings.some((o) => offeringDegreeSlugs.includes(o.degreeSlug))
        )
      : [];
  const usingListed = listedColleges.length >= 4;
  const colleges = usingListed ? listedColleges : derivedColleges;
  const collegeSubtitle = usingListed
    ? undefined
    : `Colleges offering ${offeringDegreeSlugs
        .map((d) => degreesBySlug.get(d)?.title ?? d)
        .join(" / ")}, the qualification this exam admits to`;

  // The branches: one row per (career, degree) the exam admits to. Grouped by
  // career, because the degree is almost always the same one -- GATE's 16
  // offerings are all M.Tech, and repeating that on every card says nothing.
  const branches = exam.careerDegreeOfferings
    .map((o) => ({
      career: careersBySlug.get(o.careerSlug),
      degree: degreesBySlug.get(o.degreeSlug),
    }))
    .filter((b) => b.career);

  // Other exams in the same field at the same level.
  const siblings = allExams
    .filter(
      (e) =>
        e.slug !== exam.slug &&
        e.level === exam.level &&
        e.categorySlug !== null &&
        e.categorySlug === exam.categorySlug
    )
    .slice(0, 6);

  const metrics = [
    { icon: "cap", label: "Gets You", value: exam.level },
    { icon: "cal", label: exam.frequency, value: exam.frequencyType },
    ...(exam.mode ? [{ icon: "monitor", label: "Mode", value: exam.mode }] : []),
    ...(careers.length > 0
      ? [{ icon: "brief", label: "Careers", value: String(careers.length) }]
      : []),
  ];

  // "Popular For", from what the exam actually opens: the degrees it admits to
  // and the roles it recruits into. Composed rather than stored, so it cannot
  // disagree with the sections below it.
  const popularFor = [
    ...offeringDegreeSlugs.map((d) => `${degreesBySlug.get(d)?.title ?? d} admissions`),
    ...(jobRoles.length > 0 ? ["Recruitment"] : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    { icon: "cap", label: "Exam Level", value: exam.level },
    { icon: "target", label: "Exam Type", value: exam.examType },
    { icon: "clip", label: "Stage", value: exam.category },
    ...(exam.categorySlug
      ? [
          {
            icon: "compass",
            label: "Field",
            value: categoriesBySlug.get(exam.categorySlug)?.name ?? exam.categorySlug,
          },
        ]
      : []),
    { icon: "bld", label: "Conducting Body", value: exam.conductedBy },
    { icon: "cal", label: "Frequency", value: exam.frequency },
    ...(exam.mode ? [{ icon: "monitor", label: "Mode of Exam", value: exam.mode }] : []),
    ...(exam.eligibilityMinQualification
      ? [{ icon: "check", label: "Eligibility", value: exam.eligibilityMinQualification }]
      : []),
    ...(popularFor.length > 0
      ? [{ icon: "star", label: "Popular For", value: popularFor.join(", ") }]
      : []),
  ];

  const heroLabels = (
    branches.length >= 3 ? branches.map((b) => b.career!.title) : careers.map((c) => c.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Exams", href: "/exams" },
            { label: exam.name },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name={exam.icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {exam.name}
                </h1>
                <p className="text-ink/70 text-[16px] font-semibold mt-1.5">{exam.fullName}</p>
              </div>
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {exam.description}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            {exam.officialWebsite && (
              <a
                href={exam.officialWebsite}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 mt-6 text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Official website
                <Icon name="external" className="w-3.5 h-3.5" />
              </a>
            )}
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={exam.icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            <Card>
              <CardTitle icon="doc">About {exam.name}</CardTitle>
              <p className="text-[14px] text-ink/75 leading-relaxed">{exam.description}</p>
              {exam.syllabusOverview && (
                <div className="bg-bg-soft rounded-2xl p-5 mt-4">
                  <div className="text-[12.5px] font-bold text-navy mb-1.5">Syllabus overview</div>
                  <p className="text-[13.5px] text-ink/75 leading-relaxed">
                    {exam.syllabusOverview}
                  </p>
                </div>
              )}
            </Card>

            {branches.length > 0 && (
              <Section
                icon="layers"
                title="Branches It Admits To"
                subtitle={`Each one is a field you can enter with ${exam.name}, and the qualification it leads to`}
                viewAll={{ href: "/careers", count: branches.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {branches.slice(0, 6).map((b, i) => (
                    <RowCard
                      key={`${b.career!.slug}|${b.degree?.slug ?? ""}`}
                      href={`/careers/${b.career!.slug}`}
                      icon={b.career!.icon}
                      tint={tint(i)}
                      title={b.career!.title}
                      meta={b.degree ? `Leads to ${b.degree.title}` : undefined}
                    />
                  ))}
                </div>
              </Section>
            )}

            {jobRoles.length > 0 && (
              <Section
                icon="users"
                title="Roles It Recruits Into"
                subtitle={`${exam.name} is a recruitment route, not only an admission one`}
                viewAll={{ href: "/job-roles", count: jobRoles.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {jobRoles.slice(0, 6).map((r, i) => (
                    <RowCard
                      key={r.slug}
                      href={`/job-roles/${r.slug}`}
                      icon="user"
                      tint={tint(i)}
                      title={r.name}
                    />
                  ))}
                </div>
              </Section>
            )}

            {colleges.length > 0 && (
              <Section
                icon="bank"
                title={`Top Colleges Accepting ${exam.name}`}
                subtitle={collegeSubtitle}
                viewAll={{ href: "/colleges", count: colleges.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  {colleges.slice(0, 8).map((c, i) => (
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

            {careers.length > 0 && (
              <Section
                icon="brief"
                title="Careers This Exam Leads To"
                viewAll={{ href: "/careers", count: careers.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {careers.slice(0, 6).map((c, i) => (
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
                    <dt className="text-[13px] text-muted w-[40%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">
                      {g.value}
                    </dd>
                  </div>
                ))}
              </dl>
            </Card>

            {siblings.length > 0 && (
              <Card>
                <CardTitle
                  icon="compass"
                  subtitle={`Other ${exam.level.toLowerCase()} exams in the same field`}
                >
                  Compare With
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((e, i) => (
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
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/exams"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all exams
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
