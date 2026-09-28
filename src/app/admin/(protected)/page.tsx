"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import {
  adminGetDashboard,
  type AdminContentGap,
  type AdminDashboard,
  type AdminEntityCount,
} from "@/lib/adminApi";

/**
 * The admin dashboard.
 *
 * A client component because the whole page is one token-authenticated
 * request (GET /api/admin/dashboard) rather than a fan-out over the public
 * content endpoints -- which is what it used to be, ten public GETs whose
 * array lengths were the stats. One aggregate query replaced them.
 *
 * WHAT THIS DELIBERATELY DOES NOT SHOW: a percentage next to each count, and
 * a user-growth line. Neither has data behind it. Catalog rows only got
 * created_at in V115 and it was not backfilled, so "+12% this month" would be
 * invented, and there is no second month to compare against. The slot where
 * that badge would go shows the entity's real content gap instead, which is
 * a number an editor can act on today.
 */

const ICONS: Record<string, string> = {
  careers: "brief",
  degrees: "cap",
  exams: "doc",
  colleges: "bld",
  specializations: "layers",
  jobRoles: "users",
  skills: "bolt",
  resources: "book",
  certifications: "award",
  industries: "building",
};

/** Cycled per card, and reused as the donut's segment colours so the chart and
 *  the cards agree on which colour means which entity. */
const PALETTE = [
  { fg: "text-blue", bg: "bg-blue-soft", hex: "#2563eb" },
  { fg: "text-green", bg: "bg-green-soft", hex: "#16a34a" },
  { fg: "text-purple", bg: "bg-purple-soft", hex: "#7c3aed" },
  { fg: "text-amber", bg: "bg-amber-soft", hex: "#d97706" },
  { fg: "text-teal", bg: "bg-teal-soft", hex: "#0d9488" },
  { fg: "text-pink", bg: "bg-pink-soft", hex: "#db2777" },
  { fg: "text-slate", bg: "bg-slate-soft", hex: "#475569" },
];

function paletteFor(i: number) {
  return PALETTE[i % PALETTE.length];
}

function Panel({
  icon,
  title,
  subtitle,
  action,
  children,
  className = "",
}: {
  icon: string;
  title: string;
  subtitle?: string;
  action?: { href: string; label: string };
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={`bg-white rounded-2xl border border-line ${className}`}>
      <div className="flex items-start justify-between gap-4 px-5 py-4 border-b border-line">
        <div className="min-w-0">
          <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
            <Icon name={icon} className="w-[18px] h-[18px] text-blue shrink-0" />
            {title}
          </h2>
          {subtitle && <p className="text-[12px] text-muted mt-1">{subtitle}</p>}
        </div>
        {action && (
          <Link
            href={action.href}
            className="text-[12.5px] font-bold text-blue hover:underline shrink-0 whitespace-nowrap"
          >
            {action.label}
          </Link>
        )}
      </div>
      {children}
    </section>
  );
}

function StatCard({
  entry,
  index,
  gap,
}: {
  entry: AdminEntityCount;
  index: number;
  /** The gap filed under the same admin path, when there is one. */
  gap?: AdminContentGap;
}) {
  const p = paletteFor(index);
  return (
    <Link
      href={entry.adminPath}
      className="group bg-white rounded-2xl border border-line p-5 hover:border-blue/40 hover:shadow-card transition-all"
    >
      <div className="flex items-start justify-between gap-3">
        <span className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${p.bg} ${p.fg}`}>
          <Icon name={ICONS[entry.entity] ?? "grid"} className="w-5 h-5" />
        </span>
        <Icon
          name="chevRight"
          className="w-4 h-4 text-subtle shrink-0 mt-1 group-hover:text-blue transition-colors"
        />
      </div>
      <p className="font-display font-extrabold text-navy text-[26px] leading-none mt-4">
        {entry.count.toLocaleString()}
      </p>
      <p className="text-[13px] font-bold text-ink mt-1.5">{entry.label}</p>
      {/* Where a mock would put "+12% vs last month". This is the real
          alternative: how many of these rows are still incomplete. */}
      {gap ? (
        <p className="flex items-center gap-1.5 text-[11.5px] font-semibold text-amber mt-2">
          <Icon name="pulse" className="w-3.5 h-3.5 shrink-0" />
          {gap.affected.toLocaleString()} need attention
        </p>
      ) : (
        <p className="flex items-center gap-1.5 text-[11.5px] font-semibold text-green mt-2">
          <Icon name="check" className="w-3.5 h-3.5 shrink-0" />
          No tracked gaps
        </p>
      )}
    </Link>
  );
}

/** A donut from the real proportions -- no chart library, since this is one
 *  ring of eleven arcs and pulling in a charting dependency for it would be
 *  more code than the arcs. */
function Donut({ counts }: { counts: AdminEntityCount[] }) {
  const ranked = [...counts].sort((a, b) => b.count - a.count);
  const top = ranked.slice(0, 6);
  const rest = ranked.slice(6);
  const restTotal = rest.reduce((n, c) => n + c.count, 0);

  const slices = [
    ...top.map((c, i) => ({ label: c.label, count: c.count, hex: paletteFor(i).hex, href: c.adminPath })),
    ...(restTotal > 0
      ? [
          {
            label: `${rest.length} smaller sets`,
            count: restTotal,
            hex: paletteFor(6).hex,
            href: undefined as string | undefined,
          },
        ]
      : []),
  ];

  const total = slices.reduce((n, s) => n + s.count, 0);
  const R = 56;
  const C = 2 * Math.PI * R;
  let offset = 0;

  return (
    <div className="px-5 py-5 flex flex-col sm:flex-row items-center gap-6">
      <div className="relative w-[150px] h-[150px] shrink-0">
        <svg viewBox="0 0 150 150" className="w-full h-full -rotate-90">
          {slices.map((s) => {
            const len = total > 0 ? (s.count / total) * C : 0;
            const dash = `${len} ${C - len}`;
            const thisOffset = offset;
            offset += len;
            return (
              <circle
                key={s.label}
                cx="75"
                cy="75"
                r={R}
                fill="none"
                stroke={s.hex}
                strokeWidth="19"
                strokeDasharray={dash}
                strokeDashoffset={-thisOffset}
              />
            );
          })}
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="font-display font-extrabold text-navy text-[21px] leading-none">
            {total.toLocaleString()}
          </span>
          <span className="text-[10.5px] font-bold text-subtle uppercase tracking-wide mt-1">Rows</span>
        </div>
      </div>

      <ul className="flex-1 w-full flex flex-col gap-2">
        {slices.map((s) => {
          const pct = total > 0 ? (s.count / total) * 100 : 0;
          const row = (
            <>
              <span className="w-2.5 h-2.5 rounded-sm shrink-0" style={{ backgroundColor: s.hex }} />
              <span className="text-[12.5px] font-semibold text-ink truncate">{s.label}</span>
              <span className="ml-auto text-[12.5px] font-bold text-navy shrink-0 tabular-nums">
                {s.count.toLocaleString()}
              </span>
              <span className="text-[11.5px] text-subtle shrink-0 w-11 text-right tabular-nums">
                {pct.toFixed(1)}%
              </span>
            </>
          );
          return (
            <li key={s.label}>
              {s.href ? (
                <Link href={s.href} className="flex items-center gap-2.5 hover:opacity-70 transition-opacity">
                  {row}
                </Link>
              ) : (
                <span className="flex items-center gap-2.5">{row}</span>
              )}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function GapRow({ gap }: { gap: AdminContentGap }) {
  const pct = gap.total > 0 ? (gap.affected / gap.total) * 100 : 0;
  return (
    <Link
      href={gap.adminPath}
      className="block px-5 py-3.5 border-b border-line last:border-0 hover:bg-bg-soft transition-colors"
    >
      <div className="flex items-baseline justify-between gap-3">
        <span className="text-[13px] font-bold text-navy">{gap.label}</span>
        <span className="text-[12.5px] font-bold text-navy shrink-0 tabular-nums">
          {gap.affected.toLocaleString()}
          <span className="text-subtle font-semibold"> / {gap.total.toLocaleString()}</span>
        </span>
      </div>
      <div className="h-1.5 rounded-full bg-line overflow-hidden mt-2">
        <div
          className={`h-full rounded-full ${pct >= 75 ? "bg-amber" : pct >= 25 ? "bg-blue" : "bg-green"}`}
          style={{ width: `${Math.max(pct, 2)}%` }}
        />
      </div>
      <p className="text-[12px] text-muted leading-snug mt-2">{gap.detail}</p>
    </Link>
  );
}

function formatWhen(iso: string | null): string {
  if (!iso) return "Date unknown";
  const then = new Date(iso);
  const mins = Math.round((Date.now() - then.getTime()) / 60000);
  if (mins < 1) return "Just now";
  if (mins < 60) return `${mins}m ago`;
  if (mins < 60 * 24) return `${Math.round(mins / 60)}h ago`;
  if (mins < 60 * 24 * 30) return `${Math.round(mins / 1440)}d ago`;
  return then.toLocaleDateString(undefined, { day: "numeric", month: "short", year: "numeric" });
}

type LoadState =
  | { status: "loading" }
  | { status: "error"; message: string }
  | { status: "ready"; data: AdminDashboard };

export default function AdminDashboardPage() {
  const [state, setState] = useState<LoadState>({ status: "loading" });

  useEffect(() => {
    let cancelled = false;
    adminGetDashboard()
      .then((data) => {
        if (!cancelled) setState({ status: "ready", data });
      })
      .catch((err: unknown) => {
        if (cancelled) return;
        setState({
          status: "error",
          message: err instanceof Error ? err.message : "The dashboard could not be loaded.",
        });
      });
    return () => {
      cancelled = true;
    };
  }, []);

  if (state.status === "loading") {
    return (
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} className="bg-white rounded-2xl border border-line p-5 h-[152px] animate-pulse" />
        ))}
      </div>
    );
  }

  if (state.status === "error") {
    return (
      <div className="bg-white rounded-2xl border border-line p-6 max-w-lg">
        <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
          <Icon name="shield" className="w-[18px] h-[18px] text-red shrink-0" />
          Dashboard unavailable
        </h2>
        <p className="text-[13px] text-muted leading-relaxed mt-2">{state.message}</p>
      </div>
    );
  }

  const d = state.data;
  const gapByPath = new Map(d.gaps.map((g) => [g.adminPath, g]));
  const totalRows = d.counts.reduce((n, c) => n + c.count, 0);

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="font-display font-extrabold text-navy text-[20px]">Overview</h2>
        <p className="text-[13px] text-muted mt-1">
          {totalRows.toLocaleString()} rows across {d.counts.length} content types, and what still needs
          filling in.
        </p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 xl:grid-cols-5 gap-4">
        {d.counts.map((entry, i) => (
          <StatCard key={entry.entity} entry={entry} index={i} gap={gapByPath.get(entry.adminPath)} />
        ))}
      </div>

      {/* Two counts that are not catalog content: the people side. Kept apart
          from the grid above so a visitor count never reads as a row count. */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-line p-5">
          <p className="flex items-center gap-2 text-[12.5px] font-bold text-muted">
            <Icon name="user" className="w-4 h-4 text-blue shrink-0" />
            Registered users
          </p>
          <p className="font-display font-extrabold text-navy text-[26px] leading-none mt-3">
            {d.totalUsers.toLocaleString()}
          </p>
        </div>

        <Link
          href="/admin/counselling-requests"
          className="bg-white rounded-2xl border border-line p-5 hover:border-blue/40 transition-colors"
        >
          <p className="flex items-center gap-2 text-[12.5px] font-bold text-muted">
            <Icon name="mail" className="w-4 h-4 text-amber shrink-0" />
            Counselling requests
          </p>
          <p className="font-display font-extrabold text-navy text-[26px] leading-none mt-3">
            {d.counsellingRequests.toLocaleString()}
          </p>
          <p className="text-[11.5px] font-semibold text-muted mt-2">
            {d.pendingCounsellingRequests.toLocaleString()} pending
          </p>
        </Link>

        <div className="bg-white rounded-2xl border border-line p-5">
          <p className="flex items-center gap-2 text-[12.5px] font-bold text-muted">
            <Icon name="clock" className="w-4 h-4 text-purple shrink-0" />
            Rows with no created date
          </p>
          <p className="font-display font-extrabold text-navy text-[26px] leading-none mt-3">
            {d.undatedRows.toLocaleString()}
          </p>
          <p className="text-[11.5px] font-semibold text-muted mt-2">Seeded before timestamps existed</p>
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 items-start">
        <Panel
          icon="chart"
          title="Content Distribution"
          subtitle={`How the ${totalRows.toLocaleString()} rows are split across content types`}
        >
          <Donut counts={d.counts} />
        </Panel>

        <Panel
          icon="target"
          title="Content Gaps"
          subtitle="Queries against real columns, largest first"
        >
          {d.gaps.length > 0 ? (
            <div>
              {d.gaps.map((gap) => (
                <GapRow key={gap.label} gap={gap} />
              ))}
            </div>
          ) : (
            <p className="px-5 py-8 text-[13px] text-muted text-center">
              Nothing outstanding — every gap this dashboard checks for is closed.
            </p>
          )}
        </Panel>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 items-start">
        <Panel
          icon="pulse"
          title="Recently Added or Edited"
          subtitle="Changes made since timestamps were introduced"
        >
          {d.recentChanges.length > 0 ? (
            <ul>
              {d.recentChanges.map((change) => (
                <li key={`${change.entity}-${change.slug}`}>
                  <Link
                    href={`/admin/${change.entity === "jobRoles" ? "job-roles" : change.entity}`}
                    className="flex items-center gap-3 px-5 py-3 border-b border-line last:border-0 hover:bg-bg-soft transition-colors"
                  >
                    <span className="min-w-0 flex-1">
                      <span className="block text-[13px] font-bold text-navy truncate">{change.title}</span>
                      <span className="block text-[11.5px] text-muted mt-0.5">{change.label}</span>
                    </span>
                    <span
                      className={`text-[11px] font-bold px-2 py-0.5 rounded-md shrink-0 ${
                        change.isNew ? "bg-green-soft text-green" : "bg-blue-soft text-blue"
                      }`}
                    >
                      {change.isNew ? "New" : "Edited"}
                    </span>
                    <span className="text-[11.5px] text-subtle shrink-0 w-[68px] text-right">
                      {formatWhen(change.at)}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          ) : (
            // Not a loading state and not an error: the catalog genuinely has
            // no change history yet, and saying so is more use than an empty
            // table with a spinner in it.
            <div className="px-5 py-7">
              <p className="text-[13px] text-ink/75 leading-relaxed">
                Nothing yet. The {d.undatedRows.toLocaleString()} rows already in the catalog were seeded
                before this application recorded timestamps, so they have no date to show here rather than
                a made-up one.
              </p>
              <p className="text-[12.5px] text-muted leading-relaxed mt-2">
                The first row you create or edit from the admin will appear in this list.
              </p>
            </div>
          )}
        </Panel>

        <Panel
          icon="users"
          title="Recent Users"
          subtitle={`Newest first, of ${d.totalUsers.toLocaleString()} registered`}
        >
          {d.recentUsers.length > 0 ? (
            <ul>
              {d.recentUsers.map((user) => (
                <li
                  key={user.email}
                  className="flex items-center gap-3 px-5 py-3 border-b border-line last:border-0"
                >
                  <span className="w-9 h-9 rounded-full bg-blue-soft text-blue font-display font-bold text-[13px] flex items-center justify-center shrink-0">
                    {(user.name?.trim()?.[0] ?? user.email[0] ?? "?").toUpperCase()}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-[13px] font-bold text-navy truncate">
                      {user.name?.trim() || "Unnamed"}
                    </span>
                    <span className="block text-[11.5px] text-muted truncate">{user.email}</span>
                  </span>
                  <span className="text-[11.5px] text-subtle shrink-0">{formatWhen(user.joinedAt)}</span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="px-5 py-8 text-[13px] text-muted text-center">No one has registered yet.</p>
          )}
        </Panel>
      </div>
    </div>
  );
}
