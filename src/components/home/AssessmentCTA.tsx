import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import Reveal from "@/components/ui/Reveal";

export default function AssessmentCTA() {
  return (
    <section className="mt-24 sm:mt-28">
      <Container>
        <Reveal className="rounded-[28px] bg-gradient-to-br from-navy to-navy-2 px-6 py-14 sm:px-14 sm:py-16 text-center relative overflow-hidden ring-1 ring-white/5">
          <div className="absolute -top-16 -right-16 w-72 h-72 rounded-full bg-purple/20 blur-3xl" />
          <div className="absolute -bottom-20 -left-10 w-80 h-80 rounded-full bg-blue/20 blur-3xl" />
          <div className="relative">
            <div className="w-14 h-14 rounded-2xl bg-white/10 flex items-center justify-center mx-auto ring-1 ring-white/10">
              <Icon name="target" className="w-7 h-7 text-amber" />
            </div>
            <h2 className="font-display font-extrabold text-white text-2xl sm:text-[2rem] mt-6 text-balance">
              Not Sure What To Choose?
            </h2>
            <p className="text-white/60 text-[15px] mt-3 max-w-lg mx-auto leading-relaxed">
              Take a short career assessment covering your interests,
              strengths, academics and goals &mdash; and get a personalized
              set of career recommendations in minutes.
            </p>
            <Link
              href="/assessment"
              className="inline-flex items-center gap-2 mt-8 bg-white text-navy font-bold text-[14px] px-7 py-3.5 rounded-xl hover:shadow-[0_10px_30px_-8px_rgba(255,255,255,0.35)] transition-all"
            >
              Take the Career Assessment
              <Icon name="arrowRight" className="w-4 h-4" />
            </Link>
          </div>
        </Reveal>
      </Container>
    </section>
  );
}
