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
import { getSkill, getSkills } from "@/data/skills";
import { getCareers } from "@/data/careers";
import { getJobRoles } from "@/data/jobRoles";
import { getDegrees } from "@/data/degrees";
import { getCertifications } from "@/data/certifications";
import { getSpecializations } from "@/data/specializations";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";

// The SKILL page.
//
// Everything here is a REVERSE lookup: a skill row holds a name and a
// category and nothing else, so the page is built entirely from what points
// AT it -- the careers, job roles, degrees, certifications and
// specializations that list it. That is also why there is no "demand level"
// or "learning difficulty": nothing in this catalog implies either, and a
// High/Medium/Low badge would be a claim with nothing behind it. What the
// page shows instead is reach, which is real and is the question underneath.
//
// `description` is null for all 413 skills (V114 added the column, unseeded),
// so the overview falls back to a composed line rather than an empty card.

const CATEGORY_LABELS: Record<string, string> = {
  Soft: "Soft Skill",
  Programming: "Programming",
  Tools: "Tool or Technology",
  Analytical: "Analytical",
  Domain: "Domain Knowledge",
};

// Noun phrases for the composed overview sentence. Separate from the labels
// above because an article computed from the first letter gets it wrong: the
// labels give "a domain knowledge" and "a tool or technology". Writing the
// five phrases out is shorter than the rule that would fix them.
const CATEGORY_PHRASES: Record<string, string> = {
  Soft: "a soft skill",
  Programming: "a programming skill",
  Tools: "a tool or technology",
  Analytical: "an analytical skill",
  Domain: "domain knowledge",
};

const CATEGORY_STYLES: Record<string, string> = {
  Programming: "bg-blue-soft text-blue",
  Tools: "bg-purple-soft text-purple",
  Analytical: "bg-teal-soft text-teal",
  Soft: "bg-green-soft text-green",
  Domain: "bg-amber-soft text-amber",
};

const CATEGORY_ICONS: Record<string, string> = {
  Programming: "code",
  Tools: "wrench",
  Analytical: "chart",
  Soft: "users",
  Domain: "compass",
};

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const skill = await getSkill(slug);
  if (!skill) return {};
  return {
    title: `${skill.name} — CareerGuide`,
    description:
      skill.description ?? `The careers, job roles and qualifications that ask for ${skill.name}.`,
  };
}

export default async function SkillDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const skill = await getSkill(slug);
  if (!skill) notFound();

  const [careers, jobRoles, degrees, certifications, specializations, allSkills, categories] =
    await Promise.all([
      getCareers(),
      getJobRoles(),
      getDegrees(),
      getCertifications(),
      getSpecializations(),
      getSkills(),
      getCategories(),
    ]);

  const categoriesBySlug = indexBySlug(categories);

  const usingCareers = careers.filter((c) => c.relatedSkillSlugs.includes(skill.slug));
  const usingRoles = jobRoles.filter((r) => r.relatedSkillSlugs.includes(skill.slug));
  const teachingDegrees = degrees.filter((d) => d.skillSlugs.includes(skill.slug));
  const certs = certifications.filter((c) => c.relatedSkillSlugs.includes(skill.slug));
  const usingSpecializations = specializations.filter(
    (s) =>
      s.relatedHardSkillSlugs.includes(skill.slug) || s.relatedSoftSkillSlugs.includes(skill.slug)
  );

  // The fields this skill turns up in, from the categories of the careers
  // that ask for it. A skill has no field of its own, and giving it one would
  // be a second copy of something career_skills already answers.
  const fieldSlugs = dedupe(usingCareers.map((c) => c.categorySlug));
  const fields = fieldSlugs.map((s) => categoriesBySlug.get(s)).filter((c) => c);

  // Skills that appear alongside this one -- same category, and sharing at
  // least one career. Closer to "related" than category alone, which for
  // Domain would return 311 arbitrary rows.
  const careerSlugSet = new Set(usingCareers.map((c) => c.slug));
  const coOccurring = dedupe(
    usingCareers.flatMap((c) => c.relatedSkillSlugs).filter((s) => s !== skill.slug)
  );
  const related = allSkills
    .filter((s) => coOccurring.includes(s.slug))
    .sort((a, b) => {
      // Same category first, then by how many of this skill's careers also
      // list it -- the ones that genuinely travel together.
      const shared = (x: typeof a) =>
        careers.filter((c) => careerSlugSet.has(c.slug) && c.relatedSkillSlugs.includes(x.slug))
          .length;
      return (
        Number(b.category === skill.category) - Number(a.category === skill.category) ||
        shared(b) - shared(a)
      );
    })
    .slice(0, 8);

  const metrics = [
    { icon: CATEGORY_ICONS[skill.category] ?? "gear", label: "Category", value: CATEGORY_LABELS[skill.category] ?? skill.category },
    ...(usingRoles.length > 0
      ? [{ icon: "users", label: "Job Roles", value: String(usingRoles.length) }]
      : []),
    ...(usingCareers.length > 0
      ? [{ icon: "brief", label: "Careers", value: String(usingCareers.length) }]
      : []),
    ...(fields.length > 0 ? [{ icon: "compass", label: "Fields", value: String(fields.length) }] : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    {
      icon: CATEGORY_ICONS[skill.category] ?? "gear",
      label: "Category",
      value: CATEGORY_LABELS[skill.category] ?? skill.category,
    },
    ...(skill.skillType && skill.skillType !== skill.category
      ? [{ icon: "clip", label: "Type", value: skill.skillType }]
      : []),
    { icon: "users", label: "Job roles", value: `${usingRoles.length} ask for it` },
    { icon: "brief", label: "Careers", value: `${usingCareers.length} list it` },
    ...(usingSpecializations.length > 0
      ? [
          {
            icon: "layers",
            label: "Specializations",
            value: `${usingSpecializations.length} list it`,
          },
        ]
      : []),
    ...(teachingDegrees.length > 0
      ? [{ icon: "cap", label: "Taught in", value: `${teachingDegrees.length} degrees` }]
      : []),
    ...(certs.length > 0
      ? [{ icon: "award", label: "Certifications", value: `${certs.length} cover it` }]
      : []),
  ];

  const heroLabels = (
    usingRoles.length >= 3 ? usingRoles.map((r) => r.name) : usingCareers.map((c) => c.title)
  ).slice(0, 5);

  const tintClass = CATEGORY_STYLES[skill.category] ?? "bg-bg-soft text-navy";

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Skills", href: "/skills" },
            { label: skill.name },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${tintClass}`}>
                <Icon name={CATEGORY_ICONS[skill.category] ?? "gear"} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {skill.name}
                </h1>
                <p className="text-ink/70 text-[15px] mt-1.5">
                  {CATEGORY_LABELS[skill.category] ?? skill.category}
                </p>
              </div>
            </div>

            {fields.length > 0 && (
              <div className="flex flex-wrap items-center gap-2.5 mt-5">
                {fields.slice(0, 5).map((f, i) => (
                  <Link
                    key={f!.slug}
                    href={`/skills?field=${f!.slug}`}
                    className={`text-[13px] font-semibold px-4 py-2 rounded-full transition-opacity hover:opacity-80 ${tint(i)}`}
                  >
                    {f!.name}
                  </Link>
                ))}
              </div>
            )}

            {/* Composed rather than stored: `description` is null for every
                skill, and a blank card says less than a true sentence. */}
            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {skill.description ??
                `${skill.name} is ${CATEGORY_PHRASES[skill.category] ?? "a skill"}, asked for by ${usingRoles.length} job role${usingRoles.length === 1 ? "" : "s"} and listed by ${usingCareers.length} career${usingCareers.length === 1 ? "" : "s"} in this catalog.`}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={CATEGORY_ICONS[skill.category] ?? "gear"} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            {usingRoles.length > 0 && (
              <Section
                icon="users"
                title="Job Roles That Ask For It"
                viewAll={{ href: "/job-roles", count: usingRoles.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingRoles.slice(0, 9).map((r, i) => (
                    <RowCard
                      key={r.slug}
                      href={`/job-roles/${r.slug}`}
                      icon="user"
                      tint={tint(i)}
                      title={r.name}
                      meta={r.experienceLevel || undefined}
                    />
                  ))}
                </div>
              </Section>
            )}

            {usingCareers.length > 0 && (
              <Section
                icon="brief"
                title="Careers That List It"
                viewAll={{ href: "/careers", count: usingCareers.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingCareers.slice(0, 9).map((c, i) => (
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

            {usingSpecializations.length > 0 && (
              <Section
                icon="layers"
                title="Specializations That Use It"
                viewAll={{ href: "/specializations", count: usingSpecializations.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingSpecializations.slice(0, 6).map((s, i) => (
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

            {(teachingDegrees.length > 0 || certs.length > 0) && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {teachingDegrees.length > 0 && (
                  <Card>
                    <CardTitle icon="cap" viewAll={{ href: "/degrees", count: teachingDegrees.length }}>
                      Where You Learn It
                    </CardTitle>
                    <ul className="flex flex-col">
                      {teachingDegrees.slice(0, 6).map((d, i) => (
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

                {certs.length > 0 && (
                  <Card>
                    <CardTitle icon="award" viewAll={{ href: "/certifications", count: certs.length }}>
                      Certifications
                    </CardTitle>
                    <ul className="flex flex-col">
                      {certs.slice(0, 6).map((c, i) => (
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

            {related.length > 0 && (
              <Card>
                <CardTitle
                  icon="compass"
                  subtitle="Skills the same careers ask for alongside this one"
                >
                  Often Paired With
                </CardTitle>
                <div className="flex flex-wrap gap-2">
                  {related.map((s, i) => (
                    <Pill key={s.slug} href={`/skills/${s.slug}`} tint={tint(i)}>
                      {s.name}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {fields.length > 0 && (
              <Card>
                <CardTitle icon="grid" subtitle="Where the careers that ask for it sit">
                  Fields
                </CardTitle>
                <ul className="flex flex-col">
                  {fields.map((f, i) => (
                    <ListRow
                      key={f!.slug}
                      href={`/skills?field=${f!.slug}`}
                      label={f!.name}
                      icon={f!.icon}
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
            href="/skills"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all skills
          </Link>
          <Link
            href="/careers"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Explore careers
          </Link>
        </div>
      </Container>
    </>
  );
}
