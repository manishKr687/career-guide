import Link from "next/link";
import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import Icon from "@/components/ui/Icon";
import { getStages } from "@/data/stages";

export const metadata: Metadata = {
  title: "Career Roadmap — CareerGuide",
  description: "The step-by-step journey from choosing your stage to growing your career.",
};

const STEPS = [
  { n: 1, label: "Your Current Stage", desc: "Tell us where you are: after 10th, after 12th, graduation and beyond.", icon: "mappin", color: "bg-blue" },
  { n: 2, label: "Assess Yourself", desc: "Take the career assessment to surface your interests, strengths and goals.", icon: "target", color: "bg-teal" },
  { n: 3, label: "Explore Careers", desc: "Browse 1000+ careers with real education, skill and salary detail.", icon: "compass", color: "bg-green" },
  { n: 4, label: "Compare Options", desc: "Weigh careers side-by-side on growth, salary and required effort.", icon: "filter", color: "bg-amber" },
  { n: 5, label: "Choose Degree", desc: "Pick the degree, diploma or certification that gets you there.", icon: "book", color: "bg-pink" },
  { n: 6, label: "Find College / Institute", desc: "Shortlist colleges and universities that offer your chosen degree.", icon: "bld", color: "bg-purple" },
  { n: 7, label: "Prepare for Exams", desc: "Track entrance exams, dates and preparation resources.", icon: "cal", color: "bg-blue" },
  { n: 8, label: "Build Skills", desc: "Layer on certifications and practical skills alongside formal study.", icon: "gear", color: "bg-teal" },
  { n: 9, label: "Get Internship / Job", desc: "Apply what you've learned and get real-world experience.", icon: "brief", color: "bg-green" },
  { n: 10, label: "Grow Your Career", desc: "Keep upskilling, switch roles, or change direction entirely — and loop back.", icon: "trend", color: "bg-amber" },
];

export default async function RoadmapPage() {
  const stages = await getStages();
  return (
    <>
      <PageHero
        kicker="Plan"
        kickerColor="bg-teal-soft text-teal"
        title="Your Career Roadmap"
        description="An example journey through CareerGuide — from wherever you start today to a career you're actively growing."
      />
      <Container className="pb-24">
        <div className="flex flex-col gap-4 max-w-3xl mx-auto mt-6">
          {STEPS.map((step, i) => (
            <div key={step.n} className="flex gap-5">
              <div className="flex flex-col items-center">
                <div
                  className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-display font-extrabold shrink-0 ${step.color}`}
                >
                  {step.n}
                </div>
                {i < STEPS.length - 1 && (
                  <div className="w-px flex-1 bg-line my-1.5" style={{ minHeight: "24px" }} />
                )}
              </div>
              <div className="pb-2 flex-1">
                <div className="rounded-2xl border border-line p-5 bg-white flex items-start gap-4">
                  <div className="w-10 h-10 rounded-xl bg-bg-soft flex items-center justify-center text-navy shrink-0">
                    <Icon name={step.icon} className="w-5 h-5" />
                  </div>
                  <div>
                    <div className="font-display font-bold text-navy text-[15.5px]">
                      {step.label}
                    </div>
                    <div className="text-[13px] text-muted mt-1 leading-relaxed">
                      {step.desc}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-16 text-center">
          <h2 className="font-display font-extrabold text-navy text-xl mb-2">
            Start From Your Stage
          </h2>
          <p className="text-muted text-[14px] mb-6">
            Jump into the roadmap from wherever you are today.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            {stages.map((s) => (
              <Link
                key={s.slug}
                href={`/stage/${s.slug}`}
                className={`text-[13px] font-bold px-4 py-2.5 rounded-xl hover:opacity-80 transition-opacity ${s.badgeSoft}`}
              >
                {s.name}
              </Link>
            ))}
          </div>
        </div>
      </Container>
    </>
  );
}
