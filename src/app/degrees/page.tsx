import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import DegreesExplorer from "@/components/listing/DegreesExplorer";
import { getDegrees, filterDegreesRelevantToCareer } from "@/data/degrees";
import { getCareer, getCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Explore Degrees — CareerGuide",
  description:
    "Discover degree options, compare eligibility, duration and career scope, and find the right qualification for your goals.",
};

// Same slot as the careers hero: drop a file in and it renders, otherwise the
// built panel does. Checked on the server so a missing file cannot ship a
// broken image.
const HERO_IMAGE_CANDIDATES = [
  "hero-explore-degrees.webp",
  "hero-explore-degrees.png",
  "hero-explore-degrees.jpg",
  "hero-explore-degrees.svg",
];

// The signpost arms: degree LEVELS rather than categories, because level is
// the first cut a student makes when looking at qualifications ("am I looking
// at an undergraduate or a postgraduate route?"). Derived below from the
// levels actually present, so an arm can never link to an empty list.
const SIGNPOST_COLOURS = [
  "bg-blue text-white",
  "bg-teal text-white",
  "bg-pink text-white",
  "bg-purple text-white",
  "bg-amber text-white",
  "bg-green text-white",
];

// What this page is for, in the mock's four-bullet rail. Static copy: these
// describe the page, not the catalog, so there is nothing to derive.
const VALUE_POINTS = [
  { icon: "cap", tint: "bg-blue-soft text-blue", text: "Explore degree options across multiple fields" },
  { icon: "chart", tint: "bg-green-soft text-green", text: "Compare eligibility, duration and career scope" },
  { icon: "bank", tint: "bg-pink-soft text-pink", text: "Find colleges offering your preferred degree" },
  { icon: "bulb", tint: "bg-amber-soft text-amber", text: "Make informed decisions for a brighter future" },
];

export default async function DegreesPage({
  searchParams,
}: {
  searchParams: Promise<{ career?: string }>;
}) {
  const { career: careerSlug } = await searchParams;
  const [allDegrees, career, categories, careers] = await Promise.all([
    getDegrees(),
    careerSlug ? getCareer(careerSlug) : Promise.resolve(undefined),
    getCategories(),
    getCareers(),
  ]);

  // Prefer the real Degree<->Career relation (career_degrees, V51) when this
  // career has any; it is exact, unlike the shared-entrance-exam heuristic,
  // which stays only as a fallback for disciplines V51 deliberately left
  // unmapped. Falls all the way back to the full list rather than a dead-end
  // empty page when neither finds anything.
  const exactDegrees =
    career && career.education.length > 0
      ? allDegrees.filter((d) => career.education.some((e) => e.degreeSlug === d.slug))
      : [];
  const heuristicDegrees =
    career && exactDegrees.length === 0 ? filterDegreesRelevantToCareer(allDegrees, career) : [];
  const relevantDegrees = exactDegrees.length > 0 ? exactDegrees : heuristicDegrees;
  const isFiltered = Boolean(career) && relevantDegrees.length > 0;
  const degrees = isFiltered ? relevantDegrees : allDegrees;

  // How many specializations a degree opens up, reached through the careers it
  // qualifies you for. Derived rather than stored: specialization_degrees
  // (V108) records a specialization's OWN entry routes and is seeded for one
  // row so far, whereas career_degrees is fully populated -- so "B.Tech leads
  // to 16 careers holding 118 specializations between them" is a fact the
  // catalog can already prove today.
  const specializationCounts = new Map<string, number>();
  for (const d of allDegrees) {
    const reachable = new Set<string>();
    for (const c of careers) {
      if (c.education.some((e) => e.degreeSlug === d.slug)) {
        for (const s of c.relatedSpecializationSlugs) reachable.add(s);
      }
    }
    if (reachable.size > 0) specializationCounts.set(d.slug, reachable.size);
  }

  const levelsPresent = ["Undergraduate", "Postgraduate", "Doctoral", "Diploma", "Certificate"].filter(
    (l) => degrees.some((d) => d.level === l)
  );

  const heroImageFile = HERO_IMAGE_CANDIDATES.find((f) =>
    existsSync(path.join(process.cwd(), "public", f))
  );
  const heroImage = heroImageFile ? `/${heroImageFile}` : null;

  // The most-referenced degrees, so the row cannot drift from the catalog.
  const popular = [...allDegrees]
    .sort(
      (a, b) =>
        (specializationCounts.get(b.slug) ?? 0) - (specializationCounts.get(a.slug) ?? 0) ||
        a.title.localeCompare(b.title)
    )
    .slice(0, 8);

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="lg:col-span-6 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Build Your Future
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Degrees</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Discover degree options, explore specializations, understand eligibility and career
                opportunities, and find the right degree for your goals.
              </p>

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Popular searches:
                  </span>
                  {popular.map((d) => (
                    <Link
                      key={d.slug}
                      href={`/degrees/${d.slug}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {d.title}
                    </Link>
                  ))}
                </div>
              )}
            </div>

            <div className="lg:col-span-3 relative min-h-[220px]">
              {heroImage ? (
                <Image
                  src={heroImage}
                  alt=""
                  aria-hidden
                  width={620}
                  height={520}
                  priority
                  className="w-full h-full object-cover"
                />
              ) : (
                <LevelSignpost levels={levelsPresent} />
              )}
            </div>

            {/* The mock's four-bullet rail. Kept as its own column so it does
                not compete with the search for the eye on the left. */}
            <ul className="lg:col-span-3 flex flex-col gap-2.5 p-7 sm:p-10 lg:pl-0 lg:justify-center">
              {VALUE_POINTS.map((v) => (
                <li
                  key={v.text}
                  className="flex items-start gap-3 rounded-2xl border border-line bg-white px-3.5 py-3"
                >
                  <span
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${v.tint}`}
                  >
                    <Icon name={v.icon} className="w-4 h-4" />
                  </span>
                  <span className="text-[12.5px] text-ink/75 leading-snug">{v.text}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </Container>

      {career && !isFiltered && (
        <Container className="mt-5">
          <p className="text-[13px] text-subtle">
            No degree matched {career.title} directly, so every degree is listed below.{" "}
            <Link href="/degrees" className="font-semibold text-blue hover:underline">
              Clear
            </Link>
          </p>
        </Container>
      )}

      <Suspense fallback={null}>
        <DegreesExplorer
          initialDegrees={degrees}
          categories={categories}
          specializationCounts={Object.fromEntries(specializationCounts)}
          filteredForCareer={isFiltered ? career!.title : null}
        />
      </Suspense>
    </>
  );
}

/**
 * The hero visual until artwork is supplied: a signpost whose arms are the
 * degree levels actually present, each one a live filter.
 */
function LevelSignpost({ levels }: { levels: string[] }) {
  return (
    <div className="relative h-full min-h-[220px] flex items-center justify-center p-6">
      <div
        aria-hidden
        className="absolute inset-0 opacity-80"
        style={{
          backgroundImage:
            "radial-gradient(circle at 60% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(219,39,119,0.12), transparent 60%)",
        }}
      />
      <div className="relative flex flex-col items-start gap-2">
        {levels.map((l, i) => (
          <Link
            key={l}
            href={`/degrees?level=${encodeURIComponent(l)}`}
            style={{ marginLeft: `${(i % 2) * 22}px` }}
            className={`text-[12.5px] font-bold px-4 py-2 rounded-lg shadow-card hover:opacity-90 transition-opacity ${
              SIGNPOST_COLOURS[i % SIGNPOST_COLOURS.length]
            }`}
          >
            {l}
          </Link>
        ))}
      </div>
    </div>
  );
}
