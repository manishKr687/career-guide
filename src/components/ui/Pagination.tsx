"use client";

import Icon from "@/components/ui/Icon";
import { cn } from "@/lib/utils";

/**
 * Builds a compact page-number list with ellipses, e.g. for page 5 of 20:
 * [1, "ellipsis", 4, 5, 6, "ellipsis", 20]. Always shows the first/last page
 * and a small window around the current page so it stays readable even as
 * the catalog grows well past what fits on screen.
 */
function getPageNumbers(current: number, total: number): (number | "ellipsis")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: (number | "ellipsis")[] = [1];
  if (current > 3) pages.push("ellipsis");

  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);
  for (let p = start; p <= end; p++) pages.push(p);

  if (current < total - 2) pages.push("ellipsis");
  pages.push(total);
  return pages;
}

export default function Pagination({
  page,
  totalPages,
  onChange,
  className,
}: {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
  className?: string;
}) {
  if (totalPages <= 1) return null;
  const pages = getPageNumbers(page, totalPages);

  return (
    <nav
      aria-label="Pagination"
      className={cn("flex items-center justify-center gap-1.5 mt-10", className)}
    >
      <button
        type="button"
        onClick={() => onChange(page - 1)}
        disabled={page === 1}
        aria-label="Previous page"
        className="w-9 h-9 shrink-0 rounded-lg border border-line flex items-center justify-center text-ink/70 hover:border-navy/30 hover:text-navy transition-colors disabled:opacity-30 disabled:pointer-events-none"
      >
        <Icon name="chevRight" className="w-4 h-4 rotate-180" />
      </button>

      {pages.map((p, i) =>
        p === "ellipsis" ? (
          <span
            key={`ellipsis-${i}`}
            className="w-9 h-9 shrink-0 flex items-center justify-center text-[13px] text-subtle"
          >
            &hellip;
          </span>
        ) : (
          <button
            key={p}
            type="button"
            onClick={() => onChange(p)}
            aria-current={p === page ? "page" : undefined}
            className={cn(
              "w-9 h-9 shrink-0 rounded-lg text-[13px] font-bold transition-colors",
              p === page
                ? "bg-navy text-white"
                : "text-ink/70 border border-line hover:border-navy/30 hover:text-navy"
            )}
          >
            {p}
          </button>
        )
      )}

      <button
        type="button"
        onClick={() => onChange(page + 1)}
        disabled={page === totalPages}
        aria-label="Next page"
        className="w-9 h-9 shrink-0 rounded-lg border border-line flex items-center justify-center text-ink/70 hover:border-navy/30 hover:text-navy transition-colors disabled:opacity-30 disabled:pointer-events-none"
      >
        <Icon name="chevRight" className="w-4 h-4" />
      </button>
    </nav>
  );
}
