"use client";

import { useState } from "react";
import Icon from "@/components/ui/Icon";
import { cn } from "@/lib/utils";

/**
 * The `Accordion` primitive from the UI architecture doc's design-system
 * section. Single-open by default (`allowMultiple` opts into independent
 * sections); each item's content is only mounted once expanded, so it's
 * cheap to use for long lists (e.g. FAQ-style content, or grouping a
 * detail page's less-central sections).
 */
export default function Accordion({
  items,
  allowMultiple = false,
  defaultOpen,
}: {
  items: { id: string; title: string; content: React.ReactNode }[];
  allowMultiple?: boolean;
  defaultOpen?: string;
}) {
  const [openIds, setOpenIds] = useState<Set<string>>(new Set(defaultOpen ? [defaultOpen] : []));

  function toggle(id: string) {
    setOpenIds((prev) => {
      const next = allowMultiple ? new Set(prev) : new Set<string>();
      if (prev.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }

  return (
    <div className="rounded-2xl border border-line divide-y divide-line overflow-hidden">
      {items.map((item) => {
        const isOpen = openIds.has(item.id);
        return (
          <div key={item.id}>
            <button
              type="button"
              onClick={() => toggle(item.id)}
              aria-expanded={isOpen}
              className="w-full flex items-center justify-between gap-3 px-5 py-4 text-left"
            >
              <span className="font-display font-bold text-navy text-[14.5px]">{item.title}</span>
              <Icon
                name="chevRight"
                className={cn("w-4 h-4 text-subtle shrink-0 transition-transform", isOpen && "rotate-90")}
              />
            </button>
            {isOpen && <div className="px-5 pb-4 text-[13.5px] text-muted leading-relaxed">{item.content}</div>}
          </div>
        );
      })}
    </div>
  );
}
