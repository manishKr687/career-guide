"use client";

import { useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { submitCounsellingRequest } from "@/data/counsellingRequests";
import { ApiError } from "@/lib/api";
import { getBusinessWhatsAppLink } from "@/lib/whatsapp";
import { Career, Stage } from "@/lib/types";

const INPUT_CLASS =
  "w-full rounded-xl border border-line px-3.5 py-2.5 text-[13.5px] font-medium text-ink placeholder:text-subtle focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors";
const INPUT_ICON_CLASS = `${INPUT_CLASS} pl-10`;

const NEXT_STEPS = [
  { icon: "mail", label: "We reach out within 24 hours, by call or WhatsApp", color: "bg-blue" },
  { icon: "phone", label: "A free, no-pressure 15–20 minute conversation", color: "bg-teal" },
  { icon: "check", label: "You leave with a clear, personalized next step", color: "bg-green" },
];

function StepBadge({ n, active }: { n: number; active?: boolean }) {
  return (
    <span
      className={`w-[22px] h-[22px] shrink-0 rounded-full flex items-center justify-center font-display font-extrabold text-[11px] ${
        active ? "bg-navy text-white" : "bg-line text-muted"
      }`}
    >
      {n}
    </span>
  );
}

function FieldIcon({ name }: { name: string }) {
  return (
    <span className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-subtle">
      <Icon name={name} className="w-4 h-4" />
    </span>
  );
}

export default function CounsellingForm({ stages, career }: { stages: Stage[]; career: Career | null }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [preferredDate, setPreferredDate] = useState("");
  const [preferredTime, setPreferredTime] = useState("");
  const [stageSlug, setStageSlug] = useState("");
  const [message, setMessage] = useState(career ? `I'd like to talk about the ${career.title} career path.` : "");

  const [consent, setConsent] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitted, setSubmitted] = useState(false);

  const whatsAppMessage = career
    ? `Hi! I'd like to talk about the ${career.title} career path.`
    : "Hi! I'd like to book a counselling call.";
  const whatsAppLink = getBusinessWhatsAppLink(whatsAppMessage);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await submitCounsellingRequest({
        name,
        email,
        phone,
        preferredDate: preferredDate || undefined,
        preferredTime: preferredTime || undefined,
        stageSlug: stageSlug || undefined,
        careerSlug: career?.slug,
        message: message || undefined,
        consent,
      });
      setSubmitted(true);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not reach the server. Please try again in a moment.");
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <div className="bg-white rounded-3xl shadow-card border border-line overflow-hidden">
        <div className="max-w-lg mx-auto text-center px-6 py-16 sm:py-20">
          <div className="w-16 h-16 rounded-full bg-green-soft flex items-center justify-center mx-auto mb-5">
            <div className="w-11 h-11 rounded-full bg-green flex items-center justify-center">
              <Icon name="check" className="w-5 h-5 text-white" strokeWidth={2.4} />
            </div>
          </div>
          <h2 className="font-display font-extrabold text-navy text-xl mb-2.5">Request received!</h2>
          <p className="text-[14px] text-ink/70 leading-relaxed">
            Thanks, {name.split(" ")[0]}. We&apos;ll reach out on <span className="font-semibold text-ink">{phone}</span> to
            confirm a time{preferredDate ? ` around ${preferredDate}` : ""}.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mt-8">
            {whatsAppLink && (
              <Link
                href={whatsAppLink}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-[13.5px] font-bold text-white bg-green px-5 py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                <Icon name="phone" className="w-4 h-4" />
                Message us on WhatsApp now
              </Link>
            )}
            <button
              type="button"
              onClick={() => setSubmitted(false)}
              className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
            >
              Submit another request
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl shadow-card border border-line overflow-hidden">
      <div className="grid grid-cols-1 lg:grid-cols-5">
        <form onSubmit={handleSubmit} className="lg:col-span-3 p-6 sm:p-10 space-y-7">
          {career && (
            <div className="text-[12.5px] font-semibold px-3.5 py-2.5 rounded-xl bg-blue-soft text-blue inline-flex items-center gap-2">
              <Icon name="chevRight" className="w-3.5 h-3.5" />
              Regarding: {career.title}
            </div>
          )}

          <div className="space-y-4">
            <h2 className="flex items-center gap-2.5 text-[12px] font-bold uppercase tracking-wide text-subtle">
              <StepBadge n={1} active />
              Your details
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[13px] font-bold text-ink mb-1.5">Name *</label>
                <div className="relative">
                  <FieldIcon name="user" />
                  <input
                    required
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Your full name"
                    className={INPUT_ICON_CLASS}
                  />
                </div>
              </div>
              <div>
                <label className="block text-[13px] font-bold text-ink mb-1.5">Phone *</label>
                <div className="relative">
                  <FieldIcon name="phone" />
                  <input
                    required
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+91 98765 43210"
                    className={INPUT_ICON_CLASS}
                  />
                </div>
              </div>
            </div>
            <div>
              <label className="block text-[13px] font-bold text-ink mb-1.5">Email *</label>
              <div className="relative">
                <FieldIcon name="mail" />
                <input
                  required
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="you@example.com"
                  className={INPUT_ICON_CLASS}
                />
              </div>
            </div>
          </div>

          <div className="h-px bg-line" />

          <div className="space-y-4">
            <h2 className="flex items-center gap-2.5 text-[12px] font-bold uppercase tracking-wide text-subtle">
              <StepBadge n={2} />
              When &amp; what
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[13px] font-bold text-ink mb-1.5">Preferred date</label>
                <div className="relative">
                  <FieldIcon name="cal" />
                  <input
                    type="date"
                    value={preferredDate}
                    onChange={(e) => setPreferredDate(e.target.value)}
                    className={INPUT_ICON_CLASS}
                  />
                </div>
              </div>
              <div>
                <label className="block text-[13px] font-bold text-ink mb-1.5">Preferred time</label>
                <div className="relative">
                  <FieldIcon name="clock" />
                  <input
                    type="text"
                    value={preferredTime}
                    onChange={(e) => setPreferredTime(e.target.value)}
                    placeholder="e.g. Weekday evenings"
                    className={INPUT_ICON_CLASS}
                  />
                </div>
              </div>
            </div>
            <div>
              <label className="block text-[13px] font-bold text-ink mb-1.5">Current stage</label>
              <select value={stageSlug} onChange={(e) => setStageSlug(e.target.value)} className={INPUT_CLASS}>
                <option value="">Prefer not to say</option>
                {stages.map((s) => (
                  <option key={s.slug} value={s.slug}>
                    {s.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-[13px] font-bold text-ink mb-1.5">What would you like to discuss?</label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={3}
                className={INPUT_CLASS}
              />
            </div>
          </div>

          {error && (
            <p className="flex items-center gap-2 text-[13.5px] text-red bg-red-soft rounded-xl px-3.5 py-2.5">
              <Icon name="close" className="w-4 h-4 shrink-0" />
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 text-[13.5px] font-bold text-white bg-navy px-7 py-3.5 rounded-xl hover:bg-navy-2 transition-colors disabled:opacity-50"
          >
            {submitting && (
              <span className="w-3.5 h-3.5 rounded-full border-2 border-white/40 border-t-white animate-spin" />
            )}
            {submitting ? "Sending..." : "Request a call"}
            {!submitting && <Icon name="arrowRight" className="w-4 h-4" />}
          </button>
          <label className="flex items-start gap-3 -mt-4 cursor-pointer">
            <input
              type="checkbox"
              checked={consent}
              onChange={(e) => setConsent(e.target.checked)}
              required
              className="mt-0.5 w-4 h-4 shrink-0 accent-navy"
            />
            <span className="text-[12.5px] text-ink/75 leading-snug">
              I agree to CareerGuide contacting me about this enquiry, and to my details being
              stored for that purpose. If you are under 18, please ask a parent or guardian before
              submitting.{" "}
              <Link href="/privacy" className="font-bold text-navy hover:underline">
                Privacy policy
              </Link>
            </span>
          </label>
          <p className="text-[12px] text-subtle -mt-2">
            We&apos;ll only use these details to get in touch about your counselling request.
          </p>
        </form>

        <div className="lg:col-span-2 bg-bg-soft p-6 sm:p-9 lg:border-l border-line space-y-6">
          <div>
            <h3 className="font-display font-extrabold text-navy text-[15px] mb-4">What happens next</h3>
            <ol className="relative space-y-4">
              <span className="absolute left-4 top-8 bottom-8 w-px bg-line" aria-hidden="true" />
              {NEXT_STEPS.map((step) => (
                <li key={step.label} className="relative flex items-start gap-3.5">
                  <span
                    className={`w-8 h-8 shrink-0 rounded-full flex items-center justify-center text-white ${step.color}`}
                  >
                    <Icon name={step.icon} className="w-3.5 h-3.5" strokeWidth={2.2} />
                  </span>
                  <span className="text-[13px] text-ink/75 leading-snug pt-1.5">{step.label}</span>
                </li>
              ))}
            </ol>
          </div>

          {/* Placeholder testimonial -- swap for a real one (or remove this
              card) before shipping; this quote is not from an actual student. */}
          <div className="rounded-2xl bg-white border border-line p-5">
            <p className="text-[13px] italic text-ink leading-relaxed">
              &ldquo;I had no idea how to choose between commerce and science. The call gave me an actual plan instead of more confusion.&rdquo;
            </p>
            <div className="flex items-center gap-2.5 mt-3.5">
              <div className="w-8 h-8 rounded-full bg-purple-soft text-purple text-[11px] font-bold flex items-center justify-center">
                AP
              </div>
              <div className="flex flex-col">
                <span className="text-[12.5px] font-bold text-navy">Ananya P.</span>
                <span className="text-[11px] text-subtle">Class 12, Delhi</span>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-gradient-to-br from-green-soft to-white border border-green/15 p-5">
            <div className="w-10 h-10 rounded-xl bg-green flex items-center justify-center mb-3">
              <Icon name="phone" className="w-5 h-5 text-white" />
            </div>
            <h3 className="font-display font-extrabold text-navy text-[14.5px] mb-1.5">Prefer to chat directly?</h3>
            <p className="text-[12.5px] text-ink/70 mb-4 leading-relaxed">
              Message us on WhatsApp instead of filling out the form &mdash; we usually reply
              within a day.
            </p>
            {whatsAppLink ? (
              <Link
                href={whatsAppLink}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-[13px] font-bold text-white bg-green px-4 py-2.5 rounded-xl hover:opacity-90 transition-opacity w-full justify-center sm:w-auto"
              >
                <Icon name="phone" className="w-4 h-4" />
                Chat with us on WhatsApp
              </Link>
            ) : (
              <p className="text-[12px] text-subtle">The form on the left is the best way to reach us right now.</p>
            )}
          </div>

          <div className="flex items-start gap-2.5 text-[12px] text-subtle">
            <Icon name="shield" className="w-4 h-4 shrink-0 mt-0.5" />
            <span>Your information is confidential and only used to get in touch about this request.</span>
          </div>
        </div>
      </div>
    </div>
  );
}
