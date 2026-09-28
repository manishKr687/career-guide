import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Industry } from "@/lib/types";

export default function IndustryCard({ industry }: { industry: Industry }) {
  return (
    <Link
      href={`/industries/${industry.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex items-center gap-4"
    >
      <div className="w-11 h-11 rounded-[13px] bg-green-soft flex items-center justify-center text-green shrink-0">
        <Icon name="building" className="w-5 h-5" />
      </div>
      <div className="min-w-0">
        <div className="font-display font-bold text-navy text-[15px] truncate">
          {industry.name}
        </div>
        <div className="text-[11.5px] font-semibold text-subtle mt-1">
          {industry.isSector ? "Sector" : "Employer"}
        </div>
      </div>
    </Link>
  );
}
