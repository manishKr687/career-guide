import { Stage } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

export async function getStages(): Promise<Stage[]> {
  return apiGet<Stage[]>("/api/stages");
}

export async function getStage(slug: string): Promise<Stage | undefined> {
  const stage = await apiGetOptional<Stage>(`/api/stages/${encodeURIComponent(slug)}`);
  return stage ?? undefined;
}
