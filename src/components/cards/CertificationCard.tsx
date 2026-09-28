import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Certification } from "@/lib/types";

export default function CertificationCard({ certification }: { certification: Certification }) {
  return (
    <Link
      href={`/certifications/${certification.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="flex items-start justify-between">
        <div className="w-11 h-11 rounded-[13px] bg-pink-soft flex items-center justify-center text-pink">
          <Icon name="award" className="w-5 h-5" />
        </div>
        {certification.level && (
          <span className="text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-subtle">
            {certification.level}
          </span>
        )}
      </div>
      <div className="font-display font-bold text-navy text-[15.5px] mt-4">
        {certification.name}
      </div>
      {certification.provider && (
        <div className="text-[12.5px] text-muted mt-1">{certification.provider}</div>
      )}
      {certification.duration && (
        <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
          {certification.duration}
        </div>
      )}
    </Link>
  );
}
