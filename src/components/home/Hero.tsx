import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import Reveal from "@/components/ui/Reveal";

const STATS = [
  { label: "Careers Mapped", value: "1000+", icon: "compass" },
  { label: "Degrees & Exams", value: "500+", icon: "book" },
  { label: "Colleges & Universities", value: "10K+", icon: "building" },
] as const;

export default function Hero() {
  return (
    <section className="pt-10 sm:pt-14">
      <Container>
        <div className="relative rounded-[28px] bg-gradient-to-br from-purple-soft via-blue-soft to-amber-soft px-6 py-12 sm:px-12 sm:py-16 flex flex-col lg:flex-row items-center gap-10 overflow-hidden ring-1 ring-navy/5">
          {/* Soft layered glow, purely decorative depth -- clipped by the
              parent's overflow-hidden so it never affects layout/scroll. */}
          <div className="pointer-events-none absolute -top-24 -right-16 w-80 h-80 rounded-full bg-purple/10 blur-3xl" />
          <div className="pointer-events-none absolute -bottom-24 -left-10 w-72 h-72 rounded-full bg-blue/10 blur-3xl" />

          <Reveal className="relative max-w-2xl text-center lg:text-left">
            <span className="inline-flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1.5 rounded-full mb-5 bg-navy/8 text-navy font-display">
              <span className="w-1.5 h-1.5 rounded-full bg-purple" />
              Your Future Starts Here
            </span>
            <h1 className="font-display font-extrabold text-navy text-[2.5rem] sm:text-[3.35rem] leading-[1.08] tracking-tight text-balance">
              Your Career.
              <br />
              Your Journey.
              <br />
              <span className="bg-gradient-to-r from-purple to-blue bg-clip-text text-transparent">
                Your Choice.
              </span>
            </h1>
            <p className="text-muted text-[15px] sm:text-base mt-6 leading-relaxed max-w-lg mx-auto lg:mx-0">
              Whether you&rsquo;re after 10th, after 12th, a graduate, or
              already working &mdash; find the right path for your future
              with personalized guidance, trusted information and expert
              resources.
            </p>
            <div className="flex flex-col sm:flex-row items-center gap-3 mt-9 justify-center lg:justify-start">
              <Link
                href="/careers"
                className="w-full sm:w-auto text-center text-[14px] font-bold text-white bg-navy px-6 py-3.5 rounded-xl hover:bg-navy-2 hover:shadow-[0_10px_30px_-10px_rgba(22,33,62,0.5)] transition-all flex items-center justify-center gap-2"
              >
                Explore My Career
                <Icon name="arrowRight" className="w-4 h-4" />
              </Link>
              <Link
                href="/assessment"
                className="w-full sm:w-auto text-center text-[14px] font-bold text-navy bg-white/90 backdrop-blur-sm px-6 py-3.5 rounded-xl border border-navy/10 hover:border-navy/30 hover:bg-white transition-all"
              >
                Take Career Assessment
              </Link>
            </div>
          </Reveal>

          <Reveal delay={150} className="relative flex lg:flex-col gap-3 w-full lg:w-auto flex-wrap justify-center">
            {STATS.map((s) => (
              <div
                key={s.label}
                className="flex items-center gap-3 bg-white/90 backdrop-blur-sm rounded-2xl shadow-card border border-white/60 px-5 py-4 min-w-[190px] hover:-translate-y-0.5 transition-transform"
              >
                <div className="w-9 h-9 rounded-[10px] bg-bg-soft flex items-center justify-center text-navy shrink-0">
                  <Icon name={s.icon} className="w-[18px] h-[18px]" />
                </div>
                <div className="text-left">
                  <div className="font-display font-extrabold text-xl text-navy leading-none">
                    {s.value}
                  </div>
                  <div className="text-[11px] font-semibold text-subtle mt-1">
                    {s.label}
                  </div>
                </div>
              </div>
            ))}
          </Reveal>
        </div>
      </Container>
    </section>
  );
}
