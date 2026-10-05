import { JobRole } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getJobRoles(filters?: { career?: string }): Promise<JobRole[]> {
  return apiGet<JobRole[]>("/api/job-roles", { career: filters?.career });
}

export async function getJobRole(slug: string): Promise<JobRole | undefined> {
  const jobRole = await apiGetOptional<JobRole>(`/api/job-roles/${encodeURIComponent(slug)}`);
  return jobRole ?? undefined;
}

export async function getManyJobRoles(slugs: string[]): Promise<JobRole[]> {
  return fetchManyBySlugChunked(slugs, "/api/job-roles");
}

// Unlike Skill/Industry, the backend already supports filtering job roles by
// career server-side (JobRoleController's `career` param), so this doesn't
// need the fetch-all-then-filter workaround used for getCareersBySkill/
// getCareersByIndustry.
export async function getJobRolesByCareer(careerSlug: string): Promise<JobRole[]> {
  return getJobRoles({ career: careerSlug });
}
