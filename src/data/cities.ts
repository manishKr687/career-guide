import { City } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

// Added in V53 (College MVP).

export async function getCities(): Promise<City[]> {
  return apiGet<City[]>("/api/cities");
}

export async function getCity(slug: string): Promise<City | undefined> {
  const city = await apiGetOptional<City>(`/api/cities/${encodeURIComponent(slug)}`);
  return city ?? undefined;
}
