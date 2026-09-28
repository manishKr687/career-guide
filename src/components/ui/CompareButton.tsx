"use client";

import { useEffect, useState } from "react";
import Icon from "@/components/ui/Icon";
import { isComparing, toggleCompare, MAX_COMPARE } from "@/lib/compareList";
import { useToast } from "@/components/ui/Toast";
import { cn } from "@/lib/utils";

export default function CompareButton({
  slug,
  label = true,
  className,
}: {
  slug: string;
  /** Icon-only when false, for tight spaces like a card corner. */
  label?: boolean;
  className?: string;
}) {
  const [comparing, setComparing] = useState(false);
  const [mounted, setMounted] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    // Client-only hydration from localStorage (unavailable during SSR), so
    // this must run after mount rather than during render -- same pattern
    // as SaveButton.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
    setComparing(isComparing(slug));

    // Stay in sync when the list changes from elsewhere on the page (the
    // floating CompareBar's "Clear" action, another CompareButton for the
    // same career, or the /compare page itself removing this slug).
    function sync() {
      setComparing(isComparing(slug));
    }
    window.addEventListener("compare:change", sync);
    window.addEventListener("storage", sync);
    return () => {
      window.removeEventListener("compare:change", sync);
      window.removeEventListener("storage", sync);
    };
  }, [slug]);

  if (!mounted) return null;

  function handleClick(e: React.MouseEvent) {
    e.preventDefault(); // cards are wrapped in a Link -- don't navigate
    e.stopPropagation();
    const { added, slugs } = toggleCompare(slug);
    setComparing(slugs.includes(slug));
    if (!added && !slugs.includes(slug)) {
      // toggled off
      showToast("Removed from comparison", "info");
    } else if (added) {
      showToast("Added to comparison", "success");
    } else {
      showToast(`You can compare up to ${MAX_COMPARE} careers at once`, "error");
    }
  }

  return (
    <button
      onClick={handleClick}
      aria-pressed={comparing}
      aria-label={comparing ? "Remove from comparison" : "Add to comparison"}
      className={cn(
        "inline-flex items-center gap-2 text-[13.5px] font-bold rounded-xl border transition-colors",
        label ? "px-5 py-3" : "w-9 h-9 justify-center rounded-full",
        comparing
          ? "bg-blue-soft text-blue border-transparent"
          : "bg-white text-navy border-line hover:border-navy/30",
        className
      )}
    >
      <Icon name="scale" className="w-4 h-4" />
      {label && (comparing ? "Comparing" : "Compare")}
    </button>
  );
}
