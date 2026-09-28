"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { getCompareSlugs, setCompareSlugs } from "@/lib/compareList";

/**
 * A persistent floating bar (mounted once in the root layout, next to
 * ToastProvider) that appears whenever the compare list is non-empty --
 * without it, "Add to comparison" from a career card would have no visible
 * next step until the user thought to go find /compare themselves.
 */
export default function CompareBar() {
  const [slugs, setSlugs] = useState<string[]>([]);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
    setSlugs(getCompareSlugs());

    function sync() {
      setSlugs(getCompareSlugs());
    }
    window.addEventListener("compare:change", sync);
    window.addEventListener("storage", sync);
    return () => {
      window.removeEventListener("compare:change", sync);
      window.removeEventListener("storage", sync);
    };
  }, []);

  if (!mounted || slugs.length === 0) return null;

  return (
    <div className="fixed bottom-5 left-1/2 -translate-x-1/2 z-[150] flex items-center gap-3 bg-navy text-white rounded-2xl shadow-card px-5 py-3">
      <Icon name="scale" className="w-4 h-4" />
      <span className="text-[13px] font-semibold">
        {slugs.length} career{slugs.length === 1 ? "" : "s"} to compare
      </span>
      <Link
        href={`/compare?careers=${slugs.map(encodeURIComponent).join(",")}`}
        className="text-[12.5px] font-bold bg-white text-navy px-3.5 py-1.5 rounded-lg hover:opacity-90 transition-opacity"
      >
        Compare
      </Link>
      <button
        onClick={() => setCompareSlugs([])}
        aria-label="Clear comparison"
        className="text-white/60 hover:text-white transition-colors"
      >
        <Icon name="close" className="w-4 h-4" />
      </button>
    </div>
  );
}
