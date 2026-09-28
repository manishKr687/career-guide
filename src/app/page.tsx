import Hero from "@/components/home/Hero";
import StageGrid from "@/components/home/StageGrid";
import CategoryGrid from "@/components/home/CategoryGrid";
import HowItWorks from "@/components/home/HowItWorks";
import PopularCareers from "@/components/home/PopularCareers";
import AssessmentCTA from "@/components/home/AssessmentCTA";

export default function Home() {
  return (
    <>
      <Hero />
      <StageGrid />
      <CategoryGrid />
      <HowItWorks />
      <PopularCareers />
      <AssessmentCTA />
      <div className="h-20" />
    </>
  );
}
