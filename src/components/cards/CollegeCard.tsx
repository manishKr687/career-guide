import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { College } from "@/lib/types";

export default function CollegeCard({ college }: { college: College }) {
  return (
    <Link
      href={`/colleges/${college.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="flex items-start justify-between">
        <div className="w-11 h-11 rounded-[13px] bg-purple-soft flex items-center justify-center text-purple">
          <Icon name="bld" className="w-5 h-5" />
        </div>
        <span className="text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-subtle">
          {college.type}
        </span>
      </div>
      <div className="font-display font-bold text-navy text-[15.5px] mt-4">
        {college.name}
      </div>
      <div className="text-[12.5px] text-muted mt-1 flex items-center gap-1.5">
        <Icon name="mappin" className="w-3.5 h-3.5" />
        {college.location}
      </div>
      <div className="flex flex-wrap gap-1.5 mt-3 pt-3 border-t border-line">
        {college.tags.slice(0, 3).map((t) => (
          <span
            key={t}
            className="text-[10.5px] font-semibold px-2 py-1 rounded-full bg-bg-soft text-ink/60"
          >
            {t}
          </span>
        ))}
      </div>
    </Link>
  );
}
