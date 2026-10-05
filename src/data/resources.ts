import { Resource } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getResources(): Promise<Resource[]> {
  return apiGet<Resource[]>("/api/resources");
}

export async function getResource(slug: string): Promise<Resource | undefined> {
  const resource = await apiGetOptional<Resource>(`/api/resources/${encodeURIComponent(slug)}`);
  return resource ?? undefined;
}

export async function getManyResources(slugs: string[]): Promise<Resource[]> {
  return fetchManyBySlugChunked(slugs, "/api/resources");
}

// Same reverse-relation situation as getCertificationsByCareer: Resource
// stores relatedCareerSlugs, but Career has no relatedResourceSlugs back and
// there's no backend filter param for it. Fetching all and filtering here
// is fine at this scale, and a no-op today since the table has no seeded
// rows yet.
export async function getResourcesByCareer(careerSlug: string): Promise<Resource[]> {
  const resources = await getResources();
  return resources.filter((r) => r.relatedCareerSlugs.includes(careerSlug));
}
