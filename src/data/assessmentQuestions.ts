import { AssessmentQuestion } from "@/lib/types";
import { apiGet } from "@/lib/api";

export async function getAssessmentQuestions(): Promise<AssessmentQuestion[]> {
  return apiGet<AssessmentQuestion[]>("/api/assessment/questions");
}
