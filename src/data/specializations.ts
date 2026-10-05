import { Specialization } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getSpecializations(): Promise<Specialization[]> {
  return apiGet<Specialization[]>("/api/specializations");
}

export async function getSpecialization(slug: string): Promise<Specialization | undefined> {
  const specialization = await apiGetOptional<Specialization>(`/api/specializations/${encodeURIComponent(slug)}`);
  return specialization ?? undefined;
}

export async function getManySpecializations(slugs: string[]): Promise<Specialization[]> {
  return fetchManyBySlugChunked(slugs, "/api/specializations");
}
