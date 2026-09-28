import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import AssessmentResults from "@/components/assessment/AssessmentResults";

export const metadata: Metadata = {
  title: "Your Career Recommendations — CareerGuide",
  description: "Personalized career recommendations based on your assessment answers.",
};

export default function AssessmentResultsPage() {
  return (
    <>
      <PageHero
        kicker="Results"
        kickerColor="bg-green-soft text-green"
        title="Your Career Recommendations"
      />
      <Container className="pb-24 pt-6">
        <AssessmentResults />
      </Container>
    </>
  );
}
