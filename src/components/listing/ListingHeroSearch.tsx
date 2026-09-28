"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import Icon from "@/components/ui/Icon";

/**
 * The hero search box shared by every listing page.
 *
 * There were five near-identical copies of this (careers, degrees, exams,
 * colleges, skills) differing only in a path and a placeholder. This replaces
 * all five.
 *
 * It writes `?q=` rather than holding the query itself, so the page's
 * `useUrlListState` stays the single owner: this pushes the URL, the explorer
 * reads it back, and there is never a second copy to fall out of sync. The
 * rest of the query string survives, so searching does not silently drop the
 * filters someone already set.
 *
 * `basePath` and `anchorId` are the only things that vary. `anchorId` is the
 * results heading, so submitting on a phone scrolls past the hero to what was
 * actually asked for.
 */
export default function ListingHeroSearch({
  basePath,
  anchorId,
  placeholder,
  label,
}: {
  basePath: string;
  anchorId: string;
  placeholder: string;
  /** For the input's accessible name, e.g. "Search careers". */
  label: string;
}) {
  const router = useRouter();
  const [value, setValue] = useState("");

  function submit(e: React.FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams(window.location.search);
    const q = value.trim();
    if (q) params.set("q", q);
    else params.delete("q");
    // A new search invalidates the page number -- page 3 of the old results
    // has nothing to do with the new ones.
    params.delete("page");
    const qs = params.toString();
    router.replace(qs ? `${basePath}?${qs}` : basePath, { scroll: false });
    document.getElementById(anchorId)?.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  return (
    <form
      onSubmit={submit}
      role="search"
      className="flex items-center gap-2 mt-6 max-w-xl rounded-2xl border border-line bg-white px-3 py-2.5 focus-within:border-blue/50 transition-colors"
    >
      <Icon name="search" className="w-[18px] h-[18px] text-subtle shrink-0 ml-1" />
      <input
        type="search"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder={placeholder}
        aria-label={label}
        className="flex-1 min-w-0 bg-transparent text-[14px] text-ink placeholder:text-subtle outline-none"
      />
      <button
        type="submit"
        className="text-[13px] font-bold text-white bg-blue px-5 py-2 rounded-xl shrink-0 hover:opacity-90 transition-opacity"
      >
        Search
      </button>
    </form>
  );
}
