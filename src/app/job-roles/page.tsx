import { existsSync } from "node:fs";
import path from "node:path";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import JobRolesExplorer from "@/components/listing/JobRolesExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { getJobRoles } from "@/data/jobRoles";
import { getCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Explore Job Roles — CareerGuide",
  description:
    "Browse the roles you can actually be hired into, what they pay, the skills they ask for and the careers they sit under.",
};

const HERO_IMAGE_CANDIDATES = [
  "hero-explore-job-roles.webp",
  "hero-explore-job-roles.png",
  "hero-explore-job-roles.jpg",
  "hero-explore-job-roles.svg",
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
  { icon: "user", tint: "bg-blue-soft text-blue", text: "See the roles a career actually hires for" },
  { icon: "bank", tint: "bg-green-soft text-green", text: "Compare what each role pays" },
  { icon: "gear", tint: "bg-pink-soft text-pink", text: "Check the skills a role asks for" },
  { icon: "trend", tint: "bg-amber-soft text-amber", text: "Find where a role sits on the ladder" },
];

export default async function JobRolesPage() {
  const [jobRoles, careers, categories] = await Promise.all([
    getJobRoles(),
    getCareers(),
    getCategories(),
  ]);

  const careerBySlug = new Map(careers.map((c) => [c.slug, c]));

  // A role's field comes from its parent career's category -- a role has none
  // of its own, and giving it one would be a second copy of what
  // career_job_roles already answers. A role under careers in two different
  // categories belongs to both.
  const fieldsByRole = new Map<string, string[]>();
  for (const r of jobRoles) {
    const fields = new Set<string>();
    for (const slug of r.careerSlugs) {
      const c = careerBySlug.get(slug);
      if (c) fields.add(c.categorySlug);
    }
    fieldsByRole.set(r.slug, [...fields]);
  }

  const fieldCounts = new Map<string, number>();
  for (const fields of fieldsByRole.values()) {
    for (const f of fields) fieldCounts.set(f, (fieldCounts.get(f) ?? 0) + 1);
  }

  const withSalary = jobRoles.filter((r) => r.salaryMaxLpa !== null);
  const topPay = withSalary.reduce((n, r) => Math.max(n, r.salaryMaxLpa ?? 0), 0);

  const stats = [
    { icon: "user", tint: "bg-blue-soft text-blue", value: jobRoles.length, label: "Job Roles", sub: "Across the catalog" },
    { icon: "brief", tint: "bg-purple-soft text-purple", value: new Set(jobRoles.flatMap((r) => r.careerSlugs)).size, label: "Parent careers", sub: `Of ${careers.length} careers` },
    { icon: "bank", tint: "bg-green-soft text-green", value: `₹${topPay}L`, label: "Top salary", sub: `${withSalary.length} roles priced` },
    { icon: "grid", tint: "bg-amber-soft text-amber", value: fieldCounts.size, label: "Fields", sub: "Engineering, Medical…" },
  ];

  // The best-paid roles. Derived, so the row cannot drift -- and possible at
  // all only because V107's numeric salary is finally exposed on the API.
  const popular = [...withSalary]
    .sort((a, b) => (b.salaryMaxLpa ?? 0) - (a.salaryMaxLpa ?? 0) || a.name.localeCompare(b.name))
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
                The Jobs Behind the Careers
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Job Roles</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                A career is a field; a job role is the post you are actually hired into. Browse them
                by field, compare what they pay, and see the skills each one asks for.
              </p>

              <ListingHeroSearch
                basePath="/job-roles"
                anchorId="all-job-roles"
                label="Search job roles"
                placeholder="Search job roles (e.g. Software Engineer, Cardiologist...)"
              />

              {popular.length > 0 && (
                <div className="flex flex-wrap items-center gap-2 mt-4">
                  <span className="text-[12.5px] font-semibold text-muted mr-1">Best paid:</span>
                  {popular.map((r) => (
                    <Link
                      key={r.slug}
                      href={`/job-roles/${r.slug}`}
                      className="text-[12.5px] font-semibold px-3.5 py-1.5 rounded-full bg-white border border-line text-ink/75 hover:border-blue/40 hover:text-blue transition-colors"
                    >
                      {r.name}
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
                        "radial-gradient(circle at 60% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(22,163,74,0.14), transparent 60%)",
                    }}
                  />
                  <div className="relative flex flex-col items-start gap-2">
                    {signpost.map((c, i) => (
                      <Link
                        key={c.slug}
                        href={`/job-roles?field=${c.slug}`}
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
        <JobRolesExplorer
          initialJobRoles={jobRoles}
          careers={careers}
          categories={categories}
          fieldsByRole={Object.fromEntries(fieldsByRole)}
        />
      </Suspense>
    </>
  );
}
