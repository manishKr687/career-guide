import { Industry } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlug } from "@/lib/api";

export async function getIndustries(): Promise<Industry[]> {
  return apiGet<Industry[]>("/api/industries");
}

export async function getIndustry(slug: string): Promise<Industry | undefined> {
  const industry = await apiGetOptional<Industry>(`/api/industries/${encodeURIComponent(slug)}`);
  return industry ?? undefined;
}

export async function getManyIndustries(slugs: string[]): Promise<Industry[]> {
  return fetchManyBySlug(slugs, getIndustry);
}
