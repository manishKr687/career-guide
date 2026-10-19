"use client";

import { useState } from "react";
import Icon from "@/components/ui/Icon";

/**
 * The shared furniture of the explore/listing pages.
 *
 * Careers, Degrees, Exams, Colleges and Skills were each carrying their own
 * copy of QuickPick, FilterGroup, CheckRow and Chip, plus the same results
 * header and the same collapsible filter panel. The copies had already begun
 * to drift -- Careers' CheckRow had no count column and its Chip did not
 * truncate, both of which the later pages fixed without the earlier ones
 * getting the change. This is the newest version of each, so consolidating
 * upgrades the older callers rather than levelling them down.
 *
 * Kept separate from DetailKit: the detail pages read a single record and
 * these browse a list, so they share an aesthetic but not a component.
 */

export type ViewMode = "grid" | "list";

/**
 * Multi-select filters ride in the single-value slots useUrlListState gives
 * us, comma-joined, so /careers?demand=Emerging,Stable stays shareable and
 * bookmarkable like every other listing page's state.
 */
export const NONE = "all";

export const splitParam = (v: string): string[] => (v === NONE || !v ? [] : v.split(","));

export const joinParam = (v: string[]): string => (v.length === 0 ? NONE : v.join(","));

/** Toggles one value in a comma-joined multi-select param. */
export function toggleParam(list: string[], value: string, set: (v: string) => void) {
  set(joinParam(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]));
}

/*
 * QuickPick and QuickPickRow lived here: the horizontally scrolling strip of
 * category tiles that sat above the results on nine of the ten listing pages.
 *
 * Every one of them drove the same state as the first group in the filter
 * panel, so each page shipped its primary facet twice -- and because the strips
 * were truncated to fit (Degrees' top 7 of 14, Exams' top 8 of 13) the two
 * copies disagreed about which options existed at all. Careers had already
 * dropped its strip when the filters moved into the left rail; this is the rest
 * of the pages catching up.
 *
 * Deleted rather than left as unused exports, so nothing reintroduces the
 * duplicate by reaching for a component that is still here.
 */

/** One labelled block inside the filter card. */
export function FilterGroup({
  label,
  children,
  collapsible = false,
  activeCount = 0,
}: {
  label: string;
  children: React.ReactNode;
  /**
   * Render the group behind a disclosure, closed unless something in it is
   * already selected. For a filter worth keeping but not worth the vertical
   * space it takes from the ones people actually use.
   */
  collapsible?: boolean;
  /** How many options in this group are selected. Shown on the summary when closed, so a collapsed filter is never silently in effect. */
  activeCount?: number;
}) {
  // Deliberately NOT <details open={activeCount > 0}>. React re-applies `open`
  // on every render, so any unrelated state change -- a keystroke in the search
  // box, a page change -- would snap the panel shut under someone who had just
  // opened it. The initial value is read once; after that the group is wherever
  // the reader left it.
  const [open, setOpen] = useState(activeCount > 0);
  const panelId = `filter-group-${label.replace(/[^a-z0-9]+/gi, "-").toLowerCase()}`;

  if (!collapsible) {
    return (
      <div className="pt-4 mt-4 border-t border-line first:pt-0 first:mt-0 first:border-0">
        <div className="text-[12.5px] font-bold text-navy mb-2.5">{label}</div>
        {children}
      </div>
    );
  }

  return (
    <div className="pt-4 mt-4 border-t border-line first:pt-0 first:mt-0 first:border-0">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        aria-controls={panelId}
        className="w-full flex items-center gap-2 text-left text-[12.5px] font-bold text-navy py-1.5"
      >
        <Icon
          name="chevRight"
          className={`w-3.5 h-3.5 text-subtle shrink-0 transition-transform ${open ? "rotate-90" : ""}`}
        />
        <span className="flex-1">{label}</span>
        {activeCount > 0 && (
          <span className="text-[11px] font-bold text-blue bg-blue-soft rounded-full px-2 py-0.5 shrink-0">
            {activeCount}
          </span>
        )}
      </button>
      <div id={panelId} hidden={!open} className="mt-2.5">
        {children}
      </div>
    </div>
  );
}

/**
 * A single-select facet, as a dropdown.
 *
 * Four of these started life as CheckRow lists, which was the wrong control
 * twice over. Ticking one box cleared the box you had ticked before, so they
 * were radios wearing a checkbox; and the longest of them, Exams' 13
 * categories, was most of the rail's height for a facet whose options mostly
 * pick out one or two rows. The counts move into the option labels, so nothing
 * the checkbox list told you is lost.
 *
 * Multi-select facets stay as CheckRow lists -- a dropdown cannot show two
 * things chosen at once.
 */
export function FilterSelect({
  id,
  value,
  onChange,
  allLabel,
  options,
}: {
  id: string;
  value: string;
  onChange: (v: string) => void;
  /** The cleared state, e.g. "All fields". Selecting it sets the value to NONE. */
  allLabel: string;
  options: { value: string; label: string; count?: number }[];
}) {
  return (
    <select
      id={id}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
    >
      <option value={NONE}>{allLabel}</option>
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
          {o.count !== undefined ? ` (${o.count})` : ""}
        </option>
      ))}
    </select>
  );
}

/** A checkbox row with an optional right-aligned count. */
export function CheckRow({
  checked,
  onChange,
  count,
  children,
}: {
  checked: boolean;
  onChange: () => void;
  count?: number;
  children: React.ReactNode;
}) {
  return (
    <label className="flex items-center gap-2 cursor-pointer select-none">
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}
        className="w-4 h-4 rounded border-line accent-blue shrink-0"
      />
      {children}
      {count !== undefined && (
        <span className="ml-auto text-[11.5px] text-muted shrink-0">{count}</span>
      )}
    </label>
  );
}

/** A removable active-filter chip, shown above the results. */
export function Chip({ children, onRemove }: { children: React.ReactNode; onRemove: () => void }) {
  return (
    <span className="inline-flex items-center gap-1.5 text-[12.5px] font-semibold text-navy bg-bg-soft border border-line rounded-full pl-3 pr-1.5 py-1.5 max-w-full">
      <span className="truncate">{children}</span>
      <button
        type="button"
        onClick={onRemove}
        aria-label="Remove filter"
        className="w-5 h-5 rounded-full flex items-center justify-center text-subtle hover:text-navy hover:bg-line transition-colors shrink-0"
      >
        <Icon name="close" className="w-3 h-3" />
      </button>
    </span>
  );
}

/**
 * The row above the results: heading, the live count, sort, and the view
 * toggle. The count sits inline here rather than on its own line, which is
 * where it started and where it read as an orphan.
 */
export function ResultsHeader({
  anchorId,
  title,
  subtitle,
  countLabel,
  sort,
  onSortChange,
  sorts,
  view,
  onViewChange,
}: {
  anchorId: string;
  title: string;
  subtitle: string;
  countLabel: string;
  /**
   * Omitted when FilterRail owns sort, which is the case on every listing page
   * now -- one control that changes what you see, not two at opposite ends of
   * the page. Kept optional rather than deleted so a future page that has a
   * sort but no filter rail still has somewhere to put it.
   */
  sort?: string;
  onSortChange?: (v: string) => void;
  sorts?: { value: string; label: string }[];
  view: ViewMode;
  onViewChange: (v: ViewMode) => void;
}) {
  return (
    <div
      id={anchorId}
      className="flex flex-wrap items-end justify-between gap-4 mb-6 scroll-mt-24"
    >
      <div>
        <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[22px]">
          <Icon name="grid" className="w-[22px] h-[22px] text-blue shrink-0" />
          {title}
        </h2>
        <p className="text-[13px] text-muted mt-1.5">{subtitle}</p>
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <span className="text-[13px] font-semibold text-subtle">{countLabel}</span>
        {sort !== undefined && onSortChange && sorts && (
        <label className="flex items-center gap-2">
          <span className="text-[12.5px] font-semibold text-muted">Sort by</span>
          <select
            value={sort}
            onChange={(e) => onSortChange(e.target.value)}
            className="rounded-xl border border-line bg-white px-3 py-2 text-[13px] font-semibold text-navy"
          >
            {sorts.map((s) => (
              <option key={s.value} value={s.value}>
                {s.label}
              </option>
            ))}
          </select>
        </label>
        )}
        <div className="flex items-center rounded-xl border border-line overflow-hidden">
          {(["grid", "list"] as const).map((v) => (
            <button
              key={v}
              type="button"
              onClick={() => onViewChange(v)}
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
  );
}

/**
 * The right rail: a sticky column that collapses behind a disclosure on a
 * phone, where a full-height filter panel above the results would push every
 * result off the screen.
 *
 * `extra` is anything that belongs in the rail below the filter card -- a
 * "Top ranked" list, say -- and is hidden with the filters on mobile.
 */
export function FilterRail({
  title,
  open,
  onOpenChange,
  activeCount,
  onReset,
  ctaLabel,
  anchorId,
  children,
  extra,
  sort,
  onSortChange,
  sorts,
  query,
  onQueryChange,
  searchPlaceholder = "Search...",
  searchLabel = "Search",
}: {
  title: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  activeCount: number;
  onReset: () => void;
  /** The primary button, e.g. "Show 25 careers". */
  ctaLabel: string;
  /** Scrolled to when the CTA is pressed. */
  anchorId: string;
  children: React.ReactNode;
  extra?: React.ReactNode;
  /**
   * Sort lives in this panel rather than in ResultsHeader, so there is one
   * place that changes what you see instead of two at opposite ends of the
   * page. Pass all three or none.
   */
  sort?: string;
  onSortChange?: (v: string) => void;
  sorts?: { value: string; label: string }[];
  /**
   * Free-text search, in the panel rather than in the page hero. Bound to the
   * live query the list filters on, so it narrows as you type -- unlike the
   * hero box it replaces, which was a form you had to submit.
   */
  query?: string;
  onQueryChange?: (v: string) => void;
  searchPlaceholder?: string;
  /** For the input's accessible name, e.g. "Search careers". */
  searchLabel?: string;
}) {
  const ownsSort = sort !== undefined && onSortChange !== undefined && sorts !== undefined;
  const ownsSearch = query !== undefined && onQueryChange !== undefined;
  return (
    <aside className="w-full lg:w-[264px] lg:shrink-0 order-1 lg:sticky lg:top-24">
      <button
        type="button"
        onClick={() => onOpenChange(!open)}
        aria-expanded={open}
        className="lg:hidden w-full flex items-center justify-between gap-2 rounded-2xl border border-line bg-white px-4 py-3 mb-3"
      >
        <span className="flex items-center gap-2 font-display font-extrabold text-navy text-[14px]">
          <Icon name="filter" className="w-4 h-4 text-blue" />
          {/* Named for what is inside it. On a phone this button is the only way
              to reach sort now that the rail owns it, so calling it "Filters"
              would hide a control people use more often than any filter. */}
          {ownsSearch || ownsSort ? "Search & filter" : "Filters"}
          {activeCount > 0 && (
            <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-blue text-white">
              {activeCount}
            </span>
          )}
        </span>
        <Icon
          name="arrowDown"
          className={`w-3.5 h-3.5 text-subtle transition-transform ${open ? "rotate-180" : ""}`}
        />
      </button>

      <div className={`${open ? "flex" : "hidden"} lg:flex flex-col gap-5`}>
        {/* On a desktop the card is capped at the viewport and its options
            scroll inside it, between a fixed title row and a fixed CTA. At
            1366x768 the panel was taller than the screen on five pages
            (Colleges 884px against ~670px visible below the header), so while
            pinned its bottom groups and the "Show N" button sat off-screen
            with no way to reach them short of scrolling to the end of the
            results. 7.5rem is the rail's top-24 offset plus a 1.5rem gap. On a
            phone the panel is inline and uncapped, as before. */}
        <div className="flex flex-col rounded-3xl border border-line bg-white lg:max-h-[calc(100vh-7.5rem)]">
          <div className="flex items-center justify-between px-5 pt-5 pb-4 shrink-0">
            <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
              <Icon name="filter" className="w-4 h-4 text-blue" />
              {title}
            </h2>
            <button
              type="button"
              onClick={onReset}
              disabled={activeCount === 0}
              className="text-[12.5px] font-semibold text-blue hover:underline disabled:text-subtle disabled:no-underline disabled:cursor-default"
            >
              Reset
            </button>
          </div>

          {/* min-h-0 lets this flex child shrink below its content height,
              which is what makes overflow-y-auto engage at all. */}
          <div className="px-5 min-h-0 lg:overflow-y-auto overscroll-contain [scrollbar-width:thin]">
            {ownsSearch && (
              <div className="pb-4 mb-4 border-b border-line">
                <label htmlFor={`${anchorId}-q`} className="block text-[12.5px] font-bold text-navy mb-2.5">
                  Search
                </label>
                <div className="flex items-center gap-2 rounded-xl border border-line bg-white px-3 py-1 focus-within:border-blue/50 transition-colors">
                  <Icon name="search" className="w-3.5 h-3.5 text-subtle shrink-0" />
                  <input
                    id={`${anchorId}-q`}
                    type="search"
                    value={query}
                    onChange={(e) => onQueryChange?.(e.target.value)}
                    placeholder={searchPlaceholder}
                    aria-label={searchLabel}
                    className="flex-1 min-w-0 bg-transparent py-1.5 text-[13px] text-ink placeholder:text-subtle outline-none"
                  />
                </div>
              </div>
            )}

            {ownsSort && (
              <div className="pb-4 mb-4 border-b border-line">
                <label htmlFor={`${anchorId}-sort`} className="block text-[12.5px] font-bold text-navy mb-2.5">
                  Sort by
                </label>
                <select
                  id={`${anchorId}-sort`}
                  value={sort}
                  onChange={(e) => onSortChange?.(e.target.value)}
                  className="w-full rounded-xl border border-line bg-white px-3 py-2.5 text-[13px] font-semibold text-navy"
                >
                  {sorts?.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {children}
          </div>

          {/* Where a mock usually puts "Apply Filters". Filtering is live on
              every listing page here, so a button labelled Apply would imply
              the results behind it were stale. It says what it does instead:
              jump to the results, closing the panel on a phone. Outside the
              scrolling body, so it is always on screen. */}
          <div className="px-5 pt-5 pb-5 shrink-0">
            <button
              type="button"
              onClick={() => {
                onOpenChange(false);
                document
                  .getElementById(anchorId)
                  ?.scrollIntoView({ behavior: "smooth", block: "start" });
              }}
              className="w-full text-[13.5px] font-bold text-white bg-blue py-3 rounded-xl hover:opacity-90 transition-opacity"
            >
              {ctaLabel}
            </button>
          </div>
        </div>

        {extra}
      </div>
    </aside>
  );
}

/** The two-column body: sticky filter rail on the left, results on the right.
 *  On a phone both collapse to one column with the filter toggle on top. */
export function ListingLayout({ children }: { children: React.ReactNode }) {
  return <div className="flex flex-col lg:flex-row lg:items-start gap-8">{children}</div>;
}

export function ResultsColumn({ children }: { children: React.ReactNode }) {
  return <div className="flex-1 min-w-0 order-2">{children}</div>;
}

/** The empty state, with a way out of whatever filter caused it. */
export function NoResults({
  noun,
  activeCount,
  onReset,
}: {
  noun: string;
  activeCount: number;
  onReset: () => void;
}) {
  return (
    <div className="text-center py-20">
      <p className="text-muted text-sm">No {noun} match these filters.</p>
      {activeCount > 0 && (
        <button
          type="button"
          onClick={onReset}
          className="mt-4 text-[13.5px] font-bold text-white bg-navy px-5 py-2.5 rounded-xl hover:bg-navy-2 transition-colors"
        >
          Clear filters
        </button>
      )}
    </div>
  );
}

/** "Showing 1–12 of 42 careers" / "7 careers". */
export function countLabel(total: number, page: number, pageSize: number, noun: string) {
  if (total <= pageSize) return `${total} ${noun}${total === 1 ? "" : "s"}`;
  const from = (page - 1) * pageSize + 1;
  const to = Math.min(page * pageSize, total);
  return `Showing ${from}–${to} of ${total} ${noun}s`;
}

/**
 * The four-bullet "what this page is for" rail every explore hero carries.
 * Static copy by nature -- it describes the page, not the catalog.
 */
export function ValuePoints({
  points,
  className = "",
}: {
  points: { icon: string; tint: string; text: string }[];
  className?: string;
}) {
  return (
    <ul className={`flex flex-col gap-2.5 ${className}`}>
      {points.map((v) => (
        <li
          key={v.text}
          className="flex items-start gap-3 rounded-2xl border border-line bg-white px-3.5 py-3"
        >
          <span className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${v.tint}`}>
            <Icon name={v.icon} className="w-4 h-4" />
          </span>
          <span className="text-[12.5px] text-ink/75 leading-snug">{v.text}</span>
        </li>
      ))}
    </ul>
  );
}

/**
 * The counted figures under a hero. Every value is passed in already
 * computed -- the point of this strip is that nothing in it is written down.
 */
export function StatsStrip({
  stats,
}: {
  stats: { icon: string; tint: string; value: string | number; label: string; sub: string }[];
}) {
  // Two columns on a phone leave each tile about 171px, and a w-12 icon plus
  // px-5 took all but 63px of it -- so every label and sub-label here was
  // clipped mid-word ("Sectors and employers" needed 115px, "To a career, exam
  // or skill" 124px). The icon and padding shrink below sm, and the two text
  // lines wrap instead of truncating: they are two or three words, so a second
  // line costs nothing and a clipped one cost the whole meaning.
  return (
    <dl className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((s) => (
        <div
          key={s.label}
          className="flex items-center gap-3 sm:gap-3.5 rounded-2xl border border-line bg-white px-3.5 sm:px-5 py-4"
        >
          <span
            className={`w-10 h-10 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center shrink-0 ${s.tint}`}
          >
            <Icon name={s.icon} className="w-[19px] h-[19px] sm:w-[21px] sm:h-[21px]" />
          </span>
          <div className="min-w-0">
            <dd className="font-display font-extrabold text-navy text-[22px] leading-none">
              {s.value}
            </dd>
            <dt className="text-[12.5px] font-semibold text-ink/75 mt-1 leading-snug">{s.label}</dt>
            <div className="text-[11.5px] text-muted leading-snug">{s.sub}</div>
          </div>
        </div>
      ))}
    </dl>
  );
}

/** The gradient panel behind a hero signpost, used until artwork exists. */
export function SignpostPanel({
  items,
  gradient,
}: {
  items: { href: string; label: string }[];
  gradient: string;
}) {
  const colours = [
    "bg-blue text-white",
    "bg-teal text-white",
    "bg-pink text-white",
    "bg-purple text-white",
    "bg-amber text-white",
    "bg-green text-white",
  ];
  return (
    <div className="relative h-full min-h-[220px] flex items-center justify-center p-6">
      <div aria-hidden className="absolute inset-0 opacity-80" style={{ backgroundImage: gradient }} />
      <div className="relative flex flex-col items-start gap-2">
        {items.map((it, i) => (
          <a
            key={it.href}
            href={it.href}
            style={{ marginLeft: `${(i % 2) * 22}px` }}
            className={`text-[12.5px] font-bold px-4 py-2 rounded-lg shadow-card hover:opacity-90 transition-opacity ${colours[i % colours.length]}`}
          >
            {it.label}
          </a>
        ))}
      </div>
    </div>
  );
}
