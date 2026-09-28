"use client";

import { cn } from "@/lib/utils";

/**
 * The `Tabs` primitive from the UI architecture doc's design-system section
 * -- controlled, content rendered by the caller (mirrors `FilterChips`'
 * shape). Intended for e.g. a future Saved Items view split into
 * Careers/Courses/Colleges/Exams tabs (doc section 30).
 */
export default function Tabs({
  tabs,
  active,
  onChange,
}: {
  tabs: { value: string; label: string }[];
  active: string;
  onChange: (value: string) => void;
}) {
  return (
    <div role="tablist" className="flex gap-1 border-b border-line overflow-x-auto">
      {tabs.map((tab) => (
        <button
          key={tab.value}
          type="button"
          role="tab"
          aria-selected={active === tab.value}
          onClick={() => onChange(tab.value)}
          className={cn(
            "shrink-0 text-[13px] font-bold px-4 py-2.5 border-b-2 -mb-px transition-colors",
            active === tab.value
              ? "border-navy text-navy"
              : "border-transparent text-subtle hover:text-ink"
          )}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
}
