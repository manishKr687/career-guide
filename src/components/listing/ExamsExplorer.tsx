"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Category, Exam } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";
import { useUrlListState } from "@/hooks/useUrlListState";
import { usePagedList } from "@/hooks/usePagedList";
import {
  CheckRow,
  Chip,
  FilterGroup,
  FilterRail,
  FilterSelect,
  ListingLayout,
  NONE,
  NoResults,
  ResultsColumn,
  ResultsHeader,
  countLabel,
  joinParam,
  splitParam,
} from "@/components/listing/ListingKit";

const PAGE_SIZE = 12;

// The catalog's seven levels (V112), ordered as a student climbs rather than
// alphabetically. Not the mock's Undergraduate/Postgraduate/Doctorate/
// Certification/Competitive: "Doctorate" would match nothing here, and what
// this catalog actually holds is a Research bucket (UGC-NET, CSIR-NET, JRF)
// that gates a PhD rather than being one.
const LEVEL_OPTIONS = [
  "School",
  "Diploma",
  "Undergraduate",
  "Postgraduate",
  "Research",
  "Certification",
  "Recruitment",
];

const LEVEL_STYLES: Record<string, string> = {
  School: "bg-slate-soft text-slate",
  Diploma: "bg-amber-soft text-amber",
  Undergraduate: "bg-blue-soft text-blue",
  Postgraduate: "bg-purple-soft text-purple",
  Research: "bg-teal-soft text-teal",
  Certification: "bg-green-soft text-green",
  Recruitment: "bg-pink-soft text-pink",
};

// Only the four buckets this catalog uses. Quarterly and Monthly exist in the
// column's CHECK constraint but no exam is either, and an always-empty facet
// is a dead control.
const FREQUENCY_OPTIONS = ["Annual", "Biannual", "Rolling", "As notified"];

const SORTS = [
  { value: "popularity", label: "Popularity" },
  { value: "az", label: "A – Z" },
  { value: "level", label: "Level" },
];


export default function ExamsExplorer({
  initialExams,
  categories,
}: {
  initialExams: Exam[];
  categories: Category[];
}) {
  const {
    query,
    setQuery,
    filter: field,
    setFilter: setField,
    filter2: levelParam,
    setFilter2: setLevelParam,
    filter3: freqParam,
    setFilter3: setFreqParam,
    filter4: sort,
    setFilter4: setSort,
    page,
    setPage,
  } = useUrlListState("field", "all", "level", NONE, "frequency", NONE, "sort", "popularity");

  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  // Memoised so the filter memo below can depend on the parsed arrays rather
  // than on the raw param strings, which is what forced an exhaustive-deps
  // suppression here.
  const levels = useMemo(() => splitParam(levelParam), [levelParam]);
  const freqs = useMemo(() => splitParam(freqParam), [freqParam]);

  function toggle(list: string[], value: string, set: (v: string) => void) {
    set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
  }

  function reset() {
    setField("all");
    setLevelParam(NONE);
    setFreqParam(NONE);
    setQuery("");
  }

  const activeCount =
    (field !== "all" ? 1 : 0) + levels.length + freqs.length + (query.trim() ? 1 : 0);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return initialExams.filter((e) => {
      // "none" is the sentinel for the two exams that belong to no single
      // field (CUET, NTSE). Comparing it as a slug would never match, since
      // their categorySlug is null rather than the string "none".
      if (field === "none") {
        if (e.categorySlug !== null) return false;
      } else if (field !== "all" && e.categorySlug !== field) {
        return false;
      }
      if (levels.length > 0 && !levels.includes(e.level)) return false;
      if (freqs.length > 0 && !freqs.includes(e.frequencyType)) return false;
      if (q === "") return true;
      // The full name is what someone typing "joint entrance examination" is
      // after; matching only the acronym would miss it. Matching the conducting
      // body here is also what let the "Conducting Body" dropdown go: typing
      // "NTA" finds the same four exams that facet's 27 options did, 26 of
      // which picked out one or two rows.
      return (
        e.name.toLowerCase().includes(q) ||
        e.fullName.toLowerCase().includes(q) ||
        e.description.toLowerCase().includes(q) ||
        e.conductedBy.toLowerCase().includes(q)
      );
    });
  }, [initialExams, query, field, levels, freqs]);

  const sorted = useMemo(() => {
    const list = [...filtered];
    switch (sort) {
      case "az":
        return list.sort((a, b) => a.name.localeCompare(b.name));
      case "level":
        return list.sort(
          (a, b) =>
            LEVEL_OPTIONS.indexOf(a.level) - LEVEL_OPTIONS.indexOf(b.level) ||
            a.name.localeCompare(b.name)
        );
      default:
        // "Popularity": how many careers an exam opens up. The closest thing
        // the catalog can prove to how much an exam matters -- it is a measure
        // of reach, not of how many people sit it.
        return list.sort(
          (a, b) => b.careerSlugs.length - a.careerSlugs.length || a.name.localeCompare(b.name)
        );
    }
  }, [filtered, sort]);

  const { paginated, safePage, totalPages, resultsTopRef, goToPage } = usePagedList(
    sorted,
    page,
    setPage,
    PAGE_SIZE
  );

  // Counts from the UNFILTERED list, so a facet always says how many exams it
  // holds rather than how many survive the current filter.
  const fieldCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const e of initialExams) {
      if (e.categorySlug) counts.set(e.categorySlug, (counts.get(e.categorySlug) ?? 0) + 1);
    }
    return [...counts.entries()]
      .map(([slug, count]) => ({ category: categoriesBySlug.get(slug), count }))
      .filter((x) => x.category)
      .sort((a, b) => b.count - a.count);
  }, [initialExams, categoriesBySlug]);

  const levelCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const e of initialExams) counts.set(e.level, (counts.get(e.level) ?? 0) + 1);
    return LEVEL_OPTIONS.filter((l) => counts.has(l)).map((l) => ({
      level: l,
      count: counts.get(l) ?? 0,
    }));
  }, [initialExams]);

  const freqCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const e of initialExams) counts.set(e.frequencyType, (counts.get(e.frequencyType) ?? 0) + 1);
    return FREQUENCY_OPTIONS.filter((f) => counts.has(f)).map((f) => ({
      frequency: f,
      count: counts.get(f) ?? 0,
    }));
  }, [initialExams]);

  // Exams with no field (CUET, NTSE) are reachable through "All Exams" and
  // their own chip rather than being filed under a category they do not
  // belong to.
  const unfiled = initialExams.filter((e) => !e.categorySlug).length;

  return (
    <Container className="py-8 pb-24">
      <ListingLayout>
        <ResultsColumn>
          <ResultsHeader
            anchorId="all-exams"
            title="All Exams"
            subtitle="Explore different exams and find the one that matches your career goals."
            countLabel={countLabel(sorted.length, safePage, PAGE_SIZE, "exam")}
            view={view}
            onViewChange={setView}
          />

          {activeCount > 0 && (
            <div ref={resultsTopRef} className="flex flex-wrap items-center gap-2 mb-5">
              {query.trim() && <Chip onRemove={() => setQuery("")}>{`"${query.trim()}"`}</Chip>}
              {field !== "all" && (
                <Chip onRemove={() => setField("all")}>
                  {field === "none" ? "No single field" : (categoriesBySlug.get(field)?.name ?? field)}
                </Chip>
              )}
              {levels.map((l) => (
                <Chip key={l} onRemove={() => toggle(levels, l, setLevelParam)}>
                  {l}
                </Chip>
              ))}
              {freqs.map((f) => (
                <Chip key={f} onRemove={() => toggle(freqs, f, setFreqParam)}>
                  {f}
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
                {paginated.map((exam) => (
                  <ExamListCard
                    key={exam.slug}
                    exam={exam}
                    category={exam.categorySlug ? categoriesBySlug.get(exam.categorySlug) : undefined}
                    view={view}
                  />
                ))}
              </div>
              <Pagination page={safePage} totalPages={totalPages} onChange={goToPage} />
            </>
          ) : (
            <NoResults noun="exams" activeCount={activeCount} onReset={reset} />
          )}
        </ResultsColumn>

        <FilterRail
          query={query}
          onQueryChange={setQuery}
          searchPlaceholder="Search exams..."
          searchLabel="Search exams"
          sort={sort}
          onSortChange={setSort}
          sorts={SORTS}
          title="Filter Exams"
          open={filtersOpen}
          onOpenChange={setFiltersOpen}
          activeCount={activeCount}
          onReset={reset}
          anchorId="all-exams"
          ctaLabel={`Show ${sorted.length} exam${sorted.length === 1 ? "" : "s"}`}
        >
          {/* 13 categories, 12 of which hold two exams or fewer. As a
              checkbox list that was most of the rail; the strip above the
              results showed only the top 8, so the two copies disagreed
              about which categories you could even reach.

              The unfiled option is labelled for what it means here. In a
              dropdown sitting under "All categories", the old "All Fields"
              read as the cleared state rather than as its opposite. */}
          <FilterGroup label="Category">
            <FilterSelect
              id="all-exams-field"
              value={field}
              onChange={setField}
              allLabel="All categories"
              options={[
                ...fieldCounts.map(({ category: c, count }) => ({
                  value: c!.slug,
                  label: c!.name,
                  count,
                })),
                ...(unfiled > 0
                  ? [{ value: "none", label: "No single field", count: unfiled }]
                  : []),
              ]}
            />
          </FilterGroup>

          <FilterGroup label="Exam Level">
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

          <FilterGroup label="Frequency">
            <div className="flex flex-col gap-2">
              {freqCounts.map(({ frequency, count }) => (
                <CheckRow
                  key={frequency}
                  checked={freqs.includes(frequency)}
                  onChange={() => toggle(freqs, frequency, setFreqParam)}
                  count={count}
                >
                  <span className="text-[12.5px] text-ink/80">{frequency}</span>
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
 * The listing card: acronym, full name, description, the field/stage tags, and
 * a footer of level, frequency and conducting body.
 *
 * The third footer figure is the conducting body rather than the mock's exam
 * months. Dates shift year to year, so a static month on a listing page would
 * go stale silently -- they belong in a per-year sessions model. The body is
 * real for all 34 and is the other thing people actually check.
 */
function ExamListCard({
  exam,
  category,
  view,
}: {
  exam: Exam;
  category?: Category;
  view: "grid" | "list";
}) {
  const figures = (
    <div className="flex items-center gap-4 text-[12px]">
      <span className="flex items-center gap-1.5 shrink-0">
        <Icon name="cap" className="w-3.5 h-3.5 text-subtle shrink-0" />
        <span
          className={`font-bold text-[11.5px] px-2 py-0.5 rounded-full ${LEVEL_STYLES[exam.level] ?? "bg-slate-soft text-slate"}`}
        >
          {exam.level}
        </span>
      </span>
      <span
        className="flex items-center gap-1.5 text-muted whitespace-nowrap"
        title={exam.frequency}
      >
        <Icon name="cal" className="w-3.5 h-3.5 text-subtle shrink-0" />
        {exam.frequencyType}
      </span>
      <span className="flex items-center gap-1.5 text-muted min-w-0" title={exam.conductedBy}>
        <Icon name="bld" className="w-3.5 h-3.5 text-subtle shrink-0" />
        <span className="truncate">{exam.conductedBy}</span>
      </span>
    </div>
  );

  if (view === "list") {
    return (
      <Link
        href={`/exams/${exam.slug}`}
        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 hover:border-blue/40 hover:shadow-card transition-all"
      >
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={exam.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-display font-bold text-navy text-[15.5px]">{exam.name}</span>
          <span className="block text-[12.5px] text-muted mt-0.5 line-clamp-1">
            {exam.fullName}
          </span>
        </span>
        <span className="hidden sm:block shrink-0 max-w-[45%]">{figures}</span>
        <Icon
          name="chevRight"
          className="w-4 h-4 text-subtle shrink-0 group-hover:text-blue transition-colors"
        />
      </Link>
    );
  }

  return (
    <Link
      href={`/exams/${exam.slug}`}
      className="group flex flex-col rounded-2xl border border-line bg-white overflow-hidden hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start gap-3.5 p-5 pb-3">
        <span className="w-12 h-12 rounded-xl bg-blue-soft text-blue flex items-center justify-center shrink-0">
          <Icon name={exam.icon} className="w-6 h-6" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="flex items-start justify-between gap-2">
            <span className="font-display font-bold text-navy text-[16px] leading-snug">
              {exam.name}
            </span>
            <Icon
              name="chevRight"
              className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
            />
          </span>
          <span className="block text-[12.5px] font-semibold text-ink/60 mt-0.5 leading-snug">
            {exam.fullName}
          </span>
        </span>
      </div>
      <p className="px-5 text-[12.5px] text-ink/70 leading-relaxed line-clamp-2">
        {exam.description}
      </p>
      {/* Two tags: the field it belongs to and the stage it sits at. `category`
          is the stage axis the pre-V112 column has always held. */}
      <div className="flex flex-wrap gap-1.5 px-5 mt-3 flex-1 content-start">
        {category && (
          <span className="text-[11px] font-bold px-2.5 py-1 rounded-full bg-blue-soft text-blue">
            {category.name}
          </span>
        )}
        <span className="text-[11px] font-bold px-2.5 py-1 rounded-full bg-bg-soft text-ink/70">
          {exam.category}
        </span>
      </div>
      {/* Conducting body on its own line. Sharing one line with level and
          frequency left it about 80px, so "National Testing Agency (NTA)"
          read as "Na..." and "IIT (rotating zone)" as "IIT (r...". Every exam
          has one, so every footer is two lines and a row stays aligned. */}
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft text-[12px]">
        <div className="flex items-center gap-4">
          <span className="flex items-center gap-1.5 shrink-0">
            <Icon name="cap" className="w-3.5 h-3.5 text-subtle shrink-0" />
            <span
              className={`font-bold text-[11.5px] px-2 py-0.5 rounded-full whitespace-nowrap ${LEVEL_STYLES[exam.level] ?? "bg-slate-soft text-slate"}`}
            >
              {exam.level}
            </span>
          </span>
          <span className="flex items-center gap-1.5 text-muted whitespace-nowrap" title={exam.frequency}>
            <Icon name="cal" className="w-3.5 h-3.5 text-subtle shrink-0" />
            {exam.frequencyType}
          </span>
        </div>
        <div className="flex items-center gap-1.5 text-muted mt-2 min-w-0" title={exam.conductedBy}>
          <Icon name="bld" className="w-3.5 h-3.5 text-subtle shrink-0" />
          <span className="truncate">{exam.conductedBy}</span>
        </div>
      </div>
    </Link>
  );
}
