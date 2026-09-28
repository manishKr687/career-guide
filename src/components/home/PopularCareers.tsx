import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import SectionHeader from "@/components/ui/SectionHeader";
import Reveal from "@/components/ui/Reveal";
import { getManyCareers } from "@/data/careers";

// Slugs match the current 42-career taxonomy (V49/V50) -- the previous
// list (data-scientist, doctor-mbbs, lawyer, school-teacher, entrepreneur,
// ...) predated that rebuild and no longer resolved to anything, so this
// section was silently rendering an empty grid under its own heading.
const FEATURED = [
  "computer-science-and-engineering",
  "medicine",
  "law",
  "business-administration",
  "design",
  "finance",
];

const DEMAND_STYLES: Record<string, string> = {
  "High Demand": "bg-amber-soft text-amber",
  Emerging: "bg-purple-soft text-purple",
  Evergreen: "bg-green-soft text-green",
  Stable: "bg-blue-soft text-blue",
  Competitive: "bg-pink-soft text-pink",
};

export default async function PopularCareers() {
  const careers = await getManyCareers(FEATURED);
  return (
    <section className="mt-24 sm:mt-28">
      <Container>
        <Reveal>
          <SectionHeader
            kicker="Popular Career Paths"
            kickerColor="bg-amber-soft text-amber"
            title="Explore detailed career paths"
            description="See required skills, colleges, exams and salary ranges for careers people explore most."
            action={
              <Link
                href="/careers"
                className="text-[13px] font-bold text-navy border border-line rounded-xl px-4 py-2.5 hover:border-navy/30 hover:bg-bg-soft transition-colors inline-flex items-center gap-2 shrink-0"
              >
                View All Career Paths
                <Icon name="arrowRight" className="w-3.5 h-3.5" />
              </Link>
            }
          />
        </Reveal>
        <Reveal delay={100} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {careers.map((career) => (
            <Link
              key={career.slug}
              href={`/careers/${career.slug}`}
              className="group rounded-2xl border border-line p-5 hover:border-transparent hover:shadow-card hover:-translate-y-1 transition-all bg-white flex flex-col"
            >
              <div className="flex items-start justify-between">
                <div className="w-11 h-11 rounded-[13px] bg-bg-soft flex items-center justify-center text-navy group-hover:bg-navy group-hover:text-white transition-colors">
                  <Icon name={career.icon} className="w-5 h-5" />
                </div>
                <span
                  className={`text-[10.5px] font-bold px-2.5 py-1 rounded-full ${DEMAND_STYLES[career.demand]}`}
                >
                  {career.demand}
                </span>
              </div>
              <div className="font-display font-bold text-navy text-[16px] mt-4">
                {career.title}
              </div>
              <div className="text-[12.5px] text-muted mt-1">{career.tagline}</div>
              <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line flex items-center justify-between">
                {career.salaryRange}
                <Icon name="arrowRight" className="w-3.5 h-3.5 text-navy opacity-0 group-hover:opacity-100 group-hover:translate-x-0.5 transition-all" />
              </div>
            </Link>
          ))}
        </Reveal>
      </Container>
    </section>
  );
}
