import { cn } from "@/lib/utils";

/**
 * The `Input` primitive from the UI architecture doc's design-system
 * section -- a labeled text field with an optional error message, for
 * forms (login/register, admin entity forms) rather than the icon-prefixed
 * `SearchInput` used on listing pages.
 */
export default function Input({
  label,
  error,
  className,
  id,
  ...rest
}: {
  label?: string;
  error?: string;
  className?: string;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, "className">) {
  const inputId = id ?? (label ? label.toLowerCase().replace(/\s+/g, "-") : undefined);
  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label htmlFor={inputId} className="text-[12.5px] font-semibold text-ink/80">
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          "w-full rounded-xl border border-line px-4 py-2.5 text-[13.5px] font-medium text-ink placeholder:text-subtle focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors",
          error && "border-red/40 focus:border-red/40 focus:ring-red/10",
          className
        )}
        aria-invalid={error ? true : undefined}
        aria-describedby={error && inputId ? `${inputId}-error` : undefined}
        {...rest}
      />
      {error && (
        <p id={inputId ? `${inputId}-error` : undefined} className="text-[12px] text-red">
          {error}
        </p>
      )}
    </div>
  );
}
