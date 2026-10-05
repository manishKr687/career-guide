import { Career, Exam } from "@/lib/types";
import { apiGet, apiGetOptional, fetchManyBySlugChunked } from "@/lib/api";
import { getManyCareers } from "@/data/careers";
import { getManyDegrees } from "@/data/degrees";

export async function getExams(filters?: { category?: string; q?: string }): Promise<Exam[]> {
  return apiGet<Exam[]>("/api/exams", { category: filters?.category, q: filters?.q });
}

export async function getExam(slug: string): Promise<Exam | undefined> {
  const exam = await apiGetOptional<Exam>(`/api/exams/${encodeURIComponent(slug)}`);
  return exam ?? undefined;
}

export async function getManyExams(slugs: string[]): Promise<Exam[]> {
  return fetchManyBySlugChunked(slugs, "/api/exams");
}

// Resolves an exam's careerDegreeOfferings (career+degree slug pairs, V66)
// into display-ready data for CareerCard: one entry per career, with all of
// that career's degrees this exam is an entry gate into combined into a
// single label (e.g. "B.Tech"). Same shape/purpose as
// getCollegeCareerOfferings in src/data/colleges.ts.
export async function getExamCareerDegreeOfferings(
  exam: Exam
): Promise<{ career: Career; degreeLabel: string }[]> {
  const careerSlugs = Array.from(new Set(exam.careerDegreeOfferings.map((o) => o.careerSlug)));
  const degreeSlugs = Array.from(new Set(exam.careerDegreeOfferings.map((o) => o.degreeSlug)));
  const [careers, degrees] = await Promise.all([getManyCareers(careerSlugs), getManyDegrees(degreeSlugs)]);
  const careersBySlug = new Map(careers.map((c) => [c.slug, c]));
  const degreesBySlug = new Map(degrees.map((d) => [d.slug, d]));

  const degreeTitlesByCareer = new Map<string, string[]>();
  for (const offering of exam.careerDegreeOfferings) {
    const degree = degreesBySlug.get(offering.degreeSlug);
    if (!degree) continue;
    const titles = degreeTitlesByCareer.get(offering.careerSlug) ?? [];
    titles.push(degree.title);
    degreeTitlesByCareer.set(offering.careerSlug, titles);
  }

  const result: { career: Career; degreeLabel: string }[] = [];
  for (const [careerSlug, degreeTitles] of degreeTitlesByCareer) {
    const career = careersBySlug.get(careerSlug);
    if (!career) continue;
    result.push({ career, degreeLabel: degreeTitles.join(" · ") });
  }
  return result;
}
