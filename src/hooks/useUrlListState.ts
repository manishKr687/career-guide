"use client";

import { useCallback, useEffect, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";

/**
 * Keeps a listing page's search/filter/page state in the URL's query
 * string, so results are shareable and bookmarkable (see the UI
 * architecture doc's "Filtering Architecture" section) -- e.g.
 * `/careers?category=engineering-technology&q=robot&page=2`.
 *
 * `filterKey` is the query param name for this page's single-select filter
 * (e.g. "category", "level", "type"); `defaultFilter` is the value that
 * means "no filter" and is omitted from the URL entirely (e.g. "all").
 *
 * `secondFilterKey`/`secondDefaultFilter` add an optional second,
 * independent filter dimension (e.g. Specializations' "career" filter
 * alongside its existing "category" one) -- omit both to get the original
 * single-filter behavior untouched; every other page using this hook
 * passes neither and is unaffected. `thirdFilterKey`/`thirdDefaultFilter`
 * add an optional third dimension the same way (added in V53 for
 * Colleges' "state" filter alongside its existing "type" one) --
 * `fourthFilterKey`/`fourthDefaultFilter` add a fourth (added for Job
 * Roles' "career" filter between its "category" and "specialization"
 * ones) -- omit whichever trailing ones a page doesn't need to leave the
 * fewer-filter behavior exactly as before.
 *
 * Returns live `query`/`filter`/`filter2`/`filter3`/`filter4`/`page` state
 * for filtering + pagination (all applied client-side against an
 * already-fetched list -- this hook only makes the *state* shareable, it
 * doesn't change where filtering happens), and
 * `setQuery`/`setFilter`/`setFilter2`/`setFilter3`/`setFilter4`/`setPage`
 * setters. Changing `query`, `filter`, `filter2`, `filter3` or `filter4`
 * always resets `page` back to 1, since a new search/filter combined with
 * an old page number could otherwise land on an out-of-range page.
 */
export function useUrlListState(
  filterKey: string,
  defaultFilter = "all",
  secondFilterKey?: string,
  secondDefaultFilter = "all",
  thirdFilterKey?: string,
  thirdDefaultFilter = "all",
  fourthFilterKey?: string,
  fourthDefaultFilter = "all"
) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [query, setQueryState] = useState(() => searchParams.get("q") ?? "");
  const [filter, setFilterState] = useState(() => searchParams.get(filterKey) ?? defaultFilter);
  const [filter2, setFilter2State] = useState(() =>
    secondFilterKey ? searchParams.get(secondFilterKey) ?? secondDefaultFilter : secondDefaultFilter
  );
  const [filter3, setFilter3State] = useState(() =>
    thirdFilterKey ? searchParams.get(thirdFilterKey) ?? thirdDefaultFilter : thirdDefaultFilter
  );
  const [filter4, setFilter4State] = useState(() =>
    fourthFilterKey ? searchParams.get(fourthFilterKey) ?? fourthDefaultFilter : fourthDefaultFilter
  );
  const [page, setPage] = useState(() => {
    const p = Number(searchParams.get("page"));
    return Number.isFinite(p) && p > 0 ? p : 1;
  });

  // Reflect the URL back into state when it changes from outside this
  // component -- e.g. a Link elsewhere on the site (the homepage's category
  // grid) landing here with a pre-set filter while this page is already
  // mounted.
  useEffect(() => {
    // Syncing FROM the URL (an external source), not deriving state from
    // props/state, so this is exactly what an effect is for.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setQueryState(searchParams.get("q") ?? "");
    setFilterState(searchParams.get(filterKey) ?? defaultFilter);
    setFilter2State(secondFilterKey ? searchParams.get(secondFilterKey) ?? secondDefaultFilter : secondDefaultFilter);
    setFilter3State(thirdFilterKey ? searchParams.get(thirdFilterKey) ?? thirdDefaultFilter : thirdDefaultFilter);
    setFilter4State(fourthFilterKey ? searchParams.get(fourthFilterKey) ?? fourthDefaultFilter : fourthDefaultFilter);
    const p = Number(searchParams.get("page"));
    setPage(Number.isFinite(p) && p > 0 ? p : 1);
  }, [searchParams, filterKey, defaultFilter, secondFilterKey, secondDefaultFilter, thirdFilterKey, thirdDefaultFilter, fourthFilterKey, fourthDefaultFilter]);

  // Debounce the free-text query specifically so the URL isn't rewritten on
  // every keystroke -- the `filtered` list in each Explorer still reacts to
  // the live `query` instantly, only the URL write lags behind slightly.
  const [debouncedQuery, setDebouncedQuery] = useState(query);
  useEffect(() => {
    const id = setTimeout(() => setDebouncedQuery(query), 400);
    return () => clearTimeout(id);
  }, [query]);

  // Search params this hook doesn't own -- e.g. `career` on /degrees, set by
  // an incoming Link from a career's page to pre-filter the list server-side
  // -- must survive every replace() below. Captured ONCE, lazily, rather
  // than re-derived from the live `searchParams` on every render: this hook
  // already writes back to the URL itself, so treating live `searchParams`
  // as a source for this would risk a replace -> new searchParams -> effect
  // fires again loop. A foreign param set after mount (e.g. by a Link click
  // while already on this page) is handled by the page component re-reading
  // its own props on the resulting navigation, same as before this fix --
  // this only prevents THIS hook from stripping it out from under that read.
  const [foreignParams] = useState(() => {
    const params = new URLSearchParams(searchParams.toString());
    params.delete("q");
    params.delete(filterKey);
    if (secondFilterKey) params.delete(secondFilterKey);
    if (thirdFilterKey) params.delete(thirdFilterKey);
    if (fourthFilterKey) params.delete(fourthFilterKey);
    params.delete("page");
    return params;
  });

  // Push state back to the URL. `replace`, not `push`, so filtering/paging
  // doesn't spam browser history with an entry per keystroke or click.
  useEffect(() => {
    const params = new URLSearchParams(foreignParams);
    if (debouncedQuery.trim()) params.set("q", debouncedQuery.trim());
    if (filter !== defaultFilter) params.set(filterKey, filter);
    if (secondFilterKey && filter2 !== secondDefaultFilter) params.set(secondFilterKey, filter2);
    if (thirdFilterKey && filter3 !== thirdDefaultFilter) params.set(thirdFilterKey, filter3);
    if (fourthFilterKey && filter4 !== fourthDefaultFilter) params.set(fourthFilterKey, filter4);
    if (page > 1) params.set("page", String(page));
    const qs = params.toString();
    router.replace(qs ? `${pathname}?${qs}` : pathname, { scroll: false });
  }, [debouncedQuery, filter, filter2, filter3, filter4, page, pathname, router, filterKey, defaultFilter, secondFilterKey, secondDefaultFilter, thirdFilterKey, thirdDefaultFilter, fourthFilterKey, fourthDefaultFilter, foreignParams]);

  const setQuery = useCallback((value: string) => {
    setQueryState(value);
    setPage(1);
  }, []);

  const setFilter = useCallback((value: string) => {
    setFilterState(value);
    setPage(1);
  }, []);

  const setFilter2 = useCallback((value: string) => {
    setFilter2State(value);
    setPage(1);
  }, []);

  const setFilter3 = useCallback((value: string) => {
    setFilter3State(value);
    setPage(1);
  }, []);

  const setFilter4 = useCallback((value: string) => {
    setFilter4State(value);
    setPage(1);
  }, []);

  return {
    query,
    setQuery,
    filter,
    setFilter,
    filter2,
    setFilter2,
    filter3,
    setFilter3,
    filter4,
    setFilter4,
    page,
    setPage,
  };
}
