"use client";

import { useEffect, useMemo, useState } from "react";
import Icon from "@/components/ui/Icon";
import { useToast } from "@/components/ui/Toast";
import { ApiError } from "@/lib/api";
import { getFriendlyErrorMessage } from "@/lib/errors";
import { GOAL_TYPES as TYPES, GoalOption as Option, loadGoalOptions as loadOptions } from "@/lib/goalOptions";
import {
  GoalType,
  Journey,
  addGoalFocus,
  addGoalStation,
  addLearningLog,
  keepGoalLine,
  refreshGoalLine,
  removeGoalFocus,
  removeGoalStation,
  removeLearningLog,
  setGoal,
  setGoalFocusLevel,
  setGoalStationDone,
} from "@/lib/userApi";

/**
 * My Career's "Your line": a goal, the stations towards it, what the user is
 * focusing on, and a learning log -- the design approved as the canvas demo.
 *
 * All state lives on the server; every action returns the whole journey and
 * the page re-renders from that, so it never drifts from what is saved.
 */

const KICKER: Record<GoalType, string> = {
  career: "Heading to", exam: "Preparing for", college: "Aiming for", degree: "Planning",
  job_role: "Moving into", company: "Aiming for", sector: "Moving into", certification: "Getting",
};

const LEVELS = ["Not started", "Learning", "Comfortable", "Confident"];
const LEVEL_ON = [
  "bg-slate-soft text-slate border-[#cfc8bc]",
  "bg-amber-soft text-[#6f4f16] border-amber",
  "bg-teal-soft text-[#24554e] border-teal",
  "bg-green-soft text-[#3b5632] border-green",
];
const GRID = ["#ece6dc", "#e2c9a8", "#c08f5d", "#8a5a2b"];
const MAX_FOCUS = 6;

function fmt(m: number): string {
  const h = Math.floor(m / 60);
  const r = m % 60;
  return h ? (r ? `${h}h ${r}m` : `${h}h`) : `${r}m`;
}

function monthLabel(v: string): string {
  const [y, m] = v.split("-").map(Number);
  return new Date(y, m - 1, 1).toLocaleDateString("en-IN", { month: "short", year: "numeric" });
}

function dayLabel(daysAgo: number): string {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  return d.toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" });
}

function whenLabel(iso: string): string {
  const [y, m, d] = iso.split("-").map(Number);
  const then = new Date(y, m - 1, d);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const ago = Math.round((today.getTime() - then.getTime()) / 86400000);
  if (ago === 0) return "Today";
  if (ago === 1) return "Yesterday";
  return then.toLocaleDateString("en-IN", { day: "numeric", month: "short" });
}

/** The server's own messages for a broken rule are written for people; anything else gets the generic one. */
function messageFor(error: unknown): string {
  if (error instanceof ApiError && (error.status === 400 || error.status === 409) && error.message && error.message.length <= 140
      && !/failed:|Exception|\{/.test(error.message)) {
    return error.message;
  }
  return getFriendlyErrorMessage(error);
}

const CARD = "rounded-3xl border border-line bg-white p-6";
const BTN_PRIMARY = "min-h-[44px] px-[18px] rounded-xl bg-blue text-white text-[14px] font-bold hover:opacity-90 transition-opacity disabled:opacity-50";
const BTN_SECONDARY = "min-h-[44px] px-4 rounded-xl border border-line bg-white text-[13.5px] font-bold text-[#6e4620] hover:border-blue/40 transition-colors disabled:opacity-50";
const INPUT = "min-h-[44px] w-full rounded-xl border border-[#ddd6cb] bg-white px-3 text-[14px] text-ink placeholder:text-subtle";
const LABEL = "text-[12.5px] font-bold text-navy";

/** A goal picked elsewhere on the page (a saved item, an assessment match), waiting for the user to confirm. */
export type PendingGoal = { type: GoalType; slug: string; name: string };

export function goalKicker(type: GoalType): string {
  return KICKER[type];
}

/**
 * The page owns the journey (its header shows the goal too) and passes it
 * down; this component renders it and sends every change back through
 * onChange with the server's answer.
 */
export default function MyCareerJourney({
  journey, loadError, onChange, pending, onPendingDone,
}: {
  journey: Journey | null;
  loadError: boolean;
  onChange: (j: Journey) => void;
  pending: PendingGoal | null;
  onPendingDone: () => void;
}) {
  const { showToast } = useToast();
  const [busy, setBusy] = useState(false);
  const [editing, setEditing] = useState(false);
  const [lineEdit, setLineEdit] = useState(false);

  /** Runs one action; on success the page shows the server's answer. */
  async function act(run: () => Promise<Journey>, onDone?: () => void): Promise<boolean> {
    if (busy) return false;
    setBusy(true);
    try {
      onChange(await run());
      onDone?.();
      return true;
    } catch (e) {
      showToast(messageFor(e), "error");
      return false;
    } finally {
      setBusy(false);
    }
  }

  if (loadError) {
    return (
      <section className={CARD} aria-label="Your line">
        <p className="text-[13.5px] text-muted">We couldn&rsquo;t load your goal just now. Refresh the page to try again.</p>
      </section>
    );
  }
  if (!journey) {
    return <section className={`${CARD} h-40 animate-pulse`} aria-label="Loading your goal" />;
  }

  const goal = journey.goal;
  const pendingIsCurrent = pending && goal && goal.type === pending.type && goal.slug === pending.slug;

  return (
    <section aria-label="Your line" className="flex flex-col gap-6">
      {pending && !pendingIsCurrent && (
        <div role="region" aria-label="Confirm your new goal" className="rounded-3xl border border-[#e2c9a8] bg-blue-soft p-5 flex flex-wrap items-center gap-4">
          <div className="flex-1 basis-[300px] min-w-0">
            <p className="font-display font-extrabold text-navy text-[16px]">
              {goal ? `Make ${pending.name} your goal?` : `Set ${pending.name} as your goal?`}
            </p>
            <p className="text-[13.5px] text-muted mt-1">
              {goal
                ? "Your line and focus list are rebuilt for it. Your learning log and streak stay."
                : "We'll build your line and focus list from the catalogue."}
            </p>
          </div>
          <div className="flex flex-wrap gap-2.5">
            <button type="button" className={BTN_PRIMARY} disabled={busy}
              onClick={() => act(() => setGoal(pending.type, pending.slug, null), () => {
                onPendingDone();
                showToast(`${pending.name} is now your goal.`, "success");
              })}>
              {goal ? "Switch goal" : "Set goal"}
            </button>
            <button type="button" className={BTN_SECONDARY} onClick={onPendingDone}>
              {goal ? `Keep ${goal.name}` : "Not now"}
            </button>
          </div>
        </div>
      )}

      {(!goal || editing) && (
        <GoalPicker
          current={goal ? { type: goal.type, slug: goal.slug, month: goal.targetMonth } : null}
          busy={busy}
          onCancel={goal ? () => setEditing(false) : undefined}
          onSave={(type, slug, month) => act(() => setGoal(type, slug, month), () => setEditing(false))}
        />
      )}

      {goal && (
        <>
          <GoalSummary journey={journey} onEdit={() => setEditing((v) => !v)} editing={editing} />
          <Line journey={journey} busy={busy} lineEdit={lineEdit} setLineEdit={setLineEdit} act={act} />
          <div className="flex flex-wrap items-start gap-6">
            {/* Keyed on the goal so a new goal starts these forms fresh. */}
            <FocusCard key={`f-${goal.type}-${goal.slug}`} journey={journey} busy={busy} act={act} />
            <LogCard key={`l-${goal.type}-${goal.slug}`} journey={journey} busy={busy} act={act} />
          </div>
          <div className="flex flex-wrap items-stretch gap-6">
            <NextUp journey={journey} />
            {goal.mockMax != null && <MockChart journey={journey} />}
          </div>
        </>
      )}
    </section>
  );
}

// ------------------------------------------------------------------ picker

function GoalPicker({
  current, busy, onSave, onCancel,
}: {
  current: { type: GoalType; slug: string; month: string | null } | null;
  busy: boolean;
  onSave: (type: GoalType, slug: string, month: string | null) => Promise<boolean>;
  onCancel?: () => void;
}) {
  const [type, setType] = useState<GoalType>(current?.type ?? "career");
  const [lists, setLists] = useState<Partial<Record<GoalType, Option[]>>>({});
  const [failed, setFailed] = useState(false);
  const [search, setSearch] = useState("");
  const [pick, setPick] = useState(current?.slug ?? "");
  const [month, setMonth] = useState(current?.month ?? "");

  useEffect(() => {
    if (lists[type]) return;
    let alive = true;
    loadOptions(type)
      .then((opts) => { if (alive) setLists((l) => ({ ...l, [type]: opts })); })
      .catch(() => { if (alive) setFailed(true); });
    return () => { alive = false; };
  }, [type, lists]);

  const meta = TYPES.find((t) => t.type === type)!;
  const list = lists[type];
  const q = search.trim().toLowerCase();
  const filtered = useMemo(() => (list ?? []).filter((o) => !q || o.name.toLowerCase().includes(q)), [list, q]);
  const shown = filtered.slice(0, 80);
  const value = shown.some((o) => o.slug === pick) ? pick : shown[0]?.slug ?? "";

  return (
    <div className={`${CARD} flex flex-col gap-5`}>
      <div>
        <h3 className="font-display font-extrabold text-navy text-[17px]">{current ? "Change your goal" : "What are you working towards?"}</h3>
        <p className="text-[12.5px] text-muted mt-1">
          One goal at a time. A new goal rebuilds your line and focus list from the catalogue; your learning log stays.
        </p>
      </div>
      {(["study", "work"] as const).map((group) => (
        <div key={group} className="flex flex-col gap-2">
          <span className="text-[12.5px] font-bold text-muted">{group === "study" ? "If you are studying" : "If you are working"}</span>
          <div className="grid grid-cols-[repeat(auto-fit,minmax(190px,1fr))] gap-2.5">
            {TYPES.filter((t) => t.group === group).map((t) => (
              <button
                key={t.type}
                type="button"
                aria-pressed={t.type === type}
                onClick={() => { setType(t.type); setSearch(""); setPick(""); }}
                className={`text-left min-h-[60px] rounded-2xl px-3.5 py-3 border-2 transition-colors ${
                  t.type === type ? "bg-blue-soft border-blue" : "bg-white border-line hover:border-blue/40"
                }`}
              >
                <span className="block text-[14px] font-extrabold text-navy">{t.title}</span>
                <span className="block text-[12px] text-muted mt-0.5">{t.example}</span>
              </button>
            ))}
          </div>
        </div>
      ))}
      <div className="flex flex-wrap gap-3 items-end">
        <label className="flex-1 basis-[220px] min-w-0 flex flex-col gap-1.5">
          <span className={LABEL}>Search</span>
          <input type="search" value={search} onChange={(e) => setSearch(e.target.value)}
            placeholder={list ? `Type to filter ${list.length} ${meta.noun}s` : "Loading…"} className={INPUT} />
        </label>
        <label className="flex-[2] basis-[260px] min-w-0 flex flex-col gap-1.5">
          <span className={LABEL}>Your {meta.noun}</span>
          <select value={value} onChange={(e) => setPick(e.target.value)} disabled={!list || shown.length === 0} className={INPUT}>
            {shown.map((o) => <option key={o.slug} value={o.slug}>{o.name}</option>)}
          </select>
        </label>
        <label className="basis-[170px] flex flex-col gap-1.5">
          <span className={LABEL}>Target month <span className="font-semibold text-muted">(optional)</span></span>
          <input type="month" value={month} onChange={(e) => setMonth(e.target.value)} className={INPUT} />
        </label>
      </div>
      <p className="text-[12.5px] text-muted -mt-2">
        {failed ? "Couldn't load the list. Refresh and try again." : list ? `${filtered.length} of ${list.length} ${meta.noun}s${filtered.length > 80 ? " — showing the first 80, keep typing" : ""}` : "Loading the catalogue…"}
      </p>
      <div className="flex flex-wrap gap-2.5">
        <button type="button" className={BTN_PRIMARY} disabled={busy || !value}
          onClick={() => onSave(type, value, month || null)}>
          {current ? "Save goal" : "Set my goal"}
        </button>
        {onCancel && <button type="button" className={BTN_SECONDARY} onClick={onCancel}>Cancel</button>}
      </div>
    </div>
  );
}

// ----------------------------------------------------------------- summary

function GoalSummary({ journey, onEdit, editing }: { journey: Journey; onEdit: () => void; editing: boolean }) {
  const goal = journey.goal!;
  const C = 2 * Math.PI * 54;
  const started = journey.focus.filter((f) => f.level > 0).length;
  return (
    <div className={`${CARD} flex flex-wrap items-center gap-7`}>
      <div className="flex-1 basis-[320px] min-w-0 flex flex-col gap-3">
        <span className="text-[12.5px] font-bold text-muted">{KICKER[goal.type]}</span>
        <span className="font-display font-extrabold text-navy text-[24px] leading-tight">{goal.name}</span>
        <div className="flex flex-wrap gap-2">
          {goal.facts.map((f, i) => (
            <span key={f} className={`text-[12.5px] font-semibold rounded-full px-3 py-1.5 ${i === 0 ? "bg-blue-soft text-[#6e4620]" : "bg-slate-soft text-slate"}`}>{f}</span>
          ))}
          {goal.targetMonth
            ? <span className="text-[12.5px] font-semibold rounded-full px-3 py-1.5 bg-teal-soft text-[#24554e]">Target: {monthLabel(goal.targetMonth)}</span>
            : <span className="text-[12.5px] font-semibold rounded-full px-3 py-1.5 border border-dashed border-[#b9b3a8] text-slate">Target: set a date</span>}
        </div>
        <button type="button" onClick={onEdit} aria-expanded={editing} className={`${BTN_SECONDARY} self-start border-blue`}>
          {editing ? "Close" : "Change goal or date"}
        </button>
      </div>
      <div className="flex items-center gap-4">
        <div className="relative w-[132px] h-[132px] shrink-0">
          <svg width="132" height="132" viewBox="0 0 132 132" role="img" aria-label={`${journey.readiness} percent ready for ${goal.name}`}>
            <circle cx="66" cy="66" r="54" fill="none" stroke="#efe8dd" strokeWidth="12" />
            <circle cx="66" cy="66" r="54" fill="none" stroke="#8a5a2b" strokeWidth="12" strokeLinecap="round"
              strokeDasharray={`${((C * journey.readiness) / 100).toFixed(1)} ${C.toFixed(1)}`} transform="rotate(-90 66 66)" />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center" aria-hidden="true">
            <span className="font-display font-extrabold text-navy text-[30px] leading-none">{journey.readiness}%</span>
            <span className="text-[12px] font-semibold text-muted mt-1">ready</span>
          </div>
        </div>
        <p className="text-[12.5px] text-muted max-w-[150px] leading-snug">Half from stations passed, half from your focus levels.</p>
      </div>
      <div className="flex-1 basis-[280px] grid grid-cols-3 gap-3">
        <Stat value={fmt(journey.weekMinutes)} label="learned in 7 days" />
        <Stat value={`${journey.streak} ${journey.streak === 1 ? "day" : "days"}`} label="streak" />
        <Stat value={`${started} of ${journey.focus.length}`} label="focus items started" />
      </div>
    </div>
  );
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div className="rounded-2xl border border-line bg-bg-soft p-3.5 flex flex-col gap-1">
      <span className="font-display font-extrabold text-navy text-[19px] leading-tight">{value}</span>
      <span className="text-[12px] font-semibold text-muted leading-snug">{label}</span>
    </div>
  );
}

// -------------------------------------------------------------------- line

type Act = (run: () => Promise<Journey>, onDone?: () => void) => Promise<boolean>;

function Line({ journey, busy, lineEdit, setLineEdit, act }: {
  journey: Journey; busy: boolean; lineEdit: boolean; setLineEdit: (v: boolean) => void; act: Act;
}) {
  const [name, setName] = useState("");
  const stations = journey.stations;
  const here = stations.findIndex((s) => !s.done);
  const lastDone = stations.reduce((acc, s, i) => (s.done ? i : acc), -1);
  const fill = lastDone <= 0 ? 0 : Math.round((lastDone / Math.max(1, stations.length - 1)) * 100);
  const goalName = journey.goal!.name;

  return (
    <div className={CARD}>
      <div className="flex flex-wrap items-center justify-between gap-3 mb-5">
        <div>
          <h3 className="font-display font-extrabold text-navy text-[18px]">The line to {goalName}</h3>
          <p className="text-[13px] text-muted mt-1">Tap a station when you pass it.</p>
        </div>
        <button type="button" onClick={() => setLineEdit(!lineEdit)} aria-pressed={lineEdit} className={BTN_SECONDARY}>
          {lineEdit ? "Done editing" : "Edit line"}
        </button>
      </div>
      {journey.lineUpdated && (
        <div role="region" aria-label="Updated line available"
          className="mb-5 rounded-2xl border border-[#e2c9a8] bg-blue-soft p-4 flex flex-wrap items-center gap-3">
          <div className="flex-1 basis-[280px] min-w-0">
            <p className="text-[14.5px] font-bold text-navy">The line to {goalName} has been updated</p>
            <p className="text-[13px] text-muted mt-0.5">
              Stations you&rsquo;ve passed stay ticked, and stations you added stay on your line.
            </p>
          </div>
          <div className="flex flex-wrap gap-2.5">
            <button type="button" className={BTN_PRIMARY} disabled={busy} onClick={() => act(refreshGoalLine)}>
              Use the new line
            </button>
            <button type="button" className={BTN_SECONDARY} disabled={busy} onClick={() => act(keepGoalLine)}>
              Keep mine
            </button>
          </div>
        </div>
      )}
      <div className="overflow-x-auto pb-1">
        <ol className="relative flex justify-between" style={{ minWidth: `${Math.max(640, stations.length * 140)}px` }}>
          <div aria-hidden="true" className="absolute left-[22px] right-[22px] top-[21px] h-[3px]"
            style={{ background: "repeating-linear-gradient(90deg,#cfc8bc 0 8px,transparent 8px 14px)" }} />
          <div aria-hidden="true" className="absolute left-[22px] right-[22px] top-[21px] h-[3px]">
            <div className="h-[3px] rounded bg-blue transition-all" style={{ width: `${fill}%` }} />
          </div>
          {stations.map((s, i) => {
            const isHere = i === here;
            const isLast = i === stations.length - 1;
            return (
              <li key={s.id} className="relative w-[132px] flex flex-col items-center gap-2.5 text-center">
                <button
                  type="button"
                  disabled={busy}
                  aria-pressed={s.done}
                  aria-label={`${s.name}, ${s.done ? "passed. Mark as not passed" : "not passed yet. Mark as passed"}`}
                  onClick={() => act(() => setGoalStationDone(s.id, !s.done))}
                  className={`relative z-[1] w-11 h-11 rounded-full flex items-center justify-center transition-colors ${
                    s.done ? "bg-blue border-[3px] border-blue" : isHere ? "bg-white border-4 border-blue shadow-[0_0_0_6px_#f0e4d6]" : "bg-white border-2 border-[#b9b3a8]"
                  }`}
                >
                  {s.done && <Icon name="check" className="w-[18px] h-[18px] text-white" />}
                </button>
                {isHere && <span className="text-[11.5px] font-bold text-white bg-navy rounded-full px-2.5 py-0.5">You are here</span>}
                <span className="text-[14px] font-bold text-navy leading-tight">{s.name}</span>
                <span className="text-[12px] font-semibold text-blue">{s.kind}</span>
                {s.detail && <span className="text-[12px] text-muted leading-snug">{s.detail}</span>}
                {lineEdit && !isLast && stations.length > 2 && (
                  <button type="button" disabled={busy} onClick={() => act(() => removeGoalStation(s.id))}
                    aria-label={`Remove the station ${s.name}`}
                    className="min-h-[44px] px-3 rounded-[10px] border border-line bg-white text-[12.5px] font-bold text-red disabled:opacity-50">
                    Remove
                  </button>
                )}
              </li>
            );
          })}
        </ol>
      </div>
      {lineEdit && (
        <form
          className="mt-5 flex flex-wrap gap-2.5 items-end rounded-2xl border border-line bg-bg-soft p-3.5"
          onSubmit={(e) => {
            e.preventDefault();
            if (name.trim()) act(() => addGoalStation(name.trim()), () => setName(""));
          }}
        >
          <label className="flex-1 basis-[240px] min-w-0 flex flex-col gap-1.5">
            <span className={LABEL}>Add your own station</span>
            <input value={name} maxLength={80} onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Coaching classes, Internship, Board exams" className={INPUT} />
          </label>
          <button type="submit" className={BTN_PRIMARY} disabled={busy || !name.trim()}>Add before the goal</button>
          <span className="basis-full text-[12.5px] text-muted">Remove any station that doesn&rsquo;t apply to you. The goal itself stays at the end.</span>
        </form>
      )}
    </div>
  );
}

// ------------------------------------------------------------------- focus

function FocusCard({ journey, busy, act }: { journey: Journey; busy: boolean; act: Act }) {
  const goal = journey.goal!;
  const [open, setOpen] = useState(journey.focus.length === 0);
  const [text, setText] = useState("");
  const [filter, setFilter] = useState("");
  const full = journey.focus.length >= MAX_FOCUS;
  const own = goal.focusMode === "own";
  const taken = new Set(journey.focus.map((f) => f.name.toLowerCase()));
  const q = filter.trim().toLowerCase();
  const options = goal.suggestedSkills.filter((s) => !taken.has(s.name.toLowerCase()) && (!q || s.name.toLowerCase().includes(q))).slice(0, 14);
  const unit = own ? (goal.type === "certification" ? "topics" : "subjects") : "skills";

  return (
    <div className={`${CARD} flex-1 basis-[460px] min-w-0`}>
      <div className="flex flex-wrap items-start justify-between gap-2.5 mb-4">
        <div>
          <h3 className="font-display font-extrabold text-navy text-[18px]">
            {own ? (goal.type === "certification" ? "Topics" : "Subjects") : goal.type === "career" ? "Focus skills" : "Your skill gap"}
          </h3>
          <p className="text-[13px] text-muted mt-1">
            {own
              ? `${journey.focus.length} ${journey.focus.length === 1 ? unit.slice(0, -1) : unit} added. The catalogue doesn't list these for this goal yet, so add the ones you study.`
              : `${journey.focus.filter((f) => f.skillSlug).length} of ${goal.suggestedSkills.length} skills linked to ${goal.name}. Pick up to ${MAX_FOCUS} and set your level.`}
          </p>
        </div>
        {!full && (
          <button type="button" onClick={() => setOpen(!open)} aria-expanded={open} className={BTN_SECONDARY}>
            {open ? "Done" : own ? `+ Add ${unit === "topics" ? "a topic" : "a subject"}` : "+ Add a skill"}
          </button>
        )}
      </div>

      {open && !full && (
        <div className="mb-4 rounded-2xl border border-line bg-bg-soft p-3.5 flex flex-col gap-3">
          {!own && goal.suggestedSkills.length > 14 && (
            <label className="flex flex-col gap-1.5">
              <span className={LABEL}>Filter {goal.suggestedSkills.length} skills</span>
              <input type="search" value={filter} onChange={(e) => setFilter(e.target.value)} placeholder="e.g. SQL" className={INPUT} />
            </label>
          )}
          {!own && (
            <div className="flex flex-wrap gap-2">
              {options.map((s) => (
                <button key={s.slug} type="button" disabled={busy} onClick={() => act(() => addGoalFocus(s.name, s.slug))}
                  className="min-h-[44px] px-3.5 rounded-full border border-line bg-white text-[13px] font-semibold text-ink hover:border-blue/40 disabled:opacity-50">
                  + {s.name}
                </button>
              ))}
              {options.length === 0 && (
                <span className="text-[12.5px] text-muted">
                  {q ? "No more skills match." : `Every skill linked to ${goal.name} is already in your list.`}
                </span>
              )}
            </div>
          )}
          {/* Free-typed items are allowed for every goal: the catalogue's skill links are a starting point, not the whole list. */}
          <form
            className="flex flex-wrap gap-2.5 items-end"
            onSubmit={(e) => { e.preventDefault(); if (text.trim()) act(() => addGoalFocus(text.trim(), null), () => setText("")); }}
          >
            <label className="flex-1 basis-[200px] min-w-0 flex flex-col gap-1.5">
              <span className={LABEL}>{own ? (unit === "topics" ? "Add a topic" : "Add a subject") : "Or add your own"}</span>
              <input value={text} maxLength={60} onChange={(e) => setText(e.target.value)}
                placeholder={own ? "e.g. Physics, Biology, Reasoning" : "e.g. Public speaking"} className={INPUT} />
            </label>
            <button type="submit" className={BTN_PRIMARY} disabled={busy || !text.trim()}>Add</button>
          </form>
        </div>
      )}

      <ul className="flex flex-col gap-4">
        {journey.focus.map((f) => (
          <li key={f.id} className="flex flex-col gap-2.5 pb-4 border-b border-[#efeae2]">
            <div className="flex items-center justify-between gap-2.5">
              <div className="min-w-0">
                <span className="block text-[15px] font-bold text-navy">{f.name}</span>
                <span className="block text-[12px] text-muted">{fmt(f.minutesLogged)} logged</span>
              </div>
              <button type="button" disabled={busy} onClick={() => act(() => removeGoalFocus(f.id))} aria-label={`Remove ${f.name}`}
                className="w-11 h-11 shrink-0 rounded-xl text-subtle hover:text-navy flex items-center justify-center disabled:opacity-50">
                <Icon name="close" className="w-4 h-4" />
              </button>
            </div>
            <fieldset className="grid grid-cols-4 gap-1.5 min-w-0 border-0 p-0 m-0">
              <legend className="sr-only">Your level in {f.name}</legend>
              {LEVELS.map((label, li) => (
                <button key={label} type="button" disabled={busy} aria-pressed={f.level === li}
                  onClick={() => f.level !== li && act(() => setGoalFocusLevel(f.id, li))}
                  className={`min-h-[44px] rounded-xl border px-1.5 text-[12.5px] font-bold transition-colors disabled:cursor-wait ${
                    f.level === li ? LEVEL_ON[li] : "bg-white text-muted border-line hover:border-blue/40"
                  }`}>
                  {label}
                </button>
              ))}
            </fieldset>
          </li>
        ))}
      </ul>
    </div>
  );
}

// --------------------------------------------------------------------- log

function LogCard({ journey, busy, act }: { journey: Journey; busy: boolean; act: Act }) {
  const goal = journey.goal!;
  const targets = Array.from(new Set(journey.focus.map((f) => f.name).concat(goal.logTargets)));
  if (targets.length === 0) targets.push("General");
  const [note, setNote] = useState("");
  const [target, setTarget] = useState(targets[0]);
  const [minutes, setMinutes] = useState("30");
  const [score, setScore] = useState("");
  const [error, setError] = useState("");
  const chosen = targets.includes(target) ? target : targets[0];
  const isMock = goal.mockTarget != null && chosen === goal.mockTarget && goal.mockMax != null;
  const percent = goal.mockMax === 100;
  const activeDays = journey.minutesByDay.filter((m) => m > 0).length;

  function submit(e: React.FormEvent) {
    e.preventDefault();
    if (!note.trim()) { setError("Write one line about what you learned first."); return; }
    let s: number | null = null;
    if (isMock) {
      s = Number(score);
      if (score === "" || !Number.isFinite(s) || s < 0 || s > goal.mockMax!) {
        setError(`Enter your score, from 0 to ${goal.mockMax}${percent ? "%" : ""}.`);
        return;
      }
    }
    setError("");
    act(() => addLearningLog({ note: note.trim(), target: chosen, minutes: Number(minutes), score: s === null ? null : Math.round(s), scoreMax: isMock ? goal.mockMax : null }),
      () => { setNote(""); setScore(""); });
  }

  return (
    <div id="learning-log" className={`${CARD} flex-1 basis-[400px] min-w-0 flex flex-col gap-5 scroll-mt-24`}>
      <div>
        <h3 className="font-display font-extrabold text-navy text-[18px]">Learning log</h3>
        <p className="text-[13px] text-muted mt-1">A line a day is enough. Practice from anywhere counts — a book, YouTube, a coaching class, a mock test.</p>
      </div>
      <form onSubmit={submit} noValidate className="flex flex-col gap-2.5 rounded-2xl border border-line bg-bg-soft p-3.5">
        <label className="flex flex-col gap-1.5">
          <span className={LABEL}>What did you learn?</span>
          <input value={note} maxLength={280} onChange={(e) => { setNote(e.target.value); setError(""); }} placeholder="e.g. Rotational motion — 25 questions" className={INPUT} />
        </label>
        <div className="flex flex-wrap gap-2.5 items-end">
          <label className="flex-1 basis-[160px] min-w-0 flex flex-col gap-1.5">
            <span className={LABEL}>For</span>
            <select value={chosen} onChange={(e) => setTarget(e.target.value)} className={INPUT}>
              {targets.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </label>
          <label className="basis-[110px] flex flex-col gap-1.5">
            <span className={LABEL}>Time</span>
            <select value={minutes} onChange={(e) => setMinutes(e.target.value)} className={INPUT}>
              {[["15", "15 min"], ["30", "30 min"], ["45", "45 min"], ["60", "1 hour"], ["90", "1.5 hours"], ["120", "2 hours"], ["180", "3 hours"]].map(([v, l]) => (
                <option key={v} value={v}>{l}</option>
              ))}
            </select>
          </label>
          {isMock && (
            <label className="basis-[110px] flex flex-col gap-1.5">
              <span className={LABEL}>{percent ? "Score %" : `Score / ${goal.mockMax}`}</span>
              <input type="number" inputMode="numeric" min={0} max={goal.mockMax ?? undefined} value={score}
                onChange={(e) => { setScore(e.target.value); setError(""); }} className={INPUT} />
            </label>
          )}
          <button type="submit" className={BTN_PRIMARY} disabled={busy}>Add</button>
        </div>
        {error && <span role="alert" className="text-[12.5px] font-semibold text-red">{error}</span>}
      </form>

      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between gap-2.5">
          <span className="text-[13px] font-bold text-navy">Last 12 weeks</span>
          <span className="inline-flex items-center gap-1 text-[11.5px] text-muted" aria-hidden="true">
            Less{GRID.map((c) => <span key={c} className="w-[11px] h-[11px] rounded-[3px]" style={{ background: c }} />)}More
          </span>
        </div>
        <p className="sr-only">Learning activity over the last 12 weeks: {activeDays} active days, {journey.streak} day streak.</p>
        <div aria-hidden="true" className="flex gap-1 max-w-[300px]">
          {Array.from({ length: 12 }, (_, w) => (
            <div key={w} className="flex-1 min-w-[12px] flex flex-col gap-1">
              {Array.from({ length: 7 }, (_, k) => {
                const d = 83 - (w * 7 + k);
                const m = journey.minutesByDay[d] ?? 0;
                const lvl = m === 0 ? 0 : m < 30 ? 1 : m < 60 ? 2 : 3;
                return <span key={k} title={`${dayLabel(d)}: ${m ? fmt(m) : "nothing logged"}`} className="block w-full aspect-square rounded-[3px]" style={{ background: GRID[lvl] }} />;
              })}
            </div>
          ))}
        </div>
        <div className="flex justify-between max-w-[300px] text-[11.5px] text-muted"><span>12 weeks ago</span><span>Today</span></div>
      </div>

      {journey.recent.length > 0 ? (
        <ul className="flex flex-col">
          {journey.recent.map((e) => (
            <li key={e.id} className="flex items-start gap-3 py-3 border-t border-[#efeae2]">
              <span className="shrink-0 w-[72px] text-[12px] font-semibold text-muted pt-0.5">{whenLabel(e.loggedOn)}</span>
              <div className="flex-1 min-w-0">
                <span className="block text-[14px] text-navy leading-snug">{e.note}</span>
                <span className="block text-[12px] font-semibold text-blue mt-0.5">
                  {e.target}{e.score != null ? ` · scored ${e.score}${e.scoreMax === 100 ? "%" : `/${e.scoreMax}`}` : ""}
                </span>
              </div>
              <span className="shrink-0 text-[12.5px] font-bold text-slate pt-0.5">{fmt(e.minutes)}</span>
              <button type="button" disabled={busy} onClick={() => act(() => removeLearningLog(e.id))} aria-label={`Delete the entry: ${e.note}`}
                className="shrink-0 -my-2 w-11 h-11 rounded-xl text-subtle hover:text-navy flex items-center justify-center disabled:opacity-50">
                <Icon name="close" className="w-3.5 h-3.5" />
              </button>
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-[13px] text-muted">Nothing logged yet. Your first entry starts your streak.</p>
      )}
    </div>
  );
}

// -------------------------------------------------------- next up, mocks

function NextUp({ journey }: { journey: Journey }) {
  const items: { tag: string; text: string }[] = [];
  const here = journey.stations.find((s) => !s.done);
  if (here) items.push({ tag: "Station", text: here.nextStep ?? `${here.name}: add what it needs to your log this week.` });
  [...journey.focus].sort((a, b) => a.level - b.level).slice(0, 2).forEach((f) => {
    items.push({
      tag: "Focus",
      text: f.level === 0 ? `${f.name}: not started yet — begin with 30 minutes.`
        : f.level === 3 ? `${f.name}: you're confident here. Teach it to someone to lock it in.`
          : `${f.name}: move from ${LEVELS[f.level]} to ${LEVELS[f.level + 1]}.`,
    });
  });
  if (journey.focus.length === 0) items.push({ tag: "Focus", text: "Add what you're working on, then set your level in each." });
  if (!here) items.push({ tag: "Goal", text: "Every station is passed. Set your next goal when you're ready." });

  return (
    <div className="flex-1 basis-[400px] min-w-0 rounded-3xl bg-navy p-6 flex flex-col gap-3.5">
      <h3 className="font-display font-extrabold text-white text-[18px]">Next up this week</h3>
      {items.map((n) => (
        <div key={n.text} className="flex items-center gap-3 rounded-2xl bg-[#23262d] p-3.5">
          <span className="shrink-0 text-[11.5px] font-bold text-navy bg-[#e2c9a8] rounded-full px-2.5 py-1">{n.tag}</span>
          <span className="text-[14px] text-[#f2efe9] leading-snug">{n.text}</span>
        </div>
      ))}
    </div>
  );
}

function MockChart({ journey }: { journey: Journey }) {
  const goal = journey.goal!;
  const max = goal.mockMax!;
  const series = journey.mocks;
  const delta = series.length > 1 ? series[series.length - 1].score - series[0].score : 0;
  const word = goal.mockTarget === "Practice test" ? "Test" : "Mock";
  return (
    <div className={`${CARD} flex-1 basis-[320px] min-w-0 flex flex-col gap-3`}>
      <div className="flex items-baseline justify-between gap-2">
        <h3 className="font-display font-extrabold text-navy text-[18px]">{goal.mockTarget} scores</h3>
        {series.length > 1 && <span className="text-[12.5px] font-bold text-teal">{delta >= 0 ? "+" : ""}{delta}{max === 100 ? " points" : ""} since {word} 1</span>}
      </div>
      <p className="text-[13px] text-muted">
        {max === 100 ? "As a percentage." : `Out of ${max}.`} Log a {goal.mockTarget?.toLowerCase()} with its score and it lands here.
      </p>
      {series.length === 0 ? (
        <p className="text-[13px] text-muted rounded-2xl border border-dashed border-line p-5 text-center">No scores yet.</p>
      ) : (
        <>
          <p className="sr-only">{series.map((m, i) => `${word} ${i + 1}: ${m.score}`).join(", ")}</p>
          <div aria-hidden="true" className="h-[150px] flex items-end gap-2.5 border-b border-line pt-2">
            {series.map((m, i) => (
              <div key={i} className="flex-1 h-full min-w-0 flex flex-col justify-end items-center gap-1.5">
                <span className="text-[12px] font-bold text-navy">{m.score}</span>
                <div className="w-full max-w-[44px] rounded-t-lg bg-teal" style={{ height: `${Math.max(4, Math.round((m.score / max) * 110))}px` }} />
              </div>
            ))}
          </div>
          <div aria-hidden="true" className="flex gap-2.5">
            {series.map((_, i) => <span key={i} className="flex-1 min-w-0 text-center text-[11.5px] text-muted">{word} {i + 1}</span>)}
          </div>
        </>
      )}
    </div>
  );
}
