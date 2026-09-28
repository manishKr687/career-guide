import { apiPost } from "@/lib/api";

export interface CounsellingRequestInput {
  name: string;
  email: string;
  phone: string;
  preferredDate?: string; // "YYYY-MM-DD"
  preferredTime?: string;
  stageSlug?: string;
  careerSlug?: string;
  message?: string;
}

/** Submits the public "Book a counselling call" form. Throws ApiError on validation failure or if the API is unreachable. */
export async function submitCounsellingRequest(input: CounsellingRequestInput): Promise<void> {
  await apiPost<unknown>("/api/counselling-requests", input);
}
