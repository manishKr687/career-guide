import type { Metadata } from "next";
import CompareView from "@/components/compare/CompareView";
import { getManyCareers } from "@/data/careers";

export const metadata: Metadata = {
  title: "Compare Careers — CareerGuide",
  description: "Compare careers side by side on demand, education, salary, skills and growth path.",
};

export default async function ComparePage({
  searchParams,
}: {
  searchParams: Promise<{ careers?: string }>;
}) {
  const { careers: careersParam } = await searchParams;
  const slugs = careersParam
    ? careersParam.split(",").map((s) => s.trim()).filter(Boolean)
    : [];
  const initialCareers = slugs.length > 0 ? await getManyCareers(slugs) : [];

  // Distinguishing "no ?careers= at all" (bare /compare, e.g. from the nav)
  // from "?careers= present but resolved to nothing" matters: the former
  // should fall back to whatever's already in the visitor's localStorage
  // compare list (see CompareView), while the latter -- a shared link whose
  // careers all got deleted, or an explicitly empty list -- should not.
  const hasUrlParam = careersParam !== undefined;

  return <CompareView initialCareers={initialCareers} hasUrlParam={hasUrlParam} />;
}
