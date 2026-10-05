"use client";

import Link from "next/link";
import { useCallback, useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Category, Skill } from "@/lib/types";
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

// The catalog's five categories (V114). Not the seven a skills taxonomy
// usually has: "Creative" and "Language" were tried and dropped because
// deciding from a name alone whether "Experimental Design" is creative or
// scientific is guesswork, and a facet built on a guess is worse than one
// bucket fewer.
const CATEGORY_OPTIONS = ["Programming", "Tools", "Analytical", "Soft", "Domain"];

const CATEGORY_LABELS: Record<string, string> = {
  Soft: "Soft Skills",
  Programming: "Programming",
  Tools: "Tools & Tech",
  Analytical: "Analytical",
  Domain: "Domain Skills",
};

const CATEGORY_STYLES: Record<string, string> = {
  Programming: "bg-blue-soft text-blue",
  Tools: "bg-purple-soft text-purple",
  Analytical: "bg-teal-soft text-teal",
  Soft: "bg-green-soft text-green",
  Domain: "bg-amber-soft text-amber",
};

const CATEGORY_ICONS: Record<string, string> = {
  Programming: "code",
  Tools: "wrench",
  Analytical: "chart",
  Soft: "users",
  Domain: "compass",
};

/**
 * Reach buckets, on how many job roles ask for a skill.
 *
 * This is the page's answer to the "demand level" a skills listing normally
 * shows. Nothing in this catalog implies market demand -- no posting counts,
 * no salary signal -- so a High/Medium/Low badge would be a claim with
 * nothing behind it. How many of 255 job roles list a skill is a real number,
 * and it is labelled as reach rather than dressed up as demand.
 */
const REACH_BUCKETS: { id: string; label: string; min: number; max: number | null }[] = [
  { id: "wide", label: "10+ job roles", min: 10, max: null },
  { id: "several", label: "4 – 9 job roles", min: 4, max: 9 },
  { id: "few", label: "1 – 3 job roles", min: 1, max: 3 },
  { id: "none", label: "Not yet mapped", min: 0, max: 0 },
];

const SORTS = [
  { value: "reach", label: "Most used" },
  { value: "az", label: "A – Z" },
  { value: "careers", label: "Most careers" },
];


export default function SkillsExplorer({
  initialSkills,
  categories,
  careerCounts,
  roleCounts,
  fieldsBySkill,
}: {
  initialSkills: Skill[];
  categories: Category[];
  /** slug -> how many careers list this skill. */
  careerCounts: Record<string, number>;
  /** slug -> how many job roles list this skill. */
  roleCounts: Record<string, number>;
  /** slug -> the career-category slugs this skill appears in. */
  fieldsBySkill: Record<string, string[]>;
}) {
  const {
    query,
    setQuery,
    filter: categoryParam,
    setFilter: setCategoryParam,
    filter2: reachParam,
    setFilter2: setReachParam,
    filter3: field,
    setFilter3: setField,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("category", NONE, "reach", NONE, "field", "all", "sort", "reach");

  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  // All four memoised so the filter, sort and top-skills memos below can name
  // them as dependencies. Previously the parsed arrays were rebuilt each render
  // and the two count lookups were plain closures over props, so none could be a
  // dependency and all three memos carried exhaustive-deps suppressions instead.
  const cats = useMemo(() => splitParam(categoryParam), [categoryParam]);
  const reaches = useMemo(() => splitParam(reachParam), [reachParam]);
  const roles = useCallback((slug: string) => roleCounts[slug] ?? 0, [roleCounts]);
  const careers = useCallback((slug: string) => careerCounts[slug] ?? 0, [careerCounts]);

  function toggle(list: string[], value: string, set: (v: string) => void) {
    set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
  }

  function reset() {
    setCategoryParam(NONE);
    setReachParam(NONE);
    setField("all");
    setQuery("");
  }

  const activeCount =
    cats.length + reaches.length + (field !== "all" ? 1 : 0) + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialSkills.filter((s) => {
      if (cats.length > 0 && !cats.includes(s.category)) return false;

      if (reaches.length > 0) {
        const n = roles(s.slug);
        const inBand = reaches.some((id) => {
          const b = REACH_BUCKETS.find((x) => x.id === id);
          return b ? n >= b.min && n <= (b.max ?? Infinity) : false;
        });
        if (!inBand) return false;
      }

      if (field !== "all" && !(fieldsBySkill[s.slug] ?? []).includes(field)) return false;

      if (q === "") return true;
      return s.name.toLowerCase().includes(q) || (s.description?.toLowerCase().includes(q) ?? false);
    });
    // `fieldsBySkill` was missing from this list entirely while the suppression
    // was in place -- the memo read it but would not have recomputed if it
    // changed.
  }, [initialSkills, query, cats, reaches, field, roles, fieldsBySkill]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.name.localeCompare(b.name));
      case "careers":
        return list.sort((a, b) => careers(b.slug) - careers(a.slug) || a.name.localeCompare(b.name));
      default:
        return list.sort((a, b) => roles(b.slug) - roles(a.slug) || a.name.localeCompare(b.name));
    }
  }, [filtered, sort, careers, roles]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts from the UNFILTERED list.
  const categoryCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const s of initialSkills) counts.set(s.category, (counts.get(s.category) ?? 0) + 1);
    return CATEGORY_OPTIONS.filter((c) => counts.has(c)).map((c) => ({
      category: c,
      count: counts.get(c) ?? 0,
    }));
  }, [initialSkills]);

  const fieldOptions = useMemo(() => {
    const counts = new Map<string, number>();
    for (const slugs of Object.values(fieldsBySkill)) {
      for (const f of slugs) counts.set(f, (counts.get(f) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [fieldsBySkill, categoriesBySlug]);

  const topSkills = useMemo(
    () =>
      [...initialSkills]
        .filter((s) => roles(s.slug) > 0)
        .sort((a, b) => roles(b.slug) - roles(a.slug) || a.name.localeCompare(b.name))
        .slice(0, 6),
    [initialSkills, roles]
  );

  return (
    <Container className="py-8 pb-24">
      <div className="flex gap-3 overflow-x-auto pb-2 mb-8 -mx-1 px-1">
        <QuickPick
          active={cats.length === 0}
          onClick={() => setCategoryParam(NONE)}
          icon="grid"
          label="All Skills"
          count={initialSkills.length}
        />
        {categoryCounts.map(({ category: c, count }) => (
          <QuickPick
            key={c}
            active={cats.includes(c)}
            onClick={() => toggle(cats, c, setCategoryParam)}
            icon={CATEGORY_ICONS[c] ?? "gear"}
            label={CATEGORY_LABELS[c] ?? c}
            count={count}
          />
        ))}
      </div>

      <div className="flex flex-col lg:flex-row lg:items-start gap-8">
        {/* ------------------------------------------------------------ Results */}
        <div className="flex-1 min-w-0 order-2">
          <div id="all-skills" className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24">
            <div>
              <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
                <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
                All Skills
              </h2>
              <p className="text-[13px] text-muted mt-1.5">
                Explore different skills and find the ones that match your career goals.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <span className="text-[13px] font-semibold text-subtle">
                {sorted.length > PAGE_SIZE
                  ? `Showing ${(safePage - 1) * PAGE_SIZE + 1}–${Math.min(safePage * PAGE_SIZE, sorted.length)} of ${sorted.length} skills`
                  : `${sorted.length} skill${sorted.length === 1 ? "" : "s"}`}
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
                    <Icon name={v} className="w-4 h-4" />
                  </button>
                ))}
              </div>
            </div>
          </div>

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {cats.map((c) => (
                <Chip key={c} onRemove={() => toggle(cats, c, setCategoryParam)}>
                  {CATEGORY_LABELS[c] ?? c}
                </Chip>
              ))}
              {reaches.map((r) => (
                <Chip key={r} onRemove={() => toggle(reaches, r, setReachParam)}>
                  {REACH_BUCKETS.find((b) => b.id === r)?.label ?? r}
                </Chip>
              ))}
              {field !== "all" && (
                <Chip onRemove={() => setField("all")}>
                  {categoriesBySlug.get(field)?.name ?? field}
                </Chip>
              )}
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
                {paginated.map((skill) => (
                  <SkillListCard
                    key={skill.slug}
                    skill={skill}
                    careerCount={careers(skill.slug)}
                    roleCount={roles(skill.slug)}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <div className="text-center py-20">
              <p className="text-muted text-sm">No skills match these filters.</p>
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
        <aside className="w-full lg:w-[264px] lg:shrink-0 order-1 lg:sticky lg:top-24">
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
              Search &amp; filter
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
                  Filter Skills
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
              {/* Search lives in this panel with sort and the filters, so one
                  place changes what you see. It narrows as you type, unlike the
                  hero form it replaced, which had to be submitted. */}
              <div className="pb-4 mb-4 border-b border-line">
                <label htmlFor="skills-q" className="block text-[12.5px] font-bold text-navy mb-2.5">
                  Search
                </label>
                <div className="flex items-center gap-2 rounded-xl border border-line bg-white px-3 py-2 focus-within:border-blue/50 transition-colors">
                  <Icon name="search" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <input
                    id="skills-q"
                    type="search"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="Search skills..."
                    aria-label="Search skills"
                    className="flex-1 min-w-0 bg-transparent text-[13px] text-ink placeholder:text-subtle outline-none"
                  />
                </div>
              </div>

              <div className="pb-4 mb-4 border-b border-line">
                <label htmlFor="SkillsExplorer-sort" className="block text-[12.5px] font-bold text-navy mb-2.5">
                  Sort by
                </label>
                <select
                  id="SkillsExplorer-sort"
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

              <FilterGroup label="Category">
                <div className="flex flex-col gap-2">
                  {categoryCounts.map(({ category: c, count }) => (
                    <CheckRow
                      key={c}
                      checked={cats.includes(c)}
                      onChange={() => toggle(cats, c, setCategoryParam)}
                      count={count}
                    >
                      <Icon
                        name={CATEGORY_ICONS[c] ?? "gear"}
                        className="w-3.5 h-3.5 text-subtle shrink-0"
                      />
                      <span className="text-[12.5px] text-ink/80">{CATEGORY_LABELS[c] ?? c}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              {/* Not "Demand Level". Nothing in this catalog implies market
                  demand, so a High/Medium/Low badge would be invented. How
                  many job roles ask for a skill is real, and says what the
                  reader wanted to know anyway. */}
              <FilterGroup label="Used by">
                <div className="flex flex-col gap-2">
                  {REACH_BUCKETS.map((b) => (
                    <CheckRow
                      key={b.id}
                      checked={reaches.includes(b.id)}
                      onChange={() => toggle(reaches, b.id, setReachParam)}
                      count={
                        initialSkills.filter((s) => {
                          const n = roles(s.slug);
                          return n >= b.min && n <= (b.max ?? Infinity);
                        }).length
                      }
                    >
                      <span className="text-[12.5px] text-ink/80">{b.label}</span>
                    </CheckRow>
                  ))}
                </div>
              </FilterGroup>

              {/* "Relevance to career", as a field rather than a single career:
                  a 42-entry dropdown of careers would be unusable, and the
                  category a skill's careers sit in is the useful granularity. */}
              <FilterGroup label="Relevant to field">
                <select
                  value={field}
                  onChange={(e) => setField(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
                >
                  <option value="all">All fields</option>
                  {fieldOptions.map(({ category: c, count }) => (
                    <option key={c!.slug} value={c!.slug}>
                      {c!.name} ({count})
                    </option>
                  ))}
                </select>
              </FilterGroup>

              <button
                type="button"
                onClick={() => {
                  setFiltersOpen(false);
                  document
                    .getElementById("all-skills")
                    ?.scrollIntoView({ behavior: "smooth", block: "start" });
                }}
                className="w-full mt-5 text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                Show {sorted.length} skill{sorted.length === 1 ? "" : "s"}
              </button>
            </div>

            {topSkills.length > 0 && (
              <div className="rounded-3xl border border-line bg-white p-5">
                <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px] mb-3">
                  <Icon name="trophy" className="w-4 h-4 text-blue" />
                  Most used skills
                </h2>
                <ul className="flex flex-col">
                  {topSkills.map((s, i) => (
                    <li key={s.slug}>
                      <Link
                        href={`/skills/${s.slug}`}
                        className="group flex items-center gap-2.5 py-2.5 border-b border-line last:border-0 -mx-2 px-2 rounded-lg hover:bg-bg-soft transition-colors"
                      >
                        <span className="w-6 h-6 rounded-lg bg-bg-soft text-navy flex items-center justify-center shrink-0 text-[11px] font-bold">
                          {i + 1}
                        </span>
                        <span className="flex-1 min-w-0">
                          <span className="block text-[13px] font-semibold text-ink/85 truncate">
                            {s.name}
                          </span>
                          <span className="block text-[11px] text-muted">
                            {roles(s.slug)} job roles
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
 * Shows reach -- careers and job roles that ask for the skill -- where the
 * mock shows a demand badge and a job-count. The counts are the same idea and
 * are real; the badge is not, so it is absent rather than invented.
 *
 * `description` is null for every skill today, so the card falls back to its
 * category. That reads as a deliberate label rather than a gap.
 */
function SkillListCard({
  skill,
  careerCount,
  roleCount,
  view,
}: {
  skill: Skill;
  careerCount: number;
  roleCount: number;
  view: "grid" | "list";
}) {
  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
        <Icon name="users" className="w-3.5 h-3.5 text-subtle shrink-0" />
        {roleCount} job role{roleCount === 1 ? "" : "s"}
      </span>
      <span className="flex items-center gap-1.5 text-muted whitespace-nowrap">
        <Icon name="brief" className="w-3.5 h-3.5 text-subtle shrink-0" />
        {careerCount} career{careerCount === 1 ? "" : "s"}
      </span>
    </div>
  );

  const tint = CATEGORY_STYLES[skill.category] ?? "bg-bg-soft text-navy";

  if (view === "list") {
    return (
      <Link
        href={`/skills/${skill.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 ${tint}`}>
          <Icon name={CATEGORY_ICONS[skill.category] ?? "gear"} className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15px] truncate">
            {skill.name}
          </span>
          <span className="block text-[12.5px] text-muted mt-0.5 truncate">
            {skill.description ?? (CATEGORY_LABELS[skill.category] ?? skill.category)}
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
      href={`/skills/${skill.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-3">
        <span className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 ${tint}`}>
          <Icon name={CATEGORY_ICONS[skill.category] ?? "gear"} className="w-5 h-5" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[15.5px] leading-snug">
              {skill.name}
            </span>
            <Icon
              name="chevRight"
              className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
            />
          </span>
        </span>
      </div>
      {skill.description && (
        <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2">
          {skill.description}
        </p>
      )}
      <div className="flex flex-wrap gap-1.5 px-5 mt-2 flex-1 content-start">
        <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${tint}`}>
          {CATEGORY_LABELS[skill.category] ?? skill.category}
        </span>
        {skill.skillType && skill.skillType !== skill.category && (
          <span className="text-[11px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-ink/70">
            {skill.skillType}
          </span>
        )}
      </div>
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
