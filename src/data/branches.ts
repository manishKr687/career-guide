import { Branch } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

export async function getBranches(categorySlug?: string): Promise<Branch[]> {
  return apiGet<Branch[]>("/api/branches", { category: categorySlug });
}

export async function getBranch(slug: string): Promise<Branch | undefined> {
  const branch = await apiGetOptional<Branch>(`/api/branches/${encodeURIComponent(slug)}`);
  return branch ?? undefined;
}
