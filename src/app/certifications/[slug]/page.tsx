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
import { getCertification, getCertifications } from "@/data/certifications";
import { getManyCareers } from "@/data/careers";
import { getManySkills } from "@/data/skills";
import { getJobRoles } from "@/data/jobRoles";

// The CERTIFICATION page.
//
// A certification sits alongside a qualification rather than replacing one,
// so the page's job is to say what it covers, who awards it, and which
// careers and roles it strengthens. Everything on it is either a stored field
// or a reverse lookup -- nothing is inferred.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const certification = await getCertification(slug);
  if (!certification) return {};
  return { title: `${certification.name} — CareerGuide`, description: certification.description };
}

export default async function CertificationDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const certification = await getCertification(slug);
  if (!certification) notFound();

  const [careers, skills, jobRoles, allCertifications] = await Promise.all([
    getManyCareers(certification.relatedCareerSlugs),
    getManySkills(certification.relatedSkillSlugs),
    getJobRoles(),
    getCertifications(),
  ]);

  // JobRole owns the relation (V72), so the "which roles value this" direction
  // has to be computed rather than read off the certification.
  const valuingRoles = jobRoles.filter((r) =>
    r.relatedCertificationSlugs.includes(certification.slug)
  );

  const siblings = allCertifications
    .filter(
      (c) =>
        c.slug !== certification.slug &&
        (c.provider === certification.provider || c.level === certification.level)
    )
    .slice(0, 6);

  const metrics = [
    ...(certification.level ? [{ icon: "chart", label: "Level", value: certification.level }] : []),
    ...(certification.duration
      ? [{ icon: "clock", label: "Duration", value: certification.duration }]
      : []),
    ...(skills.length > 0 ? [{ icon: "gear", label: "Skills", value: String(skills.length) }] : []),
    ...(careers.length > 0
      ? [{ icon: "brief", label: "Careers", value: String(careers.length) }]
      : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    ...(certification.provider
      ? [{ icon: "building", label: "Provider", value: certification.provider }]
      : []),
    ...(certification.level ? [{ icon: "chart", label: "Level", value: certification.level }] : []),
    ...(certification.duration
      ? [{ icon: "clock", label: "Duration", value: certification.duration }]
      : []),
    ...(skills.length > 0
      ? [{ icon: "gear", label: "Skills covered", value: String(skills.length) }]
      : []),
    ...(careers.length > 0
      ? [{ icon: "brief", label: "Careers", value: `${careers.length} strengthened` }]
      : []),
    ...(valuingRoles.length > 0
      ? [{ icon: "user", label: "Job roles", value: `${valuingRoles.length} value it` }]
      : []),
    ...(certification.officialUrl
      ? [
          {
            icon: "external",
            label: "Official page",
            value: (
              <a
                href={certification.officialUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue hover:underline"
              >
                Visit site
              </a>
            ),
          },
        ]
      : []),
  ];

  const heroLabels = (
    skills.length >= 3 ? skills.map((s) => s.name) : careers.map((c) => c.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Certifications", href: "/certifications" },
            { label: certification.name },
          ]}
        />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className="w-14 h-14 rounded-2xl bg-pink-soft text-pink flex items-center justify-center shrink-0">
                <Icon name="award" className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {certification.name}
                </h1>
                {certification.provider && (
                  <p className="text-ink/70 text-[15px] font-semibold mt-1.5">
                    {certification.provider}
                  </p>
                )}
              </div>
            </div>

            {certification.description && (
              <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
                {certification.description}
              </p>
            )}

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>

            {certification.officialUrl && (
              <a
                href={certification.officialUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 mt-7 text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
              >
                Official page
                <Icon name="external" className="w-3.5 h-3.5" />
              </a>
            )}
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon="award" labels={heroLabels} />
          </div>
        </div>
      </Container>

      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            {certification.description && (
              <Card>
                <CardTitle icon="doc">About This Certification</CardTitle>
                <p className="text-[14px] text-ink/75 leading-relaxed">{certification.description}</p>
              </Card>
            )}

            {skills.length > 0 && (
              <Card>
                <CardTitle icon="gear" viewAll={{ href: "/skills", count: skills.length }}>
                  Skills It Covers
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

            {careers.length > 0 && (
              <Section icon="brief" title="Careers It Strengthens" viewAll={{ href: "/careers", count: careers.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {careers.map((c, i) => (
                    <RowCard key={c.slug} href={`/careers/${c.slug}`} icon={c.icon} tint={tint(i)} title={c.title} meta={c.tagline} />
                  ))}
                </div>
              </Section>
            )}

            {valuingRoles.length > 0 && (
              <Section icon="user" title="Job Roles That Value It" viewAll={{ href: "/job-roles", count: valuingRoles.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {valuingRoles.slice(0, 6).map((r, i) => (
                    <RowCard key={r.slug} href={`/job-roles/${r.slug}`} icon="user" tint={tint(i)} title={r.name} meta={r.experienceLevel || undefined} />
                  ))}
                </div>
              </Section>
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
                    <dt className="text-[13px] text-muted w-[42%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">{g.value}</dd>
                  </div>
                ))}
              </dl>
            </Card>

            {siblings.length > 0 && (
              <Card>
                <CardTitle icon="compass" subtitle="Same provider or same level">
                  Compare With
                </CardTitle>
                <ul className="flex flex-col">
                  {siblings.map((c, i) => (
                    <ListRow key={c.slug} href={`/certifications/${c.slug}`} label={c.name} icon="award" tint={tint(i)} />
                  ))}
                </ul>
              </Card>
            )}
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link href="/certifications" className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors">
            Browse all certifications
          </Link>
          <Link href="/skills" className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors">
            Explore skills
          </Link>
        </div>
      </Container>
    </>
  );
}
