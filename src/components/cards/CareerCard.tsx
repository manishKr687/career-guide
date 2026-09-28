import Link from "next/link";
import Icon from "@/components/ui/Icon";
import CompareButton from "@/components/ui/CompareButton";
import { Career, Category } from "@/lib/types";

const DEMAND_STYLES: Record<string, string> = {
  "High Demand": "bg-amber-soft text-amber",
  Emerging: "bg-purple-soft text-purple",
  Evergreen: "bg-green-soft text-green",
  Stable: "bg-blue-soft text-blue",
  Competitive: "bg-pink-soft text-pink",
};

// `category` is resolved by the caller (rather than looked up here) because
// this card is rendered from both Server Components and a Client Component
// (CareersExplorer) — a Client Component can't import a component that does
// its own async data fetching, so the lookup has to happen upstream, where a
// full categories list is already in hand.
//
// `degreeLabel` is likewise resolved by the caller (see
// getCollegeCareerOfferings in src/data/colleges.ts) — this stays a plain
// presentation prop so CareerCard has no idea what a "college offering" is;
// it just renders whatever string it's given, or nothing when omitted.
//
// `compact`: title + degreeLabel only, no icon/tagline/category/demand/
// salary/compare button — for dense grids like an exam's Career Offerings
// section, which can list a dozen-plus entries at once.
export default function CareerCard({
  career,
  category,
  degreeLabel,
  compact = false,
}: {
  career: Career;
  category?: Category;
  degreeLabel?: string;
  compact?: boolean;
}) {
  if (compact) {
    return (
      <Link
        href={`/careers/${career.slug}`}
        className="rounded-2xl border border-line px-4 py-3.5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex items-center justify-between gap-3"
      >
        <span className="font-display font-bold text-navy text-[13.5px] truncate">{career.title}</span>
        {degreeLabel && (
          <span className="shrink-0 text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-navy/5 text-navy">
            {degreeLabel}
          </span>
        )}
      </Link>
    );
  }

  return (
    <Link
      href={`/careers/${career.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="flex items-start justify-between gap-2">
        <div className="w-11 h-11 rounded-[13px] bg-bg-soft flex items-center justify-center text-navy">
          <Icon name={career.icon} className="w-5 h-5" />
        </div>
        <div className="flex flex-col items-end gap-1.5">
          <span
            className={`text-[10.5px] font-bold px-2.5 py-1 rounded-full ${DEMAND_STYLES[career.demand]}`}
          >
            {career.demand}
          </span>
          {degreeLabel && (
            <span className="text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-navy/5 text-navy">
              {degreeLabel}
            </span>
          )}
        </div>
      </div>
      <div className="font-display font-bold text-navy text-[16px] mt-4">
        {career.title}
      </div>
      <div className="text-[12.5px] text-muted mt-1">{career.tagline}</div>
      {category && (
        <div className="text-[11px] font-semibold text-subtle mt-3">
          {category.name}
        </div>
      )}
      <div className="flex items-center justify-between gap-2 mt-3 pt-3 border-t border-line">
        <span className="text-[12px] text-ink/60">{career.salaryRange}</span>
        <CompareButton slug={career.slug} label={false} />
      </div>
    </Link>
  );
}
