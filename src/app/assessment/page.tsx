import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import AssessmentFlow from "@/components/assessment/AssessmentFlow";

export const metadata: Metadata = {
  title: "Career Assessment — CareerGuide",
  description: "A short, adaptive questionnaire covering interests, strengths, academics and goals.",
};

export default function AssessmentPage() {
  return (
    <>
      <PageHero
        kicker="Not Sure What To Choose?"
        kickerColor="bg-purple-soft text-purple"
        title="Career Assessment"
        description="Answer a few questions about your interests, strengths and goals to get personalized career recommendations."
      />
      <Container className="pb-24 pt-6">
        <AssessmentFlow />
      </Container>
    </>
  );
}
