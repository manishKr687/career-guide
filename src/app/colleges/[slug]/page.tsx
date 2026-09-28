import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
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
  dedupe,
  tint,
} from "@/components/detail/DetailKit";
import { getCollege, getColleges, getCollegeCareerOfferings } from "@/data/colleges";
import { getManyExams } from "@/data/exams";
import { getDegrees } from "@/data/degrees";
import { getManySpecializations } from "@/data/specializations";
import { getState } from "@/data/states";
import { getCity } from "@/data/cities";
import { getUniversity } from "@/data/universities";
import { indexBySlug } from "@/lib/utils";

// The COLLEGE page: one institution, and everything it offers.
//
// NO FEES AND NO PLACEMENT RATE, the same call V113 made when it declined to
// add the columns. Both vary by PROGRAMME rather than by institution -- this
// college's B.Tech fee is not its M.Tech fee, and a placement rate is per
// branch per year -- so a single figure here would average away the thing
// being asked. They belong on college_degrees, the college-programme row.
//
// The NIRF badge, the rank in At a Glance and the rank metric are all
// conditional: V113 ships those columns empty, so the page is complete
// without them and gains three things the moment a rank is entered.

const TYPE_STYLES: Record<string, string> = {
  IIT: "bg-blue-soft text-blue",
  NIT: "bg-teal-soft text-teal",
  Medical: "bg-pink-soft text-pink",
  Law: "bg-purple-soft text-purple",
  Management: "bg-amber-soft text-amber",
  University: "bg-green-soft text-green",
  Polytechnic: "bg-slate-soft text-slate",
  ITI: "bg-slate-soft text-slate",
};

const TYPE_ICONS: Record<string, string> = {
  IIT: "chip",
  NIT: "wrench",
  Medical: "steth",
  Law: "scale",
  Management: "brief",
  University: "bank",
  Polytechnic: "gear",
  ITI: "gear",
};

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const college = await getCollege(slug);
  if (!college) return {};
  return { title: `${college.name} — CareerGuide`, description: college.description };
}

export default async function CollegeDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const college = await getCollege(slug);
  if (!college) notFound();

  // state is always present; city and university are optional -- see V53's
  // migration comment on why most colleges here have no parent university.
  const [exams, allDegrees, specializations, careerOfferings, state, city, university, allColleges] =
    await Promise.all([
      getManyExams(college.examSlugs),
      getDegrees(),
      getManySpecializations(college.specializationSlugs),
      getCollegeCareerOfferings(college),
      getState(college.stateSlug),
      college.citySlug ? getCity(college.citySlug) : Promise.resolve(undefined),
      college.universitySlug ? getUniversity(college.universitySlug) : Promise.resolve(undefined),
      getColleges(),
    ]);

  const degreesBySlug = indexBySlug(allDegrees);

  // Each offering is a (degree, subject) pair, so the same degree can appear
  // more than once -- B.Tech in two subjects is two real rows, not a
  // duplicate. A row whose degree has been deleted renders nothing.
  const offerings = college.degreeOfferings
    .map((o) => ({ ...o, degree: degreesBySlug.get(o.degreeSlug) }))
    .filter((o) => o.degree);

  const levels = dedupe(offerings.map((o) => o.degree!.level));

  // Other colleges of the same type in the same state -- the comparison
  // someone on this page is most likely to want. Derived from columns the
  // college already has rather than a curated list.
  const siblings = allColleges
    .filter((c) => c.slug !== college.slug && c.type === college.type && c.stateSlug === college.stateSlug)
    .slice(0, 6);

  const place = [city?.name, state?.name].filter(Boolean).join(", ") || college.location;

  const metrics = [
    ...(college.nirfRank !== null
      ? [{ icon: "trophy", label: college.nirfLabel ?? "NIRF", value: `#${college.nirfRank}` }]
      : []),
    { icon: "bank", label: "Institute Type", value: college.type },
    ...(offerings.length > 0
      ? [{ icon: "book", label: "Courses", value: String(offerings.length) }]
      : []),
    { icon: "cal", label: "Established", value: String(college.established) },
    ...(exams.length > 0 ? [{ icon: "doc", label: "Admits via", value: `${exams.length} exams` }] : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    ...(college.nirfRank !== null
      ? [{ icon: "trophy", label: "NIRF Rank", value: `#${college.nirfRank} · ${college.nirfLabel}` }]
      : []),
    { icon: "bank", label: "Institute Type", value: college.type },
    { icon: "users", label: "Ownership", value: college.ownershipType },
    { icon: "mappin", label: "Location", value: place },
    { icon: "cal", label: "Established", value: String(college.established) },
    ...(university
      ? [
          {
            icon: "cap",
            label: "Affiliated To",
            value: (
              <Link href={`/colleges?q=${encodeURIComponent(university.name)}`} className="text-blue hover:underline">
                {university.name}
              </Link>
            ),
          },
        ]
      : []),
    ...(levels.length > 0 ? [{ icon: "chart", label: "Levels Offered", value: levels.join(", ") }] : []),
    ...(college.website
      ? [
          {
            icon: "external",
            label: "Website",
            value: (
              <a
                href={college.website}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue hover:underline break-all"
              >
                Official site
              </a>
            ),
          },
        ]
      : []),
  ];

  const heroLabels = (
    offerings.length >= 3
      ? dedupe(offerings.map((o) => o.degree!.title))
      : careerOfferings.map((o) => o.career.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Colleges", href: "/colleges" },
            { label: college.name },
          ]}
        />
      </Container>

      {/* ---------------------------------------------------------------- Hero */}
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span
                className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${TYPE_STYLES[college.type] ?? "bg-bg-soft text-navy"}`}
              >
                <Icon name={TYPE_ICONS[college.type] ?? "bank"} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[30px] sm:text-[38px] leading-[1.1] tracking-tight">
                  {college.name}
                </h1>
                <p className="flex items-center gap-1.5 text-ink/70 text-[14.5px] mt-2">
                  <Icon name="mappin" className="w-4 h-4 text-subtle shrink-0" />
                  {place}
                </p>
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-2.5 mt-5">
              <span
                className={`text-[13px] font-bold px-4 py-2 rounded-full ${TYPE_STYLES[college.type] ?? "bg-bg-soft text-navy"}`}
              >
                {college.type}
              </span>
              <span className="text-[13px] font-semibold px-4 py-2 rounded-full bg-bg-soft text-ink/75">
                {college.ownershipType}
              </span>
              {college.tags.slice(0, 3).map((t, i) => (
                <span
                  key={t}
                  className={`text-[13px] font-semibold px-4 py-2 rounded-full ${tint(i + 2)}`}
                >
                  {t}
                </span>
              ))}
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {college.description}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            <div className="flex flex-wrap gap-3 mt-7">
              <SaveButton type="colleges" slug={college.slug} />
              {college.website && (
                <a
                  href={college.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
                >
                  Official website
                  <Icon name="external" className="w-3.5 h-3.5" />
                </a>
              )}
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={TYPE_ICONS[college.type] ?? "bank"} labels={heroLabels} />
          </div>
        </div>
      </Container>

      {/* ---------------------------------------------------------------- Body */}
      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            <Card>
              <CardTitle icon="book">About {college.name}</CardTitle>
              <p className="text-[14px] text-ink/75 leading-relaxed">{college.description}</p>
            </Card>

            {offerings.length > 0 && (
              <Section
                icon="cap"
                title="Courses Offered"
                subtitle="Each row is a qualification and the subject it is awarded in"
                viewAll={{ href: "/degrees", count: offerings.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {offerings.slice(0, 9).map((o, i) => (
                    <RowCard
                      key={`${o.degreeSlug}|${o.subjectSlug ?? ""}`}
                      href={`/degrees/${o.degreeSlug}`}
                      icon={o.degree!.icon}
                      tint={tint(i)}
                      title={o.title}
                      meta={o.degree!.level}
                    />
                  ))}
                </div>
              </Section>
            )}

            {careerOfferings.length > 0 && (
              <Section
                icon="brief"
                title="Careers You Can Enter From Here"
                subtitle="The career, and the qualification this college offers it through"
                viewAll={{ href: "/careers", count: careerOfferings.length }}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {careerOfferings.slice(0, 9).map((o, i) => (
                    <RowCard
                      key={o.career.slug}
                      href={`/careers/${o.career.slug}`}
                      icon={o.career.icon}
                      tint={tint(i)}
                      title={o.career.title}
                      meta={`via ${o.degreeLabel}`}
                    />
                  ))}
                </div>
              </Section>
            )}

            {specializations.length > 0 && (
              <Section
                icon="layers"
                title="Specializations Taught Here"
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
                    />
                  ))}
                </div>
              </Section>
            )}

            {college.tags.length > 0 && (
              <Card>
                <CardTitle icon="star">Highlights</CardTitle>
                <div className="flex flex-wrap gap-2">
                  {college.tags.map((t, i) => (
                    <span
                      key={t}
                      className={`text-[12.5px] font-semibold px-3.5 py-2 rounded-full ${tint(i)}`}
                    >
                      {t}
                    </span>
                  ))}
                </div>
              </Card>
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

            {exams.length > 0 && (
              <Card>
                <CardTitle icon="doc" viewAll={{ href: "/exams", count: exams.length }}>
                  Admits Through
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

            {levels.length > 0 && (
              <Card>
                <CardTitle icon="cap">Levels Offered</CardTitle>
                <div className="flex flex-wrap gap-2">
                  {levels.map((l, i) => (
                    <Pill key={l} href={`/degrees?level=${encodeURIComponent(l)}`} tint={tint(i)}>
                      {l}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {siblings.length > 0 && (
              <Card>
                <CardTitle
                  icon="compass"
                  subtitle={`Other ${college.type} institutes in ${state?.name ?? "the same state"}`}
                >
                  Compare With
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((c, i) => (
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
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/colleges"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all colleges
          </Link>
          <Link
            href="/degrees"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Explore degrees
          </Link>
        </div>
      </Container>
    </>
  );
}
