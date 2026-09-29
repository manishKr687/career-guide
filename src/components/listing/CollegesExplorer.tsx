"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { City, College, State } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";
import { useUrlListState } from "@/hooks/useUrlListState";
import { usePagedList } from "@/hooks/usePagedList";
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

// The catalog's own eight institute types. Not the mock's Government /
// Private / Deemed / Central / State list, which is an OWNERSHIP axis -- this
// app records that separately, and both are offered as their own facet below.
const TYPES = ["IIT", "NIT", "Medical", "Law", "Management", "University", "Polytechnic", "ITI"];

const TYPE_STYLES: Record<string, string> = {
  IIT: "bg-blue-soft text-blue",
  NIT: "bg-teal-soft text-teal",
  Medical: "bg-pink-soft text-pink",
  Law: "bg-purple-soft text-purple",
  Management: "bg-amber-soft text-amber",
  University: "bg-green-soft text-green",
  Polytechnic: "bg-slate-soft text-slate",
  ITI: "bg-slate-soft text-slate",
};

const TYPE_ICONS: Record<string, string> = {
  IIT: "chip",
  NIT: "wrench",
  Medical: "steth",
  Law: "scale",
  Management: "brief",
  University: "bank",
  Polytechnic: "gear",
  ITI: "gear",
};

const OWNERSHIP_OPTIONS = ["Government", "Private", "Government-Aided"];

// NIRF buckets. Rendered only when some college actually carries a rank --
// V113 ships the columns empty on purpose, and a facet matching nothing is a
// dead control.
const RANK_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "top-10", label: "Top 10", min: 1, max: 10 },
  { id: "11-50", label: "11 – 50", min: 11, max: 50 },
  { id: "51-100", label: "51 – 100", min: 51, max: 100 },
  { id: "101-200", label: "101 – 200", min: 101, max: 200 },
  { id: "201plus", label: "201+", min: 201, max: null },
];

const SORTS = [
  { value: "popularity", label: "Popularity" },
  { value: "az", label: "A – Z" },
  { value: "courses", label: "Most courses" },
  { value: "oldest", label: "Oldest first" },
  { value: "newest", label: "Newest first" },
];


export default function CollegesExplorer({
  initialColleges,
  states,
  cities,
}: {
  initialColleges: College[];
  states: State[];
  cities: City[];
}) {
  const {
    query,
    setQuery,
    filter: type,
    setFilter: setType,
    filter2: ownershipParam,
    setFilter2: setOwnershipParam,
    filter3: state,
    setFilter3: setState,
    filter4: city,
    setFilter4: setCity,
    page,
    setPage,
  } = useUrlListState("type", "all", "ownership", NONE, "state", "all", "city", "all");

  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);
  // Sort and the rank filter are local: the hook's four URL slots are already
  // spent on type/ownership/state/city, which are the ones worth sharing.
  const [sort, setSort] = useState("popularity");
  const [ranks, setRanks] = useState<string[]>([]);

  const statesBySlug = useMemo(() => indexBySlug(states), [states]);
  const citiesBySlug = useMemo(() => indexBySlug(cities), [cities]);
  // Memoised so the filter memo below can depend on the parsed array rather
  // than on the raw param string, which is what forced an exhaustive-deps
  // suppression here.
  const ownerships = useMemo(() => splitParam(ownershipParam), [ownershipParam]);

  const ranked = initialColleges.some((c) => c.nirfRank !== null);

  function toggle(list: string[], value: string, set: (v: string[]) => void) {
    set(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);
  }

  function reset() {
    setType("all");
    setOwnershipParam(NONE);
    setState("all");
    setCity("all");
    setRanks([]);
    setQuery("");
  }

  const activeCount =
    (type !== "all" ? 1 : 0) +
    ownerships.length +
    (state !== "all" ? 1 : 0) +
    (city !== "all" ? 1 : 0) +
    ranks.length +
    (query.trim() ? 1 : 0);

  // Cities narrow to the selected state -- scrolling 64 cities to find one in
  // Tamil Nadu defeats the point of having both.
  const availableCities = useMemo(() => {
    const present = new Set(
      initialColleges
        .filter((c) => state === "all" || c.stateSlug === state)
        .map((c) => c.citySlug)
        .filter((s): s is string => Boolean(s))
    );
    return cities.filter((c) => present.has(c.slug)).sort((a, b) => a.name.localeCompare(b.name));
  }, [initialColleges, cities, state]);

  function handleStateChange(next: string) {
    setState(next);
    // A city from the old state would silently return nothing.
    if (city !== "all" && next !== "all" && citiesBySlug.get(city)?.stateSlug !== next) {
      setCity("all");
    }
  }

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialColleges.filter((c) => {
      if (type !== "all" && c.type !== type) return false;
      if (ownerships.length > 0 && !ownerships.includes(c.ownershipType)) return false;
      if (state !== "all" && c.stateSlug !== state) return false;
      if (city !== "all" && c.citySlug !== city) return false;

      if (ranks.length > 0) {
        if (c.nirfRank === null) return false;
        const rank = c.nirfRank;
        const inBand = ranks.some((id) => {
          const b = RANK_BUCKETS.find((x) => x.id === id);
          return b ? rank >= b.min && rank <= (b.max ?? Infinity) : false;
        });
        if (!inBand) return false;
      }

      if (q === "") return true;
      return (
        c.name.toLowerCase().includes(q) ||
        c.location.toLowerCase().includes(q) ||
        c.description.toLowerCase().includes(q)
      );
    });
  }, [initialColleges, query, type, ownerships, state, city, ranks]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.name.localeCompare(b.name));
      case "courses":
        return list.sort((a, b) => b.degreeOfferings.length - a.degreeOfferings.length);
      case "oldest":
        return list.sort((a, b) => a.established - b.established);
      case "newest":
        return list.sort((a, b) => b.established - a.established);
      default:
        // "Popularity": NIRF rank where a college has one, then how many
        // courses it offers. Rank is the honest first key once it exists; the
        // course count is what the catalog can prove until then.
        return list.sort((a, b) => {
          const ra = a.nirfRank ?? Infinity;
          const rb = b.nirfRank ?? Infinity;
          if (ra !== rb) return ra - rb;
          return b.degreeOfferings.length - a.degreeOfferings.length || a.name.localeCompare(b.name);
        });
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts from the UNFILTERED list, so a facet says how many colleges it
  // holds rather than how many survive the current filter.
  const typeCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const c of initialColleges) counts.set(c.type, (counts.get(c.type) ?? 0) + 1);
    return TYPES.filter((t) => counts.has(t)).map((t) => ({ type: t, count: counts.get(t) ?? 0 }));
  }, [initialColleges]);

  const ownershipCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const c of initialColleges) counts.set(c.ownershipType, (counts.get(c.ownershipType) ?? 0) + 1);
    return OWNERSHIP_OPTIONS.filter((o) => counts.has(o)).map((o) => ({
      ownership: o,
      count: counts.get(o) ?? 0,
    }));
  }, [initialColleges]);

  const statesWithColleges = useMemo(() => {
    const present = new Set(initialColleges.map((c) => c.stateSlug));
    return states.filter((s) => present.has(s.slug)).sort((a, b) => a.name.localeCompare(b.name));
  }, [initialColleges, states]);

  const topRanked = useMemo(
    () =>
      initialColleges
        .filter((c) => c.nirfRank !== null)
        .sort((a, b) => (a.nirfRank ?? 0) - (b.nirfRank ?? 0))
        .slice(0, 6),
    [initialColleges]
  );

  return (
    <Container className="py-8 pb-24">
      <div className="flex gap-3 overflow-x-auto pb-2 mb-8 -mx-1 px-1">
        <QuickPick
          active={type === "all"}
          onClick={() => setType("all")}
          icon="grid"
          label="All Colleges"
          count={initialColleges.length}
        />
        {typeCounts.map(({ type: t, count }) => (
          <QuickPick
            key={t}
            active={type === t}
            onClick={() => setType(type === t ? "all" : t)}
            icon={TYPE_ICONS[t] ?? "bank"}
            label={t}
            count={count}
          />
        ))}
      </div>

      <div className="flex flex-col lg:flex-row lg:items-start gap-8">
        {/* ------------------------------------------------------------ Results */}
        <div className="flex-1 min-w-0 order-2 lg:order-1">
          <div id="all-colleges" className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24">
            <div>
              <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
                <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
                All Colleges
              </h2>
              <p className="text-[13px] text-muted mt-1.5">
                Explore colleges and find the one that matches your career goals.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <span className="text-[13px] font-semibold text-subtle">
                {sorted.length > PAGE_SIZE
                  ? `Showing ${(safePage - 1) * PAGE_SIZE + 1}–${Math.min(safePage * PAGE_SIZE, sorted.length)} of ${sorted.length} colleges`
                  : `${sorted.length} college${sorted.length === 1 ? "" : "s"}`}
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
              {type !== "all" && <Chip onRemove={() => setType("all")}>{type}</Chip>}
              {ownerships.map((o) => (
                <Chip
                  key={o}
                  onRemove={() =>
                    setOwnershipParam(joinParam(ownerships.filter((v) => v !== o)))
                  }
                >
                  {o}
                </Chip>
              ))}
              {state !== "all" && (
                <Chip onRemove={() => handleStateChange("all")}>
                  {statesBySlug.get(state)?.name ?? state}
                </Chip>
              )}
              {city !== "all" && (
                <Chip onRemove={() => setCity("all")}>{citiesBySlug.get(city)?.name ?? city}</Chip>
              )}
              {ranks.map((id) => (
                <Chip key={id} onRemove={() => toggle(ranks, id, setRanks)}>
                  {RANK_BUCKETS.find((b) => b.id === id)?.label ?? id}
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
                {paginated.map((college) => (
                  <CollegeListCard
                    key={college.slug}
                    college={college}
                    state={statesBySlug.get(college.stateSlug)}
                    city={college.citySlug ? citiesBySlug.get(college.citySlug) : undefined}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <div className="text-center py-20">
              <p className="text-muted text-sm">No colleges match these filters.</p>
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
                  Filter Colleges
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

              <FilterGroup label="Search by name">
                <div className="flex items-center gap-2 rounded-xl border border-line bg-white px-3 py-2 focus-within:border-blue/50 transition-colors">
                  <Icon name="search" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <input
                    type="search"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="Search colleges..."
                    aria-label="Search colleges by name"
                    className="flex-1 min-w-0 bg-transparent text-[13px] text-ink placeholder:text-subtle outline-none"
                  />
                </div>
              </FilterGroup>

              {/* "Institute Type", not the mock's "College Type": that list
                  (Government / Deemed / Central) is an ownership axis, which
                  this app records separately and which gets its own facet
                  below. Collapsing the two would lose one of them. */}
              <FilterGroup label="Institute Type">
                <div className="flex flex-col gap-2">
                  {typeCounts.map(({ type: t, count }) => (
                    <CheckRow
                      key={t}
                      checked={type === t}
                      onChange={() => setType(type === t ? "all" : t)}
                      count={count}
                    >
                      <Icon name={TYPE_ICONS[t] ?? "bank"} className="w-3.5 h-3.5 text-subtle shrink-0" />
                      <span className="text-[12.5px] text-ink/80">{t}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              <FilterGroup label="Ownership">
                <div className="flex flex-col gap-2">
                  {ownershipCounts.map(({ ownership, count }) => (
                    <CheckRow
                      key={ownership}
                      checked={ownerships.includes(ownership)}
                      onChange={() =>
                        setOwnershipParam(
                          joinParam(
                            ownerships.includes(ownership)
                              ? ownerships.filter((v) => v !== ownership)
                              : [...ownerships, ownership]
                          )
                        )
                      }
                      count={count}
                    >
                      <span className="text-[12.5px] text-ink/80">{ownership}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              <FilterGroup label="City / State">
                <select
                  value={state}
                  onChange={(e) => handleStateChange(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy mb-2"
                >
                  <option value="all">All States</option>
                  {statesWithColleges.map((s) => (
                    <option key={s.slug} value={s.slug}>
                      {s.name}
                    </option>
                  ))}
                </select>
                <select
                  value={city}
                  onChange={(e) => setCity(e.target.value)}
                  disabled={availableCities.length === 0}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy disabled:opacity-50"
                >
                  <option value="all">All Cities</option>
                  {availableCities.map((c) => (
                    <option key={c.slug} value={c.slug}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </FilterGroup>

              {/* Only when something is actually ranked. V113 ships the NIRF
                  columns empty on purpose -- rendering five buckets that all
                  match nothing would be a dead control. */}
              {ranked && (
                <FilterGroup label="NIRF Ranking">
                  <div className="flex flex-col gap-2">
                    {RANK_BUCKETS.map((b) => (
                      <CheckRow
                        key={b.id}
                        checked={ranks.includes(b.id)}
                        onChange={() => toggle(ranks, b.id, setRanks)}
                        count={
                          initialColleges.filter(
                            (c) =>
                              c.nirfRank !== null &&
                              c.nirfRank >= b.min &&
                              c.nirfRank <= (b.max ?? Infinity)
                          ).length
                        }
                      >
                        <span className="text-[12.5px] text-ink/80">{b.label}</span>
                      </CheckRow>
                    ))}
                  </div>
                </FilterGroup>
              )}

              <button
                type="button"
                onClick={() => {
                  setFiltersOpen(false);
                  document
                    .getElementById("all-colleges")
                    ?.scrollIntoView({ behavior: "smooth", block: "start" });
                }}
                className="w-full mt-5 text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                Show {sorted.length} college{sorted.length === 1 ? "" : "s"}
              </button>
            </div>

            {topRanked.length > 0 && (
              <div className="rounded-3xl border border-line bg-white p-5">
                <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px] mb-3">
                  <Icon name="trophy" className="w-4 h-4 text-blue" />
                  Top Ranked
                </h2>
                <ul className="flex flex-col">
                  {topRanked.map((c) => (
                    <li key={c.slug}>
                      <Link
                        href={`/colleges/${c.slug}`}
                        className="group flex items-center gap-2.5 py-2.5 border-b border-line last:border-0 -mx-2 px-2 rounded-lg hover:bg-bg-soft transition-colors"
                      >
                        <span className="w-7 h-7 rounded-lg bg-amber-soft text-amber flex items-center justify-center shrink-0 text-[11px] font-bold">
                          {c.nirfRank}
                        </span>
                        <span className="flex-1 min-w-0">
                          <span className="block text-[13px] font-semibold text-ink/85 truncate">
                            {c.name}
                          </span>
                          <span className="block text-[11px] text-muted truncate">
                            {c.nirfLabel}
                          </span>
                        </span>
                        <Icon
                          name="chevRight"
                          className="w-3.5 h-3.5 text-subtle shrink-0 group-hover:text-blue transition-colors"
                        />
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </aside>
      </div>
    </Container>
  );
}

/**
 * The listing card.
 *
 * The footer figures are courses, founding year and intake exams -- all three
 * real for every college. The mock puts average fees and placement rate here
 * instead; both vary by PROGRAMME rather than by institution (IIT Delhi's
 * B.Tech and M.Tech fees are different numbers, and a placement rate is per
 * branch per year), so a single value hung off the college would average away
 * the thing being asked about. See V113's header.
 *
 * The rank badge renders only for a college that has one.
 */
function CollegeListCard({
  college,
  state,
  city,
  view,
}: {
  college: College;
  state?: State;
  city?: City;
  view: "grid" | "list";
}) {
  const place = [city?.name, state?.name].filter(Boolean).join(", ") || college.location;

  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      {college.degreeOfferings.length > 0 && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="book" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {college.degreeOfferings.length} course
          {college.degreeOfferings.length === 1 ? "" : "s"}
        </span>
      )}
      <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
        <Icon name="cal" className="w-3.5 h-3.5 text-subtle shrink-0" />
        Est. {college.established}
      </span>
      {college.examSlugs.length > 0 && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="doc" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {college.examSlugs.length} exam{college.examSlugs.length === 1 ? "" : "s"}
        </span>
      )}
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/colleges/${college.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span
          className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${TYPE_STYLES[college.type] ?? "bg-bg-soft text-navy"}`}
        >
          <Icon name={TYPE_ICONS[college.type] ?? "bank"} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15px] truncate">
            {college.name}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 truncate">
            {college.ownershipType} · {college.type} · {place}
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
      href={`/colleges/${college.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      {/* A tinted banner in place of the mock's campus photo: 90 licensed
          photographs is not a set that stays maintained, and the type tint
          already distinguishes an IIT from a medical college at a glance. */}
      <div
        className={`relative h-20 flex items-center justify-center ${TYPE_STYLES[college.type] ?? "bg-bg-soft text-navy"}`}
      >
        <Icon name={TYPE_ICONS[college.type] ?? "bank"} aria-hidden className="w-10 h-10 opacity-30" />
        {college.nirfRank !== null && (
          <span
            className="absolute top-3 left-3 text-[11px] font-bold px-2.5 py-1 rounded-full bg-white text-navy shadow-card"
            title={college.nirfLabel ?? undefined}
          >
            #{college.nirfRank} {college.nirfLabel}
          </span>
        )}
        <span className="absolute top-3 right-3 text-[11px] font-bold px-2.5 py-1 rounded-full bg-white/90 text-navy">
          {college.type}
        </span>
      </div>

      <div className="flex items-start justify-between gap-2 p-5 pb-2">
        <span className="min-w-0">
          <span className="block font-display font-bold text-navy text-[15px] leading-snug">
            {college.name}
          </span>
          <span className="block text-[12px] font-semibold text-ink/60 mt-1">
            {college.ownershipType} · {college.type}
          </span>
          <span className="flex items-center gap-1.5 text-[12px] text-muted mt-1.5">
            <Icon name="mappin" className="w-3.5 h-3.5 text-subtle shrink-0" />
            <span className="truncate">{place}</span>
          </span>
        </span>
        <Icon
          name="chevRight"
          className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
        />
      </div>

      <div className="flex-1" />
      <div className="px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
