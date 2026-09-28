"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import Icon from "@/components/ui/Icon";
import { AdminResource, adminDelete, adminUpdate, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import {
  FieldOption,
  FormValues,
  RESOURCE_CONFIGS,
  toFormValues,
  toPayload,
} from "@/lib/admin/resourceConfig";
import AdminEntityForm, { type FieldValue } from "@/components/admin/AdminEntityForm";
import ConfirmDialog from "@/components/ui/ConfirmDialog";
import Modal from "@/components/ui/Modal";
import {
  BTN_PRIMARY,
  BTN_SECONDARY,
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

  // Quick-edit panel. `draft` holds a FULL copy of the row, not just the fields
  // the panel shows -- the admin API is a PUT that replaces the whole record, so
  // submitting a partial object would blank every field the panel omits. The
  // panel renders a subset; the payload is built from all of it.
  const [draft, setDraft] = useState<FormValues | null>(null);
  const [saving, setSaving] = useState(false);
  const [referenceOptions, setReferenceOptions] = useState<Record<string, FieldOption[]>>({});

  // Loaded once the first panel opens rather than on page load: most visits to a
  // list page never open one, and these are a dozen parallel API calls.
  useEffect(() => {
    if (draft === null || Object.keys(referenceOptions).length > 0) return;
    let cancelled = false;
    config.loadReferenceOptions()
      .then((opts) => {
        if (!cancelled) setReferenceOptions(opts);
      })
      .catch(() => {
        if (!cancelled) setToast({ tone: "error", message: "Could not load the dropdown options for this form." });
      });
    return () => {
      cancelled = true;
    };
  }, [draft, referenceOptions, config]);

  /**
   * The fields the inline panel shows: the plain scalar ones, capped at four.
   * Relations -- multiselects, paired rows, ordered lists -- are deliberately
   * left to the full edit page, where there is room to see what you are changing.
   * A five-across grid of twenty-item multiselects is not a quick edit.
   */
  const quickFields = useMemo(
    () =>
      config.fields
        .filter((f) => ["text", "textarea", "select", "number"].includes(f.type) && f.key !== "slug")
        .slice(0, 4),
    [config]
  );

  // Short fields pair up two to a row, long ones run full width -- so a dialog
  // opens with Title and Level side by side and the description beneath, rather
  // than four boxes in a column with a lot of empty space to their right.
  const shortFields = useMemo(() => quickFields.filter((f) => f.type !== "textarea"), [quickFields]);
  const longFields = useMemo(() => quickFields.filter((f) => f.type === "textarea"), [quickFields]);

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
    return [...seen.keys()].sort();
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
      if (draft && draft.slug === slug) setDraft(null);
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

  async function handleSave() {
    if (!draft) return;
    setSaving(true);
    const savedSlug = String(draft.slug);
    try {
      await adminUpdate(resource, savedSlug, toPayload(config, draft));
      setDraft(null);
      await refresh();
      setToast({ tone: "success", message: `Saved changes to "${savedSlug}".` });
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setToast({
        tone: "error",
        message: err instanceof ApiError ? err.message : "Save failed. Is the backend running?",
      });
    } finally {
      setSaving(false);
    }
  }

  // Shown only where the resource actually has the column. States, Cities and
  // Universities were not part of V115, so their DTOs carry no updatedAt at all
  // and an always-empty column would be noise on those three pages.
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
                const isEditing = draft !== null && draft.slug === slug;
                return (
                  <tr
                    key={slug}
                    className={`border-t border-line ${isEditing ? "bg-blue-soft/40" : "hover:bg-bg-soft"}`}
                  >
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
                          label={`Quick edit ${slug}`}
                          tone="primary"
                          onClick={() => setDraft(toFormValues(config, item))}
                        />
                        <IconButton
                          icon="eye"
                          label={`Open the full form for ${slug}`}
                          href={`/admin/${resource}/${encodeURIComponent(slug)}/edit`}
                        />
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

      <Modal
        open={draft !== null}
        onClose={() => setDraft(null)}
        title={`Edit ${config.label}`}
        subtitle={draft ? String(draft.slug) : undefined}
        size="lg"
      >
        {draft && (
          <>
            {shortFields.length > 0 && (
              <AdminEntityForm
                fields={shortFields}
                values={draft}
                onChange={(key: string, value: FieldValue) => setDraft({ ...draft, [key]: value })}
                referenceOptions={referenceOptions}
                className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-5"
              />
            )}

            {longFields.length > 0 && (
              <div className={shortFields.length > 0 ? "mt-5" : undefined}>
                <AdminEntityForm
                  fields={longFields}
                  values={draft}
                  onChange={(key: string, value: FieldValue) => setDraft({ ...draft, [key]: value })}
                  referenceOptions={referenceOptions}
                />
              </div>
            )}

            {/* Said plainly, because the dialog shows four fields out of what is
                often twenty, and an editor who assumed otherwise would go looking
                for the relations and conclude they had been lost. */}
            <p className="text-[12px] text-muted mt-5">
              Relations and ordered lists are edited on the{" "}
              <Link
                href={`/admin/${resource}/${encodeURIComponent(String(draft.slug))}/edit`}
                className="font-bold text-blue hover:underline"
              >
                full form
              </Link>
              . Saving here keeps them untouched.
            </p>

            <div className="flex justify-end gap-3 mt-6">
              <button type="button" onClick={() => setDraft(null)} disabled={saving} className={BTN_SECONDARY}>
                Cancel
              </button>
              <button type="button" onClick={handleSave} disabled={saving} className={BTN_PRIMARY}>
                {saving ? "Saving..." : "Update"}
              </button>
            </div>
          </>
        )}
      </Modal>

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
