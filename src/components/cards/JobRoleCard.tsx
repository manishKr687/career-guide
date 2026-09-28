import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { JobRole } from "@/lib/types";

export default function JobRoleCard({ jobRole }: { jobRole: JobRole }) {
  return (
    <Link
      href={`/job-roles/${jobRole.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="w-11 h-11 rounded-[13px] bg-amber-soft flex items-center justify-center text-amber">
        <Icon name="brief" className="w-5 h-5" />
      </div>
      <div className="font-display font-bold text-navy text-[15.5px] mt-4">
        {jobRole.name}
      </div>
      {jobRole.experienceLevel && (
        <div className="text-[12px] text-subtle mt-0.5">{jobRole.experienceLevel}</div>
      )}
      {jobRole.description && (
        <div className="text-[12.5px] text-muted mt-1 line-clamp-2">{jobRole.description}</div>
      )}
      {(jobRole.salaryMin || jobRole.salaryMax) && (
        <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
          {jobRole.salaryMin} {jobRole.salaryMin && jobRole.salaryMax ? "–" : ""} {jobRole.salaryMax}
        </div>
      )}
    </Link>
  );
}
