import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Exam } from "@/lib/types";

export default function ExamCard({ exam }: { exam: Exam }) {
  return (
    <Link
      href={`/exams/${exam.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="flex items-start justify-between">
        <div className="w-11 h-11 rounded-[13px] bg-amber-soft flex items-center justify-center text-amber">
          <Icon name={exam.icon} className="w-5 h-5" />
        </div>
        <span className="text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-subtle">
          {exam.category}
        </span>
      </div>
      <div className="font-display font-bold text-navy text-[15.5px] mt-4">
        {exam.name}
      </div>
      <div className="text-[12.5px] text-muted mt-1 leading-relaxed">
        {exam.fullName}
      </div>
      <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
        Conducted by {exam.conductedBy}
      </div>
    </Link>
  );
}
