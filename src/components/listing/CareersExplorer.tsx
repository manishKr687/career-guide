"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Career, Category } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";
import { useUrlListState } from "@/hooks/useUrlListState";
import { usePagedList } from "@/hooks/usePagedList";
import {
  CheckRow,
  Chip,
  FilterGroup,
  NONE,
  joinParam,
  splitParam,
} from "@/components/listing/ListingKit";

const PAGE_SIZE = 12;

// The catalog's actual demand vocabulary, not the mock's Very High / High /
// Medium / Low. Offering a "Very High" box that matches nothing would be a
// filter that silently returns zero results.
const DEMAND_OPTIONS = ["High Demand", "Emerging", "Evergreen", "Stable", "Competitive"];

const DEMAND_STYLES: Record<string, string> = {
  "High Demand": "bg-green-soft text-green",
  Emerging: "bg-purple-soft text-purple",
  Evergreen: "bg-teal-soft text-teal",
  Stable: "bg-blue-soft text-blue",
  Competitive: "bg-amber-soft text-amber",
};

// Just the hue from DEMAND_STYLES, for the compact sidebar rows: a dot carries
// the colour so the label can stay plain text. Five full-size pills stacked
// vertically made the filter panel taller than the first row of results.
const DEMAND_DOTS: Record<string, string> = {
  "High Demand": "bg-green",
  Emerging: "bg-purple",
  Evergreen: "bg-teal",
  Stable: "bg-blue",
  Competitive: "bg-amber",
};

/**
 * Salary buckets, matched on a career's CEILING -- the top of its range.
 *
 * Two earlier cuts were wrong against the real data, and it is worth saying
 * why. The mock's bands (< 5, 5-10, 10-20, 20-30, > 30 LPA) assume careers
 * spread across the whole scale. These 42 do not: every one starts at
 * Rs 3-5 LPA and tops out between Rs 15 and Rs 40 LPA. So bucketing by range
 * OVERLAP made "< 5 LPA" match all 42 -- a filter that returns everything --
 * and the mock's two lowest bands would never have matched a single career
 * on their own.
 *
 * The ceiling is also the more useful question. "How far can this career take
 * me" is what someone filtering on pay is asking; the floor is nearly
 * constant across the catalog and so tells them nothing.
 *
 * Cut points follow the actual distribution (ceilings at 15, 18, 20, 25, 30,
 * 35 and 40), which puts 8 / 9 / 21 / 4 careers in the four bands. Re-cut
 * these if the spread changes; a band nothing can land in is a dead control.
 *
 * Half-open [min, max): a career topping out at exactly Rs 30 LPA belongs to
 * the 30-40 band, not the 20-30 one. `max: null` is open-ended.
 */
const SALARY_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "to-20", label: "Up to \u20B920L", min: 0, max: 20 },
  { id: "20-30", label: "\u20B920 \u2013 30L", min: 20, max: 30 },
  { id: "30-40", label: "\u20B930 \u2013 40L", min: 30, max: 40 },
  { id: "40+", label: "\u20B940L+", min: 40, max: null },
];

const SORTS = [
  { value: "popularity", label: "Popularity" },
  { value: "az", label: "A – Z" },
  { value: "salary-high", label: "Salary: high to low" },
  { value: "salary-low", label: "Salary: low to high" },
  { value: "specializations", label: "Most specializations" },
];


/**
 * The fields this listing renders. Absent on purpose: `description` (22 KB),
 * `growthStages` (17 KB) and `typicalWork` (13 KB), none of which a card shows --
 * the cards use `tagline`. Together with the other unused relations that is most
 * of a 153 KB payload, serialised twice because this is a client component.
 */
export type CareerListItem = Pick<
  Career,
  | "slug" | "title" | "categorySlug" | "tagline" | "demand" | "icon"
  | "salaryMinLpa" | "salaryMaxLpa" | "relatedSkillSlugs" | "relatedSpecializationSlugs"
>;

export default function CareersExplorer({
  initialCareers,
  categories,
}: {
  initialCareers: CareerListItem[];
  categories: Category[];
}) {
  const {
    query,
    setQuery,
    filter: category,
    setFilter: setCategory,
    filter2: demandParam,
    setFilter2: setDemandParam,
    filter3: salaryParam,
    setFilter3: setSalaryParam,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("category", "all", "demand", NONE, "salary", NONE, "sort", "popularity");

  // View is a per-visit preference, not something worth putting in a URL
  // someone shares -- a shared link should reproduce the RESULTS, not how the
  // sender happened to be looking at them.
  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  // Memoised so the filter memo below can depend on the parsed arrays rather
  // than on the raw param strings, which is what forced an exhaustive-deps
  // suppression here.
  const demands = useMemo(() => splitParam(demandParam), [demandParam]);
  const salaries = useMemo(() => splitParam(salaryParam), [salaryParam]);

  function toggle(list: string[], value: string, set: (v: string) => void) {
    set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
  }

  function reset() {
    setCategory("all");
    setDemandParam(NONE);
    setSalaryParam(NONE);
    setQuery("");
  }

  const activeCount =
    (category !== "all" ? 1 : 0) + demands.length + salaries.length + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    const slugged = q.replace(/\s+/g, "-");
    return initialCareers.filter((c) => {
      if (category !== "all" && c.categorySlug !== category) return false;
      if (demands.length > 0 && !demands.includes(c.demand)) return false;

      if (salaries.length > 0) {
        const ceiling = c.salaryMaxLpa;
        // A career with no salary recorded cannot satisfy a salary filter --
        // including it would be guessing on the student's behalf.
        if (ceiling === null) return false;
        const inBand = salaries.some((id) => {
          const b = SALARY_BUCKETS.find((x) => x.id === id);
          if (!b) return false;
          return ceiling >= b.min && ceiling < (b.max ?? Infinity);
        });
        if (!inBand) return false;
      }

      if (q === "") return true;
      return (
        c.title.toLowerCase().includes(q) ||
        c.tagline.toLowerCase().includes(q) ||
        // Skills are slugs since V81 made career_skills the single source of
        // truth, so "data structures" has to match "data-structures-...".
        c.relatedSkillSlugs.some((s) => s.includes(slugged))
      );
    });
  }, [initialCareers, query, category, demands, salaries]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.title.localeCompare(b.title));
      case "salary-high":
        return list.sort((a, b) => (b.salaryMaxLpa ?? -1) - (a.salaryMaxLpa ?? -1));
      case "salary-low":
        return list.sort((a, b) => (a.salaryMinLpa ?? Infinity) - (b.salaryMinLpa ?? Infinity));
      case "specializations":
        return list.sort(
          (a, b) => b.relatedSpecializationSlugs.length - a.relatedSpecializationSlugs.length
        );
      default:
        // "Popularity" is the catalog's own curated order (careers.sort_order,
        // which is how the API returns them) -- left untouched.
        return list;
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts come from the UNFILTERED list, so the sidebar always says how many
  // careers a category holds rather than how many survive the current filter.
  const categoryCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const c of initialCareers) {
      counts.set(c.categorySlug, (counts.get(c.categorySlug) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [initialCareers, categoriesBySlug]);

  return (
    <Container className="py-10 pb-24">
      {/* Flex with a FIXED-WIDTH rail, not a 12-column grid. As 3 of 12 the
          sidebar took a quarter of the page and squeezed the card grid; the
          filters need about 264px and nothing more, and every pixel saved
          goes to the results. `items-start` is what lets the rail stick. */}
      <div className="flex flex-col lg:flex-row lg:items-start gap-8">
        {/* ------------------------------------------------------------ Results */}
        <div className="flex-1 min-w-0 order-2">
          <div id="all-careers" className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24">
            <div>
              <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
                <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
                All Careers
              </h2>
              <p className="text-[13px] text-muted mt-1.5">
                Explore different career options and find the one that matches your interests.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <span className="text-[13px] font-semibold text-subtle">
                {sorted.length > PAGE_SIZE
                  ? `Showing ${(safePage - 1) * PAGE_SIZE + 1}–${Math.min(safePage * PAGE_SIZE, sorted.length)} of ${sorted.length} careers`
                  : `${sorted.length} career${sorted.length === 1 ? "" : "s"}`}
              </span>

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
                    <Icon name={v === "grid" ? "grid" : "list"} className="w-4 h-4" />
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Active filters as removable chips. The sidebar says what CAN be
              filtered; this says what IS filtered, which is the thing a reader
              looking at a short result list actually needs. */}
          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {category !== "all" && (
                <Chip onRemove={() => setCategory("all")}>
                  {categoriesBySlug.get(category)?.name ?? category}
                </Chip>
              )}
              {demands.map((d) => (
                <Chip key={d} onRemove={() => toggle(demands, d, setDemandParam)}>
                  {d}
                </Chip>
              ))}
              {salaries.map((id) => (
                <Chip key={id} onRemove={() => toggle(salaries, id, setSalaryParam)}>
                  {SALARY_BUCKETS.find((b) => b.id === id)?.label ?? id}
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
                {paginated.map((career) => (
                  <ExploreCareerCard
                    key={career.slug}
                    career={career}
                    category={categoriesBySlug.get(career.categorySlug)}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <div className="text-center py-20">
              <p className="text-muted text-sm">No careers match these filters.</p>
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
        {/* One sticky rail holding both panels. Previously only the filter
            card was sticky while the categories card scrolled independently,
            which made the two drift apart as you scrolled. */}
        <aside className="w-full lg:w-[264px] lg:shrink-0 order-1 lg:sticky lg:top-24">
          {/* On a phone a full filter panel above the results pushes every
              career off-screen, so it collapses. Forced open from lg up, where
              there is a column for it to live in. */}
          <button
            type="button"
            onClick={() => setFiltersOpen((v) => !v)}
            aria-expanded={filtersOpen}
            className="lg:hidden w-full flex items-center justify-between gap-2 rounded-2xl border border-line bg-white px-4 py-3 mb-3"
          >
            <span className="flex items-center gap-2 font-display font-extrabold text-navy text-[14px]">
              <Icon name="filter" className="w-4 h-4 text-blue" />
              {/* Named for what is inside it: on a phone this button is the
                  only route to sort now that the panel owns it. */}
              Filter &amp; sort
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
                  Filter Careers
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

              {/* Sort lives in this panel, not in the results header, so one
                  place changes what you see instead of two at opposite ends of
                  the page. On a phone the panel toggle is the only route to it,
                  which is why that button says "Filter & sort". */}
              <div className="pb-4 mb-4 border-b border-line">
                <label htmlFor="CareersExplorer-sort" className="block text-[12.5px] font-bold text-navy mb-2.5">
                  Sort by
                </label>
                <select
                  id="CareersExplorer-sort"
                  value={sort}
                  onChange={(e) => setSort(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
                >
                  {SORTS.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </div>

              <FilterGroup label="Domain / Field">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
                >
                  <option value="all">All Domains</option>
                  {categories.map((c) => (
                    <option key={c.slug} value={c.slug}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </FilterGroup>

              {/* Compact rows: a dot carries the colour and the label stays
                  plain text. Five full-size demand pills stacked vertically
                  made the panel taller than the first row of results. */}
              {/* Collapsed by default. Field and salary are what people open this
                  panel for; five demand labels stacked above the salary buckets
                  pushed them below the fold on a laptop. It opens by itself when
                  a demand filter is already set, and the summary carries a count,
                  so a collapsed filter is never quietly in effect. */}
              <FilterGroup label="Job Demand" collapsible activeCount={demands.length}>
                <div className="flex flex-col gap-2">
                  {DEMAND_OPTIONS.map((d) => (
                    <CheckRow
                      key={d}
                      checked={demands.includes(d)}
                      onChange={() => toggle(demands, d, setDemandParam)}
                    >
                      <span className={`w-2 h-2 rounded-full shrink-0 ${DEMAND_DOTS[d]}`} />
                      <span className="text-[12.5px] text-ink/80">{d}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              {/* Not "Average Salary": these match the TOP of a career's
                  range. Every career in the catalog starts at Rs 3-5 LPA, so
                  filtering on the floor separates nothing. */}
              <FilterGroup label="Salary Potential">
                <div className="grid grid-cols-2 gap-x-3 gap-y-2">
                  {SALARY_BUCKETS.map((b) => (
                    <CheckRow
                      key={b.id}
                      checked={salaries.includes(b.id)}
                      onChange={() => toggle(salaries, b.id, setSalaryParam)}
                    >
                      <span className="text-[12.5px] text-ink/80">{b.label}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              {/* The mock's "Apply Filters" slot. Filtering is live here, as on
                  every other listing page, so a button labelled "Apply" would
                  imply the results behind it were stale. It says what it does
                  instead: jump to the results, closing the panel on a phone. */}
              <button
                type="button"
                onClick={() => {
                  setFiltersOpen(false);
                  document
                    .getElementById("all-careers")
                    ?.scrollIntoView({ behavior: "smooth", block: "start" });
                }}
                className="w-full mt-5 text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                Show {sorted.length} career{sorted.length === 1 ? "" : "s"}
              </button>
            </div>

            <div className="rounded-3xl border border-line bg-white p-5">
              <div className="flex items-center justify-between mb-3">
                <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
                  <Icon name="target" className="w-4 h-4 text-blue" />
                  Top Career Categories
                </h2>
                <Link
                  href="/categories"
                  className="text-[12.5px] font-semibold text-blue hover:underline"
                >
                  View all
                </Link>
              </div>
              <ul className="flex flex-col">
                {categoryCounts.slice(0, 8).map(({ category: c, count }) => (
                  <li key={c!.slug}>
                    <button
                      type="button"
                      onClick={() => setCategory(category === c!.slug ? "all" : c!.slug)}
                      aria-pressed={category === c!.slug}
                      className={`w-full group flex items-center gap-2.5 py-2.5 border-b border-line last:border-0 -mx-2 px-2 rounded-lg transition-colors text-left ${
                        category === c!.slug ? "bg-blue-soft" : "hover:bg-bg-soft"
                      }`}
                    >
                      <span className="w-7 h-7 rounded-lg bg-bg-soft text-navy flex items-center justify-center shrink-0">
                        <Icon name={c!.icon} className="w-3.5 h-3.5" />
                      </span>
                      <span className="flex-1 min-w-0 text-[13px] font-semibold text-ink/85 truncate">
                        {c!.name}
                      </span>
                      <span className="text-[11.5px] text-muted shrink-0 whitespace-nowrap">
                        {count}
                      </span>
                      <Icon
                        name="chevRight"
                        className="w-3.5 h-3.5 text-subtle shrink-0 group-hover:text-blue transition-colors"
                      />
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </aside>
      </div>
    </Container>
  );
}

/**
 * The listing card. Separate from the shared CareerCard, which 12 other pages
 * render -- this one carries the three-figure footer (specializations /
 * demand / salary) the explore page is built around, and changing the shared
 * card to match would have rewritten all 12.
 */
function ExploreCareerCard({
  career,
  category,
  view,
}: {
  career: CareerListItem;
  category?: Category;
  view: "grid" | "list";
}) {
  const specializations = career.relatedSpecializationSlugs.length;
  const salary =
    career.salaryMinLpa !== null && career.salaryMaxLpa !== null
      ? `₹ ${career.salaryMinLpa}–${career.salaryMaxLpa} LPA`
      : null;

  const figures = (
    <div className="flex items-stretch gap-4 text-[12px]">
      {specializations > 0 && (
        <div className="min-w-0">
          <div className="font-display font-bold text-navy text-[13px]">{specializations}</div>
          <div className="text-muted mt-0.5 truncate">
            Specialization{specializations === 1 ? "" : "s"}
          </div>
        </div>
      )}
      <div className="min-w-0">
        <div
          className={`inline-block font-bold text-[11.5px] px-2 py-0.5 rounded-full ${DEMAND_STYLES[career.demand]}`}
        >
          {career.demand}
        </div>
        <div className="text-muted mt-0.5 truncate">Demand</div>
      </div>
      {salary && (
        <div className="min-w-0">
          <div className="font-display font-bold text-navy text-[13px] whitespace-nowrap">
            {salary}
          </div>
          <div className="text-muted mt-0.5 truncate">Salary</div>
        </div>
      )}
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/careers/${career.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={career.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15.5px]">
            {career.title}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 line-clamp-1">
            {career.tagline}
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
      href={`/careers/${career.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-4">
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={career.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[15.5px] leading-snug">
              {career.title}
            </span>
            <Icon
              name="chevRight"
              className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
            />
          </span>
          {category && (
            <span className="block text-[11.5px] font-semibold text-subtle mt-1">
              {category.name}
            </span>
          )}
        </span>
      </div>
      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2 flex-1">
        {career.tagline}
      </p>
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
