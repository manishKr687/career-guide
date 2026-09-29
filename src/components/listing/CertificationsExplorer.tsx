"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Certification } from "@/lib/types";
import { useUrlListState } from "@/hooks/useUrlListState";
import { usePagedList } from "@/hooks/usePagedList";
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

const PAGE_SIZE = 12;

// Level is free text on the entity, so the options come from the data rather
// than a fixed list -- and a certification with none is shown as such rather
// than dropped.
const UNSET = "Unspecified";

const SORTS = [
  { value: "az", label: "A – Z" },
  { value: "provider", label: "By provider" },
  { value: "careers", label: "Most career links" },
];

export default function CertificationsExplorer({
  initialCertifications,
}: {
  initialCertifications: Certification[];
}) {
  const {
    query,
    setQuery,
    filter: levelParam,
    setFilter: setLevelParam,
    filter2: provider,
    setFilter2: setProvider,
    filter3: sort,
    setFilter3: setSort,
    page,
    setPage,
  } = useUrlListState("level", NONE, "provider", "all", "sort", "az");

  const [view, setView] = useState<ViewMode>("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);
  // Memoised so the filter memo below can depend on the parsed array itself
  // rather than on the raw param string, which is what forced an
  // exhaustive-deps suppression here.
  const levels = useMemo(() => splitParam(levelParam), [levelParam]);

  function reset() {
    setLevelParam(NONE);
    setProvider("all");
    setQuery("");
  }

  const activeCount = levels.length + (provider !== "all" ? 1 : 0) + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialCertifications.filter((c) => {
      if (levels.length > 0 && !levels.includes(c.level || UNSET)) return false;
      if (provider !== "all" && c.provider !== provider) return false;
      if (q === "") return true;
      return (
        c.name.toLowerCase().includes(q) ||
        c.provider.toLowerCase().includes(q) ||
        c.description.toLowerCase().includes(q)
      );
    });
  }, [initialCertifications, query, levels, provider]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "provider":
        return list.sort((a, b) => a.provider.localeCompare(b.provider) || a.name.localeCompare(b.name));
      case "careers":
        return list.sort(
          (a, b) => b.relatedCareerSlugs.length - a.relatedCareerSlugs.length || a.name.localeCompare(b.name)
        );
      default:
        return list.sort((a, b) => a.name.localeCompare(b.name));
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  const levelCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const c of initialCertifications) {
      const l = c.level || UNSET;
      counts.set(l, (counts.get(l) ?? 0) + 1);
    }
    return [...counts.entries()].sort((a, b) => b[1] - a[1]);
  }, [initialCertifications]);

  const providers = useMemo(
    () => [...new Set(initialCertifications.map((c) => c.provider).filter(Boolean))].sort(),
    [initialCertifications]
  );

  return (
    <Container className="py-8 pb-24">
      <QuickPickRow>
        <QuickPick
          active={levels.length === 0}
          onClick={() => setLevelParam(NONE)}
          icon="grid"
          label="All Certifications"
          count={initialCertifications.length}
          noun="certification"
        />
        {levelCounts.map(([l, count]) => (
          <QuickPick
            key={l}
            active={levels.includes(l)}
            onClick={() => toggleParam(levels, l, setLevelParam)}
            icon="award"
            label={l}
            count={count}
            noun="certification"
          />
        ))}
      </QuickPickRow>

      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-certifications"
            title="All Certifications"
            subtitle="Credentials that sit alongside a qualification rather than replace it."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "certification")}
            sort={sort}
            onSortChange={setSort}
            sorts={SORTS}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {levels.map((l) => (
                <Chip key={l} onRemove={() => toggleParam(levels, l, setLevelParam)}>
                  {l}
                </Chip>
              ))}
              {provider !== "all" && <Chip onRemove={() => setProvider("all")}>{provider}</Chip>}
              <button type="button" onClick={reset} className="text-[12.5px] font-semibold text-blue hover:underline ml-1">
                Clear all
              </button>
            </div>
          )}

          {sorted.length > 0 ? (
            <>
              <div className={view === "grid" ? "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5" : "flex flex-col gap-3"}>
                {paginated.map((c) => (
                  <Link
                    key={c.slug}
                    href={`/certifications/${c.slug}`}
                    className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
                  >
                    <div className="flex items-start gap-3.5 p-5 pb-3">
                      <span className="w-11 h-11 rounded-xl bg-pink-soft text-pink flex items-center justify-center shrink-0">
                        <Icon name="award" className="w-5 h-5" />
                      </span>
                      <span className="min-w-0 flex-1">
                        <span className="flex items-start justify-between gap-2">
                          <span className="font-display font-bold text-navy text-[15.5px] leading-snug">{c.name}</span>
                          <Icon name="chevRight" className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors" />
                        </span>
                        {c.provider && (
                          <span className="block text-[12px] font-semibold text-ink/60 mt-1">{c.provider}</span>
                        )}
                      </span>
                    </div>
                    {c.description && (
                      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2 flex-1">{c.description}</p>
                    )}
                    <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft flex items-center gap-4 text-[12px]">
                      {c.level && (
                        <span className="font-bold text-[11.5px] px-2 py-0.5 rounded-full bg-purple-soft text-purple">{c.level}</span>
                      )}
                      {c.duration && (
                        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                          <Icon name="clock" className="w-3.5 h-3.5 text-subtle shrink-0" />
                          {c.duration}
                        </span>
                      )}
                      {c.relatedCareerSlugs.length > 0 && (
                        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                          <Icon name="brief" className="w-3.5 h-3.5 text-subtle shrink-0" />
                          {c.relatedCareerSlugs.length} careers
                        </span>
                      )}
                    </div>
                  </Link>
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="certifications" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          title="Filter Certifications"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-certifications"
          ctaLabel={`Show ${sorted.length} certification${sorted.length === 1 ? "" : "s"}`}
        >
          <FilterGroup label="Level">
            <div className="flex flex-col gap-2">
              {levelCounts.map(([l, count]) => (
                <CheckRow key={l} checked={levels.includes(l)} onChange={() => toggleParam(levels, l, setLevelParam)} count={count}>
                  <span className="text-[12.5px] text-ink/80">{l}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>

          <FilterGroup label="Provider">
            <select
              value={provider}
              onChange={(e) => setProvider(e.target.value)}
              className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
            >
              <option value="all">All providers</option>
              {providers.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
          </FilterGroup>
        </FilterRail>
      </ListingLayout>
    </Container>
  );
}
