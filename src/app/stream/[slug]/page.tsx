import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
import CareerCard from "@/components/cards/CareerCard";
import { Card, CardTitle, ListRow, MetricRow, HeroVisual, tint } from "@/components/detail/DetailKit";
import { getStream, getStreams } from "@/data/streams";
import { getManyCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";
import { getDegrees } from "@/data/degrees";
import { indexBySlug } from "@/lib/utils";

// Lowest-first, so the minimum over a career's degrees is its ENTRY level --
// the earliest point you can start, not the highest you could reach.
// Mechanical Engineering holds B.Tech, M.Tech and Diploma; the answer a
// student picking a stream needs is "Diploma", because that is the door that
// opens first. Showing "Doctoral" for anything with a PhD attached would be
// true and useless.
//
// "Certificate" is deliberately absent, so a career holding one falls through
// to its next-lowest level. The catalog has a single generic `certificate`
// degree linked to exactly one career, sports-science, alongside B.Sc.
// Ranking it lowest would badge that career "Certificate" when the real entry
// route is the bachelor's. A placeholder row should not outrank a genuine
// qualification.
const LEVEL_RANK: Record<string, number> = {
  Diploma: 0,
  Undergraduate: 1,
  Postgraduate: 2,
  Doctoral: 3,
};

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const stream = await getStream(slug);
  if (!stream) return {};
  return { title: `${stream.name} Stream — CareerGuide`, description: stream.description };
}

export default async function StreamDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ c?: string }>;
}) {
  const { slug } = await params;
  const { c } = await searchParams;
  const stream = await getStream(slug);
  if (!stream) notFound();

  // `?c=pcm` narrows to one subject combination (V97). Only Science has any;
  // the other three streams return an empty array and this is a no-op.
  //
  // An unrecognised value falls back to the whole stream rather than 404ing:
  // a stale or hand-edited link should show more than the reader asked for,
  // never an error page.
  const selected = stream.combinations.find((k) => k.slug === c) ?? null;
  const visibleSlugs = selected ? selected.careerSlugs : stream.careerSlugs;

  const [careers, categories, allStreams, degrees] = await Promise.all([
    getManyCareers(visibleSlugs),
    getCategories(),
    getStreams(),
    getDegrees(),
  ]);
  const categoriesBySlug = indexBySlug(categories);
  const degreesBySlug = indexBySlug(degrees);
  const otherStreams = allStreams.filter((s) => s.slug !== stream.slug);

  // The lowest qualification level this career can be entered at. Undefined
  // when a career has no degrees mapped -- CareerCard then renders no badge,
  // which is better than guessing.
  const entryLevelOf = (career: (typeof careers)[number]) => {
    const levels = career.education
      .map((e) => degreesBySlug.get(e.degreeSlug)?.level)
      .filter((l): l is NonNullable<typeof l> => Boolean(l));
    if (levels.length === 0) return undefined;
    return levels.reduce((lowest, l) =>
      (LEVEL_RANK[l] ?? 99) < (LEVEL_RANK[lowest] ?? 99) ? l : lowest
    );
  };

  // Group by category so a 29-career list reads as a set of fields rather
  // than one long alphabetical wall. The API already sorts careers by title,
  // so each group stays alphabetical without re-sorting here.
  const byCategory = new Map<string, typeof careers>();
  for (const career of careers) {
    const group = byCategory.get(career.categorySlug);
    if (group) group.push(career);
    else byCategory.set(career.categorySlug, [career]);
  }
  const groups = [...byCategory.entries()].sort(
    (a, b) => b[1].length - a[1].length || a[0].localeCompare(b[0])
  );

  const metrics = [
    { icon: "brief", label: selected ? `Careers with ${selected.shortName}` : "Careers", value: String(careers.length) },
    { icon: "grid", label: "Fields", value: String(groups.length) },
    ...(stream.combinations.length > 0
      ? [{ icon: "layers", label: "Subject combinations", value: String(stream.combinations.length) }]
      : []),
  ];

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "After 10th", href: "/stage/after-10th" },
            { label: stream.name },
          ]}
        />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
                <Icon name="layers" className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <span className="inline-block text-[11.5px] font-bold px-2.5 py-1 rounded-full bg-blue-soft text-blue">
                  Stream
                </span>
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight mt-2">
                  {stream.name}
                </h1>
              </div>
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {selected ? selected.description : stream.description}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            {stream.combinations.length > 0 && (
              <div className="mt-7">
                <div className="text-[12.5px] font-bold text-navy/50 uppercase tracking-wide mb-3">
                  Which subjects will you take?
                </div>
                <div className="flex flex-wrap gap-2.5">
                  <Link
                    href={`/stream/${stream.slug}`}
                    className={`text-[13px] font-bold px-4 py-2.5 rounded-xl transition-colors ${
                      selected ? "bg-white border border-line text-navy hover:border-blue/40" : "bg-navy text-white"
                    }`}
                  >
                    All ({stream.careerSlugs.length})
                  </Link>
                  {stream.combinations.map((k) => (
                    <Link
                      key={k.slug}
                      href={`/stream/${stream.slug}?c=${k.slug}`}
                      title={k.name}
                      className={`text-[13px] font-bold px-4 py-2.5 rounded-xl transition-colors ${
                        selected?.slug === k.slug
                          ? "bg-navy text-white"
                          : "bg-white border border-line text-navy hover:border-blue/40"
                      }`}
                    >
                      {k.shortName} ({k.careerSlugs.length})
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="lg:col-span-5">
            <HeroVisual
              icon="layers"
              labels={groups.slice(0, 5).map(([s]) => categoriesBySlug.get(s)?.name ?? s)}
            />
          </div>
        </div>
      </Container>

      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-9 flex flex-col gap-10">
            {groups.map(([categorySlug, group]) => (
              <section key={categorySlug}>
                <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[19px] mb-4">
                  <Icon
                    name={categoriesBySlug.get(categorySlug)?.icon ?? "grid"}
                    className="w-[21px] h-[21px] text-blue shrink-0"
                  />
                  {categoriesBySlug.get(categorySlug)?.name ?? categorySlug}
                  <span className="text-[13px] font-semibold text-muted">{group.length}</span>
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
                  {group.map((career) => (
                    <CareerCard
                      key={career.slug}
                      career={career}
                      category={categoriesBySlug.get(career.categorySlug)}
                      degreeLabel={entryLevelOf(career)}
                    />
                  ))}
                </div>
              </section>
            ))}
          </div>

          <aside className="lg:col-span-3 flex flex-col gap-6">
            <Card>
              <CardTitle icon="compass">Other Streams</CardTitle>
              <ul className="flex flex-col">
                {otherStreams.map((s, i) => (
                  <ListRow
                    key={s.slug}
                    href={`/stream/${s.slug}`}
                    label={`${s.name} · ${s.careerSlugs.length}`}
                    icon="layers"
                    tint={tint(i)}
                  />
                ))}
              </ul>
            </Card>

            <Card>
              <CardTitle icon="bulb">Still deciding?</CardTitle>
              <p className="text-[13.5px] text-ink/75 leading-relaxed">
                Your stream is the first real fork after 10th, and it narrows what you can enter
                later. The assessment can suggest which of the four fits.
              </p>
              <Link
                href="/assessment"
                className="inline-block mt-4 text-[13.5px] font-bold text-white bg-navy px-5 py-2.5 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Take the assessment
              </Link>
            </Card>
          </aside>
        </div>
      </Container>
    </>
  );
}
