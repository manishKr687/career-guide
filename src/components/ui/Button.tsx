import Link from "next/link";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary" | "danger" | "ghost";

const VARIANT_STYLES: Record<Variant, string> = {
  primary: "bg-navy text-white hover:bg-navy-2",
  secondary: "text-navy border border-line hover:border-navy/30",
  danger: "text-red border border-red/30 hover:bg-red-soft",
  ghost: "text-ink/70 hover:text-navy",
};

const BASE =
  "inline-flex items-center justify-center gap-2 text-[13.5px] font-bold px-4 py-2.5 rounded-lg transition-colors disabled:opacity-50 disabled:pointer-events-none";

type CommonProps = {
  variant?: Variant;
  className?: string;
  children: React.ReactNode;
};

/**
 * The `Button` primitive from the UI architecture doc's design-system
 * section. Renders a real `<Link>` when `href` is given (so it works for
 * both a CTA that navigates and one that submits/click-handles), sharing one
 * consistent set of variant styles either way instead of every page hand-
 * styling its own `<Link>`/`<button>` (see e.g. `Navbar`'s "Take Career
 * Test" CTA, or the buttons on the `not-found`/`error` pages).
 */
export default function Button(
  props: CommonProps &
    (
      | ({ href: string } & Omit<React.ComponentProps<typeof Link>, "href" | "className">)
      | ({ href?: undefined } & Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "className">)
    )
) {
  const { variant = "primary", className, children, ...rest } = props;
  const classes = cn(BASE, VARIANT_STYLES[variant], className);

  if ("href" in rest && rest.href !== undefined) {
    const { href, ...linkProps } = rest as { href: string } & Omit<
      React.ComponentProps<typeof Link>,
      "href" | "className"
    >;
    return (
      <Link href={href} className={classes} {...linkProps}>
        {children}
      </Link>
    );
  }

  const buttonProps = rest as Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "className">;
  return (
    <button type="button" className={classes} {...buttonProps}>
      {children}
    </button>
  );
}
