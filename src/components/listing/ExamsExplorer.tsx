"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Pagination from "@/components/ui/Pagination";
import { Category, Exam } from "@/lib/types";
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
    filter4: body,
    setFilter4: setBody,
    page,
    setPage,
  } = useUrlListState("field", "all", "level", NONE, "frequency", NONE, "body", "all");

  const [view, setView] = useState<"grid" | "list">("grid");
  const [filtersOpen, setFiltersOpen] = useState(false);
  // Sort is not in the URL here: with four filter slots already taken by
  // field/level/frequency/body, there is no fifth, and of the five bits of
  // state on this page sort is the one a shared link least needs.
  const [sort, setSort] = useState("popularity");

  const categoriesBySlug = useMemo(() => indexBySlug(categories), [categories]);
  const levels = splitParam(levelParam);
  const freqs = splitParam(freqParam);

  function toggle(list: string[], value: string, set: (v: string) => void) {
    set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
  }

  function reset() {
    setField("all");
    setLevelParam(NONE);
    setFreqParam(NONE);
    setBody("all");
    setQuery("");
  }

  const activeCount =
    (field !== "all" ? 1 : 0) +
    levels.length +
    freqs.length +
    (body !== "all" ? 1 : 0) +
    (query.trim() ? 1 : 0);

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
      if (body !== "all" && e.conductedBy !== body) return false;
      if (q === "") return true;
      // The full name is what someone typing "joint entrance examination" is
      // after; matching only the acronym would miss it.
      return (
        e.name.toLowerCase().includes(q) ||
        e.fullName.toLowerCase().includes(q) ||
        e.description.toLowerCase().includes(q) ||
        e.conductedBy.toLowerCase().includes(q)
      );
    });
  }, [initialExams, query, field, levelParam, freqParam, body]); // eslint-disable-line react-hooks/exhaustive-deps

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

  const totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const safePage = Math.min(page, totalPages);
  const paginated = sorted.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  const resultsTopRef = useRef<HTMLDivElement>(null);
  function goToPage(next: number) {
    setPage(next);
    resultsTopRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }

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

  const bodies = useMemo(
    () => [...new Set(initialExams.map((e) => e.conductedBy))].sort((a, b) => a.localeCompare(b)),
    [initialExams]
  );

  // Exams with no field (CUET, NTSE) are reachable through "All Exams" and
  // their own chip rather than being filed under a category they do not
  // belong to.
  const unfiled = initialExams.filter((e) => !e.categorySlug).length;

  return (
    <Container className="py-8 pb-24">
      <div className="flex gap-3 overflow-x-auto pb-2 mb-8 -mx-1 px-1">
        <QuickPick
          active={field === "all"}
          onClick={() => setField("all")}
          icon="grid"
          label="All Exams"
          count={initialExams.length}
        />
        {fieldCounts.slice(0, 8).map(({ category: c, count }) => (
          <QuickPick
            key={c!.slug}
            active={field === c!.slug}
            onClick={() => setField(field === c!.slug ? "all" : c!.slug)}
            icon={c!.icon}
            label={c!.name}
            count={count}
          />
        ))}
        {unfiled > 0 && (
          <QuickPick
            active={field === "none"}
            onClick={() => setField(field === "none" ? "all" : "none")}
            icon="compass"
            label="All Fields"
            count={unfiled}
          />
        )}
      </div>

      <div className="flex flex-col lg:flex-row lg:items-start gap-8">
        {/* ------------------------------------------------------------ Results */}
        <div className="flex-1 min-w-0 order-2 lg:order-1">
          <div id="all-exams" className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24">
            <div>
              <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
                <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
                All Exams
              </h2>
              <p className="text-[13px] text-muted mt-1.5">
                Explore different exams and find the one that matches your career goals.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <span className="text-[13px] font-semibold text-subtle">
                {sorted.length > PAGE_SIZE
                  ? `Showing ${(safePage - 1) * PAGE_SIZE + 1}–${Math.min(safePage * PAGE_SIZE, sorted.length)} of ${sorted.length} exams`
                  : `${sorted.length} exam${sorted.length === 1 ? "" : "s"}`}
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
              {field !== "all" && (
                <Chip onRemove={() => setField("all")}>
                  {field === "none" ? "All Fields" : (categoriesBySlug.get(field)?.name ?? field)}
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
              {body !== "all" && <Chip onRemove={() => setBody("all")}>{body}</Chip>}
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
            <div className="text-center py-20">
              <p className="text-muted text-sm">No exams match these filters.</p>
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
                  Filter Exams
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
                  {unfiled > 0 && (
                    <CheckRow
                      checked={field === "none"}
                      onChange={() => setField(field === "none" ? "all" : "none")}
                      count={unfiled}
                    >
                      <Icon name="compass" className="w-3.5 h-3.5 text-subtle shrink-0" />
                      <span className="text-[12.5px] text-ink/80 truncate">All Fields</span>
                    </CheckRow>
                  )}
                </div>
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

              <FilterGroup label="Conducting Body">
                <select
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
                >
                  <option value="all">All Conducting Bodies</option>
                  {bodies.map((b) => (
                    <option key={b} value={b}>
                      {b}
                    </option>
                  ))}
                </select>
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

              <button
                type="button"
                onClick={() => {
                  setFiltersOpen(false);
                  document
                    .getElementById("all-exams")
                    ?.scrollIntoView({ behavior: "smooth", block: "start" });
                }}
                className="w-full mt-5 text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
              >
                Show {sorted.length} exam{sorted.length === 1 ? "" : "s"}
              </button>
            </div>
          </div>
        </aside>
      </div>
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
      <div className="mt-4 px-5 py-3.5 border-t border-line bg-bg-soft">{figures}</div>
    </Link>
  );
}
