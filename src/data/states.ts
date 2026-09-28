import { State } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

// Added in V53 (College MVP).

export async function getStates(): Promise<State[]> {
  return apiGet<State[]>("/api/states");
}

export async function getState(slug: string): Promise<State | undefined> {
  const state = await apiGetOptional<State>(`/api/states/${encodeURIComponent(slug)}`);
  return state ?? undefined;
}
