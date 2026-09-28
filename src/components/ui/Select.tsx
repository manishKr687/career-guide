import { cn } from "@/lib/utils";

/**
 * The `Select` primitive from the UI architecture doc's design-system
 * section -- a labeled native `<select>`, styled to match `Input`.
 */
export default function Select({
  label,
  error,
  className,
  id,
  children,
  ...rest
}: {
  label?: string;
  error?: string;
  className?: string;
  children: React.ReactNode;
} & Omit<React.SelectHTMLAttributes<HTMLSelectElement>, "className">) {
  const selectId = id ?? (label ? label.toLowerCase().replace(/\s+/g, "-") : undefined);
  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label htmlFor={selectId} className="text-[12.5px] font-semibold text-ink/80">
          {label}
        </label>
      )}
      <select
        id={selectId}
        className={cn(
          "w-full rounded-xl border border-line px-4 py-2.5 text-[13.5px] font-medium text-ink focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors bg-white",
          error && "border-red/40 focus:border-red/40 focus:ring-red/10",
          className
        )}
        aria-invalid={error ? true : undefined}
        {...rest}
      >
        {children}
      </select>
      {error && <p className="text-[12px] text-red">{error}</p>}
    </div>
  );
}
