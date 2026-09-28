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
import { getJobRole, getJobRoles } from "@/data/jobRoles";
import { getManyCareers } from "@/data/careers";
import { getManySkills } from "@/data/skills";
import { getManyIndustries } from "@/data/industries";
import { getManyCertifications } from "@/data/certifications";
import { getManyExams } from "@/data/exams";
import { getSpecializations } from "@/data/specializations";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";

// The JOB ROLE page: one post you can be hired into.
//
// A job role is a PERSON ("Backend Developer"), where a career and a
// specialization are FIELDS ("Backend Development") -- the boundary V93 made
// a checked rule. So this page answers the person-shaped questions: what it
// pays, how senior it is, which skills it asks for, and which fields it sits
// under.
//
// Salary reads the NUMERIC columns, not the "5 LPA" strings. V107 converted
// them and backfilled 247 of 255 rows, but the DTO was never wired until this
// pass, so the figure here is the same one the listing sorts and filters on.

const LEVEL_STYLES: Record<string, string> = {
  Entry: "bg-green-soft text-green",
  "Entry to Mid": "bg-teal-soft text-teal",
  "Entry to Senior": "bg-blue-soft text-blue",
  "Mid to Senior": "bg-purple-soft text-purple",
  Senior: "bg-pink-soft text-pink",
};

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const jobRole = await getJobRole(slug);
  if (!jobRole) return {};
  return { title: `${jobRole.name} — CareerGuide`, description: jobRole.description };
}

export default async function JobRoleDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const jobRole = await getJobRole(slug);
  if (!jobRole) notFound();

  const [careers, skills, industries, certifications, exams, specializations, allRoles, categories] =
    await Promise.all([
      getManyCareers(jobRole.careerSlugs),
      getManySkills(jobRole.relatedSkillSlugs),
      getManyIndustries(jobRole.relatedIndustrySlugs),
      getManyCertifications(jobRole.relatedCertificationSlugs),
      getManyExams(jobRole.relatedExamSlugs),
      getSpecializations(),
      getJobRoles(),
      getCategories(),
    ]);

  const categoriesBySlug = indexBySlug(categories);

  // Which specializations lead here. Specialization owns that relation (V40)
  // and JobRole has no inverse field, so the direction has to be computed.
  const viaSpecializations = specializations.filter((s) =>
    s.relatedJobRoleSlugs.includes(jobRole.slug)
  );

  // Industries split the same way they do everywhere else: sectors are where
  // the work happens, employers are who hires.
  const sectors = industries.filter((i) => i.isSector);
  const employers = industries.filter((i) => !i.isSector);

  const fieldSlugs = dedupe(careers.map((c) => c.categorySlug));
  const fields = fieldSlugs.map((s) => categoriesBySlug.get(s)).filter((c) => c);

  // Other roles under the same career -- what else that field hires for.
  const siblings = allRoles
    .filter((r) => r.slug !== jobRole.slug && r.careerSlugs.some((c) => jobRole.careerSlugs.includes(c)))
    .slice(0, 8);

  const salary =
    jobRole.salaryMinLpa !== null && jobRole.salaryMaxLpa !== null
      ? `₹${jobRole.salaryMinLpa}–${jobRole.salaryMaxLpa} LPA`
      : null;

  const metrics = [
    { icon: "trend", label: "Seniority", value: jobRole.experienceLevel },
    ...(salary ? [{ icon: "bank", label: "Salary Range", value: salary }] : []),
    ...(skills.length > 0
      ? [{ icon: "gear", label: "Skills", value: String(skills.length) }]
      : []),
    ...(careers.length > 0
      ? [{ icon: "brief", label: "Careers", value: String(careers.length) }]
      : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    { icon: "trend", label: "Seniority", value: jobRole.experienceLevel },
    ...(salary ? [{ icon: "bank", label: "Salary Range", value: salary }] : []),
    ...(fields.length > 0
      ? [{ icon: "compass", label: "Field", value: fields.map((f) => f!.name).join(", ") }]
      : []),
    ...(careers.length > 0
      ? [
          {
            icon: "brief",
            label: "Sits Under",
            value: (
              <span className="flex flex-wrap gap-x-1.5">
                {careers.map((c, i) => (
                  <Link key={c.slug} href={`/careers/${c.slug}`} className="text-blue hover:underline">
                    {c.title}
                    {i < careers.length - 1 ? "," : ""}
                  </Link>
                ))}
              </span>
            ),
          },
        ]
      : []),
    ...(viaSpecializations.length > 0
      ? [
          {
            icon: "layers",
            label: "Reached Via",
            value: `${viaSpecializations.length} specialization${viaSpecializations.length === 1 ? "" : "s"}`,
          },
        ]
      : []),
    ...(skills.length > 0
      ? [{ icon: "gear", label: "Skills Asked For", value: String(skills.length) }]
      : []),
    ...(exams.length > 0
      ? [{ icon: "doc", label: "Recruited Via", value: exams.map((e) => e.name).join(", ") }]
      : []),
  ];

  const heroLabels = (
    skills.length >= 3 ? skills.map((s) => s.name) : careers.map((c) => c.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Job Roles", href: "/job-roles" },
            { label: jobRole.name },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name="user" className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {jobRole.name}
                </h1>
                {careers.length > 0 && (
                  <p className="text-ink/70 text-[14.5px] mt-1.5">
                    A role within{" "}
                    <Link
                      href={`/careers/${careers[0].slug}`}
                      className="font-semibold text-blue hover:underline"
                    >
                      {careers[0].title}
                    </Link>
                  </p>
                )}
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-2.5 mt-5">
              <span
                className={`text-[13px] font-bold px-4 py-2 rounded-full ${LEVEL_STYLES[jobRole.experienceLevel] ?? "bg-slate-soft text-slate"}`}
              >
                {jobRole.experienceLevel}
              </span>
              {fields.map((f, i) => (
                <Link
                  key={f!.slug}
                  href={`/job-roles?field=${f!.slug}`}
                  className={`text-[13px] font-semibold px-4 py-2 rounded-full transition-opacity hover:opacity-80 ${tint(i + 2)}`}
                >
                  {f!.name}
                </Link>
              ))}
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {jobRole.description}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon="user" labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            <Card>
              <CardTitle icon="doc">About This Role</CardTitle>
              <p className="text-[14px] text-ink/75 leading-relaxed">{jobRole.description}</p>
            </Card>

            {skills.length > 0 && (
              <Card>
                <CardTitle icon="gear" viewAll={{ href: "/skills", count: skills.length }}>
                  Skills It Asks For
                </CardTitle>
                <div className="flex flex-wrap gap-2">
                  {skills.map((s, i) => (
                    <Pill key={s.slug} href={`/skills/${s.slug}`} tint={tint(i)}>
                      {s.name}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {viaSpecializations.length > 0 && (
              <Section
                icon="layers"
                title="Specializations That Lead Here"
                subtitle="Focused areas within the career that hire into this role"
                viewAll={{ href: "/specializations", count: viaSpecializations.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {viaSpecializations.slice(0, 6).map((s, i) => (
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

            {careers.length > 0 && (
              <Section
                icon="brief"
                title="Careers It Sits Under"
                viewAll={{ href: "/careers", count: careers.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {careers.map((c, i) => (
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

            {(sectors.length > 0 || employers.length > 0) && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {sectors.length > 0 && (
                  <Card>
                    <CardTitle icon="bld" viewAll={{ href: "/industries", count: sectors.length }}>
                      Industries
                    </CardTitle>
                    <div className="flex flex-wrap gap-2">
                      {sectors.map((s, i) => (
                        <Pill key={s.slug} href={`/industries/${s.slug}`} tint={tint(i + 1)}>
                          {s.name}
                        </Pill>
                      ))}
                    </div>
                  </Card>
                )}
                {employers.length > 0 && (
                  <Card>
                    <CardTitle icon="building" viewAll={{ href: "/industries" }}>
                      Who Hires
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
                    <dt className="text-[13px] text-muted w-[42%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">
                      {g.value}
                    </dd>
                  </div>
                ))}
              </dl>
            </Card>

            {certifications.length > 0 && (
              <Card>
                <CardTitle icon="award" viewAll={{ href: "/certifications", count: certifications.length }}>
                  Certifications
                </CardTitle>
                <ul className="flex flex-col">
                  {certifications.map((c, i) => (
                    <ListRow
                      key={c.slug}
                      href={`/certifications/${c.slug}`}
                      label={c.name}
                      icon="award"
                      tint={tint(i)}
                    />
                  ))}
                </ul>
              </Card>
            )}

            {exams.length > 0 && (
              <Card>
                <CardTitle icon="doc" subtitle="This role is recruited through an exam">
                  Recruited Via
                </CardTitle>
                <ul className="flex flex-col">
                  {exams.map((e, i) => (
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
                  subtitle={careers[0] ? `Other roles in ${careers[0].title}` : undefined}
                >
                  Related Roles
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((r, i) => (
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
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/job-roles"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all job roles
          </Link>
          <Link
            href="/skills"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Explore skills
          </Link>
        </div>
      </Container>
    </>
  );
}
