"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { CareerRef, Category, Specialization } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";
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

/**
 * Reach buckets, on how many job roles a specialization leads to.
 *
 * Same reasoning as the skills listing: nothing here implies market demand,
 * and `demand` is set on exactly one of 263 rows, so a demand facet would be
 * a control that filters almost nothing. How many job roles an area opens up
 * is real, and is closer to what someone choosing a specialization wants.
 */
const REACH_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "many", label: "3+ job roles", min: 3, max: null },
  { id: "some", label: "1 – 2 job roles", min: 1, max: 2 },
  { id: "none", label: "Not yet mapped", min: 0, max: 0 },
];

const SORTS = [
  { value: "roles", label: "Most job roles" },
  { value: "az", label: "A – Z" },
  { value: "career", label: "By career" },
];

/**
 * The fields this listing actually reads.
 *
 * Typed as a narrow Pick rather than `Specialization` so the page can hand over
 * only these and the compiler enforces the rest. The full entity carries
 * `overview`, which V134-V146 filled for all 263 specializations -- 117 KB of
 * prose, 40% of /api/specializations, that this page never renders. Because the
 * list is a prop to a client component, every byte was serialised twice: once
 * into the HTML and again into the RSC payload for hydration. That alone was
 * roughly 234 KB of a 584 KB page.
 *
 * Narrowing the type is what makes the saving stick. Passing a trimmed object
 * into a `Specialization[]` prop would compile today and silently regrow the
 * moment someone passed the raw list again.
 */
export type SpecializationListItem = Pick<
  Specialization,
  "slug" | "name" | "description" | "icon" | "careerSlugs" | "primaryCareerSlug" | "relatedJobRoleSlugs"
>;

export default function SpecializationsExplorer({
  initialSpecializations,
  careers,
  categories,
  fieldsBySpec,
}: {
  initialSpecializations: SpecializationListItem[];
  careers: CareerRef[];
  categories: Category[];
  /** slug -> the category slugs of this specialization's parent career(s). */
  fieldsBySpec: Record<string, string[]>;
}) {
  const {
    query,
    setQuery,
    filter: field,
    setFilter: setField,
    filter2: career,
    setFilter2: setCareer,
    filter3: reachParam,
    setFilter3: setReachParam,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("field", "all", "career", "all", "reach", NONE, "sort", "roles");

  const [view, setView] = useState<ViewMode>("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const careersBySlug = useMemo(() => indexBySlug(careers), [careers]);
  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  // Memoised so the filter memo below can depend on the parsed array itself
  // rather than on the raw param string, which is what forced an
  // exhaustive-deps suppression here.
  const reaches = useMemo(() => splitParam(reachParam), [reachParam]);

  function reset() {
    setField("all");
    setCareer("all");
    setReachParam(NONE);
    setQuery("");
  }

  const activeCount =
    (field !== "all" ? 1 : 0) + (career !== "all" ? 1 : 0) + reaches.length + (query.trim() ? 1 : 0);

  // Careers narrow to the chosen field -- a 42-entry list where 40 are
  // irrelevant defeats the point of having both controls.
  const availableCareers = useMemo(() => {
    const withSpecs = new Set(initialSpecializations.flatMap((s) => s.careerSlugs));
    return careers
      .filter((c) => withSpecs.has(c.slug) && (field === "all" || c.categorySlug === field))
      .sort((a, b) => a.title.localeCompare(b.title));
  }, [initialSpecializations, careers, field]);

  function handleFieldChange(next: string) {
    setField(next);
    // A career from the old field would silently return nothing.
    if (career !== "all" && next !== "all" && careersBySlug.get(career)?.categorySlug !== next) {
      setCareer("all");
    }
  }

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialSpecializations.filter((s) => {
      if (field !== "all" && !(fieldsBySpec[s.slug] ?? []).includes(field)) return false;
      if (career !== "all" && !s.careerSlugs.includes(career)) return false;

      if (reaches.length > 0) {
        const n = s.relatedJobRoleSlugs.length;
        const inBand = reaches.some((id) => {
          const b = REACH_BUCKETS.find((x) => x.id === id);
          return b ? n >= b.min && n <= (b.max ?? Infinity) : false;
        });
        if (!inBand) return false;
      }

      if (q === "") return true;
      return s.name.toLowerCase().includes(q) || s.description.toLowerCase().includes(q);
    });
    // `fieldsBySpec` was missing from this list entirely while the suppression
    // was in place -- the memo read it but would not have recomputed if it
    // changed.
  }, [initialSpecializations, query, field, career, reaches, fieldsBySpec]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.name.localeCompare(b.name));
      case "career":
        return list.sort(
          (a, b) =>
            (careersBySlug.get(a.primaryCareerSlug)?.title ?? "").localeCompare(
              careersBySlug.get(b.primaryCareerSlug)?.title ?? ""
            ) || a.name.localeCompare(b.name)
        );
      default:
        return list.sort(
          (a, b) =>
            b.relatedJobRoleSlugs.length - a.relatedJobRoleSlugs.length ||
            a.name.localeCompare(b.name)
        );
    }
  }, [filtered, sort, careersBySlug]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts from the UNFILTERED list.
  const fieldCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const slugs of Object.values(fieldsBySpec)) {
      for (const f of slugs) counts.set(f, (counts.get(f) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [fieldsBySpec, categoriesBySlug]);

  return (
    <Container className="py-8 pb-24">
      <QuickPickRow>
        <QuickPick
          active={field === "all"}
          onClick={() => handleFieldChange("all")}
          icon="grid"
          label="All Specializations"
          count={initialSpecializations.length}
          noun="area"
        />
        {fieldCounts.map(({ category: c, count }) => (
          <QuickPick
            key={c!.slug}
            active={field === c!.slug}
            onClick={() => handleFieldChange(field === c!.slug ? "all" : c!.slug)}
            icon={c!.icon}
            label={c!.name}
            count={count}
            noun="area"
          />
        ))}
      </QuickPickRow>

      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-specializations"
            title="All Specializations"
            subtitle="Each one is a focused area inside a career, with its own page."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "specialization")}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {field !== "all" && (
                <Chip onRemove={() => handleFieldChange("all")}>
                  {categoriesBySlug.get(field)?.name ?? field}
                </Chip>
              )}
              {career !== "all" && (
                <Chip onRemove={() => setCareer("all")}>
                  {careersBySlug.get(career)?.title ?? career}
                </Chip>
              )}
              {reaches.map((r) => (
                <Chip key={r} onRemove={() => toggleParam(reaches, r, setReachParam)}>
                  {REACH_BUCKETS.find((b) => b.id === r)?.label ?? r}
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
                {paginated.map((s) => (
                  <SpecializationListCard
                    key={s.slug}
                    specialization={s}
                    parent={careersBySlug.get(s.primaryCareerSlug)}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="specializations" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          query={query}
          onQueryChange={setQuery}
          searchPlaceholder="Search specializations..."
          searchLabel="Search specializations"
          sort={sort}
          onSortChange={setSort}
          sorts={SORTS}
          title="Filter Specializations"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-specializations"
          ctaLabel={`Show ${sorted.length} specialization${sorted.length === 1 ? "" : "s"}`}
        >
          {/* Field, not a category of its own: a specialization has none, and
              adding one would be a second copy of what its parent career
              already says. */}
          <FilterGroup label="Field">
            <div className="flex flex-col gap-2">
              {fieldCounts.map(({ category: c, count }) => (
                <CheckRow
                  key={c!.slug}
                  checked={field === c!.slug}
                  onChange={() => handleFieldChange(field === c!.slug ? "all" : c!.slug)}
                  count={count}
                >
                  <Icon name={c!.icon} className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <span className="text-[12.5px] text-ink/80 truncate">{c!.name}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>

          <FilterGroup label="Parent career">
            <select
              value={career}
              onChange={(e) => setCareer(e.target.value)}
              className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
            >
              <option value="all">All careers</option>
              {availableCareers.map((c) => (
                <option key={c.slug} value={c.slug}>
                  {c.title}
                </option>
              ))}
            </select>
          </FilterGroup>

          {/* Not "Demand": `demand` is set on 1 of 263 specializations, so a
              demand facet would filter almost nothing. Job-role reach is real
              for 250 of them. */}
          <FilterGroup label="Leads to">
            <div className="flex flex-col gap-2">
              {REACH_BUCKETS.map((b) => (
                <CheckRow
                  key={b.id}
                  checked={reaches.includes(b.id)}
                  onChange={() => toggleParam(reaches, b.id, setReachParam)}
                  count={
                    initialSpecializations.filter((s) => {
                      const n = s.relatedJobRoleSlugs.length;
                      return n >= b.min && n <= (b.max ?? Infinity);
                    }).length
                  }
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

/**
 * The listing card: the specialization, the career it sits under, and how many
 * job roles it leads to.
 *
 * The parent career is the most important thing here after the name -- a
 * specialization means little without it, and "Cloud Computing" appears under
 * two different careers in this catalog.
 */
function SpecializationListCard({
  specialization,
  parent,
  view,
}: {
  specialization: SpecializationListItem;
  parent?: CareerRef;
  view: ViewMode;
}) {
  const roles = specialization.relatedJobRoleSlugs.length;

  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
        <Icon name="users" className="w-3.5 h-3.5 text-subtle shrink-0" />
        {roles} job role{roles === 1 ? "" : "s"}
      </span>
      {parent && (
        <span className="flex items-center gap-1.5 text-muted min-w-0" title={parent.title}>
          <Icon name="brief" className="w-3.5 h-3.5 text-subtle shrink-0" />
          <span className="truncate">{parent.title}</span>
        </span>
      )}
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/specializations/${specialization.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className="w-11 h-11 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={specialization.icon} className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15px] truncate">
            {specialization.name}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 truncate">
            {specialization.description}
          </span>
        </span>
        <span className="hidden sm:block shrink-0 max-w-[40%]">{figures}</span>
        <Icon
          name="chevRight"
          className="w-4 h-4 text-subtle shrink-0 group-hover:text-blue transition-colors"
        />
      </Link>
    );
  }

  return (
    <Link
      href={`/specializations/${specialization.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-3">
        <span className="w-11 h-11 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={specialization.icon} className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[15.5px] leading-snug">
              {specialization.name}
            </span>
            <Icon
              name="chevRight"
              className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
            />
          </span>
          {parent && (
            <span className="block text-[12px] font-semibold text-ink/60 mt-1">
              within {parent.title}
            </span>
          )}
        </span>
      </div>
      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2 flex-1">
        {specialization.description}
      </p>
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
