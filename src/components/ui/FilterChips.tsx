"use client";

import { cn } from "@/lib/utils";

export default function FilterChips({
  options,
  active,
  onChange,
}: {
  options: { value: string; label: string }[];
  active: string;
  onChange: (v: string) => void;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {options.map((opt) => (
        <button
          key={opt.value}
          onClick={() => onChange(opt.value)}
          className={cn(
            "text-[12.5px] font-semibold px-3.5 py-2 rounded-lg border transition-colors",
            active === opt.value
              ? "bg-navy text-white border-navy"
              : "bg-white text-ink/70 border-line hover:border-navy/30"
          )}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}
