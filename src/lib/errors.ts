import { ApiError } from "@/lib/api";

/**
 * Maps a thrown error to a short, user-facing message -- never the raw
 * `error.message`/stack, which can leak internal details (a URL, a status
 * line, "ECONNREFUSED"). Covers the status codes the UI architecture doc's
 * "Error Handling" section calls out (400/401/403/404/409/429/500) plus a
 * generic network-failure case, since the backend's `GlobalExceptionHandler`
 * can now genuinely return any of these.
 *
 * Used by the root `error.tsx` boundary. Verified against a real production
 * build (`next build && next start`), not assumed: for an error thrown
 * during a Server Component's render (which is how almost every fetch in
 * this app happens -- see `data/*.ts`), Next.js deliberately replaces BOTH
 * the error's class identity AND its `message` with a generic, redacted
 * "An error occurred..." string plus a `digest` before it ever reaches this
 * client-side boundary -- a security measure so server-side failure details
 * (a URL, a stack trace, "ECONNREFUSED") can't leak to the browser. That
 * means the `instanceof ApiError` check and the status-code regex below can
 * only ever match a genuinely client-thrown error (e.g. a "use client"
 * component calling `apiPost` directly from an event handler, like
 * `CounsellingForm`) -- for a server-rendering failure, every path here
 * falls through to the generic message at the bottom, which is the correct
 * and intended fallback, not a bug to "fix" by trying to smuggle more
 * detail across that boundary.
 */
export function getFriendlyErrorMessage(error: unknown): string {
  if (error instanceof ApiError) return messageForStatus(error.status);

  const text = error instanceof Error ? error.message : String(error);

  const statusMatch = text.match(/failed: (\d{3})\b/);
  if (statusMatch) return messageForStatus(Number(statusMatch[1]));

  if (/fetch failed|ECONNREFUSED|ENOTFOUND|NetworkError|Failed to fetch/i.test(text)) {
    return "We couldn't reach CareerGuide's servers. Check your connection and try again.";
  }

  return "Something went wrong. Please try again.";
}

function messageForStatus(status: number): string {
  switch (status) {
    case 400:
      return "That request wasn't valid. Please check the details and try again.";
    case 401:
      return "Please log in again to continue.";
    case 403:
      return "You don't have permission to do that.";
    case 404:
      return "We couldn't find what you were looking for.";
    case 409:
      return "That conflicts with something that already exists.";
    case 429:
      return "You've made too many requests. Please wait a moment and try again.";
    default:
      if (status >= 500) return "Something went wrong on our end. Please try again shortly.";
      return "Something went wrong. Please try again.";
  }
}
