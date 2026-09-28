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
  const [error, setError] = useState<string | null>(null);
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
        if (!cancelled) setError("Could not load the dropdown options for this form.");
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
    setError(null);
    try {
      setItems(await config.loadAll());
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?");
    }
  }

  async function handleDelete(slug: string) {
    setConfirmSlug(null);
    setPendingDelete(slug);
    setError(null);
    try {
      await adminDelete(resource, slug);
      if (draft && draft.slug === slug) setDraft(null);
      await refresh();
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setError(err instanceof ApiError ? err.message : "Delete failed. Is the backend running?");
    } finally {
      setPendingDelete(null);
    }
  }

  async function handleSave() {
    if (!draft) return;
    setSaving(true);
    setError(null);
    try {
      await adminUpdate(resource, String(draft.slug), toPayload(config, draft));
      setDraft(null);
      await refresh();
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setError(err instanceof ApiError ? err.message : "Save failed. Is the backend running?");
    } finally {
      setSaving(false);
    }
  }

  // Shown only where the resource actually has the column. States, Cities and
  // Universities were not part of V115, so their DTOs carry no updatedAt at all
  // and an always-empty column would be noise on those three pages.
  const hasUpdatedAt = useMemo(() => items.some((item) => "updatedAt" in item), [items]);

  const iconButton =
    "w-8 h-8 rounded-lg border border-line flex items-center justify-center transition-colors disabled:opacity-40";

  return (
    <div>
      <div className="flex flex-wrap items-start justify-between gap-4 mb-5">
        <div>
          <h2 className="font-display font-extrabold text-navy text-[22px]">{config.pluralLabel}</h2>
          <p className="text-[13px] text-muted mt-1">
            Manage {config.pluralLabel.toLowerCase()} and their details.
          </p>
        </div>
        <Link
          href={`/admin/${resource}/new`}
          className="flex items-center gap-2 text-[13px] font-bold text-white bg-blue px-4 py-2.5 rounded-xl hover:opacity-90 transition-opacity shrink-0"
        >
          {/* A literal plus rather than an icon: the set has no plus glyph, and
              inventing one for a single button is not worth a new path. */}
          <span className="text-[15px] leading-none -mt-px">+</span>
          Add {config.label}
        </Link>
      </div>

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

      {error && <p className="text-[13px] text-red mb-4">{error}</p>}

      <div className="bg-white rounded-2xl border border-line overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-[13px]">
            <thead className="bg-bg-soft">
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
                        <button
                          onClick={() => setDraft(toFormValues(config, item))}
                          title="Quick edit"
                          aria-label={`Quick edit ${slug}`}
                          className={`${iconButton} text-blue hover:border-blue/40`}
                        >
                          <Icon name="pencil" className="w-4 h-4" />
                        </button>
                        <Link
                          href={`/admin/${resource}/${encodeURIComponent(slug)}/edit`}
                          title="Open the full form"
                          aria-label={`Edit ${slug}`}
                          className={`${iconButton} text-muted hover:border-navy/30 hover:text-navy`}
                        >
                          <Icon name="eye" className="w-4 h-4" />
                        </Link>
                        <button
                          onClick={() => setConfirmSlug(slug)}
                          disabled={pendingDelete === slug}
                          title="Delete"
                          aria-label={`Delete ${slug}`}
                          className={`${iconButton} text-red hover:border-red/40`}
                        >
                          <Icon name="trash" className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {visible.length === 0 && (
          <p className="px-4 py-10 text-[13px] text-muted text-center">
            {items.length === 0
              ? `No ${config.pluralLabel.toLowerCase()} yet.`
              : `No ${config.pluralLabel.toLowerCase()} match that search.`}
          </p>
        )}
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

            {error && <p className="text-[12.5px] text-red mt-4">{error}</p>}

            <div className="flex justify-end gap-3 mt-6">
              <button
                type="button"
                onClick={() => setDraft(null)}
                disabled={saving}
                className="text-[13px] font-bold text-navy bg-white px-4 py-2.5 rounded-xl border border-line hover:border-navy/30 transition-colors disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleSave}
                disabled={saving}
                className="text-[13px] font-bold text-white bg-blue px-5 py-2.5 rounded-xl hover:opacity-90 transition-opacity disabled:opacity-50"
              >
                {saving ? "Saving..." : "Update"}
              </button>
            </div>
          </>
        )}
      </Modal>

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
