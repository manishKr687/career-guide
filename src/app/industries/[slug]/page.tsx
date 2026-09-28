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
  dedupe,
  tint,
} from "@/components/detail/DetailKit";
import { getIndustry, getIndustries } from "@/data/industries";
import { getCareers } from "@/data/careers";
import { getJobRoles } from "@/data/jobRoles";
import { getSpecializations } from "@/data/specializations";
import { getCategories } from "@/data/categories";
import { indexBySlug } from "@/lib/utils";

// The INDUSTRY page.
//
// `industries` holds a name and `is_sector` and nothing else, so like the
// skill page this is built entirely from REVERSE lookups -- the careers, job
// roles and specializations that point at it.
//
// The two kinds are genuinely different questions and the page says which one
// it is answering: a SECTOR is where work happens ("Healthcare"), an EMPLOYER
// is who hires ("Apollo Hospitals"). One table, one boolean, two meanings --
// which is exactly why `is_sector` exists.

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const industry = await getIndustry(slug);
  if (!industry) return {};
  return {
    title: `${industry.name} — CareerGuide`,
    description: `The careers and job roles linked to ${industry.name}.`,
  };
}

export default async function IndustryDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const industry = await getIndustry(slug);
  if (!industry) notFound();

  const [careers, jobRoles, specializations, allIndustries, categories] = await Promise.all([
    getCareers(),
    getJobRoles(),
    getSpecializations(),
    getIndustries(),
    getCategories(),
  ]);

  const categoriesBySlug = indexBySlug(categories);

  const usingCareers = careers.filter((c) => c.relatedIndustrySlugs.includes(industry.slug));
  const usingRoles = jobRoles.filter((r) => r.relatedIndustrySlugs.includes(industry.slug));
  const usingSpecializations = specializations.filter((s) =>
    s.industrySlugs.includes(industry.slug)
  );

  const fieldSlugs = dedupe(usingCareers.map((c) => c.categorySlug));
  const fields = fieldSlugs.map((s) => categoriesBySlug.get(s)).filter((c) => c);

  // Industries that turn up alongside this one -- same careers, same kind.
  const coOccurring = dedupe(
    usingCareers.flatMap((c) => c.relatedIndustrySlugs).filter((s) => s !== industry.slug)
  );
  const related = allIndustries
    .filter((i) => coOccurring.includes(i.slug) && i.isSector === industry.isSector)
    .slice(0, 8);

  const kind = industry.isSector ? "Sector" : "Employer";
  const kindIcon = industry.isSector ? "compass" : "building";
  const kindTint = industry.isSector ? "bg-blue-soft text-blue" : "bg-purple-soft text-purple";

  const metrics = [
    { icon: kindIcon, label: "Kind", value: kind },
    ...(usingCareers.length > 0
      ? [{ icon: "brief", label: "Careers", value: String(usingCareers.length) }]
      : []),
    ...(usingRoles.length > 0
      ? [{ icon: "user", label: "Job Roles", value: String(usingRoles.length) }]
      : []),
    ...(fields.length > 0 ? [{ icon: "grid", label: "Fields", value: String(fields.length) }] : []),
  ];

  const glance: { icon: string; label: string; value: React.ReactNode }[] = [
    { icon: kindIcon, label: "Kind", value: kind },
    { icon: "brief", label: "Careers", value: `${usingCareers.length} linked` },
    { icon: "user", label: "Job roles", value: `${usingRoles.length} linked` },
    ...(usingSpecializations.length > 0
      ? [{ icon: "layers", label: "Specializations", value: `${usingSpecializations.length} linked` }]
      : []),
    ...(fields.length > 0
      ? [{ icon: "compass", label: "Fields", value: fields.map((f) => f!.name).join(", ") }]
      : []),
  ];

  const heroLabels = (
    usingRoles.length >= 3 ? usingRoles.map((r) => r.name) : usingCareers.map((c) => c.title)
  ).slice(0, 5);

  return (
    <>
      <Container className="pt-5">
        <Breadcrumb
          items={[
            { label: "Home", href: "/" },
            { label: "Industries", href: "/industries" },
            { label: industry.name },
          ]}
        />
      </Container>

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 items-center">
          <div className="lg:col-span-7">
            <div className="flex items-start gap-4">
              <span className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${kindTint}`}>
                <Icon name={kindIcon} className="w-7 h-7" />
              </span>
              <div className="min-w-0">
                <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[42px] leading-[1.08] tracking-tight">
                  {industry.name}
                </h1>
                <p className="text-ink/70 text-[15px] mt-1.5">
                  {industry.isSector
                    ? "A sector — where this kind of work happens"
                    : "An employer — an organisation known to hire"}
                </p>
              </div>
            </div>

            {fields.length > 0 && (
              <div className="flex flex-wrap items-center gap-2.5 mt-5">
                {fields.slice(0, 5).map((f, i) => (
                  <Link
                    key={f!.slug}
                    href={`/careers?category=${f!.slug}`}
                    className={`text-[13px] font-semibold px-4 py-2 rounded-full transition-opacity hover:opacity-80 ${tint(i)}`}
                  >
                    {f!.name}
                  </Link>
                ))}
              </div>
            )}

            <p className="text-ink/70 text-[14.5px] leading-relaxed mt-5 max-w-2xl">
              {`${industry.name} is linked to ${usingCareers.length} career${usingCareers.length === 1 ? "" : "s"} and ${usingRoles.length} job role${usingRoles.length === 1 ? "" : "s"} in this catalog.`}
            </p>

            <div className="mt-7">
              <MetricRow metrics={metrics} />
            </div>
          </div>

          <div className="lg:col-span-5">
            <HeroVisual icon={kindIcon} labels={heroLabels} />
          </div>
        </div>
      </Container>

      <Container className="mt-12 pb-24">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 flex flex-col gap-6">
            {usingCareers.length > 0 && (
              <Section icon="brief" title="Careers Linked Here" viewAll={{ href: "/careers", count: usingCareers.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingCareers.slice(0, 9).map((c, i) => (
                    <RowCard key={c.slug} href={`/careers/${c.slug}`} icon={c.icon} tint={tint(i)} title={c.title} meta={c.tagline} />
                  ))}
                </div>
              </Section>
            )}

            {usingRoles.length > 0 && (
              <Section icon="user" title="Job Roles Linked Here" viewAll={{ href: "/job-roles", count: usingRoles.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingRoles.slice(0, 9).map((r, i) => (
                    <RowCard key={r.slug} href={`/job-roles/${r.slug}`} icon="user" tint={tint(i)} title={r.name} meta={r.experienceLevel || undefined} />
                  ))}
                </div>
              </Section>
            )}

            {usingSpecializations.length > 0 && (
              <Section icon="layers" title="Specializations Applied Here" viewAll={{ href: "/specializations", count: usingSpecializations.length }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                  {usingSpecializations.slice(0, 6).map((s, i) => (
                    <RowCard key={s.slug} href={`/specializations/${s.slug}`} icon={s.icon} tint={tint(i)} title={s.name} />
                  ))}
                </div>
              </Section>
            )}

            {usingCareers.length === 0 && usingRoles.length === 0 && usingSpecializations.length === 0 && (
              <Card>
                <CardTitle icon="compass">Nothing links here yet</CardTitle>
                <p className="text-[13.5px] text-ink/75 leading-relaxed">
                  {industry.name} is in the catalog but no career, job role or specialization points
                  at it. That is a content gap rather than a fact about the industry.
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
                    <dt className="text-[13px] text-muted w-[42%] shrink-0">{g.label}</dt>
                    <dd className="text-[13px] font-semibold text-ink/85 flex-1 min-w-0">{g.value}</dd>
                  </div>
                ))}
              </dl>
            </Card>

            {related.length > 0 && (
              <Card>
                <CardTitle icon="compass" subtitle={`Other ${kind.toLowerCase()}s the same careers point at`}>
                  Often Alongside
                </CardTitle>
                <ul className="flex flex-col">
                  {related.map((i, n) => (
                    <ListRow key={i.slug} href={`/industries/${i.slug}`} label={i.name} icon={kindIcon} tint={tint(n)} />
                  ))}
                </ul>
              </Card>
            )}
          </aside>
        </div>

        <div className="flex flex-wrap gap-3 mt-10">
          <Link href="/industries" className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors">
            Browse all industries
          </Link>
          <Link href="/careers" className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors">
            Explore careers
          </Link>
        </div>
      </Container>
    </>
  );
}
