"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "@/components/ui/Icon";
import { AdminResource, adminDelete, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { FormValues, RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";
import ConfirmDialog from "@/components/ui/ConfirmDialog";
import {
  EmptyState,
  IconButton,
  PageHeader,
  SURFACE,
  Toast,
  type ToastTone,
} from "@/components/admin/AdminKit";

/**
 * Renders updated_at, or an em dash where there is none.
 *
 * Most rows have none, and that is correct rather than broken: the column is
 * maintained by a trigger that fires on UPDATE, and V115 deliberately did not
 * backfill the rows that already existed, so a row shows a date only once
 * somebody has actually changed it. An em dash says "never edited here"; a
 * fabricated date would have said something false.
 */
function formatUpdated(value: unknown): string {
  if (typeof value !== "string" || value === "") return "—";
  const at = new Date(value);
  if (Number.isNaN(at.getTime())) return "—";
  return at.toLocaleDateString(undefined, { day: "numeric", month: "short", year: "numeric" });
}

/**
 * Where a record can be seen the way a visitor sees it.
 *
 * Not every admin resource has a public page: States, Cities and Universities
 * are reference data that no route renders on its own, so the view action is
 * hidden for them rather than linking somewhere that 404s.
 */
const PUBLIC_PATHS: Partial<Record<AdminResource, string>> = {
  careers: "/careers",
  degrees: "/degrees",
  exams: "/exams",
  colleges: "/colleges",
  skills: "/skills",
  "job-roles": "/job-roles",
  industries: "/industries",
  certifications: "/certifications",
  resources: "/resources",
  specializations: "/specializations",
};

/**
 * The list screen every /admin/<resource> page renders.
 *
 * One component for all fifteen resources, the same reasoning as DetailKit and
 * ListingKit on the public side: a change to the toolbar or the row actions
 * happens once rather than fifteen times, and the pages cannot drift apart.
 *
 * `initialItems` is fetched server-side (see each resource's page.tsx) so the
 * table renders on first paint instead of showing "Loading..." while a Client
 * Component mounts, hydrates and only then fetches.
 */
export default function AdminResourceList({
  resource,
  initialItems,
}: {
  resource: AdminResource;
  initialItems: FormValues[];
}) {
  const router = useRouter();
  const config = RESOURCE_CONFIGS[resource];

  const [items, setItems] = useState<FormValues[]>(initialItems);
  const [toast, setToast] = useState<{ tone: ToastTone; message: string } | null>(null);
  const [pendingDelete, setPendingDelete] = useState<string | null>(null);
  const [confirmSlug, setConfirmSlug] = useState<string | null>(null);

  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("");

  /** The first select field over a reference list doubles as the table filter. */
  const filterField = useMemo(
    () => config.fields.find((f) => f.type === "select" && f.optionsKey),
    [config]
  );

  const filterOptions = useMemo(() => {
    if (!filterField) return [];
    const seen = new Map<string, string>();
    for (const item of items) {
      const v = item[filterField.key];
      if (typeof v === "string" && v !== "") seen.set(v, v);
    }
    // localeCompare, not a bare sort(). Array.sort() with no comparator orders
    // by UTF-16 code unit, which puts every capitalised value before every
    // lowercase one and mis-orders anything outside ASCII. These values are
    // whatever an admin typed into a filterable field, across all thirteen
    // resource types, so the content decides whether that shows -- today every
    // value happens to be consistently capitalised ASCII and the two agree.
    return [...seen.keys()].sort((a, b) => a.localeCompare(b));
  }, [items, filterField]);

  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return items.filter((item) => {
      if (filterField && filter && item[filterField.key] !== filter) return false;
      if (q === "") return true;
      // Matched across the slug and every rendered column, so the box searches
      // what the reader can actually see in the table.
      const haystack = [String(item.slug ?? ""), ...config.columns.map((c) => c.render(item))]
        .join(" ")
        .toLowerCase();
      return haystack.includes(q);
    });
  }, [items, query, filter, filterField, config]);

  async function refresh() {
    try {
      setItems(await config.loadAll());
    } catch (err) {
      setToast({
        tone: "error",
        message: err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?",
      });
    }
  }

  async function handleDelete(slug: string) {
    setConfirmSlug(null);
    setPendingDelete(slug);
    try {
      await adminDelete(resource, slug);
      await refresh();
      setToast({ tone: "success", message: `Deleted "${slug}".` });
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setToast({
        tone: "error",
        message: err instanceof ApiError ? err.message : "Delete failed. Is the backend running?",
      });
    } finally {
      setPendingDelete(null);
    }
  }

  // Shown only where the resource actually has the column. States, Cities and
  // Universities were not part of V115, so their DTOs carry no updatedAt at all
  // and an always-empty column would be noise on those three pages.
  const publicPath = PUBLIC_PATHS[resource];

  const hasUpdatedAt = useMemo(() => items.some((item) => "updatedAt" in item), [items]);

  return (
    <div>
      <PageHeader
        title={config.pluralLabel}
        subtitle={`Manage all ${config.pluralLabel.toLowerCase()}, add new ones or edit existing ones.`}
        action={{ href: `/admin/${resource}/new`, label: `Add ${config.label}` }}
      />

      <div className="flex flex-wrap items-center justify-end gap-3 mb-4">
        {filterField && filterOptions.length > 1 && (
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="text-[13px] text-ink bg-white border border-line rounded-xl px-3 py-2.5 min-w-[150px]"
          >
            <option value="">All {filterField.label}</option>
            {filterOptions.map((opt) => (
              <option key={opt} value={opt}>
                {opt}
              </option>
            ))}
          </select>
        )}
        <div className="relative">
          <Icon
            name="search"
            className="w-4 h-4 text-subtle absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
          />
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={`Search ${config.pluralLabel.toLowerCase()}...`}
            className="text-[13px] text-ink bg-white border border-line rounded-xl pl-9 pr-3 py-2.5 w-[240px]"
          />
        </div>
      </div>

      <div className={`${SURFACE} overflow-hidden`}>
        <div className="overflow-x-auto overflow-y-auto max-h-[calc(100vh-19rem)]">
          <table className="w-full text-left text-[13px]">
            {/* Sticky because Skills runs to 413 rows, and a header that scrolls
                away turns the remaining columns into guesswork. */}
            <thead className="bg-bg-soft sticky top-0 z-10">
              <tr>
                <th className="px-4 py-3 font-bold text-ink w-12">#</th>
                {config.columns.map((col) => (
                  <th key={col.label} className="px-4 py-3 font-bold text-ink whitespace-nowrap">
                    {col.label}
                  </th>
                ))}
                <th className="px-4 py-3 font-bold text-ink whitespace-nowrap">Slug</th>
                {hasUpdatedAt && (
                  <th className="px-4 py-3 font-bold text-ink whitespace-nowrap">Updated On</th>
                )}
                <th className="px-4 py-3 font-bold text-ink text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {visible.map((item, i) => {
                const slug = String(item.slug ?? "");
                return (
                  <tr key={slug} className="border-t border-line hover:bg-bg-soft transition-colors">
                    <td className="px-4 py-3 text-subtle tabular-nums">{i + 1}</td>
                    {config.columns.map((col) => (
                      <td key={col.label} className="px-4 py-3 text-ink">
                        {col.render(item)}
                      </td>
                    ))}
                    <td className="px-4 py-3 font-mono text-[12px] text-subtle">{slug}</td>
                    {hasUpdatedAt && (
                      <td className="px-4 py-3 text-muted whitespace-nowrap">
                        {formatUpdated(item.updatedAt)}
                      </td>
                    )}
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-end gap-2">
                        <IconButton
                          icon="pencil"
                          label={`Edit ${slug}`}
                          tone="primary"
                          href={`/admin/${resource}/${encodeURIComponent(slug)}/edit`}
                        />
                        {publicPath && (
                          <IconButton
                            icon="eye"
                            label={`View the public page for ${slug}`}
                            href={`${publicPath}/${encodeURIComponent(slug)}`}
                          />
                        )}
                        <IconButton
                          icon="trash"
                          label={`Delete ${slug}`}
                          tone="danger"
                          disabled={pendingDelete === slug}
                          onClick={() => setConfirmSlug(slug)}
                        />
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {visible.length === 0 &&
          (items.length === 0 ? (
            <EmptyState
              icon="layers"
              title={`No ${config.pluralLabel.toLowerCase()} yet`}
              message={`Nothing has been added here. Create the first ${config.label.toLowerCase()} to get started.`}
              action={{ href: `/admin/${resource}/new`, label: `Add ${config.label}` }}
            />
          ) : (
            <EmptyState
              title="Nothing matches"
              message={`No ${config.pluralLabel.toLowerCase()} match the current search or filter.`}
              action={{
                label: "Clear search and filters",
                onClick: () => {
                  setQuery("");
                  setFilter("");
                },
              }}
            />
          ))}
      </div>

      {toast && <Toast tone={toast.tone} message={toast.message} onClose={() => setToast(null)} />}

      <ConfirmDialog
        open={confirmSlug !== null}
        title={`Delete "${confirmSlug}"?`}
        message="This can't be undone, and removes it from anything that links to it."
        busy={pendingDelete === confirmSlug}
        onConfirm={() => confirmSlug && handleDelete(confirmSlug)}
        onCancel={() => setConfirmSlug(null)}
      />
    </div>
  );
}
