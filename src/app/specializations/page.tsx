import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import SpecializationsExplorer from "@/components/listing/SpecializationsExplorer";
import { getSpecializations } from "@/data/specializations";
import { getCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Explore Specializations — CareerGuide",
  description:
    "Browse the focused areas within every career, see the job roles each one leads to, and find the one to specialise in.",
};

const HERO_IMAGE_CANDIDATES = [
  "hero-explore-specializations.webp",
  "hero-explore-specializations.png",
  "hero-explore-specializations.jpg",
  "hero-explore-specializations.svg",
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
  { icon: "layers", tint: "bg-blue-soft text-blue", text: "Narrow a broad career into a focused area" },
  { icon: "users", tint: "bg-green-soft text-green", text: "See the job roles each area leads to" },
  { icon: "cap", tint: "bg-pink-soft text-pink", text: "Check the degrees and exams that get you there" },
  { icon: "compass", tint: "bg-amber-soft text-amber", text: "Compare areas within the same career" },
];

export default async function SpecializationsPage() {
  const [specializations, careers, categories] = await Promise.all([
    getSpecializations(),
    getCareers(),
    getCategories(),
  ]);

  const careerBySlug = new Map(careers.map((c) => [c.slug, c]));

  // A specialization's field comes from its parent career's category -- it
  // has no category of its own, and inventing one would be a second, drifting
  // copy of something career_specializations already answers. A specialization
  // under two careers in different categories belongs to both.
  const fieldsBySpec = new Map<string, string[]>();
  for (const s of specializations) {
    const fields = new Set<string>();
    for (const slug of s.careerSlugs) {
      const c = careerBySlug.get(slug);
      if (c) fields.add(c.categorySlug);
    }
    fieldsBySpec.set(s.slug, [...fields]);
  }

  const fieldCounts = new Map<string, number>();
  for (const fields of fieldsBySpec.values()) {
    for (const f of fields) fieldCounts.set(f, (fieldCounts.get(f) ?? 0) + 1);
  }

  const withRoles = specializations.filter((s) => s.relatedJobRoleSlugs.length > 0).length;
  const parentCareers = new Set(specializations.flatMap((s) => s.careerSlugs)).size;

  const stats = [
    { icon: "layers", tint: "bg-blue-soft text-blue", value: specializations.length, label: "Specializations", sub: "Across the catalog" },
    { icon: "brief", tint: "bg-purple-soft text-purple", value: parentCareers, label: "Parent careers", sub: `Of ${careers.length} careers` },
    { icon: "users", tint: "bg-green-soft text-green", value: withRoles, label: "With job roles", sub: "Mapped to real roles" },
    { icon: "grid", tint: "bg-amber-soft text-amber", value: fieldCounts.size, label: "Fields", sub: "Engineering, Medical…" },
  ];

  // The specializations that lead to the most job roles -- derived, so the
  // row cannot drift the way a hand-written "popular" list would.
  const popular = [...specializations]
    .sort(
      (a, b) =>
        b.relatedJobRoleSlugs.length - a.relatedJobRoleSlugs.length || a.name.localeCompare(b.name)
    )
    .slice(0, 6);

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
                Go Deeper Than a Career
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Specializations</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                A specialization is a focused area inside a career — Cloud Computing within Computer
                Science, say. Browse them by field, see the job roles each one leads to, and find
                where to go deep.
              </p>

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Most job roles:
                  </span>
                  {popular.map((s) => (
                    <Link
                      key={s.slug}
                      href={`/specializations/${s.slug}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {s.name}
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
                        "radial-gradient(circle at 60% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(219,39,119,0.12), transparent 60%)",
                    }}
                  />
                  <div className="relative flex flex-col items-start gap-2">
                    {signpost.map((c, i) => (
                      <Link
                        key={c.slug}
                        href={`/specializations?field=${c.slug}`}
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
        {/* Trimmed to the fields the listing renders. The Explorer is a client
            component, so whatever is passed here is serialised into the RSC
            payload on top of the HTML -- every unused field is paid for twice.
            `overview` alone is 117 KB across 263 rows and appears nowhere on
            this page. See SpecializationListItem for the full reasoning. */}
        <SpecializationsExplorer
          initialSpecializations={specializations.map((s) => ({
            slug: s.slug,
            name: s.name,
            description: s.description,
            icon: s.icon,
            careerSlugs: s.careerSlugs,
            primaryCareerSlug: s.primaryCareerSlug,
            relatedJobRoleSlugs: s.relatedJobRoleSlugs,
          }))}
          careers={careers.map((c) => ({ slug: c.slug, title: c.title, categorySlug: c.categorySlug }))}
          categories={categories}
          fieldsBySpec={Object.fromEntries(fieldsBySpec)}
        />
      </Suspense>
    </>
  );
}
