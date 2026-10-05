import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import CollegesExplorer from "@/components/listing/CollegesExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { getColleges } from "@/data/colleges";
import { getStates } from "@/data/states";
import { getCities } from "@/data/cities";

export const metadata: Metadata = {
  title: "Explore Colleges — CareerGuide",
  description:
    "Discover colleges and institutes, explore the degrees they offer, check admission details and find the best fit for your career goals.",
};

const HERO_IMAGE_CANDIDATES = [
  "hero-explore-colleges.webp",
  "hero-explore-colleges.png",
  "hero-explore-colleges.jpg",
  "hero-explore-colleges.svg",
];

const SIGNPOST_COLOURS = [
  "bg-blue text-white",
  "bg-teal text-white",
  "bg-pink text-white",
  "bg-purple text-white",
  "bg-amber text-white",
  "bg-green text-white",
];

const VALUE_POINTS = [
  { icon: "bank", tint: "bg-green-soft text-green", text: "Explore colleges across all fields" },
  { icon: "doc", tint: "bg-blue-soft text-blue", text: "Check the degrees and courses on offer" },
  { icon: "chart", tint: "bg-amber-soft text-amber", text: "Compare institute type, intake exams and scale" },
  { icon: "mappin", tint: "bg-pink-soft text-pink", text: "Find the right college in the right state" },
];

// Well-known institute families, matched against the catalog by name so a
// chip can never be a dead link. Hard-coded because "popular" is a fact about
// the outside world -- the catalog holds nothing that stands in for it.
const POPULAR_QUERIES = ["IIT", "NIT", "AIIMS", "BITS", "Delhi", "Bombay", "Madras", "Chennai"];

export default async function CollegesPage() {
  const [colleges, states, cities] = await Promise.all([getColleges(), getStates(), getCities()]);

  // Counted, never written down. Courses here means degree offerings -- a
  // (college, degree, subject) row -- which is the real unit behind "5,000+
  // courses" and is a number this catalog can actually prove.
  const courseOfferings = colleges.reduce((n, c) => n + c.degreeOfferings.length, 0);
  const cityCount = new Set(colleges.map((c) => c.citySlug).filter(Boolean)).size;
  const stateCount = new Set(colleges.map((c) => c.stateSlug)).size;

  const stats = [
    { icon: "bank", tint: "bg-blue-soft text-blue", value: colleges.length, label: "Colleges", sub: "Across India" },
    { icon: "book", tint: "bg-purple-soft text-purple", value: courseOfferings, label: "Course Offerings", sub: "Degree + subject" },
    { icon: "mappin", tint: "bg-pink-soft text-pink", value: cityCount, label: "Cities", sub: `In ${stateCount} states` },
    { icon: "cap", tint: "bg-amber-soft text-amber", value: new Set(colleges.map((c) => c.type)).size, label: "Institute Types", sub: "IIT, NIT, Medical…" },
  ];

  const popular = POPULAR_QUERIES.filter((q) =>
    colleges.some((c) => c.name.toLowerCase().includes(q.toLowerCase()))
  );

  // Signpost arms: the institute types actually present, biggest first, so an
  // arm can never link to an empty list.
  const typeCounts = new Map<string, number>();
  for (const c of colleges) typeCounts.set(c.type, (typeCounts.get(c.type) ?? 0) + 1);
  const signpost = [...typeCounts.entries()].sort((a, b) => b[1] - a[1]).slice(0, 6);

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
                Your Path to the Right College
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Colleges</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Discover colleges and institutes, explore the degrees they offer, check which exams
                they admit through, and find the best fit for your career goals.
              </p>

              <ListingHeroSearch
                basePath="/colleges"
                anchorId="all-colleges"
                label="Search colleges"
                placeholder="Search colleges (e.g. IIT Delhi, AIIMS, NIT Trichy...)"
              />

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Popular searches:
                  </span>
                  {popular.map((q) => (
                    <Link
                      key={q}
                      href={`/colleges?q=${encodeURIComponent(q)}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {q}
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
                        "radial-gradient(circle at 60% 25%, rgba(124,58,237,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(37,99,235,0.14), transparent 60%)",
                    }}
                  />
                  <div className="relative flex flex-col items-start gap-2">
                    {signpost.map(([type], i) => (
                      <Link
                        key={type}
                        href={`/colleges?type=${encodeURIComponent(type)}`}
                        style={{ marginLeft: `${(i % 2) * 22}px` }}
                        className={`text-[12.5px] font-bold px-4 py-2 rounded-lg shadow-card hover:opacity-90 transition-opacity ${
                          SIGNPOST_COLOURS[i % SIGNPOST_COLOURS.length]
                        }`}
                      >
                        {type}
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

      <Container className="mt-6">
        <dl className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {stats.map((s) => (
            <div
              key={s.label}
              className="flex items-center gap-3.5 rounded-2xl border border-line bg-white px-5 py-4"
            >
              <span
                className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${s.tint}`}
              >
                <Icon name={s.icon} className="w-[21px] h-[21px]" />
              </span>
              <div className="min-w-0">
                <dd className="font-display font-extrabold text-navy text-[22px] leading-none">
                  {s.value}
                </dd>
                <dt className="text-[12.5px] font-semibold text-ink/75 mt-1 truncate">{s.label}</dt>
                <div className="text-[11.5px] text-muted truncate">{s.sub}</div>
              </div>
            </div>
          ))}
        </dl>
      </Container>

      <Suspense fallback={null}>
        <CollegesExplorer initialColleges={colleges.map((c) => ({
            slug: c.slug, name: c.name, location: c.location, type: c.type,
            ownershipType: c.ownershipType, stateSlug: c.stateSlug, citySlug: c.citySlug,
            nirfRank: c.nirfRank, nirfLabel: c.nirfLabel, established: c.established,
            description: c.description, degreeOfferings: c.degreeOfferings, examSlugs: c.examSlugs,
          }))} states={states} cities={cities} />
      </Suspense>
    </>
  );
}
