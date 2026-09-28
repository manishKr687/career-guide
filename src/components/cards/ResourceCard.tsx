import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { Resource } from "@/lib/types";
import { formatDate } from "@/lib/utils";

export default function ResourceCard({ resource }: { resource: Resource }) {
  return (
    <Link
      href={`/resources/${resource.slug}`}
      className="rounded-2xl border border-line p-5 hover:shadow-card hover:-translate-y-0.5 transition-all bg-white flex flex-col"
    >
      <div className="flex items-start justify-between">
        <div className="w-11 h-11 rounded-[13px] bg-purple-soft flex items-center justify-center text-purple">
          <Icon name="doc" className="w-5 h-5" />
        </div>
        {resource.resourceType && (
          <span className="text-[10.5px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-subtle">
            {resource.resourceType}
          </span>
        )}
      </div>
      <div className="font-display font-bold text-navy text-[15.5px] mt-4 line-clamp-2">
        {resource.title}
      </div>
      {resource.description && (
        <div className="text-[12.5px] text-muted mt-1 line-clamp-2">{resource.description}</div>
      )}
      {(resource.author || resource.publishedAt) && (
        <div className="text-[12px] text-ink/60 mt-3 pt-3 border-t border-line">
          {resource.author}
          {resource.author && resource.publishedAt ? " · " : ""}
          {resource.publishedAt && formatDate(resource.publishedAt)}
        </div>
      )}
    </Link>
  );
}
