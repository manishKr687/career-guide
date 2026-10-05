import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import ResourcesExplorer from "@/components/listing/ResourcesExplorer";
import { StatsStrip, ValuePoints, SignpostPanel } from "@/components/listing/ListingKit";
import { getResources } from "@/data/resources";

export const metadata: Metadata = {
  title: "Explore Resources — CareerGuide",
  description:
    "Guides, courses, articles and official portals linked to the careers, exams and skills in this catalog.",
};

const VALUE_POINTS = [
  { icon: "book", tint: "bg-purple-soft text-purple", text: "Find material for a specific exam or skill" },
  { icon: "cap", tint: "bg-blue-soft text-blue", text: "Follow a preparation guide end to end" },
  { icon: "external", tint: "bg-green-soft text-green", text: "Go straight to the source" },
  { icon: "target", tint: "bg-amber-soft text-amber", text: "See what each one is actually for" },
];

export default async function ResourcesPage() {
  const resources = await getResources();

  const types = [...new Set(resources.map((r) => r.resourceType).filter(Boolean))];
  const withUrl = resources.filter((r) => r.contentUrl);
  const linked = resources.filter(
    (r) => r.relatedCareerSlugs.length + r.relatedExamSlugs.length + r.relatedSkillSlugs.length > 0
  );

  const stats = [
    { icon: "book", tint: "bg-purple-soft text-purple", value: resources.length, label: "Resources", sub: "In the catalog" },
    { icon: "clip", tint: "bg-blue-soft text-blue", value: types.length, label: "Types", sub: "Guide, course, article" },
    { icon: "external", tint: "bg-green-soft text-green", value: withUrl.length, label: "With a link", sub: "Straight to the source" },
    { icon: "target", tint: "bg-amber-soft text-amber", value: linked.length, label: "Linked", sub: "To a career, exam or skill" },
  ];

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="lg:col-span-6 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Where to Start Reading
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Resources</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Guides, courses, articles and official portals, each tied to the careers, exams and
                skills it actually helps with.
              </p>
            </div>
            <div className="lg:col-span-3 relative min-h-[220px]">
              <SignpostPanel
                gradient="radial-gradient(circle at 60% 25%, rgba(124,58,237,0.14), transparent 60%), radial-gradient(circle at 30% 85%, rgba(37,99,235,0.14), transparent 60%)"
                items={types.slice(0, 6).map((t) => ({
                  href: `/resources?type=${encodeURIComponent(t)}`,
                  label: t,
                }))}
              />
            </div>
            <ValuePoints
              points={VALUE_POINTS}
              className="lg:col-span-3 p-7 sm:p-10 lg:pl-0 lg:justify-center"
            />
          </div>
        </div>
      </Container>

      <Container className="mt-6">
        <StatsStrip stats={stats} />
      </Container>

      <Suspense fallback={null}>
        <ResourcesExplorer initialResources={resources} />
      </Suspense>
    </>
  );
}
