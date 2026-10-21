import { getCareers } from "@/data/careers";
import { getExams } from "@/data/exams";
import { getColleges } from "@/data/colleges";
import { getDegrees } from "@/data/degrees";
import { getJobRoles } from "@/data/jobRoles";
import { getIndustries } from "@/data/industries";
import { getCertifications } from "@/data/certifications";
import type { GoalType } from "@/lib/userApi";

/**
 * The eight things a My Career goal can be, and the catalogue list behind
 * each -- shared by the user's goal picker and the admin's goal-line editor so
 * the two can never disagree about what counts as, say, a company.
 */

export const GOAL_TYPES: { type: GoalType; group: "study" | "work"; title: string; example: string; noun: string }[] = [
  { type: "career", group: "study", title: "A career", example: "e.g. Computer Science & Engineering", noun: "career" },
  { type: "exam", group: "study", title: "An exam", example: "e.g. JEE Main, NEET-UG", noun: "exam" },
  { type: "college", group: "study", title: "A college", example: "e.g. IIT Madras", noun: "college" },
  { type: "degree", group: "study", title: "A degree", example: "e.g. B.Tech", noun: "degree" },
  { type: "job_role", group: "work", title: "A new job role", example: "e.g. Data Analyst", noun: "job role" },
  { type: "company", group: "work", title: "A company", example: "e.g. Larsen & Toubro", noun: "company" },
  { type: "sector", group: "work", title: "A sector", example: "e.g. Healthcare", noun: "sector" },
  { type: "certification", group: "work", title: "A certification", example: "e.g. AWS Solutions Architect", noun: "certification" },
];

export type GoalOption = { slug: string; name: string };

/** Every item of one goal type, sorted by name. */
export async function loadGoalOptions(type: GoalType): Promise<GoalOption[]> {
  const byName = (a: GoalOption, b: GoalOption) => a.name.localeCompare(b.name);
  switch (type) {
    case "career": return (await getCareers()).map((c) => ({ slug: c.slug, name: c.title })).sort(byName);
    case "exam": return (await getExams()).map((e) => ({ slug: e.slug, name: e.name })).sort(byName);
    case "college": return (await getColleges()).map((c) => ({ slug: c.slug, name: c.name })).sort(byName);
    case "degree": return (await getDegrees()).map((d) => ({ slug: d.slug, name: d.title })).sort(byName);
    case "job_role": return (await getJobRoles()).map((r) => ({ slug: r.slug, name: r.name })).sort(byName);
    case "company": return (await getIndustries()).filter((i) => !i.isSector).map((i) => ({ slug: i.slug, name: i.name })).sort(byName);
    case "sector": return (await getIndustries()).filter((i) => i.isSector).map((i) => ({ slug: i.slug, name: i.name })).sort(byName);
    case "certification": return (await getCertifications()).map((c) => ({ slug: c.slug, name: c.name })).sort(byName);
  }
}
