import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
import {
  Card,
  CardTitle,
  Section,
  RowCard,
  ListRow,
  MetricRow,
  HeroVisual,
  tint,
} from "@/components/detail/DetailKit";
import { getStages, getStage } from "@/data/stages";
import { getManyExams } from "@/data/exams";
import { getStreamsByStage } from "@/data/streams";

// The STAGE page: one point on the student timeline.
//
// It deliberately lists no careers. `stage.relatedCareerSlugs` still exists
// and is still editable from the admin Career form, but the section was
// removed by request -- a stage answers "what do I decide now", and the
// answer after 10th is a stream, not a career.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const stage = await getStage(slug);
  if (!stage) return {};
  return { title: `${stage.name} — CareerGuide`, description: stage.description };
}

export default async function StageDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const stage = await getStage(slug);
  if (!stage) notFound();

  const [exams, allStages, streams] = await Promise.all([
    getManyExams(stage.relatedExamSlugs),
    getStages(),
    getStreamsByStage(stage.slug),
  ]);
  const otherStages = allStages.filter((s) => s.slug !== stage.slug);

  const careersViaStreams = streams.reduce((n, s) => n + s.careerSlugs.length, 0);

  const metrics = [
    ...(streams.length > 0
      ? [{ icon: "layers", label: "Streams", value: String(streams.length) }]
      : []),
    ...(careersViaStreams > 0
      ? [{ icon: "brief", label: "Careers reachable", value: String(careersViaStreams) }]
      : []),
    ...(exams.length > 0 ? [{ icon: "doc", label: "Exams", value: String(exams.length) }] : []),
  ];

  const heroLabels = (
    streams.length > 0 ? streams.map((s) => s.name) : exams.map((e) => e.name)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[{ label: "Home", href: "/" }, { label: "Stages" }, { label: stage.name }]}
        />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span
                className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${stage.badgeSolid}`}
              >
                <Icon name={stage.icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <span className={`inline-block text-[11.5px] font-bold px-2.5 py-1 rounded-full ${stage.badgeSoft}`}>
                  Choose Your Stage
                </span>
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight mt-2">
                  {stage.name}
                </h1>
                <p className="text-ink/70 text-[15px] mt-1.5">{stage.tagline}</p>
              </div>
            </div>

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {stage.description}
            </p>

            {metrics.length > 0 && (
              <div className="mt-7">
                <MetricRow metrics={metrics} />
              </div>
            )}

            <div className="flex flex-wrap gap-3 mt-7">
              <Link
                href="/assessment"
                className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Take career assessment
              </Link>
              <Link
                href="/roadmap"
                className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
              >
                View career roadmap
              </Link>
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={stage.icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            {stage.highlights.length > 0 && (
              <Card>
                <CardTitle icon="star">What This Stage Is About</CardTitle>
                <ul className="flex flex-col gap-3">
                  {stage.highlights.map((h) => (
                    <li key={h} className="flex items-start gap-3">
                      <Icon name="check" className="w-4 h-4 text-green shrink-0 mt-0.5" />
                      <span className="text-[13.5px] text-ink/75 leading-snug">{h}</span>
                    </li>
                  ))}
                </ul>
              </Card>
            )}

            {streams.length > 0 && (
              <Section
                icon="layers"
                title="Choose Your Stream"
                subtitle="The decision this stage actually asks you to make"
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {streams.map((s, i) => (
                    <RowCard
                      key={s.slug}
                      href={`/stream/${s.slug}`}
                      icon="layers"
                      tint={tint(i)}
                      title={s.name}
                      meta={`${s.careerSlugs.length} careers · ${s.description}`}
                    />
                  ))}
                </div>
              </Section>
            )}

            {exams.length > 0 && (
              <Section icon="doc" title="Relevant Exams" viewAll={{ href: "/exams", count: exams.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {exams.map((e, i) => (
                    <RowCard
                      key={e.slug}
                      href={`/exams/${e.slug}`}
                      icon={e.icon}
                      tint={tint(i)}
                      title={e.name}
                      meta={e.fullName}
                    />
                  ))}
                </div>
              </Section>
            )}
          </div>

          <aside className="lg:col-span-4 flex flex-col gap-6">
            <Card>
              <CardTitle icon="compass">Other Stages</CardTitle>
              <ul className="flex flex-col">
                {otherStages.map((s, i) => (
                  <ListRow
                    key={s.slug}
                    href={`/stage/${s.slug}`}
                    label={s.name}
                    icon={s.icon}
                    tint={tint(i)}
                  />
                ))}
              </ul>
            </Card>

            <Card>
              <CardTitle icon="bulb">Not sure yet?</CardTitle>
              <p className="text-[13.5px] text-ink/75 leading-relaxed">
                The assessment asks a short set of questions and points at the careers that fit.
                It works from any stage.
              </p>
              <Link
                href="/assessment"
                className="inline-block mt-4 text-[13.5px] font-bold text-white bg-navy px-5 py-2.5 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Start the assessment
              </Link>
            </Card>
          </aside>
        </div>
      </Container>
    </>
  );
}
