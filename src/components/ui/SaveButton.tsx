"use client";

import { useState } from "react";
import Icon from "@/components/ui/Icon";
import { SavedType } from "@/lib/savedItems";
import { useSavedItems } from "@/components/providers/SavedItemsProvider";
import { cn } from "@/lib/utils";

/**
 * Backed by SavedItemsProvider -- server-synced once logged in, localStorage
 * otherwise (see that provider's doc comment). `ready` covers both the
 * localStorage-hydration flash SaveButton always had, and the extra beat
 * needed to fetch the server list for a logged-in visitor.
 */
export default function SaveButton({
  type,
  slug,
  className,
}: {
  type: SavedType;
  slug: string;
  className?: string;
}) {
  const { isSaved, toggleSaved, ready } = useSavedItems();
  const [pending, setPending] = useState(false);
  const saved = isSaved(type, slug);

  if (!ready) return null;

  async function handleClick() {
    setPending(true);
    try {
      await toggleSaved(type, slug);
    } finally {
      setPending(false);
    }
  }

  return (
    <button
      onClick={handleClick}
      disabled={pending}
      aria-pressed={saved}
      className={cn(
        "inline-flex items-center gap-2 text-[13.5px] font-bold px-5 py-3 rounded-xl border transition-colors disabled:opacity-60",
        saved
          ? "bg-amber-soft text-amber border-transparent"
          : "bg-white text-navy border-line hover:border-navy/30",
        className
      )}
    >
      <Icon name="star" className="w-4 h-4" />
      {saved ? "Saved" : "Save"}
    </button>
  );
}
