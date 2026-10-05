import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import IndustriesExplorer from "@/components/listing/IndustriesExplorer";
import { StatsStrip, ValuePoints, SignpostPanel } from "@/components/listing/ListingKit";
import { getIndustries } from "@/data/industries";
import { getCareers } from "@/data/careers";
import { getJobRoles } from "@/data/jobRoles";

export const metadata: Metadata = {
  title: "Explore Industries — CareerGuide",
  description:
    "The sectors careers are practised in and the employers that hire for them, with the roles behind each.",
};

const VALUE_POINTS = [
  { icon: "bld", tint: "bg-blue-soft text-blue", text: "See which sectors a career is practised in" },
  { icon: "building", tint: "bg-green-soft text-green", text: "Find the employers that hire for it" },
  { icon: "user", tint: "bg-pink-soft text-pink", text: "Check the job roles each one takes on" },
  { icon: "compass", tint: "bg-amber-soft text-amber", text: "Compare where a field's work happens" },
];

export default async function IndustriesPage() {
  const [industries, careers, jobRoles] = await Promise.all([
    getIndustries(),
    getCareers(),
    getJobRoles(),
  ]);

  // Reach: how many careers and roles point at each industry. Counted here
  // because `industries` itself holds only a name and is_sector -- everything
  // interesting about one is what links to it.
  const careerCounts = new Map<string, number>();
  for (const c of careers) {
    for (const s of c.relatedIndustrySlugs) careerCounts.set(s, (careerCounts.get(s) ?? 0) + 1);
  }
  const roleCounts = new Map<string, number>();
  for (const r of jobRoles) {
    for (const s of r.relatedIndustrySlugs) roleCounts.set(s, (roleCounts.get(s) ?? 0) + 1);
  }

  const sectors = industries.filter((i) => i.isSector);
  const linked = industries.filter((i) => (careerCounts.get(i.slug) ?? 0) + (roleCounts.get(i.slug) ?? 0) > 0);

  const stats = [
    { icon: "bld", tint: "bg-blue-soft text-blue", value: industries.length, label: "Industries", sub: "Sectors and employers" },
    { icon: "compass", tint: "bg-green-soft text-green", value: sectors.length, label: "Sectors", sub: "Where work happens" },
    { icon: "building", tint: "bg-purple-soft text-purple", value: industries.length - sectors.length, label: "Employers", sub: "Known to hire" },
    { icon: "target", tint: "bg-amber-soft text-amber", value: linked.length, label: "Linked", sub: "To a career or role" },
  ];

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="lg:col-span-6 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Where the Work Happens
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Industries</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Two different answers live here: the sectors a career is practised in, and the
                employers known to hire for it. Both are filterable separately.
              </p>
            </div>
            <div className="lg:col-span-3 relative min-h-[220px]">
              <SignpostPanel
                gradient="radial-gradient(circle at 60% 25%, rgba(37,99,235,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(22,163,74,0.14), transparent 60%)"
                items={sectors.slice(0, 6).map((s) => ({ href: `/industries/${s.slug}`, label: s.name }))}
              />
            </div>
            <ValuePoints points={VALUE_POINTS} className="lg:col-span-3 p-7 sm:p-10 lg:pl-0 lg:justify-center" />
          </div>
        </div>
      </Container>

      <Container className="mt-6">
        <StatsStrip stats={stats} />
      </Container>

      <Suspense fallback={null}>
        <IndustriesExplorer
          initialIndustries={industries}
          careerCounts={Object.fromEntries(careerCounts)}
          roleCounts={Object.fromEntries(roleCounts)}
        />
      </Suspense>
    </>
  );
}
