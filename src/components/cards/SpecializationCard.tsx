import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Career, Exam, Specialization } from "@/lib/types";

interface SpecializationCardProps {
  specialization: Specialization;
  relatedExams: Exam[];
  relatedCareers?: Career[];
}

interface SpecializationCardVariantProps extends SpecializationCardProps {
  /**
   * "detailed" (default) is used inline on a career's own page, where the
   * whole point is to jump straight from a specialization to the specific
   * exam that covers it, so every exam gets its own chip link. "compact" is
   * for listing pages (e.g. /specializations) where a card sits next to
   * hundreds of others and should look like every other card on the site
   * (CareerCard, JobRoleCard, CertificationCard, ...): icon, title, one-line
   * description, a bit of context, a meta footer -- no chip wall.
   */
  variant?: "detailed" | "compact";
}

export default function SpecializationCard({
  specialization, relatedExams, relatedCareers, variant = "detailed",
}: SpecializationCardVariantProps) {
  if (variant === "compact") {
    return (
      <Link
        href={`/specializations/${specialization.slug}`}
        className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
      >
        <div className="w-11 h-11 rounded-[13px] bg-green-soft flex items-center justify-center text-green">
          <Icon name={specialization.icon} className="w-5 h-5" />
        </div>
        <div className="font-display font-bold text-navy text-[15.5px] mt-4">{specialization.name}</div>
        <div className="text-[12.5px] text-muted mt-1 line-clamp-2">{specialization.description}</div>
        {relatedCareers && relatedCareers.length > 0 && (
          <div className="text-[11px] font-semibold text-subtle mt-3">
            {relatedCareers.map((c) => c.title).join(" · ")}
          </div>
        )}
        {relatedExams.length > 0 && (
          <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
            {relatedExams.length} exam{relatedExams.length === 1 ? "" : "s"}
          </div>
        )}
      </Link>
    );
  }

  return (
    <div className="rounded-2xl border border-line p-5 bg-white flex flex-col hover:border-navy/30 hover:shadow-card transition-all">
      <Link href={`/specializations/${specialization.slug}`} className="flex flex-col flex-1">
        <div className="w-11 h-11 rounded-[13px] bg-green-soft flex items-center justify-center text-green">
          <Icon name={specialization.icon} className="w-5 h-5" />
        </div>
        <div className="font-display font-bold text-navy text-[15.5px] mt-4">{specialization.name}</div>
        <div className="text-[12.5px] text-muted mt-2 leading-relaxed">{specialization.description}</div>
      </Link>
      {relatedExams.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mt-3 pt-3 border-t border-line">
          {relatedExams.map((e) => (
            <Link key={e.slug} href={`/exams/${e.slug}`} className="text-[10.5px] font-semibold px-2 py-1 rounded-full bg-bg-soft text-ink/60 hover:text-navy hover:bg-amber-soft transition-colors">{e.name}</Link>
          ))}
        </div>
      )}
    </div>
  );
}
