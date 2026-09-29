"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Resource } from "@/lib/types";
import { formatDate } from "@/lib/utils";
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

// resource_type is free text with no constraint, so the facet is built from
// whatever the data holds -- Guide / Website / Article, plus Course from the
// AI resources V109 added.
const TYPE_ICONS: Record<string, string> = {
  Article: "doc",
  Guide: "book",
  Website: "external",
  Course: "cap",
  Video: "monitor",
  PDF: "doc",
};

const SORTS = [
  { value: "az", label: "A – Z" },
  { value: "type", label: "By type" },
  { value: "linked", label: "Most linked" },
];

export default function ResourcesExplorer({ initialResources }: { initialResources: Resource[] }) {
  const {
    query,
    setQuery,
    filter: typeParam,
    setFilter: setTypeParam,
    filter2: linkage,
    setFilter2: setLinkage,
    filter3: sort,
    setFilter3: setSort,
    page,
    setPage,
  } = useUrlListState("type", NONE, "for", "all", "sort", "az");

  const [view, setView] = useState<ViewMode>("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);
  // Memoised so the filter memo below can depend on the parsed array itself
  // rather than on the raw param string, which is what forced an
  // exhaustive-deps suppression here.
  const types = useMemo(() => splitParam(typeParam), [typeParam]);

  const linksOf = (r: Resource) =>
    r.relatedCareerSlugs.length + r.relatedExamSlugs.length + r.relatedSkillSlugs.length;

  function reset() {
    setTypeParam(NONE);
    setLinkage("all");
    setQuery("");
  }

  const activeCount = types.length + (linkage !== "all" ? 1 : 0) + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialResources.filter((r) => {
      if (types.length > 0 && !types.includes(r.resourceType)) return false;
      if (linkage === "careers" && r.relatedCareerSlugs.length === 0) return false;
      if (linkage === "exams" && r.relatedExamSlugs.length === 0) return false;
      if (linkage === "skills" && r.relatedSkillSlugs.length === 0) return false;
      if (q === "") return true;
      return (
        r.title.toLowerCase().includes(q) ||
        (r.description?.toLowerCase().includes(q) ?? false) ||
        (r.author?.toLowerCase().includes(q) ?? false)
      );
    });
  }, [initialResources, query, types, linkage]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "type":
        return list.sort((a, b) => a.resourceType.localeCompare(b.resourceType) || a.title.localeCompare(b.title));
      case "linked":
        return list.sort((a, b) => linksOf(b) - linksOf(a) || a.title.localeCompare(b.title));
      default:
        return list.sort((a, b) => a.title.localeCompare(b.title));
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  const typeCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const r of initialResources) {
      if (r.resourceType) counts.set(r.resourceType, (counts.get(r.resourceType) ?? 0) + 1);
    }
    return [...counts.entries()].sort((a, b) => b[1] - a[1]);
  }, [initialResources]);

  const linkageCounts = {
    careers: initialResources.filter((r) => r.relatedCareerSlugs.length > 0).length,
    exams: initialResources.filter((r) => r.relatedExamSlugs.length > 0).length,
    skills: initialResources.filter((r) => r.relatedSkillSlugs.length > 0).length,
  };

  return (
    <Container className="py-8 pb-24">
      <QuickPickRow>
        <QuickPick
          active={types.length === 0}
          onClick={() => setTypeParam(NONE)}
          icon="grid"
          label="All Resources"
          count={initialResources.length}
          noun="resource"
        />
        {typeCounts.map(([t, count]) => (
          <QuickPick
            key={t}
            active={types.includes(t)}
            onClick={() => toggleParam(types, t, setTypeParam)}
            icon={TYPE_ICONS[t] ?? "doc"}
            label={t}
            count={count}
            noun="resource"
          />
        ))}
      </QuickPickRow>

      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-resources"
            title="All Resources"
            subtitle="Each one tied to the careers, exams and skills it actually helps with."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "resource")}
            sort={sort}
            onSortChange={setSort}
            sorts={SORTS}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {types.map((t) => (
                <Chip key={t} onRemove={() => toggleParam(types, t, setTypeParam)}>
                  {t}
                </Chip>
              ))}
              {linkage !== "all" && <Chip onRemove={() => setLinkage("all")}>{`Linked to ${linkage}`}</Chip>}
              <button type="button" onClick={reset} className="text-[12.5px] font-semibold text-blue hover:underline ml-1">
                Clear all
              </button>
            </div>
          )}

          {sorted.length > 0 ? (
            <>
              <div className={view === "grid" ? "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5" : "flex flex-col gap-3"}>
                {paginated.map((r) => (
                  <Link
                    key={r.slug}
                    href={`/resources/${r.slug}`}
                    className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
                  >
                    <div className="flex items-start gap-3.5 p-5 pb-3">
                      <span className="w-11 h-11 rounded-xl bg-purple-soft text-purple flex items-center justify-center shrink-0">
                        <Icon name={TYPE_ICONS[r.resourceType] ?? "doc"} className="w-5 h-5" />
                      </span>
                      <span className="min-w-0 flex-1">
                        <span className="flex items-start justify-between gap-2">
                          <span className="font-display font-bold text-navy text-[15px] leading-snug">{r.title}</span>
                          <Icon name="chevRight" className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors" />
                        </span>
                        {r.author && (
                          <span className="block text-[12px] font-semibold text-ink/60 mt-1">{r.author}</span>
                        )}
                      </span>
                    </div>
                    {r.description && (
                      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2 flex-1">{r.description}</p>
                    )}
                    <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft flex items-center gap-4 text-[12px]">
                      {r.resourceType && (
                        <span className="font-bold text-[11.5px] px-2 py-0.5 rounded-full bg-blue-soft text-blue">{r.resourceType}</span>
                      )}
                      {linksOf(r) > 0 && (
                        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                          <Icon name="target" className="w-3.5 h-3.5 text-subtle shrink-0" />
                          {linksOf(r)} links
                        </span>
                      )}
                      {r.publishedAt && (
                        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
                          <Icon name="cal" className="w-3.5 h-3.5 text-subtle shrink-0" />
                          {formatDate(r.publishedAt)}
                        </span>
                      )}
                    </div>
                  </Link>
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="resources" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          title="Filter Resources"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-resources"
          ctaLabel={`Show ${sorted.length} resource${sorted.length === 1 ? "" : "s"}`}
        >
          <FilterGroup label="Type">
            <div className="flex flex-col gap-2">
              {typeCounts.map(([t, count]) => (
                <CheckRow key={t} checked={types.includes(t)} onChange={() => toggleParam(types, t, setTypeParam)} count={count}>
                  <Icon name={TYPE_ICONS[t] ?? "doc"} className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <span className="text-[12.5px] text-ink/80">{t}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>

          {/* A resource is only useful if something points at it, so this
              filters on WHAT it is attached to rather than on a property of
              the resource itself. */}
          <FilterGroup label="Useful for">
            <div className="flex flex-col gap-2">
              {(["careers", "exams", "skills"] as const).map((k) => (
                <CheckRow
                  key={k}
                  checked={linkage === k}
                  onChange={() => setLinkage(linkage === k ? "all" : k)}
                  count={linkageCounts[k]}
                >
                  <span className="text-[12.5px] text-ink/80 capitalize">{k}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>
        </FilterRail>
      </ListingLayout>
    </Container>
  );
}
