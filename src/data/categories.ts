import { Category } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

export async function getCategories(): Promise<Category[]> {
  return apiGet<Category[]>("/api/categories");
}

export async function getCategory(slug: string): Promise<Category | undefined> {
  const category = await apiGetOptional<Category>(`/api/categories/${encodeURIComponent(slug)}`);
  return category ?? undefined;
}
