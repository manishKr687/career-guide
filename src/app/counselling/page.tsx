import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import CounsellingForm from "@/components/counselling/CounsellingForm";
import { getStages } from "@/data/stages";
import { getCareer } from "@/data/careers";

export const metadata: Metadata = {
  title: "Book a Counselling Call — CareerGuide",
  description: "Talk to a career counsellor about your options -- book a call or message us on WhatsApp.",
};

const TRUST_POINTS: { icon: string; label: string }[] = [
  { icon: "shield", label: "100% free & confidential" },
  { icon: "clock", label: "We reply within 24 hours" },
  { icon: "phone", label: "WhatsApp follow-up available" },
];

export default async function CounsellingPage({
  searchParams,
}: {
  searchParams: Promise<{ career?: string }>;
}) {
  const { career: careerSlug } = await searchParams;
  const [stages, career] = await Promise.all([
    getStages(),
    careerSlug ? getCareer(careerSlug) : Promise.resolve(undefined),
  ]);

  return (
    <>
      <div className="bg-navy pt-12 pb-24 sm:pt-16 sm:pb-32 relative overflow-hidden">
        <div className="pointer-events-none absolute -top-24 -right-16 w-80 h-80 rounded-full bg-green/15 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-28 -left-20 w-80 h-80 rounded-full bg-blue/15 blur-3xl" />
        <Container className="relative">
          <div className="max-w-2xl">
            <span className="inline-flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1.5 rounded-full mb-5 bg-green-soft text-green font-display">
              <Icon name="users" className="w-3.5 h-3.5" />
              Get Guidance
            </span>
            <h1 className="font-display font-extrabold text-white text-3xl sm:text-[2.6rem] leading-tight text-balance">
              Book a Counselling Call
            </h1>
            <p className="text-white/65 text-[15px] sm:text-base mt-4 leading-relaxed max-w-xl">
              Talk through your options one-on-one with a real person. Tell us a bit
              about yourself and we&rsquo;ll reach out to schedule a time &mdash; or
              message us directly on WhatsApp right now.
            </p>
            <div className="flex flex-wrap gap-2.5 mt-7">
              {TRUST_POINTS.map((t) => (
                <span
                  key={t.label}
                  className="inline-flex items-center gap-2 text-[12.5px] font-semibold text-white/85 bg-white/10 px-3.5 py-2 rounded-full"
                >
                  <Icon name={t.icon} className="w-3.5 h-3.5 text-green" />
                  {t.label}
                </span>
              ))}
            </div>
          </div>
        </Container>
      </div>

      <Container className="-mt-14 sm:-mt-20 pb-24 relative">
        <CounsellingForm stages={stages} career={career ?? null} />
      </Container>
    </>
  );
}
