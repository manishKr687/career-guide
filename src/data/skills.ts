import { Skill } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getSkills(): Promise<Skill[]> {
  return apiGet<Skill[]>("/api/skills");
}

export async function getSkill(slug: string): Promise<Skill | undefined> {
  const skill = await apiGetOptional<Skill>(`/api/skills/${encodeURIComponent(slug)}`);
  return skill ?? undefined;
}

export async function getManySkills(slugs: string[]): Promise<Skill[]> {
  return fetchManyBySlugChunked(slugs, "/api/skills");
}
