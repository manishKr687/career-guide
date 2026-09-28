"use client";

import Icon from "@/components/ui/Icon";

export default function SearchInput({
  value,
  onChange,
  placeholder = "Search...",
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}) {
  return (
    <div className="relative flex-1 min-w-[220px]">
      <Icon
        name="search"
        className="w-4 h-4 text-subtle absolute left-4 top-1/2 -translate-y-1/2"
      />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full rounded-xl border border-line pl-11 pr-4 py-3 text-[13.5px] font-medium text-ink placeholder:text-subtle focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors"
      />
    </div>
  );
}
