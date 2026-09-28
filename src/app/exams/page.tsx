import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import ExamsExplorer from "@/components/listing/ExamsExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { getExams } from "@/data/exams";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Explore Exams — CareerGuide",
  description:
    "Discover entrance and competitive exams, understand eligibility and exam pattern, and explore the career opportunities they lead to.",
};

const HERO_IMAGE_CANDIDATES = [
  "hero-explore-exams.webp",
  "hero-explore-exams.png",
  "hero-explore-exams.jpg",
  "hero-explore-exams.svg",
];

const SIGNPOST_COLOURS = [
  "bg-blue text-white",
  "bg-teal text-white",
  "bg-pink text-white",
  "bg-purple text-white",
  "bg-amber text-white",
  "bg-green text-white",
];

// Static copy: these describe the page, not the catalog, so there is nothing
// to derive and nothing that can go stale.
const VALUE_POINTS = [
  { icon: "target", tint: "bg-green-soft text-green", text: "Find the right exam for your career goals" },
  { icon: "cap", tint: "bg-blue-soft text-blue", text: "Explore colleges and degrees after the exam" },
  { icon: "bank", tint: "bg-pink-soft text-pink", text: "Understand eligibility, syllabus and exam pattern" },
  { icon: "clock", tint: "bg-amber-soft text-amber", text: "Compare exams and how often they are held" },
];

// The eight exams a visitor is most likely to be looking for. Hard-coded
// rather than derived: "popular" is a fact about the outside world, and the
// catalog holds nothing that stands in for it -- an exam's link count says
// how much of it WE have modelled, not how many people sit it. Any slug that
// no longer exists is dropped below rather than rendering a dead chip.
const POPULAR_SLUGS = [
  "jee-main",
  "neet-ug",
  "gate",
  "upsc-cse",
  "cuet",
  "cat",
  "clat",
  "nda-exam",
];

export default async function ExamsPage() {
  const [exams, categories] = await Promise.all([getExams(), getCategories()]);

  const bySlug = new Map(exams.map((e) => [e.slug, e]));
  const popular = POPULAR_SLUGS.map((s) => bySlug.get(s)).filter((e) => e);

  // Signpost arms: the biggest fields, so an arm can never link to an empty
  // list. Exams with no field (CUET, NTSE) are excluded from the counts
  // rather than bucketed somewhere they do not belong.
  const fieldCounts = new Map<string, number>();
  for (const e of exams) {
    if (e.categorySlug) fieldCounts.set(e.categorySlug, (fieldCounts.get(e.categorySlug) ?? 0) + 1);
  }
  const signpost = categories
    .filter((c) => fieldCounts.has(c.slug))
    .sort((a, b) => (fieldCounts.get(b.slug) ?? 0) - (fieldCounts.get(a.slug) ?? 0))
    .slice(0, 6);

  const heroImageFile = HERO_IMAGE_CANDIDATES.find((f) =>
    existsSync(path.join(process.cwd(), "public", f))
  );
  const heroImage = heroImageFile ? `/${heroImageFile}` : null;

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="lg:col-span-6 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Your Gateway to Opportunities
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Exams</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Discover entrance and competitive exams, understand eligibility and exam pattern,
                and explore the career opportunities they can lead to.
              </p>

              <ListingHeroSearch
                basePath="/exams"
                anchorId="all-exams"
                label="Search exams"
                placeholder="Search exams (e.g. JEE Main, NEET, GATE, UPSC...)"
              />

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Popular searches:
                  </span>
                  {popular.map((e) => (
                    <Link
                      key={e!.slug}
                      href={`/exams/${e!.slug}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {e!.name}
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
                <div className="relative h-full min-h-[220px] flex items-center justify-center p-6">
                  <div
                    aria-hidden
                    className="absolute inset-0 opacity-80"
                    style={{
                      backgroundImage:
                        "radial-gradient(circle at 60% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(13,148,136,0.14), transparent 60%)",
                    }}
                  />
                  <div className="relative flex flex-col items-start gap-2">
                    {signpost.map((c, i) => (
                      <Link
                        key={c.slug}
                        href={`/exams?field=${c.slug}`}
                        style={{ marginLeft: `${(i % 2) * 22}px` }}
                        className={`text-[12.5px] font-bold px-4 py-2 rounded-lg shadow-card hover:opacity-90 transition-opacity ${
                          SIGNPOST_COLOURS[i % SIGNPOST_COLOURS.length]
                        }`}
                      >
                        {c.name}
                      </Link>
                    ))}
                  </div>
                </div>
              )}
            </div>

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

      <Suspense fallback={null}>
        <ExamsExplorer initialExams={exams} categories={categories} />
      </Suspense>
    </>
  );
}
