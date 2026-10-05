import { Career } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getCareers(filters?: { category?: string; q?: string }): Promise<Career[]> {
  return apiGet<Career[]>("/api/careers", { category: filters?.category, q: filters?.q });
}

export async function getCareer(slug: string): Promise<Career | undefined> {
  const career = await apiGetOptional<Career>(`/api/careers/${encodeURIComponent(slug)}`);
  return career ?? undefined;
}

export async function getCareersByCategory(categorySlug: string): Promise<Career[]> {
  return getCareers({ category: categorySlug });
}

export async function getManyCareers(slugs: string[]): Promise<Career[]> {
  return fetchManyBySlugChunked(slugs, "/api/careers");
}

// Skill -> careers is a reverse relation: careers store `relatedSkillSlugs`,
// but skills don't store which careers use them, and there's no backend
// filter param for it (SkillController/CareerController are both plain
// slug-keyed lookups). With the catalog this small, fetching the full list
// and filtering here is simpler than adding a new query param the backend
// would need to index against.
export async function getCareersBySkill(skillSlug: string): Promise<Career[]> {
  const careers = await getCareers();
  return careers.filter((c) => c.relatedSkillSlugs.includes(skillSlug));
}

export async function getCareersByIndustry(industrySlug: string): Promise<Career[]> {
  const careers = await getCareers();
  return careers.filter((c) => c.relatedIndustrySlugs.includes(industrySlug));
}
