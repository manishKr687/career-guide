import { cn } from "@/lib/utils";

/**
 * Generic pulsing placeholder block -- the "Skeleton" primitive from the UI
 * architecture doc's design-system section. Used to build loading states for
 * every data-driven route (see `loading.tsx` files under `src/app`), instead
 * of a blank screen while a Server Component awaits its fetch.
 */
export default function Skeleton({ className }: { className?: string }) {
  return <div className={cn("animate-pulse rounded-lg bg-line", className)} aria-hidden="true" />;
}
