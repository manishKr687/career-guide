import Link from "next/link";
import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import CareersExplorer from "@/components/listing/CareersExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { getCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";
import { getSpecializations } from "@/data/specializations";
import { getColleges } from "@/data/colleges";
import { getExams } from "@/data/exams";
import type { Category } from "@/lib/types";

export const metadata: Metadata = {
  title: "Explore Careers — CareerGuide",
  description:
    "Browse careers across every field, with specializations, education paths, skills, exams and salary ranges.",
};

// Hidden from this listing page only -- these 3 careers' data, detail pages
// (/careers/<slug>) and every other reference to them (search, related-
// careers lists, etc.) are untouched. They overlap with 3 of the 4 CSE
// specializations added in V46 (Software Engineer / Cloud Architect / AI-ML
// Engineer vs. the Software Developer / Cloud Engineer / ML-AI Engineer
// specializations under Computer Science Engineer), so they're filtered out
// of the main careers grid here to avoid showing near-duplicate entries
// side by side, per direct request.
const HIDDEN_FROM_LISTING_SLUGS = new Set([
  "software-engineer",
  "cloud-architect",
  "ai-ml-engineer",
]);

// Colours for the hero signpost's arms, cycled by position.
//
// The arms themselves are DERIVED from the categories that actually hold
// careers, not listed here. A hand-written list pointed at `it-software`,
// which reads like the obvious slug for "Technology" and has zero careers --
// the arm would have been a link to an empty result set. Deriving makes that
// class of mistake impossible.
const HERO_IMAGE_CANDIDATES = [
  "hero-explore-careers.webp",
  "hero-explore-careers.png",
  "hero-explore-careers.jpg",
  "hero-explore-careers.svg",
].map((f) => f);

const SIGNPOST_COLOURS = [
  "bg-blue text-white",
  "bg-teal text-white",
  "bg-amber text-white",
  "bg-pink text-white",
  "bg-purple text-white",
  "bg-green text-white",
];

export default async function CareersPage() {
  const [allCareers, categories, specializations, colleges, exams] = await Promise.all([
    getCareers(),
    getCategories(),
    getSpecializations(),
    getColleges(),
    getExams(),
  ]);
  const careers = allCareers.filter((c) => !HIDDEN_FROM_LISTING_SLUGS.has(c.slug));

  // Counted, not written down. A hard-coded "120+" is a number that goes
  // wrong the first time someone adds a career, and this catalog has moved a
  // lot this month.
  const stats = [
    { icon: "brief", tint: "bg-purple-soft text-purple", value: careers.length, label: "Careers" },
    { icon: "cap", tint: "bg-blue-soft text-blue", value: specializations.length, label: "Specializations" },
    { icon: "bank", tint: "bg-green-soft text-green", value: colleges.length, label: "Colleges" },
    { icon: "doc", tint: "bg-amber-soft text-amber", value: exams.length, label: "Exams" },
  ];

  // The six careers with the most specializations -- the ones with the most
  // behind them to explore. Derived so the row cannot drift from the catalog.
  const popular = [...careers]
    .sort(
      (a, b) =>
        b.relatedSpecializationSlugs.length - a.relatedSpecializationSlugs.length ||
        a.title.localeCompare(b.title)
    )
    .slice(0, 6);

  // Categories that actually hold a career, biggest first. Drives both the
  // filter dropdown and the hero signpost, so neither can offer a choice that
  // returns nothing.
  const careersPerCategory = new Map<string, number>();
  for (const c of careers) {
    careersPerCategory.set(c.categorySlug, (careersPerCategory.get(c.categorySlug) ?? 0) + 1);
  }
  const usedCategories = categories
    .filter((c) => careersPerCategory.has(c.slug))
    .sort((a, b) => (careersPerCategory.get(b.slug) ?? 0) - (careersPerCategory.get(a.slug) ?? 0));
  const signpost = usedCategories.slice(0, 6);

  // Drop an image at public/hero-explore-careers.{png,jpg,webp,svg} and the
  // hero uses it; until then the built signpost renders. Checked on the
  // server rather than just pointing <Image> at a path, because a missing
  // file would otherwise ship a broken image to every visitor -- and this
  // page has to work before the artwork exists.
  const heroImageFile = HERO_IMAGE_CANDIDATES.find((f) =>
    existsSync(path.join(process.cwd(), "public", f))
  );
  const heroImage = heroImageFile ? `/${heroImageFile}` : null;

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            <div className="lg:col-span-7 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Your Future Starts Here
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[48px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Careers</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Discover career options, explore specializations, understand required skills,
                education paths and job opportunities, and find the right career for your interests.
              </p>

              <ListingHeroSearch
                basePath="/careers"
                anchorId="all-careers"
                label="Search careers"
                placeholder="Search careers (e.g. Computer Science, Medicine, Law...)"
              />

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Popular searches:
                  </span>
                  {popular.map((c) => (
                    <Link
                      key={c.slug}
                      href={`/careers/${c.slug}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {c.title}
                    </Link>
                  ))}
                </div>
              )}

              <dl className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-7">
                {stats.map((s) => (
                  <div
                    key={s.label}
                    className="flex items-center gap-3 rounded-2xl border border-line bg-white px-4 py-3.5"
                  >
                    <span
                      className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${s.tint}`}
                    >
                      <Icon name={s.icon} className="w-[18px] h-[18px]" />
                    </span>
                    <div className="min-w-0">
                      <dd className="font-display font-extrabold text-navy text-[20px] leading-none">
                        {s.value}
                      </dd>
                      <dt className="text-[12px] font-semibold text-muted mt-1 truncate">
                        {s.label}
                      </dt>
                    </div>
                  </div>
                ))}
              </dl>
            </div>

            <div className="lg:col-span-5 h-full min-h-[280px] relative">
              {heroImage ? (
                <Image
                  src={heroImage}
                  alt=""
                  aria-hidden
                  width={760}
                  height={560}
                  priority
                  className="w-full h-full object-cover lg:rounded-l-none rounded-3xl"
                />
              ) : (
                <div className="p-7 sm:p-10 lg:pl-0 h-full">
                  <Signpost categories={signpost} />
                </div>
              )}
            </div>
          </div>
        </div>
      </Container>

      <Suspense fallback={null}>
        <CareersExplorer
          initialCareers={careers}
          categories={usedCategories}
        />
      </Suspense>
    </>
  );
}

/**
 * The hero visual: a signpost whose arms are real category filters.
 *
 * Built rather than illustrated, the same reasoning as the detail pages'
 * HeroVisual -- and here it earns more than a picture would, because every
 * arm is a link that filters the list below it.
 */
function Signpost({ categories }: { categories: Category[] }) {
  return (
    <div className="relative h-full min-h-[240px] flex items-center justify-center">
      <div
        aria-hidden
        className="absolute inset-0 rounded-3xl opacity-80"
        style={{
          backgroundImage:
            "radial-gradient(circle at 70% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 25% 80%, rgba(22,163,74,0.14), transparent 60%)",
        }}
      />
      <div className="relative flex flex-col items-start gap-2.5">
        {categories.map((c, i) => (
          <Link
            key={c.slug}
            href={`/careers?category=${c.slug}`}
            style={{ marginLeft: `${(i % 2) * 28}px` }}
            className={`text-[13px] font-bold px-5 py-2.5 rounded-lg shadow-card hover:opacity-90 transition-opacity ${
              SIGNPOST_COLOURS[i % SIGNPOST_COLOURS.length]
            }`}
          >
            {c.name}
          </Link>
        ))}
      </div>
    </div>
  );
}
