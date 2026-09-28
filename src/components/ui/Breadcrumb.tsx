import Link from "next/link";
import Icon from "@/components/ui/Icon";

/**
 * The `Breadcrumb` primitive the UI architecture doc's Career/Course/Exam/
 * College Detail Page structures all call for. The last item is the
 * current page and renders as plain text (not a link).
 */
export default function Breadcrumb({ items }: { items: { label: string; href?: string }[] }) {
  return (
    <nav aria-label="Breadcrumb" className="mb-6">
      <ol className="flex flex-wrap items-center gap-1.5 text-[12.5px]">
        {items.map((item, i) => {
          const isLast = i === items.length - 1;
          return (
            <li key={i} className="flex items-center gap-1.5">
              {i > 0 && <Icon name="chevRight" className="w-3 h-3 text-subtle" />}
              {item.href && !isLast ? (
                <Link href={item.href} className="font-semibold text-subtle hover:text-navy transition-colors">
                  {item.label}
                </Link>
              ) : (
                <span className={isLast ? "font-semibold text-ink" : "font-semibold text-subtle"} aria-current={isLast ? "page" : undefined}>
                  {item.label}
                </span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
