import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Skill } from "@/lib/types";

export default function SkillCard({ skill }: { skill: Skill }) {
  return (
    <Link
      href={`/skills/${skill.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex items-center gap-4"
    >
      <div className="w-11 h-11 rounded-[13px] bg-blue-soft flex items-center justify-center text-blue shrink-0">
        <Icon name="chip" className="w-5 h-5" />
      </div>
      <div className="min-w-0">
        <div className="font-display font-bold text-navy text-[15px] truncate">
          {skill.name}
        </div>
        {skill.skillType && (
          <div className="text-[11.5px] font-semibold text-subtle mt-1">
            {skill.skillType}
          </div>
        )}
      </div>
    </Link>
  );
}
