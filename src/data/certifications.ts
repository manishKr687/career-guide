import { Certification } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";

export async function getCertifications(): Promise<Certification[]> {
  return apiGet<Certification[]>("/api/certifications");
}

export async function getCertification(slug: string): Promise<Certification | undefined> {
  const certification = await apiGetOptional<Certification>(`/api/certifications/${encodeURIComponent(slug)}`);
  return certification ?? undefined;
}

export async function getManyCertifications(slugs: string[]): Promise<Certification[]> {
  return fetchManyBySlugChunked(slugs, "/api/certifications");
}

// Same reverse-relation situation as getCareersBySkill/getCareersByIndustry:
// CertificationDto stores relatedCareerSlugs (cert -> careers), but there's
// no relatedCertificationSlugs on CareerDto to go the other way, and no
// backend filter param for it. Fetching all certifications and filtering
// here is fine at this scale, and is a no-op today since the table has no
// seeded rows yet.
export async function getCertificationsByCareer(careerSlug: string): Promise<Certification[]> {
  const certifications = await getCertifications();
  return certifications.filter((c) => c.relatedCareerSlugs.includes(careerSlug));
}
