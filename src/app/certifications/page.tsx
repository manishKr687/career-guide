import { Suspense } from "react";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import CertificationsExplorer from "@/components/listing/CertificationsExplorer";
import ListingHeroSearch from "@/components/listing/ListingHeroSearch";
import { StatsStrip, ValuePoints, SignpostPanel } from "@/components/listing/ListingKit";
import { getCertifications } from "@/data/certifications";

export const metadata: Metadata = {
  title: "Explore Certifications — CareerGuide",
  description:
    "Credentials that strengthen a career or job role, with the provider, level and skills each one covers.",
};

const VALUE_POINTS = [
  { icon: "award", tint: "bg-pink-soft text-pink", text: "Find credentials that strengthen a career" },
  { icon: "gear", tint: "bg-blue-soft text-blue", text: "See the skills each one covers" },
  { icon: "clock", tint: "bg-amber-soft text-amber", text: "Compare level and time commitment" },
  { icon: "external", tint: "bg-green-soft text-green", text: "Go straight to the official page" },
];

export default async function CertificationsPage() {
  const certifications = await getCertifications();

  const providers = new Set(certifications.map((c) => c.provider).filter(Boolean));
  const levels = [...new Set(certifications.map((c) => c.level).filter(Boolean))];
  const linked = certifications.filter((c) => c.relatedCareerSlugs.length > 0);

  const stats = [
    { icon: "award", tint: "bg-pink-soft text-pink", value: certifications.length, label: "Certifications", sub: "In the catalog" },
    { icon: "building", tint: "bg-blue-soft text-blue", value: providers.size, label: "Providers", sub: "Awarding bodies" },
    { icon: "chart", tint: "bg-purple-soft text-purple", value: levels.length, label: "Levels", sub: "Beginner to expert" },
    { icon: "brief", tint: "bg-green-soft text-green", value: linked.length, label: "Career-linked", sub: "Tied to a career" },
  ];

  return (
    <>
      <Container className="pt-6">
        <div className="relative overflow-hidden rounded-3xl bg-bg-soft border border-line">
          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="lg:col-span-6 p-7 sm:p-10">
              <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
                Prove What You Can Do
              </span>
              <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[46px] leading-[1.05] tracking-tight mt-4">
                Explore <span className="text-blue">Certifications</span>
              </h1>
              <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-xl">
                Credentials that sit alongside a degree rather than replace it — what each covers,
                who awards it, and which careers it strengthens.
              </p>
              <ListingHeroSearch
                basePath="/certifications"
                anchorId="all-certifications"
                label="Search certifications"
                placeholder="Search certifications (e.g. AWS, PMP, Scrum...)"
              />
            </div>
            <div className="lg:col-span-3 relative min-h-[220px]">
              <SignpostPanel
                gradient="radial-gradient(circle at 60% 25%, rgba(219,39,119,0.13), transparent 60%), radial-gradient(circle at 30% 85%, rgba(37,99,235,0.14), transparent 60%)"
                items={levels.slice(0, 6).map((l) => ({
                  href: `/certifications?level=${encodeURIComponent(l)}`,
                  label: l,
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
        <CertificationsExplorer initialCertifications={certifications} />
      </Suspense>
    </>
  );
}
