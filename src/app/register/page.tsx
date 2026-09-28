"use client";

import { Suspense, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import Container from "@/components/ui/Container";
import Input from "@/components/ui/Input";
import Button from "@/components/ui/Button";
import { useUser } from "@/components/providers/UserProvider";
import { ApiError } from "@/lib/api";

// useSearchParams() (for the post-registration `?next=` redirect target)
// opts this page out of static prerendering unless it's wrapped in Suspense
// -- see https://nextjs.org/docs/messages/missing-suspense-with-csr-bailout.
export default function RegisterPage() {
  return (
    // The heading and blurb sit OUTSIDE the Suspense boundary deliberately.
    // useSearchParams() opts this route out of prerendering, so everything
    // inside the boundary is replaced by the fallback in the built HTML -- with
    // `fallback={null}` and the whole page inside it, the prerendered document
    // was completely empty. No heading, no form, nothing until JavaScript
    // loaded and hydrated: bad on a slow connection, and nothing at all for a
    // screen reader or a crawler on first paint.
    //
    // Only the form needs the search params (for the `?next=` redirect target),
    // so only the form goes inside, behind a fallback shaped like the form it
    // replaces rather than a blank.
    <Container className="max-w-sm py-20">
      <h1 className="font-display font-extrabold text-navy text-2xl mb-1.5">Create your account</h1>
      <p className="text-[13.5px] text-subtle mb-6">
        Save careers, colleges and exams, and pick up your career journey from any device.
      </p>
      <Suspense fallback={<FormSkeleton />}>
        <RegisterForm />
      </Suspense>
    </Container>
  );
}

/** Placeholder with the same rhythm as the form, so the page does not reflow. */
function FormSkeleton() {
  return (
    <div className="space-y-4" aria-hidden="true">
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i}>
          <div className="h-3 w-20 rounded bg-line animate-pulse mb-2" />
          <div className="h-11 rounded-xl bg-line/60 animate-pulse" />
        </div>
      ))}
    </div>
  );
}

function RegisterForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { register } = useUser();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await register(email, password, name);
      router.push(searchParams.get("next") || "/profile");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <>
      <form onSubmit={handleSubmit} className="space-y-4">
        <Input label="Name" value={name} onChange={(e) => setName(e.target.value)} autoFocus required />
        <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <Input
          label="Password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={8}
        />
        {error && <p className="text-[13.5px] text-red">{error}</p>}
        <Button type="submit" disabled={submitting} className="w-full justify-center">
          {submitting ? "Creating account..." : "Sign up"}
        </Button>
      </form>
      <p className="text-[13.5px] text-subtle mt-6 text-center">
        Already have an account?{" "}
        <Link href="/login" className="font-bold text-navy hover:underline">
          Log in
        </Link>
      </p>
    </>
  );
}
