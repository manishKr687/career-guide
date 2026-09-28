"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { adminListCounsellingRequests } from "@/lib/adminApi";

type LoadState = { status: "loading" } | { status: "error" } | { status: "ready"; total: number; pending: number };

/**
 * Client component because it's the one dashboard stat backed by an admin
 * (token-authenticated) endpoint rather than a public one -- see
 * AdminCareerControllerTest.java's sibling data helpers, all of which are
 * plain public GETs the parent Server Component can await directly.
 * Fails quietly into a plain link card rather than surfacing an error: a
 * missing/expired token here isn't this widget's job to handle -- the
 * layout's own AdminProtectedLayout already redirects to /admin/login when
 * that happens on a real page visit.
 */
export default function CounsellingRequestsStat() {
  const [state, setState] = useState<LoadState>({ status: "loading" });

  useEffect(() => {
    let cancelled = false;
    adminListCounsellingRequests()
      .then((requests) => {
        if (cancelled) return;
        setState({
          status: "ready",
          total: requests.length,
          pending: requests.filter((r) => r.status === "PENDING").length,
        });
      })
      .catch(() => {
        if (cancelled) return;
        setState({ status: "error" });
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <Link
      href="/admin/counselling-requests"
      className="block bg-white rounded-2xl border border-line p-6 hover:border-navy/30 transition-colors max-w-xs"
    >
      <p className="text-[13px] font-bold text-ink mb-2">Counselling requests</p>
      {state.status === "ready" ? (
        <p className="flex items-baseline gap-2">
          <span className="font-display font-semibold text-navy text-[28px] leading-none">{state.pending}</span>
          <span className="text-[13px] text-subtle">pending of {state.total.toLocaleString()} total</span>
        </p>
      ) : (
        <p className="text-[13px] text-subtle">Review and follow up on booking requests from visitors.</p>
      )}
    </Link>
  );
}
