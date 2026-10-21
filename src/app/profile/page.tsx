import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import ProfileView from "@/components/profile/ProfileView";

export const metadata: Metadata = {
  title: "My Career",
  description: "Your goal and learning log, saved careers, colleges and exams, assessment results and account.",
};

export default function ProfilePage() {
  return (
    <>
      <PageHero
        kicker="Account"
        kickerColor="bg-green-soft text-green"
        title="My Career"
        description="Your goal, what you're learning, and everything you've saved — in one place."
      />
      <Container className="pb-24 pt-6">
        <ProfileView />
      </Container>
    </>
  );
}
