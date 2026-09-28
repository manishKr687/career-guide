import { Subject } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

export async function getSubjects(): Promise<Subject[]> {
  return apiGet<Subject[]>("/api/subjects");
}

export async function getSubject(slug: string): Promise<Subject | undefined> {
  const subject = await apiGetOptional<Subject>(
    `/api/subjects/${encodeURIComponent(slug)}`
  );
  return subject ?? undefined;
}

// There are only 34 subjects total, and no backend endpoint for "subjects of
// this degree" -- the pairing lives on DegreeDto.subjectSlugs. Fetching all of
// them and filtering here costs nothing at this scale, same reasoning as
// getStreamsByStage in src/data/streams.ts.
export async function getManySubjects(slugs: string[]): Promise<Subject[]> {
  if (slugs.length === 0) return [];
  const subjects = await getSubjects();
  const bySlug = new Map(subjects.map((s) => [s.slug, s]));
  return slugs.map((s) => bySlug.get(s)).filter((s): s is Subject => Boolean(s));
}
