import { Career, Category } from "@/lib/types";
import { apiPost } from "@/lib/api";

export type AssessmentAnswers = Record<string, string>; // questionId -> optionId

export interface AssessmentResult {
  categoryScores: Record<string, number>;
  topCategories: Category[];
  recommendedCareers: Career[];
}

/**
 * Scores a completed assessment by calling the backend's
 * POST /api/assessment/submit — this used to be computed client-side
 * (computeCategoryScores/getTopCategories/getRecommendedCareers over the
 * static data arrays); that logic now lives in the Spring Boot backend's
 * AssessmentService so both the API and this app agree on one
 * implementation. Callers that want fewer results than the API's defaults
 * (4 top categories, 6 recommended careers) can just .slice() the arrays —
 * both are already ordered most-to-least relevant, so a shorter slice is
 * equivalent to asking for a smaller count.
 */
export async function submitAssessment(answers: AssessmentAnswers): Promise<AssessmentResult> {
  return apiPost<AssessmentResult>("/api/assessment/submit", { answers });
}

const STORAGE_KEY = "careerguide.assessment.v1";

export interface StoredAssessment {
  answers: AssessmentAnswers;
  completedAt: string;
}

export function saveAssessment(answers: AssessmentAnswers) {
  if (typeof window === "undefined") return;
  try {
    const payload: StoredAssessment = { answers, completedAt: new Date().toISOString() };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
  } catch {
    // ignore storage errors (private browsing, quota, etc.)
  }
}

export function loadAssessment(): StoredAssessment | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw) as StoredAssessment;
  } catch {
    return null;
  }
}
