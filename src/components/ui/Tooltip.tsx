import { cn } from "@/lib/utils";

/**
 * The `Tooltip` primitive from the UI architecture doc's design-system
 * section. CSS-only (a group-hover/focus-within reveal), no positioning
 * library or new dependency -- fine for a short label anchored directly
 * above its trigger, which covers every use this app has for one so far.
 */
export default function Tooltip({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <span className={cn("relative inline-flex group/tooltip", className)}>
      {children}
      <span
        role="tooltip"
        className="pointer-events-none absolute bottom-full left-1/2 -translate-x-1/2 mb-2 whitespace-nowrap rounded-md bg-navy px-2.5 py-1.5 text-[11.5px] font-semibold text-white opacity-0 transition-opacity group-hover/tooltip:opacity-100 group-focus-within/tooltip:opacity-100 z-50"
      >
        {label}
      </span>
    </span>
  );
}
