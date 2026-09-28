import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Degree } from "@/lib/types";

export default function DegreeCard({ degree }: { degree: Degree }) {
  return (
    <Link
      href={`/degrees/${degree.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="w-11 h-11 rounded-[13px] bg-blue-soft flex items-center justify-center text-blue">
        <Icon name={degree.icon} className="w-5 h-5" />
      </div>
      <div className="font-display font-bold text-navy text-[16px] mt-4">
        {degree.title}
      </div>
      <div className="text-[12.5px] text-muted mt-1.5 leading-relaxed line-clamp-3">
        {degree.description}
      </div>
      <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
        {degree.entranceExamSlugs.length > 0
          ? `${degree.entranceExamSlugs.length} entrance exam${degree.entranceExamSlugs.length === 1 ? "" : "s"}`
          : "No standard entrance exam"}
      </div>
    </Link>
  );
}
