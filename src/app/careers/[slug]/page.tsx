import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
import CompareButton from "@/components/ui/CompareButton";
import SaveButton from "@/components/ui/SaveButton";
import {
  Card,
  CardTitle,
  Section,
  RowCard,
  ListRow,
  Pill,
  MetricRow,
  HeroVisual,
  formatOpenings,
  tint,
} from "@/components/detail/DetailKit";
import { getCareer, getCareersByCategory } from "@/data/careers";
import { getDegrees, filterDegreesRelevantToCareer } from "@/data/degrees";
import { getResourcesByCareer } from "@/data/resources";
import { getManySpecializations } from "@/data/specializations";
import { getManyExams } from "@/data/exams";
import { getManyColleges } from "@/data/colleges";
import { getCategory } from "@/data/categories";
import { getBranch } from "@/data/branches";
import { getManySkills } from "@/data/skills";
import { getManyIndustries } from "@/data/industries";

// The CAREER page: the broad view of a field, and the parent of its
// specializations. Everything here is career-level on purpose -- the
// specialization page (same layout, narrower scope) covers one area within it,
// so anything that only holds for one specialization belongs there, not here.
//
// JOB ROLES ARE NOT ON THIS PAGE. A role is a person you hire ("Backend
// Developer"), and in this product a role is reached through the
// specialization, which is the level that can say which roles a focused area
// leads to. The career -> job role relation still exists and is still
// enforced (V95's containment check); this page just does not render it.
//
// TWO THINGS ARE DERIVED RATHER THAN STORED, and both are deliberate:
//
//   Key Highlights  -- computed from facts the catalog can prove (demand, how
//                      many specializations, the salary ceiling, how many
//                      sectors). A stored `highlights` value overrides it.
//                      A derived claim cannot go stale against its own data.
//   Related Careers -- the other careers in the same category. That relation
//                      already exists; a second "related careers" table would
//                      restate it and need re-editing forever.
//
// AND TWO ARE MISSING ON PURPOSE. `salaryBands`, `experienceMinYears` and
// `jobOpenings` ship empty for all 42 careers: none of them can be derived
// from anything in the catalog, and a generated figure would read as
// researched. Their sections and metrics are omitted rather than filled with
// placeholders -- see V110's header.

const DEMAND_STYLES: Record<string, string> = {
  "High Demand": "bg-green-soft text-green",
  Emerging: "bg-purple-soft text-purple",
  Evergreen: "bg-teal-soft text-teal",
  Stable: "bg-blue-soft text-blue",
  Competitive: "bg-amber-soft text-amber",
};

const HIGHLIGHT_ICONS = ["trend", "layers", "rocket", "bank", "compass", "bulb"] as const;

// No generateStaticParams: the catalog lives in Postgres and can change at any
// time, so career pages render dynamically per request.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const career = await getCareer(slug);
  if (!career) return {};
  return { title: `${career.title} — Career Guide`, description: career.description };
}

export default async function CareerDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const career = await getCareer(slug);
  if (!career) notFound();

  const [
    category,
    branch,
    exams,
    colleges,
    careersInCategory,
    skills,
    industries,
    resources,
    specializations,
    allDegrees,
  ] = await Promise.all([
    getCategory(career.categorySlug),
    career.branchSlug ? getBranch(career.branchSlug) : Promise.resolve(undefined),
    getManyExams(career.relatedExamSlugs),
    getManyColleges(career.relatedCollegeSlugs),
    getCareersByCategory(career.categorySlug),
    getManySkills(career.relatedSkillSlugs),
    getManyIndustries(career.relatedIndustrySlugs),
    getResourcesByCareer(career.slug),
    getManySpecializations(career.relatedSpecializationSlugs),
    getDegrees(),
  ]);

  // `industries` mixes two different answers, separated by is_sector: which
  // FIELDS the work happens in, and which COMPANIES hire for it. The page
  // asks them as two questions because they are two questions -- before V110
  // only the employer half had any data.
  const sectors = industries.filter((i) => i.isSector);
  const employers = industries.filter((i) => !i.isSector);

  const relatedCareers = careersInCategory.filter((c) => c.slug !== career.slug).slice(0, 4);

  // Exact relation first, exam-overlap heuristic as fallback -- the same rule
  // /degrees uses. See filterDegreesRelevantToCareer's doc comment.
  const exactDegrees =
    career.education.length > 0
      ? career.education
          .map((e) => ({ education: e, degree: allDegrees.find((d) => d.slug === e.degreeSlug) }))
          .filter((x) => x.degree)
      : [];
  const heuristicDegrees =
    exactDegrees.length > 0
      ? []
      : filterDegreesRelevantToCareer(allDegrees, career).map((d) => ({
          education: { degreeSlug: d.slug, subjectSlug: null, title: d.title },
          degree: d,
        }));
  const education = exactDegrees.length > 0 ? exactDegrees : heuristicDegrees;

  const tags = [category, branch].filter((t) => t);

  // Only facts the catalog can prove. A metric with nothing behind it is left
  // out entirely rather than shown as "--", which would imply the number
  // exists somewhere.
  const metrics: { icon: string; label: string; value: string }[] = [];
  if (career.salaryRange) {
    metrics.push({
      icon: "bank",
      label: "Average Salary (India)",
      value: `₹${trim(career.salaryMinLpa)}–${trim(career.salaryMaxLpa)} LPA`,
    });
  }
  metrics.push({ icon: "trend", label: "Job Demand", value: career.demand });
  if (career.experienceMinYears !== null && career.experienceMaxYears !== null) {
    metrics.push({
      icon: "clock",
      label: "Typical Experience",
      value: `${career.experienceMinYears}–${career.experienceMaxYears} years`,
    });
  } else if (specializations.length > 0) {
    metrics.push({
      icon: "layers",
      label: "Specializations",
      value: String(specializations.length),
    });
  }
  if (career.jobOpenings !== null) {
    metrics.push({ icon: "users", label: "Job Openings (India)", value: formatOpenings(career.jobOpenings) });
  } else if (colleges.length > 0) {
    // Not a job-role count: job roles are a specialization-page concept now,
    // and a metric here would point at a section this page no longer has.
    metrics.push({ icon: "bld", label: "Top Colleges", value: String(colleges.length) });
  }

  // Derived from facts the catalog can prove, so no claim here can outlive the
  // data behind it. A stored `highlights` value wins where an editor has
  // written something better.
  const derivedHighlights: string[] = [];
  if (sectors.length >= 5) {
    derivedHighlights.push(`Hiring across ${sectors.length} industries, not one`);
  }
  if (career.demand === "High Demand") {
    derivedHighlights.push("Consistently high demand in India");
  } else if (career.demand === "Emerging") {
    derivedHighlights.push("A fast-growing, still-forming field");
  } else if (career.demand === "Evergreen") {
    derivedHighlights.push("Steady demand that does not follow cycles");
  }
  if (specializations.length >= 3) {
    derivedHighlights.push(`${specializations.length} specializations to focus into`);
  }
  if (career.salaryMaxLpa !== null && career.salaryMaxLpa >= 20) {
    derivedHighlights.push(`Senior pay reaching ₹${trim(career.salaryMaxLpa)} LPA`);
  }
  if (career.growthStages.length >= 4) {
    derivedHighlights.push(`A ${career.growthStages.length}-stage path to leadership`);
  }
  if (employers.length > 0) {
    derivedHighlights.push(`Recruiters include ${employers[0].name}`);
  }
  const highlights =
    career.highlights.length > 0 ? career.highlights : derivedHighlights.slice(0, 5);

  // Skills read best as the hero's floating labels -- they are the short,
  // recognisable nouns of a field. Specializations stand in where a career
  // has none mapped.
  const heroLabels = (skills.length >= 3 ? skills.map((s) => s.name) : specializations.map((s) => s.name)).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Careers", href: "/careers" },
            { label: career.title },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name={career.icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {career.title}
                </h1>
                <p className="text-ink/70 text-[15px] mt-1.5">{career.tagline}</p>
              </div>
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {career.description}
            </p>

            <div className="flex flex-wrap items-center gap-2.5 mt-5">
              {tags.map((t, i) => (
                <span
                  key={t!.slug}
                  className={`text-[13px] font-semibold px-4 py-2 rounded-full ${tint(i)}`}
                >
                  {t!.name}
                </span>
              ))}
              <span
                className={`text-[13px] font-bold px-4 py-2 rounded-full ${
                  DEMAND_STYLES[career.demand] ?? "bg-slate-soft text-slate"
                }`}
              >
                {career.demand}
              </span>
            </div>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            <div className="flex flex-wrap gap-3 mt-7">
              <SaveButton type="careers" slug={career.slug} />
              <CompareButton slug={career.slug} />
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={career.icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-9 flex flex-col gap-6">
            <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
              <Card className="md:col-span-3">
                <CardTitle icon="book">What You Can Do in This Career</CardTitle>
                <div className="bg-bg-soft rounded-2xl p-5">
                  <p className="text-[14px] text-ink/75 leading-relaxed">{career.typicalWork}</p>
                </div>
              </Card>

              {highlights.length > 0 && (
                <Card className="md:col-span-2">
                  <CardTitle icon="star">Key Highlights</CardTitle>
                  <ul className="flex flex-col gap-3.5">
                    {highlights.map((h, i) => (
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

            {career.growthStages.length > 0 && (
              <Section icon="chart" title="Career Growth Path">
                {/* Horizontal on desktop, stacked on mobile. The arrows are
                    decorative and hidden from assistive tech -- the ordered
                    list already carries the sequence. */}
                <ol className="flex flex-col sm:flex-row sm:items-stretch gap-2 sm:gap-0 sm:overflow-x-auto sm:pb-2">
                  {career.growthStages.map((s, i) => (
                    <li key={`${s.title}-${i}`} className="flex items-center gap-2 sm:shrink-0">
                      <div
                        className={`flex-1 sm:flex-none sm:w-[168px] rounded-2xl border border-line p-4 ${
                          i === career.growthStages.length - 1 ? "bg-blue-soft" : "bg-white"
                        }`}
                      >
                        <div className="font-display font-bold text-navy text-[13.5px] leading-snug">
                          {s.title}
                        </div>
                        <div className="text-[12px] text-muted mt-1.5">({s.label})</div>
                      </div>
                      {i < career.growthStages.length - 1 && (
                        <Icon
                          name="arrowRight"
                          aria-hidden
                          className="w-4 h-4 text-subtle shrink-0 mx-1 rotate-90 sm:rotate-0"
                        />
                      )}
                    </li>
                  ))}
                </ol>
              </Section>
            )}

            {specializations.length > 0 && (
              <Section
                icon="layers"
                title={`Popular Specializations in ${career.title}`}
                subtitle="Each one is a focused area within this career, with its own page"
                viewAll={{ href: "/specializations", count: specializations.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {specializations.slice(0, 6).map((s, i) => (
                    <RowCard
                      key={s.slug}
                      href={`/specializations/${s.slug}`}
                      icon={s.icon}
                      tint={tint(i)}
                      title={s.name}
                      meta={s.description}
                    />
                  ))}
                </div>
              </Section>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {education.length > 0 && (
                <Card>
                  <CardTitle
                    icon="cap"
                    subtitle={
                      career.education.length > 0
                        ? undefined
                        : "Inferred from shared entrance exams -- no degrees are mapped to this career yet"
                    }
                  >
                    Required Education
                  </CardTitle>
                  <ul className="flex flex-col">
                    {education.map((e) => (
                      <ListRow
                        key={`${e.education.degreeSlug}|${e.education.subjectSlug ?? ""}`}
                        href={`/degrees/${e.education.degreeSlug}`}
                        label={`${e.education.title} · ${e.degree!.level}`}
                      />
                    ))}
                  </ul>
                </Card>
              )}

              {skills.length > 0 && (
                <Card>
                  <CardTitle icon="gear" viewAll={{ href: "/skills", count: skills.length }}>
                    Key Skills
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

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {exams.length > 0 && (
                <Card>
                  <CardTitle icon="doc" viewAll={{ href: "/exams", count: exams.length }}>
                    Relevant Exams
                  </CardTitle>
                  <ul className="flex flex-col">
                    {exams.slice(0, 6).map((e) => (
                      <ListRow key={e.slug} href={`/exams/${e.slug}`} label={e.name} />
                    ))}
                  </ul>
                </Card>
              )}

              {/* No job roles here. In this model a job role is a PERSON you
                  hire ("Backend Developer") and it belongs to the
                  specialization page, which is the level that can say which
                  roles a focused area actually leads to. The career page stays
                  at the level of the field.

                  The career -> job role relation is untouched: it still backs
                  the containment rule V95 made an error-level check (a
                  specialization's roles must be a subset of its career's), and
                  it is what the specialization page falls back to for a
                  specialization with no roles of its own. Only this section
                  is gone, not the data. */}

              {sectors.length > 0 && (
                <Card>
                  <CardTitle icon="bld" viewAll={{ href: "/industries", count: sectors.length }}>
                    Key Industries
                  </CardTitle>
                  <div className="flex flex-wrap gap-2">
                    {sectors.slice(0, 10).map((s, i) => (
                      <Pill key={s.slug} href={`/industries/${s.slug}`} tint={tint(i + 1)}>
                        {s.name}
                      </Pill>
                    ))}
                  </div>
                </Card>
              )}
            </div>

            {career.salaryBands.length > 0 ? (
              <Section icon="bank" title="Salary by Experience Level">
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  {career.salaryBands.map((b, i) => (
                    <div key={b.band} className={`rounded-2xl p-5 ${tint(i)}`}>
                      <div className="text-[12.5px] font-bold opacity-80">{b.band}</div>
                      <div className="font-display font-extrabold text-[19px] mt-1.5">
                        ₹{trim(b.minLpa)}
                        {b.maxLpa === null ? "+" : `–${trim(b.maxLpa)}`} LPA
                      </div>
                    </div>
                  ))}
                </div>
              </Section>
            ) : (
              career.salaryRange && (
                <Section icon="bank" title="Career-Level Salary">
                  <div className="rounded-2xl border border-line bg-white p-6 flex flex-wrap items-center gap-x-10 gap-y-4">
                    <div>
                      <div className="text-[12.5px] font-semibold text-muted">
                        Typical range across the career
                      </div>
                      <div className="font-display font-extrabold text-navy text-[26px] mt-1">
                        ₹{trim(career.salaryMinLpa)}–{trim(career.salaryMaxLpa)} LPA
                      </div>
                    </div>
                    {/* Said plainly rather than filled with a generated
                        breakdown: the per-level figures are not in the
                        catalog, and four plausible bands would read as
                        researched. */}
                    <p className="text-[12.5px] text-muted max-w-sm leading-relaxed">
                      A breakdown by experience level has not been recorded for this career yet.
                      The progression above shows the stages it moves through.
                    </p>
                  </div>
                </Section>
              )
            )}
          </div>

          {/* ------------------------------------------------------- Right rail */}
          <aside className="lg:col-span-3 flex flex-col gap-6">
            {employers.length > 0 && (
              <Card>
                <CardTitle icon="bld" viewAll={{ href: "/industries" }}>
                  Top Companies Hiring
                </CardTitle>
                <ul className="flex flex-col">
                  {employers.slice(0, 8).map((e, i) => (
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

            {career.workEnvironments.length > 0 && (
              <Card>
                <CardTitle icon="mappin">Work Environment</CardTitle>
                <div className="flex flex-wrap gap-2">
                  {career.workEnvironments.map((w, i) => (
                    <span
                      key={w}
                      className={`text-[12.5px] font-semibold px-3.5 py-2 rounded-full ${tint(i + 3)}`}
                    >
                      {w}
                    </span>
                  ))}
                </div>
              </Card>
            )}

            {colleges.length > 0 && (
              <Card>
                <CardTitle icon="bank" viewAll={{ href: "/colleges", count: colleges.length }}>
                  Top Colleges
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

            {resources.length > 0 && (
              <Card>
                <CardTitle icon="book" viewAll={{ href: "/resources" }}>
                  Resources
                </CardTitle>
                <ul className="flex flex-col">
                  {resources.slice(0, 6).map((r, i) => (
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

        {relatedCareers.length > 0 && (
          <div className="mt-6">
            <Section
              icon="compass"
              title="Related Careers"
              subtitle={`Other careers in ${category?.name ?? "this field"}`}
              viewAll={{ href: "/careers" }}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                {relatedCareers.map((c, i) => (
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
          </div>
        )}

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/careers"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all careers
          </Link>
          <Link
            href="/assessment"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Take the career test
          </Link>
        </div>
      </Container>
    </>
  );
}

/** 4 renders as "4", 2.5 as "2.5" -- the figures are written the way the
 *  domain writes them, not padded to two decimals by the NUMERIC column. */
function trim(value: number | null): string {
  if (value === null) return "";
  return String(value);
}
