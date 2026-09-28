import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import SkillsExplorer from "@/components/listing/SkillsExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { getSkills } from "@/data/skills";
import { getCareers } from "@/data/careers";
import { getJobRoles } from "@/data/jobRoles";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Explore Skills — CareerGuide",
  description:
    "Discover the skills behind every career, see which job roles need them, and find the ones worth building next.",
};

const HERO_IMAGE_CANDIDATES = [
  "hero-explore-skills.webp",
  "hero-explore-skills.png",
  "hero-explore-skills.jpg",
  "hero-explore-skills.svg",
];

const SIGNPOST_COLOURS = [
  "bg-blue text-white",
  "bg-teal text-white",
  "bg-pink text-white",
  "bg-purple text-white",
  "bg-amber text-white",
];

const VALUE_POINTS = [
  { icon: "compass", tint: "bg-green-soft text-green", text: "Explore the skills different careers ask for" },
  { icon: "users", tint: "bg-blue-soft text-blue", text: "See which job roles need each skill" },
  { icon: "chart", tint: "bg-amber-soft text-amber", text: "Compare how widely a skill is used" },
  { icon: "target", tint: "bg-pink-soft text-pink", text: "Find skills that open up more careers" },
];

const CATEGORY_LABELS: Record<string, string> = {
  Soft: "Soft Skills",
  Programming: "Programming",
  Tools: "Tools & Tech",
  Analytical: "Analytical",
  Domain: "Domain Skills",
};

export default async function SkillsPage() {
  const [skills, careers, jobRoles, categories] = await Promise.all([
    getSkills(),
    getCareers(),
    getJobRoles(),
    getCategories(),
  ]);

  // How far a skill reaches: the careers and job roles that list it. Counted
  // here rather than stored, because both are already relations -- a stored
  // total would be a second copy of a number the join already knows.
  //
  // This is also what stands in for the "demand level" a skills page usually
  // shows. Nothing in this catalog implies market demand, and inventing a
  // High/Medium/Low would be a claim with nothing behind it. Reach is a real
  // measure of how much of the catalog asks for a skill, and it is labelled
  // as exactly that.
  const careerCounts = new Map<string, number>();
  const careerFields = new Map<string, Set<string>>();
  for (const c of careers) {
    for (const s of c.relatedSkillSlugs) {
      careerCounts.set(s, (careerCounts.get(s) ?? 0) + 1);
      const fields = careerFields.get(s) ?? new Set<string>();
      fields.add(c.categorySlug);
      careerFields.set(s, fields);
    }
  }

  const roleCounts = new Map<string, number>();
  for (const r of jobRoles) {
    for (const s of r.relatedSkillSlugs) roleCounts.set(s, (roleCounts.get(s) ?? 0) + 1);
  }

  const categoryCounts = new Map<string, number>();
  for (const s of skills) categoryCounts.set(s.category, (categoryCounts.get(s.category) ?? 0) + 1);

  const stats = [
    { icon: "gear", tint: "bg-blue-soft text-blue", value: skills.length, label: "Skills", sub: "In the catalog" },
    { icon: "brief", tint: "bg-purple-soft text-purple", value: careerCounts.size, label: "Used by careers", sub: `Across ${careers.length} careers` },
    { icon: "users", tint: "bg-green-soft text-green", value: roleCounts.size, label: "Used by job roles", sub: `Across ${jobRoles.length} roles` },
    { icon: "layers", tint: "bg-amber-soft text-amber", value: categoryCounts.size, label: "Categories", sub: "Soft, Tools, Domain…" },
  ];

  // The widest-reaching skills, by how many job roles ask for them. Derived,
  // so the row cannot drift from the catalog the way a hand-written list of
  // "popular" skills would.
  const popular = [...skills]
    .sort((a, b) => (roleCounts.get(b.slug) ?? 0) - (roleCounts.get(a.slug) ?? 0) || a.name.localeCompare(b.name))
    .slice(0, 6);

  const signpost = [...categoryCounts.entries()].sort((a, b) => b[1] - a[1]);

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
                Build Future-Ready Skills
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Skills</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Discover the skills behind every career, see which job roles ask for them, and find
                the ones that open up the most options.
              </p>

              <ListingHeroSearch
                basePath="/skills"
                anchorId="all-skills"
                label="Search skills"
                placeholder="Search skills (e.g. Python, Communication, Data Analysis...)"
              />

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">
                    Most in demand:
                  </span>
                  {popular.map((s) => (
                    <Link
                      key={s.slug}
                      href={`/skills/${s.slug}`}
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
                        "radial-gradient(circle at 60% 25%, rgba(13,148,136,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(37,99,235,0.14), transparent 60%)",
                    }}
                  />
                  <div className="relative flex flex-col items-start gap-2">
                    {signpost.map(([cat], i) => (
                      <Link
                        key={cat}
                        href={`/skills?category=${cat}`}
                        style={{ marginLeft: `${(i % 2) * 22}px` }}
                        className={`text-[12.5px] font-bold px-4 py-2 rounded-lg shadow-card hover:opacity-90 transition-opacity ${
                          SIGNPOST_COLOURS[i % SIGNPOST_COLOURS.length]
                        }`}
                      >
                        {CATEGORY_LABELS[cat] ?? cat}
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
        <SkillsExplorer
          initialSkills={skills}
          categories={categories}
          careerCounts={Object.fromEntries(careerCounts)}
          roleCounts={Object.fromEntries(roleCounts)}
          fieldsBySkill={Object.fromEntries([...careerFields].map(([k, v]) => [k, [...v]]))}
        />
      </Suspense>
    </>
  );
}
