import { University } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

// Added in V53 (College MVP).

export async function getUniversities(): Promise<University[]> {
  return apiGet<University[]>("/api/universities");
}

export async function getUniversity(slug: string): Promise<University | undefined> {
  const university = await apiGetOptional<University>(`/api/universities/${encodeURIComponent(slug)}`);
  return university ?? undefined;
}
