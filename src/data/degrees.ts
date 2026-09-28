import { Career, Degree } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlug } from "@/lib/api";

export async function getDegrees(): Promise<Degree[]> {
  return apiGet<Degree[]>("/api/degrees");
}

export async function getDegree(slug: string): Promise<Degree | undefined> {
  const degree = await apiGetOptional<Degree>(`/api/degrees/${encodeURIComponent(slug)}`);
  return degree ?? undefined;
}

export async function getManyDegrees(slugs: string[]): Promise<Degree[]> {
  return fetchManyBySlug(slugs, getDegree);
}

/**
 * Degree now has a real many-to-many relation to Career (career_degrees,
 * added in V51 -- see Career.relatedDegreeSlugs's doc comment in
 * lib/types.ts) but it's deliberately incomplete: it's only populated
 * where a degree in this 10-type catalog is a clean, direct entry path
 * for that discipline, and several disciplines have none (see V51's
 * migration comment for the full per-discipline reasoning). This function
 * is the fallback for exactly those -- a computed but grounded relevance
 * signal based on shared entrance exams (Career.relatedExamSlugs and
 * Degree.entranceExamSlugs are both proper relations to Exam), not a
 * plain-text title/name guess, which this codebase deliberately avoids
 * elsewhere (see V16's migration comment).
 *
 * Exam coverage in degree_exams (V44) is intentionally partial -- only
 * ~9 of the ~10 degree types have any exams at all, and only a handful of
 * exam slugs (JEE/BITSAT, CUET, CAT, CTET, UGC-NET/CSIR-NET, polytechnic
 * CET) are used across all of them -- so this can legitimately return an
 * empty list for a career whose own exams (CLAT, NEET, UPSC, IBPS, ...)
 * aren't in that set. Callers should fall back to showing everything
 * rather than a dead-end empty page in that case (see /degrees/page.tsx).
 */
export function filterDegreesRelevantToCareer(
  degrees: Degree[],
  career: Pick<Career, "relatedExamSlugs">
): Degree[] {
  const careerExamSlugs = new Set(career.relatedExamSlugs);
  return degrees.filter((d) => d.entranceExamSlugs.some((examSlug) => careerExamSlugs.has(examSlug)));
}
