"use client";

import { useCallback, useRef } from "react";

/**
 * The page-slicing half of a listing page, factored out of the ten Explorer
 * components that each had a byte-identical copy of it.
 *
 * `useUrlListState` already owns the page NUMBER, because that belongs in the
 * URL. This owns what the number means for the current result set: how many
 * pages there are, which slice to render, and scrolling back to the top of the
 * results when the reader pages forward. The split is deliberate -- one hook
 * writes the query string, the other derives from a list, and neither needs to
 * know about the other beyond `page` and `setPage` being passed through.
 *
 * `pageSize` is a required argument rather than a shared constant because the
 * Explorers genuinely disagree: nine show 12 per page and Industries shows 24,
 * whose cards are a single line each. A default would have quietly changed one
 * of them.
 *
 * Returns the same names the Explorers already used -- `paginated`, `safePage`,
 * `totalPages`, `resultsTopRef`, `goToPage` -- so adopting it is a deletion at
 * each call site and touches no JSX.
 */
export function usePagedList<T>(
  items: T[],
  page: number,
  setPage: (next: number) => void,
  pageSize: number
) {
  const totalPages = Math.max(1, Math.ceil(items.length / pageSize));

  // Clamped for display rather than corrected in state. Filtering can shrink
  // the list below the current page while `page` still holds the old number,
  // and calling setPage during render to fix that is exactly what
  // react-hooks/set-state-in-effect warns about. Deriving a clamped value keeps
  // render pure; the stale number survives in the URL until the next
  // interaction, which is harmless and shareable either way.
  const safePage = Math.min(page, totalPages);
  const paginated = items.slice((safePage - 1) * pageSize, safePage * pageSize);

  const resultsTopRef = useRef<HTMLDivElement>(null);

  // Memoised because it is passed as a prop to <Pagination>; a fresh function
  // identity on every render would defeat any memoisation added there later.
  const goToPage = useCallback(
    (next: number) => {
      setPage(next);
      resultsTopRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
    },
    [setPage]
  );

  return { paginated, safePage, totalPages, resultsTopRef, goToPage };
}
