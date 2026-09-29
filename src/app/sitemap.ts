import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/siteUrl";
import { getCareers } from "@/data/careers";
import { getSpecializations } from "@/data/specializations";
import { getJobRoles } from "@/data/jobRoles";
import { getDegrees } from "@/data/degrees";
import { getExams } from "@/data/exams";
import { getColleges } from "@/data/colleges";
import { getSkills } from "@/data/skills";
import { getIndustries } from "@/data/industries";
import { getCertifications } from "@/data/certifications";
import { getResources } from "@/data/resources";
import { getStages } from "@/data/stages";
import { getStreams } from "@/data/streams";

/**
 * The sitemap, built from the API rather than from a hand-written list.
 *
 * This catalog has around 1,550 indexable pages and no static list of them
 * could stay accurate -- every content batch would silently leave its new pages
 * out. Deriving the list means a career added through the admin is in the
 * sitemap the next time this is generated, with no one having to remember.
 *
 * LASTMODIFIED IS OMITTED WHERE IT IS NOT KNOWN, rather than filled with
 * `new Date()`. Stamping today's date on every URL is the usual shortcut and it
 * is a lie told to a crawler: it says the whole catalog changed today, every
 * day, which trains Google to distrust the field and re-crawl 1,550 pages for
 * nothing. V115 added updated_at without backfilling it for exactly this kind of
 * reason, so most rows genuinely have no date and this says so by staying quiet.
 *
 * /search, /admin, the auth pages and /profile are absent, matching robots.ts --
 * a URL disallowed there has no business being advertised here.
 */

type Dated = { slug: string; updatedAt?: string | null };

function entries(base: string, items: Dated[]): MetadataRoute.Sitemap {
  return items.map((item) => ({
    url: `${SITE_URL}${base}/${item.slug}`,
    ...(item.updatedAt ? { lastModified: new Date(item.updatedAt) } : {}),
  }));
}

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  // Each list is fetched independently with a fallback: a sitemap missing one
  // section is far better than a build that fails, or a 500 where a crawler
  // expected XML.
  const safe = <T,>(p: Promise<T[]>): Promise<T[]> => p.catch(() => [] as T[]);

  const [
    careers, specializations, jobRoles, degrees, exams, colleges,
    skills, industries, certifications, resources, stages, streams,
  ] = await Promise.all([
    safe(getCareers()), safe(getSpecializations()), safe(getJobRoles()),
    safe(getDegrees()), safe(getExams()), safe(getColleges()),
    safe(getSkills()), safe(getIndustries()), safe(getCertifications()),
    safe(getResources()), safe(getStages()), safe(getStreams()),
  ]);

  const staticPaths = [
    "/", "/careers", "/specializations", "/job-roles", "/degrees", "/exams",
    "/colleges", "/skills", "/industries", "/certifications", "/resources",
    "/categories", "/assessment", "/roadmap", "/compare", "/counselling",
  ];

  return [
    ...staticPaths.map((path) => ({ url: `${SITE_URL}${path}` })),
    ...entries("/careers", careers),
    ...entries("/specializations", specializations),
    ...entries("/job-roles", jobRoles),
    ...entries("/degrees", degrees),
    ...entries("/exams", exams),
    ...entries("/colleges", colleges),
    ...entries("/skills", skills),
    ...entries("/industries", industries),
    ...entries("/certifications", certifications),
    ...entries("/resources", resources),
    // Stages and streams predate the timestamp columns, so they carry no date.
    ...entries("/stage", stages),
    ...entries("/stream", streams),
  ];
}
