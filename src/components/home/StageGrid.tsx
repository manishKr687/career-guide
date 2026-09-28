import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import SectionHeader from "@/components/ui/SectionHeader";
import Reveal from "@/components/ui/Reveal";
import { getStages } from "@/data/stages";

export default async function StageGrid() {
  const stages = await getStages();
  return (
    <section className="mt-24 sm:mt-28">
      <Container>
        <Reveal>
          <SectionHeader
            kicker="Choose Your Stage"
            kickerColor="bg-blue-soft text-blue"
            title="Get guidance for exactly where you are"
            description="CareerGuide isn't just for after 10th — pick the stage that matches your journey today."
          />
        </Reveal>
        <Reveal delay={100} className="grid grid-cols-1 xs:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          {stages.map((stage) => (
            <Link
              key={stage.slug}
              href={`/stage/${stage.slug}`}
              className={`group rounded-3xl p-5 flex flex-col ring-1 ring-black/[0.03] hover:ring-black/[0.06] hover:-translate-y-1 hover:shadow-card transition-all ${stage.badgeSoft.split(" ")[0]}`}
            >
              <div
                className={`w-11 h-11 rounded-[13px] flex items-center justify-center ${stage.badgeSolid}`}
              >
                <Icon name={stage.icon} className="w-5 h-5" />
              </div>
              <div className="font-display font-extrabold text-navy text-[15.5px] mt-4">
                {stage.name}
              </div>
              <div className="text-[12px] text-ink/60 mt-1 leading-snug">
                {stage.tagline}
              </div>
              <div className="mt-4 flex items-center gap-1.5 text-[12.5px] font-bold text-navy opacity-0 group-hover:opacity-100 transition-opacity">
                Explore
                <Icon name="arrowRight" className="w-3.5 h-3.5" />
              </div>
            </Link>
          ))}
        </Reveal>
      </Container>
    </section>
  );
}
