import Link from "next/link";
import Icon from "@/components/ui/Icon";

/**
 * The shared furniture of the Career and Specialization detail pages.
 *
 * Extracted from the specialization page when the career page became the
 * second caller -- the point at which duplicating it would have started the
 * usual drift, with one page's cards gaining a hover state or a tighter
 * gutter and the other not.
 *
 * The two pages are deliberately the same shape because they answer the same
 * question at two zoom levels: a Career is the parent of its Specializations,
 * so a reader moving between them should recognise the layout and only notice
 * that the scope narrowed.
 */

/** Soft tints, cycled by index so a list of any length stays varied without
 *  hard-coding a colour per row. */
export const TINTS = [
  "bg-blue-soft text-blue",
  "bg-green-soft text-green",
  "bg-purple-soft text-purple",
  "bg-amber-soft text-amber",
  "bg-teal-soft text-teal",
  "bg-pink-soft text-pink",
];

export function tint(i: number) {
  return TINTS[i % TINTS.length];
}

export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={`bg-white rounded-3xl border border-line shadow-card p-6 ${className}`}>
      {children}
    </div>
  );
}

export function CardTitle({
  icon,
  children,
  subtitle,
  viewAll,
}: {
  icon: string;
  children: React.ReactNode;
  /** Used to say when a section is showing BORROWED data -- see the note at
   *  the top of either detail page. */
  subtitle?: string;
  viewAll?: { href: string; count?: number };
}) {
  return (
    <div className="mb-4">
      <div className="flex items-start justify-between gap-3">
        <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[17px]">
          <Icon name={icon} className="w-[19px] h-[19px] text-blue shrink-0" />
          {children}
        </h2>
        {viewAll && <ViewAll {...viewAll} />}
      </div>
      {subtitle && <p className="text-[12.5px] text-muted mt-1.5">{subtitle}</p>}
    </div>
  );
}

export function Section({
  icon,
  title,
  subtitle,
  viewAll,
  children,
}: {
  icon: string;
  title: string;
  subtitle?: string;
  viewAll?: { href: string; count?: number };
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="flex items-start justify-between gap-3 mb-4">
        <div>
          <h2 className="flex items-center gap-2.5 font-display font-extrabold text-navy text-[19px]">
            <Icon name={icon} className="w-[21px] h-[21px] text-blue shrink-0" />
            {title}
          </h2>
          {subtitle && <p className="text-[12.5px] text-muted mt-1.5 ml-[31px]">{subtitle}</p>}
        </div>
        {viewAll && <ViewAll {...viewAll} className="mt-1" />}
      </div>
      {children}
    </section>
  );
}

function ViewAll({
  href,
  count,
  className = "",
}: {
  href: string;
  count?: number;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={`text-[12.5px] font-semibold text-blue hover:underline whitespace-nowrap shrink-0 mt-0.5 ${className}`}
    >
      View all{count !== undefined ? ` (${count})` : ""}
    </Link>
  );
}

/** A card-sized row: icon, title, optional second line or badge, arrow. */
export function RowCard({
  href,
  icon,
  tint: tintClass,
  title,
  meta,
  badge,
}: {
  href: string;
  icon: string;
  tint: string;
  title: string;
  meta?: string;
  badge?: { label: string; className: string };
}) {
  return (
    <Link
      href={href}
      className="group flex items-start gap-3.5 bg-white rounded-2xl border border-line p-4 hover:border-blue/40 hover:shadow-card transition-all"
    >
      <span className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 ${tintClass}`}>
        <Icon name={icon} className="w-5 h-5" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block font-display font-bold text-navy text-[14px] leading-snug">
          {title}
        </span>
        {meta && <span className="block text-[12px] text-muted mt-1 leading-snug">{meta}</span>}
        {badge && (
          <span
            className={`inline-block text-[11px] font-bold px-2.5 py-1 rounded-full mt-1.5 ${badge.className}`}
          >
            {badge.label}
          </span>
        )}
      </span>
      <Icon
        name="chevRight"
        className="w-4 h-4 text-subtle shrink-0 mt-3.5 group-hover:text-blue transition-colors"
      />
    </Link>
  );
}

/** A compact list line, for the narrow rail columns. */
export function ListRow({
  href,
  label,
  icon,
  tint: tintClass,
}: {
  href: string;
  label: string;
  icon?: string;
  tint?: string;
}) {
  return (
    <li>
      <Link
        href={href}
        className="group flex items-center gap-3 py-2.5 border-b border-line last:border-0 hover:bg-bg-soft -mx-2 px-2 rounded-lg transition-colors"
      >
        {icon && (
          <span
            className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 ${tintClass ?? "bg-bg-soft text-navy"}`}
          >
            <Icon name={icon} className="w-3.5 h-3.5" />
          </span>
        )}
        <span className="flex-1 min-w-0 text-[13.5px] font-semibold text-ink/85 truncate">
          {label}
        </span>
        <Icon
          name="chevRight"
          className="w-3.5 h-3.5 text-subtle shrink-0 group-hover:text-blue transition-colors"
        />
      </Link>
    </li>
  );
}

export function Pill({
  href,
  tint: tintClass,
  children,
}: {
  href: string;
  tint: string;
  children: React.ReactNode;
}) {
  return (
    <Link
      href={href}
      className={`text-[12.5px] font-semibold px-3.5 py-2 rounded-full transition-opacity hover:opacity-80 ${tintClass}`}
    >
      {children}
    </Link>
  );
}

/** The hero's headline figures. Each entry is a fact the catalog can prove --
 *  a metric with nothing behind it is omitted by the caller rather than
 *  rendered as a dash, so the row never implies a number exists. */
export function MetricRow({
  metrics,
}: {
  metrics: { icon: string; label: string; value: string }[];
}) {
  return (
    <dl className="flex flex-wrap gap-x-9 gap-y-5">
      {metrics.map((m) => (
        <div key={m.label} className="flex items-center gap-3">
          <Icon name={m.icon} className="w-[22px] h-[22px] text-blue shrink-0" />
          <div>
            <dd className="font-display font-extrabold text-navy text-[19px] leading-tight">
              {m.value}
            </dd>
            <dt className="text-[12px] font-semibold text-muted leading-none mt-1">{m.label}</dt>
          </div>
        </div>
      ))}
    </dl>
  );
}

/**
 * The hero image stand-in.
 *
 * A built visual rather than one illustration per row: 42 careers and 263
 * specializations is not a set anyone will commission or maintain, and a
 * generic stock photo says less than the field's own vocabulary does. The
 * floating labels are real catalog entries, so the panel is data like every
 * other part of the page.
 */
export function HeroVisual({
  icon,
  labels,
}: {
  icon: string;
  labels: string[];
}) {
  return (
    <div className="relative rounded-3xl overflow-hidden bg-navy min-h-[260px] sm:min-h-[300px] p-6 flex items-center justify-center">
      <div
        aria-hidden
        className="absolute inset-0 opacity-70"
        style={{
          backgroundImage:
            "radial-gradient(circle at 78% 28%, rgba(37,99,235,0.55), transparent 55%), radial-gradient(circle at 22% 78%, rgba(124,58,237,0.5), transparent 55%)",
        }}
      />
      <div
        aria-hidden
        className="absolute inset-0 opacity-[0.18]"
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.6) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.6) 1px, transparent 1px)",
          backgroundSize: "34px 34px",
        }}
      />
      <Icon name={icon} aria-hidden className="absolute right-6 bottom-4 w-36 h-36 text-white/10" />
      <div className="relative flex flex-wrap items-center justify-center gap-2.5 max-w-[320px]">
        {labels.map((label) => (
          <span
            key={label}
            className="text-[12.5px] font-bold text-navy bg-white/95 px-3.5 py-2 rounded-xl shadow-card"
          >
            {label}
          </span>
        ))}
      </div>
    </div>
  );
}

/** Order-preserving dedupe, for unioning a list across several parents. */
export function dedupe(values: string[]): string[] {
  return [...new Set(values)];
}

export function dedupeBy<T>(values: T[], key: (v: T) => string): T[] {
  const seen = new Set<string>();
  return values.filter((v) => {
    const k = key(v);
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
}

/** "500K+" / "12,000". Openings are an order-of-magnitude claim, so anything
 *  in the thousands is rounded rather than shown to the digit. */
export function formatOpenings(n: number): string {
  if (n >= 100000) return `${Math.round(n / 100000)}L+`;
  if (n >= 1000) return `${Math.round(n / 1000)}K+`;
  return String(n);
}
