import { Career, College } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";
import { getManyCareers } from "@/data/careers";
import { getManyDegrees } from "@/data/degrees";

export async function getColleges(filters?: {
  type?: string;
  q?: string;
  // degree/discipline/state added in V53 (College MVP).
  degree?: string;
  discipline?: string;
  state?: string;
}): Promise<College[]> {
  return apiGet<College[]>("/api/colleges", {
    type: filters?.type,
    q: filters?.q,
    degree: filters?.degree,
    discipline: filters?.discipline,
    state: filters?.state,
  });
}

export async function getCollege(slug: string): Promise<College | undefined> {
  const college = await apiGetOptional<College>(`/api/colleges/${encodeURIComponent(slug)}`);
  return college ?? undefined;
}

export async function getManyColleges(slugs: string[]): Promise<College[]> {
  return fetchManyBySlugChunked(slugs, "/api/colleges");
}

// Resolves a college's careerOfferings (career+degree slug pairs, V55)
// into display-ready data for CareerCard: one entry per career, with all of
// that career's degrees at this college combined into a single label (e.g.
// "B.Tech · M.Tech"). This is where the "which degree(s) apply" business
// logic lives, so CareerCard itself only ever renders a plain string.
export async function getCollegeCareerOfferings(
  college: College
): Promise<{ career: Career; degreeLabel: string }[]> {
  const careerSlugs = Array.from(new Set(college.careerOfferings.map((o) => o.careerSlug)));
  const degreeSlugs = Array.from(new Set(college.careerOfferings.map((o) => o.degreeSlug)));
  const [careers, degrees] = await Promise.all([getManyCareers(careerSlugs), getManyDegrees(degreeSlugs)]);
  const careersBySlug = new Map(careers.map((c) => [c.slug, c]));
  const degreesBySlug = new Map(degrees.map((d) => [d.slug, d]));

  const degreeTitlesByCareer = new Map<string, string[]>();
  for (const offering of college.careerOfferings) {
    const degree = degreesBySlug.get(offering.degreeSlug);
    if (!degree) continue;
    const titles = degreeTitlesByCareer.get(offering.careerSlug) ?? [];
    titles.push(degree.title);
    degreeTitlesByCareer.set(offering.careerSlug, titles);
  }

  const result: { career: Career; degreeLabel: string }[] = [];
  for (const [careerSlug, degreeTitles] of degreeTitlesByCareer) {
    const career = careersBySlug.get(careerSlug);
    if (!career) continue;
    result.push({ career, degreeLabel: degreeTitles.join(" · ") });
  }
  return result;
}
