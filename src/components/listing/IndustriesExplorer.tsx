"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Industry } from "@/lib/types";
import { useUrlListState } from "@/hooks/useUrlListState";
import {
  CheckRow,
  Chip,
  FilterGroup,
  FilterRail,
  ListingLayout,
  NONE,
  NoResults,
  QuickPick,
  QuickPickRow,
  ResultsColumn,
  ResultsHeader,
  ViewMode,
  countLabel,
  splitParam,
  toggleParam,
} from "@/components/listing/ListingKit";

const PAGE_SIZE = 24;

/**
 * Reach buckets, on how many careers and job roles point at an industry.
 *
 * `industries` holds a name and a boolean and nothing else, so reach is the
 * only thing there is to rank or filter by -- and it is the useful thing: an
 * employer nothing links to is a row, not an answer.
 */
const REACH_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "many", label: "5+ links", min: 5, max: null },
  { id: "some", label: "2 – 4 links", min: 2, max: 4 },
  { id: "one", label: "1 link", min: 1, max: 1 },
  { id: "none", label: "Not yet linked", min: 0, max: 0 },
];

const SORTS = [
  { value: "reach", label: "Most linked" },
  { value: "az", label: "A – Z" },
];

export default function IndustriesExplorer({
  initialIndustries,
  careerCounts,
  roleCounts,
}: {
  initialIndustries: Industry[];
  careerCounts: Record<string, number>;
  roleCounts: Record<string, number>;
}) {
  const {
    query,
    setQuery,
    filter: kind,
    setFilter: setKind,
    filter2: reachParam,
    setFilter2: setReachParam,
    filter3: sort,
    setFilter3: setSort,
    page,
    setPage,
  } = useUrlListState("kind", "all", "reach", NONE, "sort", "reach");

  const [view, setView] = useState<ViewMode>("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);
  const reaches = splitParam(reachParam);

  const careersOf = (slug: string) => careerCounts[slug] ?? 0;
  const rolesOf = (slug: string) => roleCounts[slug] ?? 0;
  const reachOf = (slug: string) => careersOf(slug) + rolesOf(slug);

  function reset() {
    setKind("all");
    setReachParam(NONE);
    setQuery("");
  }

  const activeCount = (kind !== "all" ? 1 : 0) + reaches.length + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialIndustries.filter((i) => {
      if (kind === "sector" && !i.isSector) return false;
      if (kind === "employer" && i.isSector) return false;
      if (reaches.length > 0) {
        const n = reachOf(i.slug);
        const inBand = reaches.some((id) => {
          const b = REACH_BUCKETS.find((x) => x.id === id);
          return b ? n >= b.min && n <= (b.max ?? Infinity) : false;
        });
        if (!inBand) return false;
      }
      return q === "" || i.name.toLowerCase().includes(q);
    });
  }, [initialIndustries, query, kind, reachParam]); // eslint-disable-line react-hooks/exhaustive-deps

  const sorted = useMemo(() => {
    const list = [...filtered];
    if (sort === "az") return list.sort((a, b) => a.name.localeCompare(b.name));
    return list.sort((a, b) => reachOf(b.slug) - reachOf(a.slug) || a.name.localeCompare(b.name));
  }, [filtered, sort]); // eslint-disable-line react-hooks/exhaustive-deps

  const totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const safePage = Math.min(page, totalPages);
  const paginated = sorted.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  const resultsTopRef = useRef<HTMLDivElement>(null);
  function goToPage(next: number) {
    setPage(next);
    resultsTopRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  const sectorCount = initialIndustries.filter((i) => i.isSector).length;

  return (
    <Container className="py-8 pb-24">
      <QuickPickRow>
        <QuickPick active={kind === "all"} onClick={() => setKind("all")} icon="grid" label="All" count={initialIndustries.length} noun="industry" />
        <QuickPick active={kind === "sector"} onClick={() => setKind(kind === "sector" ? "all" : "sector")} icon="compass" label="Sectors" count={sectorCount} noun="sector" />
        <QuickPick active={kind === "employer"} onClick={() => setKind(kind === "employer" ? "all" : "employer")} icon="building" label="Employers" count={initialIndustries.length - sectorCount} noun="employer" />
      </QuickPickRow>

      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-industries"
            title="All Industries"
            subtitle="Sectors are where the work happens; employers are who hires."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "industry")}
            sort={sort}
            onSortChange={setSort}
            sorts={SORTS}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {kind !== "all" && (
                <Chip onRemove={() => setKind("all")}>{kind === "sector" ? "Sectors" : "Employers"}</Chip>
              )}
              {reaches.map((r) => (
                <Chip key={r} onRemove={() => toggleParam(reaches, r, setReachParam)}>
                  {REACH_BUCKETS.find((b) => b.id === r)?.label ?? r}
                </Chip>
              ))}
              <button type="button" onClick={reset} className="text-[12.5px] font-semibold text-blue hover:underline ml-1">
                Clear all
              </button>
            </div>
          )}

          {sorted.length > 0 ? (
            <>
              <div className={view === "grid" ? "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4" : "flex flex-col gap-3"}>
                {paginated.map((i) => (
                  <Link
                    key={i.slug}
                    href={`/industries/${i.slug}`}
                    className="group flex items-center gap-3.5 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
                  >
                    <span className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 ${i.isSector ? "bg-blue-soft text-blue" : "bg-purple-soft text-purple"}`}>
                      <Icon name={i.isSector ? "compass" : "building"} className="w-5 h-5" />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block font-display font-bold text-navy text-[14.5px] truncate">{i.name}</span>
                      <span className="block text-[12px] text-muted mt-0.5">
                        {i.isSector ? "Sector" : "Employer"}
                        {reachOf(i.slug) > 0 && ` · ${careersOf(i.slug)} careers, ${rolesOf(i.slug)} roles`}
                      </span>
                    </span>
                    <Icon name="chevRight" className="w-4 h-4 text-subtle shrink-0 group-hover:text-blue transition-colors" />
                  </Link>
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="industries" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          title="Filter Industries"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-industries"
          ctaLabel={`Show ${sorted.length} ${sorted.length === 1 ? "industry" : "industries"}`}
        >
          {/* The split `is_sector` has recorded since V35. Offering it as a
              filter is the whole reason the two can live in one table. */}
          <FilterGroup label="Kind">
            <div className="flex flex-col gap-2">
              <CheckRow checked={kind === "sector"} onChange={() => setKind(kind === "sector" ? "all" : "sector")} count={sectorCount}>
                <Icon name="compass" className="w-3.5 h-3.5 text-subtle shrink-0" />
                <span className="text-[12.5px] text-ink/80">Sector</span>
              </CheckRow>
              <CheckRow checked={kind === "employer"} onChange={() => setKind(kind === "employer" ? "all" : "employer")} count={initialIndustries.length - sectorCount}>
                <Icon name="building" className="w-3.5 h-3.5 text-subtle shrink-0" />
                <span className="text-[12.5px] text-ink/80">Employer</span>
              </CheckRow>
            </div>
          </FilterGroup>

          <FilterGroup label="Linked to">
            <div className="flex flex-col gap-2">
              {REACH_BUCKETS.map((b) => (
                <CheckRow
                  key={b.id}
                  checked={reaches.includes(b.id)}
                  onChange={() => toggleParam(reaches, b.id, setReachParam)}
                  count={initialIndustries.filter((i) => {
                    const n = reachOf(i.slug);
                    return n >= b.min && n <= (b.max ?? Infinity);
                  }).length}
                >
                  <span className="text-[12.5px] text-ink/80">{b.label}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>
        </FilterRail>
      </ListingLayout>
    </Container>
  );
}
