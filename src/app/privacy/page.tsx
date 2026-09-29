import type { Metadata } from "next";
import Link from "next/link";
import Container from "@/components/ui/Container";
import Breadcrumb from "@/components/ui/Breadcrumb";

export const metadata: Metadata = {
  title: "Privacy Policy — CareerGuide",
  description:
    "What personal information CareerGuide collects, why, how long it is kept, and how to have it removed.",
};

/**
 * SCAFFOLD, NOT A FINISHED POLICY.
 *
 * Everything marked TO CONFIRM below is a decision the site owner has to make
 * and stand behind -- a retention period, a contact address, a position on
 * under-18s. They are left visible on the page on purpose rather than filled
 * with plausible defaults: a policy that states a 12-month retention period
 * nobody chose is worse than one that visibly is not finished, because the first
 * looks authoritative and is unenforceable.
 *
 * The factual sections -- what is collected, where it goes, what it is used for
 * -- are accurate as written, because they were taken from the schema rather
 * than from a template: `counselling_requests` holds name, email, phone,
 * preferred date and time, stage, career and a free-text message, and `users`
 * holds a name, an email and a password hash.
 */

const TO_CONFIRM = "bg-amber-soft text-amber font-bold px-1.5 py-0.5 rounded";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-8">
      <h2 className="font-display font-extrabold text-navy text-[18px] mb-2.5">{title}</h2>
      <div className="text-[14.5px] text-ink/80 leading-relaxed flex flex-col gap-3">{children}</div>
    </section>
  );
}

export default function PrivacyPage() {
  return (
    <>
      <Container className="pt-5">
        <Breadcrumb items={[{ label: "Home", href: "/" }, { label: "Privacy Policy" }]} />
      </Container>

      <Container className="pb-24 max-w-3xl">
        <h1 className="font-display font-extrabold text-navy text-[32px] sm:text-[40px] leading-tight">
          Privacy Policy
        </h1>
        <p className="text-[14.5px] text-muted mt-3">
          How CareerGuide handles the personal information you give us.
        </p>

        <div className="mt-6 rounded-2xl border border-amber/40 bg-amber-soft/40 px-5 py-4">
          <p className="text-[13.5px] text-ink/80 leading-relaxed">
            <span className={TO_CONFIRM}>DRAFT</span> — the highlighted items below still need to be
            decided before this page is published. They are shown rather than guessed at.
          </p>
        </div>

        <Section title="What we collect">
          <p>
            If you submit the <Link href="/counselling" className="font-bold text-navy hover:underline">counselling
            request form</Link>, we collect your <strong>name, email address and phone number</strong>, along with
            anything optional you provide: a preferred date and time, the stage you are at, the career you are asking
            about, and your message.
          </p>
          <p>
            If you create an account, we store your <strong>name and email address</strong>, and a cryptographic hash of
            your password. We never store the password itself and cannot recover it.
          </p>
          <p>
            Once signed in, we also store what you choose to save — careers, colleges and exams, your assessment
            answers, and any roadmap you build.
          </p>
        </Section>

        <Section title="Why we collect it">
          <p>
            Contact details from the counselling form are used only to reach you about that enquiry. Account
            information is used to sign you in and to show you the things you saved.
          </p>
          <p>
            We do not sell your information, and we do not use it for advertising.{" "}
            <span className={TO_CONFIRM}>TO CONFIRM: whether any third party (email, analytics, WhatsApp) receives it.</span>
          </p>
        </Section>

        <Section title="If you are under 18">
          <p>
            <span className={TO_CONFIRM}>TO CONFIRM: your position on minors.</span> India&rsquo;s Digital Personal Data
            Protection Act 2023 requires verifiable consent from a parent or guardian before processing a
            child&rsquo;s personal data. Decide whether you will accept enquiries from under-18s and, if so, how that
            consent is obtained and recorded.
          </p>
        </Section>

        <Section title="How long we keep it">
          <p>
            <span className={TO_CONFIRM}>TO CONFIRM: a retention period.</span> How long counselling enquiries are kept
            after they are answered, and what happens to an account that is never used again.
          </p>
        </Section>

        <Section title="Removing your information">
          <p>
            You can ask us to delete anything we hold about you, and we will.{" "}
            <span className={TO_CONFIRM}>TO CONFIRM: the contact address for these requests, and how quickly you will respond.</span>
          </p>
        </Section>

        <Section title="Contact">
          <p>
            <span className={TO_CONFIRM}>TO CONFIRM: a contact address, and the name and address of the entity operating this site.</span>
          </p>
        </Section>

        <p className="text-[12.5px] text-subtle mt-10">
          This page is a draft and has not been reviewed by a lawyer. Treat it as a starting point, not as legal advice.
        </p>
      </Container>
    </>
  );
}
