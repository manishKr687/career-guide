"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Container from "@/components/ui/Container";
import { adminLogin } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";

export default function AdminLoginPage() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await adminLogin(password);
      router.push("/admin");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <Container className="max-w-sm py-20">
      <h1 className="font-display font-extrabold text-navy text-2xl mb-1">Admin login</h1>
      <p className="text-[13.5px] text-subtle mb-6">Manage careers, degrees, exams and colleges.</p>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="admin-password" className="block text-[13px] font-bold text-ink mb-1.5">
            Admin password
          </label>
          <input
            id="admin-password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoFocus
            required
            className="w-full rounded-xl border border-line px-3.5 py-2.5 text-[13.5px] font-medium text-ink focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors"
          />
        </div>
        {error && <p className="text-[13.5px] text-red">{error}</p>}
        <button
          type="submit"
          disabled={submitting}
          className="w-full text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors disabled:opacity-50"
        >
          {submitting ? "Logging in..." : "Log in"}
        </button>
      </form>
    </Container>
  );
}
