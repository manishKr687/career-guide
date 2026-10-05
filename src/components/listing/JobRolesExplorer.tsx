"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { CareerRef, Category, JobRole } from "@/lib/types";
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

// The catalog's five seniority bands, ordered junior-first rather than
// alphabetically. Every one is populated.
const LEVEL_OPTIONS = ["Entry", "Entry to Mid", "Entry to Senior", "Mid to Senior", "Senior"];

const LEVEL_STYLES: Record<string, string> = {
  Entry: "bg-green-soft text-green",
  "Entry to Mid": "bg-teal-soft text-teal",
  "Entry to Senior": "bg-blue-soft text-blue",
  "Mid to Senior": "bg-purple-soft text-purple",
  Senior: "bg-pink-soft text-pink",
};

/**
 * Salary buckets on the role's CEILING.
 *
 * Possible at all only because V107's numeric columns are finally exposed on
 * the API -- until this pass the DTO returned "5 LPA" as a string and nothing
 * could sort or filter on pay. Same reasoning as the careers listing: the
 * ceiling answers "how far does this role go", and the floor barely varies.
 *
 * Half-open [min, max); `max: null` is open-ended.
 */
const SALARY_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "to-10", label: "Up to ₹10L", min: 0, max: 10 },
  { id: "10-20", label: "₹10 – 20L", min: 10, max: 20 },
  { id: "20-30", label: "₹20 – 30L", min: 20, max: 30 },
  { id: "30+", label: "₹30L+", min: 30, max: null },
];

const SORTS = [
  { value: "salary-high", label: "Salary: high to low" },
  { value: "az", label: "A – Z" },
  { value: "salary-low", label: "Salary: low to high" },
  { value: "skills", label: "Most skills" },
];

export default function JobRolesExplorer({
  initialJobRoles,
  careers,
  categories,
  fieldsByRole,
}: {
  initialJobRoles: JobRole[];
  careers: CareerRef[];
  categories: Category[];
  /** slug -> the category slugs of this role's parent career(s). */
  fieldsByRole: Record<string, string[]>;
}) {
  const {
    query,
    setQuery,
    filter: field,
    setFilter: setField,
    filter2: levelParam,
    setFilter2: setLevelParam,
    filter3: salaryParam,
    setFilter3: setSalaryParam,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("field", "all", "level", NONE, "salary", NONE, "sort", "salary-high");

  const [view, setView] = useState<ViewMode>("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const careersBySlug = useMemo(() => indexBySlug(careers), [careers]);
  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  // Memoised so the filter memo below can depend on the parsed arrays rather
  // than on the raw param strings, which is what forced an exhaustive-deps
  // suppression here.
  const levels = useMemo(() => splitParam(levelParam), [levelParam]);
  const salaries = useMemo(() => splitParam(salaryParam), [salaryParam]);

  function reset() {
    setField("all");
    setLevelParam(NONE);
    setSalaryParam(NONE);
    setQuery("");
  }

  const activeCount =
    (field !== "all" ? 1 : 0) + levels.length + salaries.length + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialJobRoles.filter((r) => {
      if (field !== "all" && !(fieldsByRole[r.slug] ?? []).includes(field)) return false;
      if (levels.length > 0 && !levels.includes(r.experienceLevel)) return false;

      if (salaries.length > 0) {
        const ceiling = r.salaryMaxLpa;
        // A role with no salary recorded cannot satisfy a salary filter --
        // 8 of 255 are in that state, and including them would be a guess.
        if (ceiling === null) return false;
        const inBand = salaries.some((id) => {
          const b = SALARY_BUCKETS.find((x) => x.id === id);
          return b ? ceiling >= b.min && ceiling < (b.max ?? Infinity) : false;
        });
        if (!inBand) return false;
      }

      if (q === "") return true;
      return r.name.toLowerCase().includes(q) || r.description.toLowerCase().includes(q);
    });
    // `fieldsByRole` was missing from this list entirely while the suppression
    // was in place -- the memo read it but would not have recomputed if it
    // changed.
  }, [initialJobRoles, query, field, levels, salaries, fieldsByRole]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.name.localeCompare(b.name));
      case "salary-low":
        return list.sort((a, b) => (a.salaryMinLpa ?? Infinity) - (b.salaryMinLpa ?? Infinity));
      case "skills":
        return list.sort(
          (a, b) => b.relatedSkillSlugs.length - a.relatedSkillSlugs.length || a.name.localeCompare(b.name)
        );
      default:
        return list.sort(
          (a, b) => (b.salaryMaxLpa ?? -1) - (a.salaryMaxLpa ?? -1) || a.name.localeCompare(b.name)
        );
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts from the UNFILTERED list.
  const fieldCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const slugs of Object.values(fieldsByRole)) {
      for (const f of slugs) counts.set(f, (counts.get(f) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [fieldsByRole, categoriesBySlug]);

  const levelCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const r of initialJobRoles) {
      counts.set(r.experienceLevel, (counts.get(r.experienceLevel) ?? 0) + 1);
    }
    return LEVEL_OPTIONS.filter((l) => counts.has(l)).map((l) => ({
      level: l,
      count: counts.get(l) ?? 0,
    }));
  }, [initialJobRoles]);

  return (
    <Container className="py-8 pb-24">
      <QuickPickRow>
        <QuickPick
          active={field === "all"}
          onClick={() => setField("all")}
          icon="grid"
          label="All Job Roles"
          count={initialJobRoles.length}
          noun="role"
        />
        {fieldCounts.map(({ category: c, count }) => (
          <QuickPick
            key={c!.slug}
            active={field === c!.slug}
            onClick={() => setField(field === c!.slug ? "all" : c!.slug)}
            icon={c!.icon}
            label={c!.name}
            count={count}
            noun="role"
          />
        ))}
      </QuickPickRow>

      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-job-roles"
            title="All Job Roles"
            subtitle="The posts you can be hired into, and what each one pays."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "job role")}
            sort={sort}
            onSortChange={setSort}
            sorts={SORTS}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {field !== "all" && (
                <Chip onRemove={() => setField("all")}>
                  {categoriesBySlug.get(field)?.name ?? field}
                </Chip>
              )}
              {levels.map((l) => (
                <Chip key={l} onRemove={() => toggleParam(levels, l, setLevelParam)}>
                  {l}
                </Chip>
              ))}
              {salaries.map((id) => (
                <Chip key={id} onRemove={() => toggleParam(salaries, id, setSalaryParam)}>
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
                {paginated.map((r) => (
                  <JobRoleListCard
                    key={r.slug}
                    jobRole={r}
                    parent={careersBySlug.get(r.careerSlugs[0])}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="job roles" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          title="Filter Job Roles"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-job-roles"
          ctaLabel={`Show ${sorted.length} job role${sorted.length === 1 ? "" : "s"}`}
        >
          <FilterGroup label="Field">
            <div className="flex flex-col gap-2">
              {fieldCounts.map(({ category: c, count }) => (
                <CheckRow
                  key={c!.slug}
                  checked={field === c!.slug}
                  onChange={() => setField(field === c!.slug ? "all" : c!.slug)}
                  count={count}
                >
                  <Icon name={c!.icon} className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <span className="text-[12.5px] text-ink/80 truncate">{c!.name}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>

          <FilterGroup label="Seniority">
            <div className="flex flex-col gap-2">
              {levelCounts.map(({ level, count }) => (
                <CheckRow
                  key={level}
                  checked={levels.includes(level)}
                  onChange={() => toggleParam(levels, level, setLevelParam)}
                  count={count}
                >
                  <span className="text-[12.5px] text-ink/80">{level}</span>
                </CheckRow>
              ))}
            </div>
          </FilterGroup>

          <FilterGroup label="Salary Potential">
            <div className="flex flex-col gap-2">
              {SALARY_BUCKETS.map((b) => (
                <CheckRow
                  key={b.id}
                  checked={salaries.includes(b.id)}
                  onChange={() => toggleParam(salaries, b.id, setSalaryParam)}
                  count={
                    initialJobRoles.filter(
                      (r) =>
                        r.salaryMaxLpa !== null &&
                        r.salaryMaxLpa >= b.min &&
                        r.salaryMaxLpa < (b.max ?? Infinity)
                    ).length
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
 * The listing card: the role, the career it sits under, seniority and pay.
 *
 * Pay comes from the numeric columns, not the "5 LPA" strings -- so the figure
 * on the card is the same one the filter and the sort use.
 */
function JobRoleListCard({
  jobRole,
  parent,
  view,
}: {
  jobRole: JobRole;
  parent?: CareerRef;
  view: ViewMode;
}) {
  const salary =
    jobRole.salaryMinLpa !== null && jobRole.salaryMaxLpa !== null
      ? `₹${jobRole.salaryMinLpa}–${jobRole.salaryMaxLpa} LPA`
      : null;

  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      <span className="flex items-center gap-1.5 shrink-0">
        <span
          className={`font-bold text-[11.5px] px-2 py-0.5 rounded-full ${LEVEL_STYLES[jobRole.experienceLevel] ?? "bg-slate-soft text-slate"}`}
        >
          {jobRole.experienceLevel}
        </span>
      </span>
      {salary && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="bank" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {salary}
        </span>
      )}
      {jobRole.relatedSkillSlugs.length > 0 && (
        <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
          <Icon name="gear" className="w-3.5 h-3.5 text-subtle shrink-0" />
          {jobRole.relatedSkillSlugs.length} skills
        </span>
      )}
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/job-roles/${jobRole.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className="w-11 h-11 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name="user" className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15px] truncate">
            {jobRole.name}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 truncate">
            {jobRole.description}
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
      href={`/job-roles/${jobRole.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-3">
        <span className="w-11 h-11 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name="user" className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[15.5px] leading-snug">
              {jobRole.name}
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
        {jobRole.description}
      </p>
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
