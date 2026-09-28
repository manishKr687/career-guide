import Link from "next/link";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
import { Card, CardTitle, MetricRow, tint } from "@/components/detail/DetailKit";
import { StatsStrip } from "@/components/listing/ListingKit";
import { getCategories } from "@/data/categories";
import { getCareers } from "@/data/careers";
import { getDegrees } from "@/data/degrees";
import { getExams } from "@/data/exams";
import { getSpecializations } from "@/data/specializations";

export const metadata: Metadata = {
  title: "Career Categories — CareerGuide",
  description:
    "The 20 fields every career, degree and exam in this catalog is filed under, and how much sits behind each.",
};

// The CATEGORY index. No filters and no search: 20 rows on one screen is
// already browsable, and a facet over 20 items is furniture rather than help.
//
// Each card's counts are the point -- a category with nothing behind it is
// worth seeing as such, and four of them are in exactly that state.

export default async function CategoriesPage() {
  const [categories, careers, degrees, exams, specializations] = await Promise.all([
    getCategories(),
    getCareers(),
    getDegrees(),
    getExams(),
    getSpecializations(),
  ]);

  const careerBySlug = new Map(careers.map((c) => [c.slug, c]));

  const careerCounts = new Map<string, number>();
  for (const c of careers) careerCounts.set(c.categorySlug, (careerCounts.get(c.categorySlug) ?? 0) + 1);

  const degreeCounts = new Map<string, number>();
  for (const d of degrees) {
    if (d.categorySlug) degreeCounts.set(d.categorySlug, (degreeCounts.get(d.categorySlug) ?? 0) + 1);
  }

  const examCounts = new Map<string, number>();
  for (const e of exams) {
    if (e.categorySlug) examCounts.set(e.categorySlug, (examCounts.get(e.categorySlug) ?? 0) + 1);
  }

  // A specialization has no category of its own -- it inherits its parent
  // career's, the same rule the specializations listing uses.
  const specCounts = new Map<string, number>();
  for (const s of specializations) {
    const fields = new Set<string>();
    for (const slug of s.careerSlugs) {
      const c = careerBySlug.get(slug);
      if (c) fields.add(c.categorySlug);
    }
    for (const f of fields) specCounts.set(f, (specCounts.get(f) ?? 0) + 1);
  }

  const totalOf = (slug: string) =>
    (careerCounts.get(slug) ?? 0) +
    (degreeCounts.get(slug) ?? 0) +
    (examCounts.get(slug) ?? 0) +
    (specCounts.get(slug) ?? 0);

  const ranked = [...categories].sort((a, b) => totalOf(b.slug) - totalOf(a.slug) || a.name.localeCompare(b.name));
  const populated = ranked.filter((c) => totalOf(c.slug) > 0);
  const empty = ranked.filter((c) => totalOf(c.slug) === 0);

  const stats = [
    { icon: "grid", tint: "bg-blue-soft text-blue", value: categories.length, label: "Categories", sub: "The full taxonomy" },
    { icon: "brief", tint: "bg-purple-soft text-purple", value: careers.length, label: "Careers", sub: "Filed across them" },
    { icon: "cap", tint: "bg-green-soft text-green", value: degrees.length, label: "Degrees", sub: "Filed across them" },
    { icon: "target", tint: "bg-amber-soft text-amber", value: populated.length, label: "In use", sub: `${empty.length} still empty` },
  ];

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb items={[{ label: "Home", href: "/" }, { label: "Categories" }]} />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          <div className="lg:col-span-8">
            <span className="inline-block text-[12px] font-bold px-3.5 py-1.5 rounded-full bg-blue-soft text-blue">
              One Taxonomy, Everywhere
            </span>
            <h1 className="font-display font-extrabold text-navy text-[36px] sm:text-[44px] leading-[1.05] tracking-tight mt-4">
              Career <span className="text-blue">Categories</span>
            </h1>
            <p className="text-ink/70 text-[15px] leading-relaxed mt-3 max-w-2xl">
              Careers, degrees and exams are all filed under the same 20 fields, so browsing works
              from any entry point. Specializations and job roles inherit theirs from the career
              they sit under.
            </p>
            <div className="mt-7">
              <MetricRow
                metrics={[
                  { icon: "grid", label: "Categories", value: String(categories.length) },
                  { icon: "target", label: "In use", value: String(populated.length) },
                  { icon: "layers", label: "Specializations", value: String(specializations.length) },
                ]}
              />
            </div>
          </div>
        </div>
      </Container>

      <Container className="mt-8">
        <StatsStrip stats={stats} />
      </Container>

      <Container className="mt-10 pb-24">
        <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px] mb-1.5">
          <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
          All Categories
        </h2>
        <p className="text-[13px] text-muted mb-6">Largest first, by everything filed under each.</p>

        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
          {populated.map((cat) => (
            <Link
              key={cat.slug}
              href={`/careers?category=${cat.slug}`}
              className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
            >
              <div className="flex items-start gap-3.5 p-5 pb-3">
                <span className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${cat.color}`}>
                  <Icon name={cat.icon} className="w-6 h-6" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="flex items-start justify-between gap-2">
                    <span className="font-display font-bold text-navy text-[16px] leading-snug">
                      {cat.name}
                    </span>
                    <Icon
                      name="chevRight"
                      className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
                    />
                  </span>
                  <span className="block text-[12px] text-muted mt-1">
                    {totalOf(cat.slug)} entries in total
                  </span>
                </span>
              </div>
              <div className="mt-2 px-5 py-3.5 border-t border-line bg-bg-soft flex items-center gap-4 text-[12px]">
                <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                  <Icon name="brief" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  {careerCounts.get(cat.slug) ?? 0} careers
                </span>
                <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                  <Icon name="cap" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  {degreeCounts.get(cat.slug) ?? 0} degrees
                </span>
                <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                  <Icon name="doc" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  {examCounts.get(cat.slug) ?? 0} exams
                </span>
              </div>
            </Link>
          ))}
        </div>

        {/* Shown rather than hidden: an empty category is a real state of the
            catalog, and quietly dropping it would make the taxonomy look
            fuller than it is. */}
        {empty.length > 0 && (
          <Card className="mt-8">
            <CardTitle icon="compass" subtitle="In the taxonomy, but nothing is filed under them yet">
              Not yet used
            </CardTitle>
            <div className="flex flex-wrap gap-2">
              {empty.map((cat, i) => (
                <span
                  key={cat.slug}
                  className={`inline-flex items-center gap-2 text-[12.5px] font-semibold px-3.5 py-2 rounded-full ${tint(i)}`}
                >
                  <Icon name={cat.icon} className="w-3.5 h-3.5" />
                  {cat.name}
                </span>
              ))}
            </div>
          </Card>
        )}

        <div className="flex flex-wrap gap-3 mt-10">
          <Link
            href="/careers"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Browse all careers
          </Link>
          <Link
            href="/degrees"
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Browse all degrees
          </Link>
        </div>
      </Container>
    </>
  );
}
