import Container from "@/components/ui/Container";
import SectionHeader from "@/components/ui/SectionHeader";
import Reveal from "@/components/ui/Reveal";

const STEPS = [
  { n: 1, label: "Select Your Stage", color: "bg-blue" },
  { n: 2, label: "Take Career Assessment", color: "bg-teal" },
  { n: 3, label: "Explore Careers", color: "bg-green" },
  { n: 4, label: "Compare Options", color: "bg-amber" },
  { n: 5, label: "Choose Degree", color: "bg-pink" },
  { n: 6, label: "Find College", color: "bg-purple" },
  { n: 7, label: "Prepare for Exams", color: "bg-blue" },
  { n: 8, label: "Build Skills", color: "bg-teal" },
  { n: 9, label: "Get Job / Internship", color: "bg-green" },
  { n: 10, label: "Grow Your Career", color: "bg-amber" },
];

export default function HowItWorks() {
  return (
    <section className="mt-24 sm:mt-28">
      <Container>
        <Reveal>
          <SectionHeader
            kicker="How CareerGuide Works"
            kickerColor="bg-teal-soft text-teal"
            title="A simple, step-by-step journey"
            align="center"
          />
        </Reveal>
        <Reveal delay={100} className="relative flex flex-wrap justify-center gap-x-8 gap-y-8">
          {/* Faint connecting thread behind the numbered steps -- purely
              decorative, reinforces "a journey" without adding real motion. */}
          <div className="hidden sm:block absolute top-[22px] left-[8%] right-[8%] h-px bg-gradient-to-r from-transparent via-line to-transparent" />
          {STEPS.map((s) => (
            <div key={s.n} className="relative flex flex-col items-center w-[92px]">
              <div
                className={`w-11 h-11 rounded-full flex items-center justify-center text-white font-display font-extrabold text-sm ring-4 ring-white shadow-card ${s.color}`}
              >
                {s.n}
              </div>
              <div className="text-[11.5px] font-semibold text-ink/70 text-center mt-2.5 leading-snug">
                {s.label}
              </div>
            </div>
          ))}
        </Reveal>
      </Container>
    </section>
  );
}
