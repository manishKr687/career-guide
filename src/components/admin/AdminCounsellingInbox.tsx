"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  AdminCounsellingRequest,
  AdminUnauthorizedError,
  CounsellingRequestStatus,
  adminDeleteCounsellingRequest,
  adminListCounsellingRequests,
  adminUpdateCounsellingStatus,
} from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { buildWhatsAppLink } from "@/lib/whatsapp";
import { useRouter } from "next/navigation";
import ConfirmDialog from "@/components/ui/ConfirmDialog";

const STATUS_OPTIONS: CounsellingRequestStatus[] = ["PENDING", "CONTACTED", "COMPLETED"];

const STATUS_STYLES: Record<CounsellingRequestStatus, string> = {
  PENDING: "bg-amber-soft text-amber",
  CONTACTED: "bg-blue-soft text-blue",
  COMPLETED: "bg-green-soft text-green",
};

function formatDate(iso: string): string {
  try {
    return new Date(iso).toLocaleString();
  } catch {
    return iso;
  }
}

export default function AdminCounsellingInbox() {
  const router = useRouter();
  const [requests, setRequests] = useState<AdminCounsellingRequest[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<number | null>(null);
  const [confirmId, setConfirmId] = useState<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    adminListCounsellingRequests()
      .then((all) => {
        if (!cancelled) setRequests(all);
      })
      .catch((err) => {
        if (cancelled) return;
        if (err instanceof AdminUnauthorizedError) {
          router.push("/admin/login");
          return;
        }
        setError(err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?");
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function handleStatusChange(id: number, status: CounsellingRequestStatus) {
    setBusyId(id);
    setError(null);
    try {
      const updated = await adminUpdateCounsellingStatus(id, status);
      setRequests((prev) => (prev ? prev.map((r) => (r.id === id ? updated : r)) : prev));
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setError(err instanceof ApiError ? err.message : "Update failed. Is the backend running?");
    } finally {
      setBusyId(null);
    }
  }

  async function handleDelete(id: number) {
    setConfirmId(null);
    setBusyId(id);
    setError(null);
    try {
      await adminDeleteCounsellingRequest(id);
      setRequests((prev) => (prev ? prev.filter((r) => r.id !== id) : prev));
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setError(err instanceof ApiError ? err.message : "Delete failed. Is the backend running?");
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div>
      <h1 className="font-display font-extrabold text-navy text-xl mb-6">Counselling Requests</h1>

      {error && <p className="text-[13.5px] text-red mb-4">{error}</p>}

      {requests === null ? (
        <p className="text-[13.5px] text-subtle">Loading...</p>
      ) : requests.length === 0 ? (
        <p className="text-[13.5px] text-subtle">No requests yet.</p>
      ) : (
        <div className="space-y-3">
          {requests.map((r) => {
            const whatsAppMessage = `Hi ${r.name}, this is CareerGuide following up on your counselling request${
              r.careerSlug ? ` about ${r.careerSlug}` : ""
            }.`;
            return (
              <div key={r.id} className="bg-white rounded-2xl border border-line p-5">
                <div className="flex flex-wrap items-start justify-between gap-3 mb-3">
                  <div>
                    <div className="font-display font-extrabold text-navy text-[15px]">{r.name}</div>
                    <div className="text-[12.5px] text-subtle">{formatDate(r.createdAt)}</div>
                  </div>
                  <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${STATUS_STYLES[r.status]}`}>
                    {r.status}
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-1.5 text-[13px] text-ink mb-3">
                  <div>
                    <span className="text-subtle">Email:</span> {r.email}
                  </div>
                  <div>
                    <span className="text-subtle">Phone:</span> {r.phone}
                  </div>
                  {(r.preferredDate || r.preferredTime) && (
                    <div>
                      <span className="text-subtle">Preferred:</span> {r.preferredDate ?? ""} {r.preferredTime ?? ""}
                    </div>
                  )}
                  {r.stageSlug && (
                    <div>
                      <span className="text-subtle">Stage:</span> {r.stageSlug}
                    </div>
                  )}
                  {r.careerSlug && (
                    <div>
                      <span className="text-subtle">Career:</span> {r.careerSlug}
                    </div>
                  )}
                </div>

                {r.message && <p className="text-[13px] text-ink/70 mb-4 whitespace-pre-wrap">{r.message}</p>}

                <div className="flex flex-wrap items-center gap-3">
                  <select
                    value={r.status}
                    disabled={busyId === r.id}
                    onChange={(e) => handleStatusChange(r.id, e.target.value as CounsellingRequestStatus)}
                    className="text-[12.5px] font-semibold rounded-lg border border-line px-2.5 py-1.5 disabled:opacity-50"
                  >
                    {STATUS_OPTIONS.map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                  <Link
                    href={buildWhatsAppLink(r.phone, whatsAppMessage)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-[12.5px] font-bold text-green hover:underline"
                  >
                    Message on WhatsApp
                  </Link>
                  <button
                    onClick={() => setConfirmId(r.id)}
                    disabled={busyId === r.id}
                    className="text-[12.5px] font-bold text-red hover:underline disabled:opacity-50 ml-auto"
                  >
                    Delete
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      <ConfirmDialog
        open={confirmId !== null}
        title="Delete this request?"
        message="This can't be undone."
        busy={busyId === confirmId}
        onConfirm={() => confirmId !== null && handleDelete(confirmId)}
        onCancel={() => setConfirmId(null)}
      />
    </div>
  );
}
