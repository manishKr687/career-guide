import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import ProfileView from "@/components/profile/ProfileView";

export const metadata: Metadata = {
  title: "My Career — CareerGuide",
  description: "Your career journey: assessment results, saved careers and colleges, and progress.",
};

export default function ProfilePage() {
  return (
    <>
      <PageHero
        kicker="Account"
        kickerColor="bg-green-soft text-green"
        title="My Career"
        description="Every action across the platform rolls up into your personal profile."
      />
      <Container className="pb-24 pt-6">
        <ProfileView />
      </Container>
    </>
  );
}
