"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Category, Degree } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";
import { useUrlListState } from "@/hooks/useUrlListState";
import {
  CheckRow,
  Chip,
  FilterGroup,
  NONE,
  QuickPick,
  joinParam,
  splitParam,
} from "@/components/listing/ListingKit";

const PAGE_SIZE = 12;

// The catalog's own five levels, in the order a student climbs them rather
// than alphabetically -- Certificate and Diploma sit below a bachelor's.
const LEVEL_OPTIONS = ["Certificate", "Diploma", "Undergraduate", "Postgraduate", "Doctoral"];

const LEVEL_STYLES: Record<string, string> = {
  Certificate: "bg-slate-soft text-slate",
  Diploma: "bg-amber-soft text-amber",
  Undergraduate: "bg-blue-soft text-blue",
  Postgraduate: "bg-purple-soft text-purple",
  Doctoral: "bg-pink-soft text-pink",
};

/**
 * Duration buckets, matched on the SHORTEST the programme can run.
 *
 * A degree's duration is a range (PhD is 3-5 years), so a bucket needs one end
 * to test. The minimum is the right one: someone filtering "2 years" is asking
 * what they can commit to, and the floor is the commitment. `max: null` is
 * open-ended.
 *
 * Degrees with no duration at all -- the three higher doctorates, which are
 * awarded on submitted published work rather than taught -- match no bucket.
 * That is correct: they have no length to filter on.
 */
const DURATION_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "to-1", label: "1 year or less", min: 0, max: 1 },
  { id: "2", label: "2 years", min: 1, max: 2 },
  { id: "3", label: "3 years", min: 2, max: 3 },
  { id: "4", label: "4 years", min: 3, max: 4 },
  { id: "5plus", label: "5 years or more", min: 4, max: null },
];

const SORTS = [
  { value: "popularity", label: "Popularity" },
  { value: "az", label: "A – Z" },
  { value: "duration-short", label: "Duration: shortest" },
  { value: "duration-long", label: "Duration: longest" },
  { value: "specializations", label: "Most specializations" },
];

// Multi-selects ride in the single-value slots useUrlListState provides,
// comma-joined, so /degrees?level=Undergraduate,Diploma stays shareable.

export default function DegreesExplorer({
  initialDegrees,
  categories,
  specializationCounts,
  filteredForCareer,
}: {
  initialDegrees: Degree[];
  categories: Category[];
  /** slug -> specializations reachable through this degree; see the page. */
  specializationCounts: Record<string, number>;
  /** Set when the page arrived with ?career=, so the explorer can say so. */
  filteredForCareer: string | null;
}) {
  const {
    query,
    setQuery,
    filter: category,
    setFilter: setCategory,
    filter2: levelParam,
    setFilter2: setLevelParam,
    filter3: durationParam,
    setFilter3: setDurationParam,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("category", "all", "level", NONE, "duration", NONE, "sort", "popularity");

  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  const levels = splitParam(levelParam);
  const durations = splitParam(durationParam);

  function toggle(list: string[], value: string, set: (v: string) => void) {
    set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
  }

  function reset() {
    setCategory("all");
    setLevelParam(NONE);
    setDurationParam(NONE);
    setQuery("");
  }

  const activeCount =
    (category !== "all" ? 1 : 0) + levels.length + durations.length + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialDegrees.filter((d) => {
      if (category !== "all" && d.categorySlug !== category) return false;
      if (levels.length > 0 && !levels.includes(d.level)) return false;

      if (durations.length > 0) {
        const min = d.durationMinYears;
        if (min === null) return false;
        const inBand = durations.some((id) => {
          const b = DURATION_BUCKETS.find((x) => x.id === id);
          if (!b) return false;
          return min > b.min && min <= (b.max ?? Infinity);
        });
        if (!inBand) return false;
      }

      if (q === "") return true;
      // The full title is what someone typing "bachelor of technology" is
      // searching for -- matching only the abbreviation would miss it.
      return (
        d.title.toLowerCase().includes(q) ||
        (d.fullTitle?.toLowerCase().includes(q) ?? false) ||
        d.description.toLowerCase().includes(q)
      );
    });
  }, [initialDegrees, query, category, levelParam, durationParam]); // eslint-disable-line react-hooks/exhaustive-deps

  const sorted = useMemo(() => {
    const list = [...filtered];
    const specs = (d: Degree) => specializationCounts[d.slug] ?? 0;
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.title.localeCompare(b.title));
      case "duration-short":
        return list.sort((a, b) => (a.durationMinYears ?? Infinity) - (b.durationMinYears ?? Infinity));
      case "duration-long":
        return list.sort((a, b) => (b.durationMaxYears ?? -1) - (a.durationMaxYears ?? -1));
      case "specializations":
        return list.sort((a, b) => specs(b) - specs(a));
      default:
        // "Popularity": how many specializations the degree opens up, which is
        // the closest thing the catalog has to how much a degree matters.
        return list.sort((a, b) => specs(b) - specs(a) || a.title.localeCompare(b.title));
    }
  }, [filtered, sort, specializationCounts]);

  const totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const safePage = Math.min(page, totalPages);
  const paginated = sorted.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  const resultsTopRef = useRef<HTMLDivElement>(null);
  function goToPage(next: number) {
    setPage(next);
    resultsTopRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  // Counts from the UNFILTERED list, so a facet always says how many degrees
  // it holds rather than how many survive the current filter.
  const categoryCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const d of initialDegrees) {
      if (d.categorySlug) counts.set(d.categorySlug, (counts.get(d.categorySlug) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [initialDegrees, categoriesBySlug]);

  const levelCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const d of initialDegrees) counts.set(d.level, (counts.get(d.level) ?? 0) + 1);
    return LEVEL_OPTIONS.filter((l) => counts.has(l)).map((l) => ({
      level: l,
      count: counts.get(l) ?? 0,
    }));
  }, [initialDegrees]);

  // The quick-pick strip above the results: the biggest categories, plus an
  // "All" chip. Same source as the sidebar list, so the two cannot disagree.
  const quickPicks = categoryCounts.slice(0, 7);

  return (
    <Container className="py-8 pb-24">
      {/* Category quick-picks, the mock's strip under the hero. A second way
          into the same filter the sidebar offers -- kept because it is the one
          most readers will actually use. */}
      <div className="flex gap-3 overflow-x-auto pb-2 mb-8 -mx-1 px-1">
        <QuickPick
          active={category === "all"}
          onClick={() => setCategory("all")}
          icon="grid"
          label="All Degrees"
          count={initialDegrees.length}
        />
        {quickPicks.map(({ category: c, count }) => (
          <QuickPick
            key={c!.slug}
            active={category === c!.slug}
            onClick={() => setCategory(category === c!.slug ? "all" : c!.slug)}
            icon={c!.icon}
            label={c!.name}
            count={count}
          />
        ))}
      </div>

      <div className="flex flex-col lg:flex-row lg:items-start gap-8">
        {/* ------------------------------------------------------------ Results */}
        <div className="flex-1 min-w-0 order-2 lg:order-1">
          <div id="all-degrees" className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24">
            <div>
              <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
                <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
                All Degrees
              </h2>
              <p className="text-[13px] text-muted mt-1.5">
                {filteredForCareer
                  ? `Degrees that lead into ${filteredForCareer}.`
                  : "Explore different degree options and find the one that matches your interests."}
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <span className="text-[13px] font-semibold text-subtle">
                {sorted.length > PAGE_SIZE
                  ? `Showing ${(safePage - 1) * PAGE_SIZE + 1}–${Math.min(safePage * PAGE_SIZE, sorted.length)} of ${sorted.length} degrees`
                  : `${sorted.length} degree${sorted.length === 1 ? "" : "s"}`}
              </span>
              <label className="flex items-center gap-2">
                <span className="text-[12.5px] font-semibold text-muted">Sort by</span>
                <select
                  value={sort}
                  onChange={(e) => setSort(e.target.value)}
                  className="rounded-xl border border-line bg-white px-3 py-2 text-[13px] font-semibold text-navy"
                >
                  {SORTS.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </label>
              <div className="flex items-center rounded-xl border border-line overflow-hidden">
                {(["grid", "list"] as const).map((v) => (
                  <button
                    key={v}
                    type="button"
                    onClick={() => setView(v)}
                    aria-pressed={view === v}
                    aria-label={`${v} view`}
                    className={`w-9 h-9 flex items-center justify-center transition-colors ${
                      view === v ? "bg-blue text-white" : "bg-white text-subtle hover:text-navy"
                    }`}
                  >
                    <Icon name={v} className="w-4 h-4" />
                  </button>
                ))}
              </div>
            </div>
          </div>

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {category !== "all" && (
                <Chip onRemove={() => setCategory("all")}>
                  {categoriesBySlug.get(category)?.name ?? category}
                </Chip>
              )}
              {levels.map((l) => (
                <Chip key={l} onRemove={() => toggle(levels, l, setLevelParam)}>
                  {l}
                </Chip>
              ))}
              {durations.map((id) => (
                <Chip key={id} onRemove={() => toggle(durations, id, setDurationParam)}>
                  {DURATION_BUCKETS.find((b) => b.id === id)?.label ?? id}
                </Chip>
              ))}
              <button
                type="button"
                onClick={reset}
                className="text-[12.5px] font-semibold text-blue hover:underline ml-1"
              >
                Clear all
              </button>
            </div>
          )}

          {sorted.length > 0 ? (
            <>
              <div
                className={
                  view === "grid"
                    ? "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5"
                    : "flex flex-col gap-3"
                }
              >
                {paginated.map((degree) => (
                  <DegreeListCard
                    key={degree.slug}
                    degree={degree}
                    specializations={specializationCounts[degree.slug] ?? 0}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <div className="text-center py-20">
              <p className="text-muted text-sm">No degrees match these filters.</p>
              {activeCount > 0 && (
                <button
                  type="button"
                  onClick={reset}
                  className="mt-4 text-[13.5px] font-bold text-white bg-navy px-5 py-2.5 rounded-xl hover:bg-navy-2 transition-colors"
                >
                  Clear filters
                </button>
              )}
            </div>
          )}
        </div>

        {/* ------------------------------------------------------------ Sidebar */}
        <aside className="w-full lg:w-[264px] lg:shrink-0 order-1 lg:order-2 lg:sticky lg:top-24">
          <button
            type="button"
            onClick={() => setFiltersOpen((v) => !v)}
            aria-expanded={filtersOpen}
            className="lg:hidden w-full flex items-center justify-between gap-2 rounded-2xl border border-line bg-white px-4 py-3 mb-3"
          >
            <span className="flex items-center gap-2 font-display font-extrabold text-navy text-[14px]">
              <Icon name="filter" className="w-4 h-4 text-blue" />
              Filters
              {activeCount > 0 && (
                <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-blue text-white">
                  {activeCount}
                </span>
              )}
            </span>
            <Icon
              name="arrowDown"
              className={`w-3.5 h-3.5 text-subtle transition-transform ${filtersOpen ? "rotate-180" : ""}`}
            />
          </button>

          <div className={`${filtersOpen ? "flex" : "hidden"} lg:flex flex-col gap-5`}>
            <div className="rounded-3xl border border-line bg-white p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
                  <Icon name="filter" className="w-4 h-4 text-blue" />
                  Filter Degrees
                </h2>
                <button
                  type="button"
                  onClick={reset}
                  disabled={activeCount === 0}
                  className="text-[12.5px] font-semibold text-blue hover:underline disabled:text-subtle disabled:no-underline disabled:cursor-default"
                >
                  Reset
                </button>
              </div>

              <FilterGroup label="Category">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy mb-2.5"
                >
                  <option value="all">All Categories</option>
                  {categoryCounts.map(({ category: c }) => (
                    <option key={c!.slug} value={c!.slug}>
                      {c!.name}
                    </option>
                  ))}
                </select>
                <div className="flex flex-col gap-2">
                  {categoryCounts.slice(0, 8).map(({ category: c, count }) => (
                    <CheckRow
                      key={c!.slug}
                      checked={category === c!.slug}
                      onChange={() => setCategory(category === c!.slug ? "all" : c!.slug)}
                      count={count}
                    >
                      <Icon name={c!.icon} className="w-3.5 h-3.5 text-subtle shrink-0" />
                      <span className="text-[12.5px] text-ink/80 truncate">{c!.name}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              <FilterGroup label="Degree Level">
                <div className="flex flex-col gap-2">
                  {levelCounts.map(({ level, count }) => (
                    <CheckRow
                      key={level}
                      checked={levels.includes(level)}
                      onChange={() => toggle(levels, level, setLevelParam)}
                      count={count}
                    >
                      <span className="text-[12.5px] text-ink/80">{level}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              <FilterGroup label="Duration">
                <div className="flex flex-col gap-2">
                  {DURATION_BUCKETS.map((b) => (
                    <CheckRow
                      key={b.id}
                      checked={durations.includes(b.id)}
                      onChange={() => toggle(durations, b.id, setDurationParam)}
                    >
                      <span className="text-[12.5px] text-ink/80">{b.label}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              <button
                type="button"
                onClick={() => {
                  setFiltersOpen(false);
                  document
                    .getElementById("all-degrees")
                    ?.scrollIntoView({ behavior: "smooth", block: "start" });
                }}
                className="w-full mt-5 text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                Show {sorted.length} degree{sorted.length === 1 ? "" : "s"}
              </button>
            </div>
          </div>
        </aside>
      </div>
    </Container>
  );
}

/**
 * The listing card: abbreviation, what it stands for, description, then the
 * three figures the mock puts in a footer strip -- level, duration and how
 * many specializations the degree opens up.
 *
 * Separate from the shared DegreeCard, which other pages render; changing that
 * one to carry this footer would have rewritten all of them.
 */
function DegreeListCard({
  degree,
  specializations,
  view,
}: {
  degree: Degree;
  specializations: number;
  view: "grid" | "list";
}) {
  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      <span className="flex items-center gap-1.5 min-w-0">
        <Icon name="cap" className="w-3.5 h-3.5 text-subtle shrink-0" />
        <span
          className={`font-bold text-[11.5px] px-2 py-0.5 rounded-full ${LEVEL_STYLES[degree.level] ?? "bg-slate-soft text-slate"}`}
        >
          {degree.level}
        </span>
      </span>
      {degree.durationLabel && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="clock" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {degree.durationLabel}
        </span>
      )}
      {specializations > 0 && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="book" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {specializations} specializations
        </span>
      )}
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/degrees/${degree.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={degree.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15.5px]">
            {degree.title}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 line-clamp-1">
            {degree.fullTitle ?? degree.description}
          </span>
        </span>
        <span className="hidden sm:block shrink-0">{figures}</span>
        <Icon
          name="chevRight"
          className="w-4 h-4 text-subtle shrink-0 group-hover:text-blue transition-colors"
        />
      </Link>
    );
  }

  return (
    <Link
      href={`/degrees/${degree.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-3">
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={degree.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[16px] leading-snug">
              {degree.title}
            </span>
            <Icon
              name="chevRight"
              className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
            />
          </span>
          {degree.fullTitle && (
            <span className="block text-[12.5px] font-semibold text-ink/60 mt-0.5 leading-snug">
              {degree.fullTitle}
            </span>
          )}
        </span>
      </div>
      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-3 flex-1">
        {degree.description}
      </p>
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
