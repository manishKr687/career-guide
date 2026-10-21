"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "@/components/ui/Icon";
import ConfirmDialog from "@/components/ui/ConfirmDialog";
import { BTN_PRIMARY, BTN_SECONDARY, PageHeader, SURFACE, Toast, ToastTone } from "@/components/admin/AdminKit";
import {
  AdminGoalLine,
  AdminUnauthorizedError,
  GoalLineStation,
  GoalLineSummary,
  adminGetGoalLine,
  adminListGoalLines,
  adminResetGoalLine,
  adminSaveGoalLine,
} from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { GOAL_TYPES, GoalOption, loadGoalOptions } from "@/lib/goalOptions";
import type { GoalType } from "@/lib/userApi";

/**
 * The stations a My Career goal starts from, per catalogue item.
 *
 * Every item has an automatic line built from its catalogue data. Customising
 * one replaces it for new goals; people who already have that goal keep their
 * own copy and are offered the new line on their page.
 */

const MIN = 2;
const MAX = 12;
const INPUT = "w-full min-h-[40px] rounded-xl border border-line bg-white px-3 text-[13.5px] text-ink placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-blue/30";
const LABEL = "text-[11.5px] font-bold text-muted uppercase tracking-wide";

/** "Exam", "Job role" -- the picker's "An exam" without the article. */
const typeTitle = (t: string) => {
  const noun = GOAL_TYPES.find((g) => g.type === t)?.noun ?? t;
  return noun.charAt(0).toUpperCase() + noun.slice(1);
};

function errorText(err: unknown, fallback: string): string {
  return err instanceof ApiError ? err.message : fallback;
}

export default function AdminGoalLines() {
  const router = useRouter();
  const [summaries, setSummaries] = useState<GoalLineSummary[] | null>(null);
  const [type, setType] = useState<GoalType>("exam");
  const [options, setOptions] = useState<Partial<Record<GoalType, GoalOption[]>>>({});
  const [search, setSearch] = useState("");
  const [slug, setSlug] = useState("");
  const [line, setLine] = useState<AdminGoalLine | null>(null);
  const [loadingLine, setLoadingLine] = useState(false);
  const [draft, setDraft] = useState<GoalLineStation[] | null>(null);
  const [busy, setBusy] = useState(false);
  const [confirmReset, setConfirmReset] = useState(false);
  const [toast, setToast] = useState<{ tone: ToastTone; message: string } | null>(null);
  const closeToast = useCallback(() => setToast(null), []);

  const fail = useCallback((err: unknown, fallback: string) => {
    if (err instanceof AdminUnauthorizedError) {
      router.push("/admin/login");
      return;
    }
    setToast({ tone: "error", message: errorText(err, fallback) });
  }, [router]);

  const refreshSummaries = useCallback(() => {
    adminListGoalLines().then(setSummaries).catch((e) => fail(e, "Could not load the customised lines."));
  }, [fail]);

  useEffect(() => {
    refreshSummaries();
  }, [refreshSummaries]);

  useEffect(() => {
    if (options[type]) return;
    let alive = true;
    loadGoalOptions(type)
      .then((opts) => { if (alive) setOptions((o) => ({ ...o, [type]: opts })); })
      .catch(() => { if (alive) setToast({ tone: "error", message: "Could not load the catalogue list." }); });
    return () => { alive = false; };
  }, [type, options]);

  const list = options[type];
  const q = search.trim().toLowerCase();
  const filtered = useMemo(() => (list ?? []).filter((o) => !q || o.name.toLowerCase().includes(q)).slice(0, 100), [list, q]);

  async function open(t: string, s: string) {
    if (!s) return;
    setLoadingLine(true);
    setDraft(null);
    try {
      setLine(await adminGetGoalLine(t, s));
    } catch (err) {
      setLine(null);
      fail(err, "Could not load that line.");
    } finally {
      setLoadingLine(false);
    }
  }

  function openSummary(s: GoalLineSummary) {
    setType(s.type as GoalType);
    setSearch("");
    setSlug(s.slug);
    open(s.type, s.slug);
  }

  async function save() {
    if (!line || !draft) return;
    const bad = draft.findIndex((s) => !s.name.trim() || !s.kind.trim());
    if (bad >= 0) {
      setToast({ tone: "error", message: `Station ${bad + 1} needs a name and a kind.` });
      return;
    }
    setBusy(true);
    try {
      const saved = await adminSaveGoalLine(line.type, line.slug, draft);
      setLine(saved);
      setDraft(null);
      setToast({ tone: "success", message: `Saved the line for ${saved.name} (version ${saved.version}).` });
      refreshSummaries();
    } catch (err) {
      fail(err, "Save failed.");
    } finally {
      setBusy(false);
    }
  }

  async function reset() {
    if (!line) return;
    setBusy(true);
    try {
      const fresh = await adminResetGoalLine(line.type, line.slug);
      setLine(fresh);
      setDraft(null);
      setToast({ tone: "success", message: `${fresh.name} is back on its automatic line.` });
      refreshSummaries();
    } catch (err) {
      fail(err, "Reset failed.");
    } finally {
      setBusy(false);
      setConfirmReset(false);
    }
  }

  const reach = line
    ? line.users === 0
      ? "Nobody has this as their goal yet."
      : `${line.users} ${line.users === 1 ? "person has" : "people have"} this as their goal. They keep their own line and are offered the new one — their ticks and the stations they added stay.`
    : "";

  return (
    <div className="max-w-5xl">
      <PageHeader
        title="Goal lines"
        subtitle="The stations people start with when they pick a goal in My Career. Items you haven't customised use an automatic line built from their catalogue data."
      />

      {summaries && summaries.length > 0 && (
        <section className={`${SURFACE} p-5 mb-5`} aria-labelledby="customised-heading">
          <h3 id="customised-heading" className="font-display font-bold text-navy text-[15px] mb-3">
            Customised lines <span className="text-subtle font-semibold">({summaries.length})</span>
          </h3>
          <ul className="flex flex-col divide-y divide-line">
            {summaries.map((s) => (
              <li key={`${s.type}/${s.slug}`}>
                <button type="button" onClick={() => openSummary(s)}
                  className="w-full flex flex-wrap items-center gap-x-4 gap-y-1 py-2.5 text-left hover:bg-bg-soft rounded-lg px-2 -mx-2">
                  <span className="text-[11.5px] font-bold text-blue bg-blue-soft rounded-full px-2.5 py-0.5">{typeTitle(s.type)}</span>
                  <span className="font-bold text-navy text-[14px] flex-1 min-w-[160px]">{s.name}</span>
                  <span className="text-[12.5px] text-muted">{s.stations} stations · v{s.version} · {s.users} on this goal</span>
                </button>
              </li>
            ))}
          </ul>
        </section>
      )}

      <section className={`${SURFACE} p-5 mb-5`} aria-label="Choose an item">
        <div className="grid grid-cols-1 sm:grid-cols-[180px_1fr_1.4fr_auto] gap-3 items-end">
          <label className="flex flex-col gap-1.5">
            <span className={LABEL}>Goal type</span>
            <select value={type} onChange={(e) => { setType(e.target.value as GoalType); setSearch(""); setSlug(""); }} className={INPUT}>
              {GOAL_TYPES.map((g) => <option key={g.type} value={g.type}>{typeTitle(g.type)}</option>)}
            </select>
          </label>
          <label className="flex flex-col gap-1.5">
            <span className={LABEL}>Search</span>
            <input type="search" value={search} onChange={(e) => setSearch(e.target.value)}
              placeholder={list ? `${list.length} to choose from` : "Loading…"} className={INPUT} />
          </label>
          <label className="flex flex-col gap-1.5">
            <span className={LABEL}>Item</span>
            <select value={filtered.some((o) => o.slug === slug) ? slug : ""} onChange={(e) => setSlug(e.target.value)} className={INPUT}>
              <option value="">{filtered.length ? "Choose…" : "No matches"}</option>
              {filtered.map((o) => <option key={o.slug} value={o.slug}>{o.name}</option>)}
            </select>
          </label>
          <button type="button" className={BTN_PRIMARY} disabled={!slug || loadingLine} onClick={() => open(type, slug)}>
            Open line
          </button>
        </div>
      </section>

      {loadingLine && <div className={`${SURFACE} h-40 animate-pulse`} aria-label="Loading line" />}

      {line && !loadingLine && (
        <section className={`${SURFACE} p-5`} aria-labelledby="line-heading">
          <div className="flex flex-wrap items-start justify-between gap-3 mb-4">
            <div className="min-w-0">
              <div className="flex flex-wrap items-center gap-2">
                <h3 id="line-heading" className="font-display font-extrabold text-navy text-[18px]">{line.name}</h3>
                <span className="text-[11.5px] font-bold text-blue bg-blue-soft rounded-full px-2.5 py-0.5">{typeTitle(line.type)}</span>
                {line.custom
                  ? <span className="text-[11.5px] font-bold text-green bg-green-soft rounded-full px-2.5 py-0.5">Custom · v{line.version}</span>
                  : <span className="text-[11.5px] font-bold text-slate bg-slate-soft rounded-full px-2.5 py-0.5">Automatic</span>}
              </div>
              <p className="text-[12.5px] text-muted mt-1">{reach}</p>
            </div>
            {!draft && (
              <div className="flex flex-wrap gap-2">
                <button type="button" className={BTN_PRIMARY} onClick={() => setDraft(line.stations.map((s) => ({ ...s })))}>
                  {line.custom ? "Edit line" : "Customise this line"}
                </button>
                {line.custom && (
                  <button type="button" className={BTN_SECONDARY} onClick={() => setConfirmReset(true)}>Reset to automatic</button>
                )}
              </div>
            )}
          </div>

          {draft ? (
            <LineEditor draft={draft} setDraft={setDraft} automatic={line.automatic} busy={busy}
              onSave={save} onCancel={() => setDraft(null)} />
          ) : (
            <ol className="flex flex-col gap-2">
              {line.stations.map((s, i) => (
                <li key={i} className="flex items-start gap-3 rounded-xl border border-line px-3.5 py-3">
                  <StationNumber i={i} last={i === line.stations.length - 1} />
                  <div className="min-w-0">
                    <p className="font-bold text-navy text-[14px]">{s.name} <span className="text-[12px] font-semibold text-blue ml-1">{s.kind}</span></p>
                    {s.detail && <p className="text-[12.5px] text-muted">{s.detail}</p>}
                    {s.nextStep && <p className="text-[12.5px] text-ink/80 mt-0.5">Next step: {s.nextStep}</p>}
                  </div>
                </li>
              ))}
            </ol>
          )}
        </section>
      )}

      <ConfirmDialog
        open={confirmReset}
        title="Reset to the automatic line?"
        message={line ? `New goals for ${line.name} will use the line built from the catalogue again. People who already have this goal will be offered it.` : ""}
        confirmLabel="Reset"
        busy={busy}
        onConfirm={reset}
        onCancel={() => setConfirmReset(false)}
      />

      {toast && <Toast tone={toast.tone} message={toast.message} onClose={closeToast} />}
    </div>
  );
}

function StationNumber({ i, last }: { i: number; last: boolean }) {
  return (
    <span aria-label={last ? "Goal station" : `Station ${i + 1}`}
      className={`w-7 h-7 shrink-0 rounded-full flex items-center justify-center text-[12px] font-bold ${
        last ? "bg-navy text-white" : "bg-bg-soft text-navy border border-line"
      }`}>
      {last ? <Icon name="target" className="w-3.5 h-3.5" /> : i + 1}
    </span>
  );
}

function LineEditor({ draft, setDraft, automatic, busy, onSave, onCancel }: {
  draft: GoalLineStation[];
  setDraft: (d: GoalLineStation[]) => void;
  automatic: GoalLineStation[];
  busy: boolean;
  onSave: () => void;
  onCancel: () => void;
}) {
  const last = draft.length - 1;

  function update(i: number, field: keyof GoalLineStation, value: string) {
    setDraft(draft.map((s, j) => (j === i ? { ...s, [field]: value } : s)));
  }
  function move(i: number, by: -1 | 1) {
    const next = [...draft];
    [next[i], next[i + by]] = [next[i + by], next[i]];
    setDraft(next);
  }
  function remove(i: number) {
    setDraft(draft.filter((_, j) => j !== i));
  }
  function add() {
    setDraft([...draft.slice(0, last), { name: "", kind: "", detail: "", nextStep: "" }, draft[last]]);
  }

  const arrow = "w-9 h-9 rounded-lg border border-line bg-white text-muted hover:text-navy hover:border-navy/30 flex items-center justify-center disabled:opacity-30 disabled:pointer-events-none";

  return (
    <div className="flex flex-col gap-3">
      <ol className="flex flex-col gap-3">
        {draft.map((s, i) => {
          const isGoal = i === last;
          return (
            <li key={i} className={`rounded-xl border p-3.5 flex gap-3 ${isGoal ? "border-navy/30 bg-bg-soft" : "border-line"}`}>
              <StationNumber i={i} last={isGoal} />
              <div className="flex-1 min-w-0 grid grid-cols-1 md:grid-cols-[1.3fr_0.8fr] gap-2.5">
                <label className="flex flex-col gap-1">
                  <span className={LABEL}>{isGoal ? "Goal station" : "Station"}</span>
                  <input value={s.name} maxLength={80} onChange={(e) => update(i, "name", e.target.value)} className={INPUT}
                    placeholder={isGoal ? "e.g. JoSAA counselling" : "e.g. Session 1"} />
                </label>
                <label className="flex flex-col gap-1">
                  <span className={LABEL}>Kind</span>
                  <input value={s.kind} maxLength={32} onChange={(e) => update(i, "kind", e.target.value)} className={INPUT}
                    placeholder="e.g. Exam, Admission" />
                </label>
                <label className="flex flex-col gap-1">
                  <span className={LABEL}>Detail</span>
                  <input value={s.detail ?? ""} maxLength={200} onChange={(e) => update(i, "detail", e.target.value)} className={INPUT}
                    placeholder="Shown under the station (optional)" />
                </label>
                <label className="flex flex-col gap-1">
                  <span className={LABEL}>Next step</span>
                  <input value={s.nextStep ?? ""} maxLength={200} onChange={(e) => update(i, "nextStep", e.target.value)} className={INPUT}
                    placeholder="“Next up” text (optional)" />
                </label>
              </div>
              {!isGoal && (
                <div className="flex flex-col gap-1.5 shrink-0">
                  <button type="button" className={arrow} disabled={i === 0} onClick={() => move(i, -1)} aria-label={`Move station ${i + 1} up`}>
                    <Icon name="arrowDown" className="w-4 h-4 rotate-180" />
                  </button>
                  <button type="button" className={arrow} disabled={i === last - 1} onClick={() => move(i, 1)} aria-label={`Move station ${i + 1} down`}>
                    <Icon name="arrowDown" className="w-4 h-4" />
                  </button>
                  <button type="button" className={`${arrow} hover:!text-red`} disabled={draft.length <= MIN} onClick={() => remove(i)} aria-label={`Remove station ${i + 1}`}>
                    <Icon name="close" className="w-4 h-4" />
                  </button>
                </div>
              )}
            </li>
          );
        })}
      </ol>
      <div className="flex flex-wrap items-center gap-2.5 pt-1">
        <button type="button" className={BTN_SECONDARY} disabled={draft.length >= MAX} onClick={add}>+ Add a station before the goal</button>
        <button type="button" className={BTN_SECONDARY} onClick={() => setDraft(automatic.map((s) => ({ ...s })))}>Start from the automatic line</button>
        <span className="text-[12px] text-muted">{draft.length} of {MAX} stations · the goal station always stays last</span>
      </div>
      <div className="flex flex-wrap gap-2.5 border-t border-line pt-4 mt-1">
        <button type="button" className={BTN_PRIMARY} disabled={busy} onClick={onSave}>Save line</button>
        <button type="button" className={BTN_SECONDARY} disabled={busy} onClick={onCancel}>Cancel</button>
      </div>
    </div>
  );
}
