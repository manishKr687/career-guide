"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { AdminResource, adminDelete, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { FormValues, RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";
import ConfirmDialog from "@/components/ui/ConfirmDialog";

// `initialItems` is fetched server-side (see the resource's page.tsx) so
// the table renders on first paint instead of showing "Loading..." while a
// Client Component mounts, hydrates and only then fetches -- the same data
// this component used to fetch itself in a useEffect on every visit.
export default function AdminResourceList({ resource, initialItems }: { resource: AdminResource; initialItems: FormValues[] }) {
  const router = useRouter();
  const config = RESOURCE_CONFIGS[resource];

  const [items, setItems] = useState<FormValues[]>(initialItems);
  const [error, setError] = useState<string | null>(null);
  const [pendingDelete, setPendingDelete] = useState<string | null>(null);
  const [confirmSlug, setConfirmSlug] = useState<string | null>(null);

  async function refresh() {
    setError(null);
    try {
      const all = await config.loadAll();
      setItems(all);
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

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display font-extrabold text-navy text-xl">{config.pluralLabel}</h1>
        <Link
          href={`/admin/${resource}/new`}
          className="text-[13.5px] font-bold text-white bg-navy px-4 py-2.5 rounded-xl hover:bg-navy-2 transition-colors"
        >
          + New {config.label}
        </Link>
      </div>

      {error && <p className="text-[13.5px] text-red mb-4">{error}</p>}

      {items.length === 0 ? (
        <p className="text-[13.5px] text-subtle">No {config.pluralLabel.toLowerCase()} yet.</p>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-line">
          <table className="w-full text-left text-[13.5px]">
            <thead className="bg-bg-soft">
              <tr>
                <th className="px-4 py-3 font-bold text-ink">Slug</th>
                {config.columns.map((col) => (
                  <th key={col.label} className="px-4 py-3 font-bold text-ink">
                    {col.label}
                  </th>
                ))}
                <th className="px-4 py-3" />
              </tr>
            </thead>
            <tbody>
              {items.map((item) => {
                const slug = String(item.slug ?? "");
                return (
                  <tr key={slug} className="border-t border-line">
                    <td className="px-4 py-3 font-mono text-[12.5px] text-subtle">{slug}</td>
                    {config.columns.map((col) => (
                      <td key={col.label} className="px-4 py-3 text-ink">
                        {col.render(item)}
                      </td>
                    ))}
                    <td className="px-4 py-3 text-right whitespace-nowrap">
                      <Link
                        href={`/admin/${resource}/${encodeURIComponent(slug)}/edit`}
                        className="text-[12.5px] font-bold text-blue hover:underline mr-4"
                      >
                        Edit
                      </Link>
                      <button
                        onClick={() => setConfirmSlug(slug)}
                        disabled={pendingDelete === slug}
                        className="text-[12.5px] font-bold text-red hover:underline disabled:opacity-50"
                      >
                        {pendingDelete === slug ? "Deleting..." : "Delete"}
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

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
