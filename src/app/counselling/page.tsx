import type { Metadata } from "next";
import Link from "next/link";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import CounsellingForm from "@/components/counselling/CounsellingForm";
import CounsellingFaq from "@/components/counselling/CounsellingFaq";
import { getStages } from "@/data/stages";
import { getCareer } from "@/data/careers";

export const metadata: Metadata = {
  title: "Book a Counselling Call — CareerGuide",
  description: "Talk to a career counsellor about your options -- book a call or message us on WhatsApp.",
};

const TRUST_POINTS: { icon: string; color: "green" | "blue" | "teal"; title: string; subtitle: string }[] = [
  { icon: "shield", color: "green", title: "100% free & confidential", subtitle: "No cost, no obligation — ever." },
  { icon: "clock", color: "blue", title: "We reply within 24 hours", subtitle: "Usually much sooner, on a weekday." },
  { icon: "phone", color: "teal", title: "WhatsApp follow-up available", subtitle: "Chat anytime after your first call." },
];

const TRUST_STYLES: Record<string, string> = {
  green: "bg-green-soft text-green",
  blue: "bg-blue-soft text-blue",
  teal: "bg-teal-soft text-teal",
};

// Placeholder social proof -- swap the count and avatars for real numbers
// (or remove this row) before this goes live. Nothing here is measured yet.
const SOCIAL_PROOF_AVATARS = [
  { initials: "RS", color: "bg-blue" },
  { initials: "AK", color: "bg-teal" },
  { initials: "PN", color: "bg-amber" },
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
      <div className="bg-navy pt-14 pb-28 sm:pt-16 sm:pb-36 relative overflow-hidden">
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

            {/* Placeholder social proof row -- see SOCIAL_PROOF_AVATARS above */}
            <div className="flex items-center gap-4 mt-6">
              <div className="flex">
                {SOCIAL_PROOF_AVATARS.map((a, i) => (
                  <div
                    key={a.initials}
                    className={`w-9 h-9 rounded-full border-2 border-navy flex items-center justify-center text-white text-[11px] font-bold ${a.color}`}
                    style={{ marginLeft: i === 0 ? 0 : -10 }}
                  >
                    {a.initials}
                  </div>
                ))}
                <div
                  className="w-9 h-9 rounded-full border-2 border-navy flex items-center justify-center text-white text-[11px] font-bold bg-purple"
                  style={{ marginLeft: -10 }}
                >
                  +
                </div>
              </div>
              <div className="flex flex-col gap-0.5">
                <div className="flex gap-0.5 text-amber">
                  {[0, 1, 2, 3, 4].map((i) => (
                    <Icon key={i} name="star" className="w-3 h-3" strokeWidth={1.6} />
                  ))}
                </div>
                <span className="text-[12px] font-semibold text-white/60">Trusted by students across India</span>
              </div>
            </div>
          </div>
        </Container>
      </div>

      <Container className="relative">
        {/* Trust strip -- overlaps the hero */}
        <div className="-mt-20 sm:-mt-24 grid grid-cols-1 sm:grid-cols-3 gap-4 relative z-10">
          {TRUST_POINTS.map((t) => (
            <div
              key={t.title}
              className="bg-white rounded-2xl shadow-card p-5 flex items-start gap-3.5"
            >
              <div className={`w-11 h-11 shrink-0 rounded-[14px] flex items-center justify-center ${TRUST_STYLES[t.color]}`}>
                <Icon name={t.icon} className="w-5 h-5" />
              </div>
              <div>
                <div className="font-display font-extrabold text-navy text-[14.5px]">{t.title}</div>
                <div className="text-[12.5px] text-muted mt-0.5 leading-snug">{t.subtitle}</div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-10 pb-8">
          <CounsellingForm stages={stages} career={career ?? null} />
        </div>

        <CounsellingFaq />

        {/* Not ready yet -- cross-link back into the catalog */}
        <div className="mb-24 rounded-3xl bg-navy relative overflow-hidden px-8 py-10 sm:px-14 sm:py-12 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
          <div className="pointer-events-none absolute -top-16 right-8 w-64 h-64 rounded-full bg-purple/15 blur-3xl" />
          <div className="relative max-w-lg">
            <h3 className="font-display font-extrabold text-white text-xl">Not ready to talk yet?</h3>
            <p className="text-white/65 text-[14px] mt-1.5 leading-relaxed">
              Browse career paths and come back whenever you&rsquo;re ready to book a call.
            </p>
          </div>
          <Link
            href="/careers"
            className="relative shrink-0 inline-flex items-center gap-2 text-[13.5px] font-bold text-navy bg-white px-6 py-3.5 rounded-xl hover:bg-white/90 transition-colors"
          >
            Browse Careers
            <Icon name="arrowRight" className="w-4 h-4" />
          </Link>
        </div>
      </Container>
    </>
  );
}
