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
  Pill,
  MetricRow,
  HeroVisual,
  tint,
} from "@/components/detail/DetailKit";
import { getResource, getResources } from "@/data/resources";
import { getManyCareers } from "@/data/careers";
import { getManyExams } from "@/data/exams";
import { getManySkills } from "@/data/skills";
import { getDegrees } from "@/data/degrees";
import { getSpecializations } from "@/data/specializations";
import { formatDate } from "@/lib/utils";

// The RESOURCE page.
//
// A resource is only useful in relation to something, so the page is mostly
// its links: the careers, exams, skills, degrees and specializations it helps
// with. Degrees and specializations own their side of that relation, so those
// two directions are computed here rather than read off the resource.

const TYPE_ICONS: Record<string, string> = {
  Article: "doc",
  Guide: "book",
  Website: "external",
  Course: "cap",
  Video: "monitor",
  PDF: "doc",
};

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const resource = await getResource(slug);
  if (!resource) return {};
  return { title: `${resource.title} — CareerGuide`, description: resource.description };
}

export default async function ResourceDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const resource = await getResource(slug);
  if (!resource) notFound();

  const [careers, exams, skills, degrees, specializations, allResources] = await Promise.all([
    getManyCareers(resource.relatedCareerSlugs),
    getManyExams(resource.relatedExamSlugs),
    getManySkills(resource.relatedSkillSlugs),
    getDegrees(),
    getSpecializations(),
    getResources(),
  ]);

  const forDegrees = degrees.filter((d) => d.resourceSlugs.includes(resource.slug));
  const forSpecializations = specializations.filter((s) => s.resourceSlugs.includes(resource.slug));

  const siblings = allResources
    .filter((r) => r.slug !== resource.slug && r.resourceType === resource.resourceType)
    .slice(0, 6);

  const totalLinks =
    careers.length + exams.length + skills.length + forDegrees.length + forSpecializations.length;

  const icon = TYPE_ICONS[resource.resourceType] ?? "doc";

  const metrics = [
    ...(resource.resourceType ? [{ icon, label: "Type", value: resource.resourceType }] : []),
    ...(resource.author ? [{ icon: "building", label: "By", value: resource.author }] : []),
    ...(totalLinks > 0 ? [{ icon: "target", label: "Linked to", value: String(totalLinks) }] : []),
    ...(resource.publishedAt
      ? [{ icon: "cal", label: "Published", value: formatDate(resource.publishedAt) }]
      : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    ...(resource.resourceType ? [{ icon, label: "Type", value: resource.resourceType }] : []),
    ...(resource.author ? [{ icon: "building", label: "Author", value: resource.author }] : []),
    ...(resource.publishedAt
      ? [{ icon: "cal", label: "Published", value: formatDate(resource.publishedAt) }]
      : []),
    ...(careers.length > 0 ? [{ icon: "brief", label: "Careers", value: String(careers.length) }] : []),
    ...(exams.length > 0 ? [{ icon: "doc", label: "Exams", value: String(exams.length) }] : []),
    ...(skills.length > 0 ? [{ icon: "gear", label: "Skills", value: String(skills.length) }] : []),
    ...(resource.contentUrl
      ? [
          {
            icon: "external",
            label: "Link",
            value: (
              <a
                href={resource.contentUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue hover:underline break-all"
              >
                Open resource
              </a>
            ),
          },
        ]
      : []),
  ];

  const heroLabels = (
    skills.length >= 3
      ? skills.map((s) => s.name)
      : [...exams.map((e) => e.name), ...careers.map((c) => c.title)]
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Resources", href: "/resources" },
            { label: resource.title },
          ]}
        />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-purple-soft text-purple flex items-center justify-center shrink-0">
                <Icon name={icon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[30px] sm:text-[38px] leading-[1.1] tracking-tight">
                  {resource.title}
                </h1>
                {resource.author && (
                  <p className="text-ink/70 text-[15px] font-semibold mt-1.5">{resource.author}</p>
                )}
              </div>
            </div>

            {resource.description && (
              <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
                {resource.description}
              </p>
            )}

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            {resource.contentUrl && (
              <a
                href={resource.contentUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 mt-7 text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Open resource
                <Icon name="external" className="w-3.5 h-3.5" />
              </a>
            )}
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={icon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            {resource.description && (
              <Card>
                <CardTitle icon="doc">What This Covers</CardTitle>
                <p className="text-[14px] text-ink/75 leading-relaxed">{resource.description}</p>
              </Card>
            )}

            {exams.length > 0 && (
              <Section icon="doc" title="Exams It Helps With" viewAll={{ href: "/exams", count: exams.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {exams.map((e, i) => (
                    <RowCard key={e.slug} href={`/exams/${e.slug}`} icon={e.icon} tint={tint(i)} title={e.name} meta={e.fullName} />
                  ))}
                </div>
              </Section>
            )}

            {careers.length > 0 && (
              <Section icon="brief" title="Careers It Helps With" viewAll={{ href: "/careers", count: careers.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {careers.map((c, i) => (
                    <RowCard key={c.slug} href={`/careers/${c.slug}`} icon={c.icon} tint={tint(i)} title={c.title} meta={c.tagline} />
                  ))}
                </div>
              </Section>
            )}

            {(forDegrees.length > 0 || forSpecializations.length > 0) && (
              <Section icon="cap" title="Also Listed Under">
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {forDegrees.map((d, i) => (
                    <RowCard key={d.slug} href={`/degrees/${d.slug}`} icon={d.icon} tint={tint(i)} title={d.title} meta={d.fullTitle ?? d.level} />
                  ))}
                  {forSpecializations.map((s, i) => (
                    <RowCard key={s.slug} href={`/specializations/${s.slug}`} icon={s.icon} tint={tint(i + forDegrees.length)} title={s.name} />
                  ))}
                </div>
              </Section>
            )}

            {skills.length > 0 && (
              <Card>
                <CardTitle icon="gear" viewAll={{ href: "/skills", count: skills.length }}>
                  Skills It Builds
                </CardTitle>
                <div className="flex flex-wrap gap-2">
                  {skills.map((s, i) => (
                    <Pill key={s.slug} href={`/skills/${s.slug}`} tint={tint(i)}>
                      {s.name}
                    </Pill>
                  ))}
                </div>
              </Card>
            )}

            {totalLinks === 0 && (
              <Card>
                <CardTitle icon="target">Not linked yet</CardTitle>
                <p className="text-[13.5px] text-ink/75 leading-relaxed">
                  This resource is in the catalog but nothing points at it yet. A resource is most
                  useful next to the career, exam or skill it helps with, so that is a content gap
                  worth closing.
                </p>
              </Card>
            )}
          </div>

          <aside className="lg:col-span-4 flex flex-col gap-6">
            <Card>
              <CardTitle icon="chart">At a Glance</CardTitle>
              <dl className="flex flex-col">
                {glance.map((g) => (
                  <div key={g.label} className="flex items-start gap-3 py-3 border-b border-line last:border-0">
                    <span className="w-7 h-7 rounded-lg bg-bg-soft text-navy flex items-center justify-center shrink-0">
                      <Icon name={g.icon} className="w-3.5 h-3.5" />
                    </span>
                    <dt className="text-[13px] text-muted w-[40%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">{g.value}</dd>
                  </div>
                ))}
              </dl>
            </Card>

            {siblings.length > 0 && (
              <Card>
                <CardTitle icon="compass" subtitle={`Other ${resource.resourceType.toLowerCase()}s`}>
                  More Like This
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((r, i) => (
                    <ListRow key={r.slug} href={`/resources/${r.slug}`} label={r.title} icon={icon} tint={tint(i)} />
                  ))}
                </ul>
              </Card>
            )}
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link href="/resources" className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors">
            Browse all resources
          </Link>
          <Link href="/exams" className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors">
            Explore exams
          </Link>
        </div>
      </Container>
    </>
  );
}
