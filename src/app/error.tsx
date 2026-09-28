"use client";

import { useEffect } from "react";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Button from "@/components/ui/Button";
import { getFriendlyErrorMessage } from "@/lib/errors";

/**
 * Global error boundary for the app segment (everything under the root
 * layout except the layout itself -- Navbar/Footer stay visible). Catches
 * anything not already handled locally: a failed fetch to the backend, a
 * 500/409/429 response, a bug in a Server or Client Component render.
 *
 * Must be a Client Component (Next.js requirement for error.tsx) and takes
 * `error`/`reset` from Next automatically -- `reset()` re-renders the
 * segment that threw, which is enough to recover from a transient failure
 * (a dropped connection, a rate limit that's since cleared) without a full
 * page reload.
 */
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Logged client-side only -- there's no error-tracking service wired up
    // yet, so this at least keeps the failure visible in the browser console
    // during development rather than silently swallowed.
    console.error(error);
  }, [error]);

  return (
    <Container className="py-24 flex flex-col items-center text-center">
      <div className="w-16 h-16 rounded-2xl bg-red-soft flex items-center justify-center text-red mb-6">
        <Icon name="wrench" className="w-8 h-8" />
      </div>
      <h1 className="font-display font-extrabold text-navy text-2xl sm:text-3xl mb-3">
        Something went wrong
      </h1>
      <p className="text-muted text-[15px] max-w-md mb-8">{getFriendlyErrorMessage(error)}</p>
      <div className="flex flex-wrap items-center justify-center gap-3">
        <Button onClick={reset}>Try again</Button>
        <Button href="/" variant="secondary">
          Go to homepage
        </Button>
      </div>
    </Container>
  );
}
