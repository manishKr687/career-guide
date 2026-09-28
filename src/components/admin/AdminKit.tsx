"use client";

import { useEffect } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";

/**
 * The shared furniture of the admin screens.
 *
 * Extracted for the same reason as DetailKit and ListingKit on the public side:
 * the list, the forms and the dashboard had each grown their own button classes,
 * their own idea of a card, and three different ways of saying "nothing here".
 * A panel gaining a tighter gutter in one place and not the others is how an
 * admin starts to feel assembled rather than designed.
 *
 * The tokens below are the whole design language, and they are deliberately few:
 * one primary colour, one surface, one focus ring, one transition.
 */

/** Blue for primary actions, navy for the chrome. The sidebar is navy, so a navy
 *  primary button disappears into it; blue is the only accent that reads as
 *  "this is the action" against both the rail and a white panel. */
export const BTN_PRIMARY =
  "inline-flex items-center justify-center gap-2 text-[13px] font-bold text-white bg-blue px-4 py-2.5 rounded-xl " +
  "hover:bg-blue/90 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue/40 " +
  "focus-visible:ring-offset-2 transition-all disabled:opacity-50 disabled:pointer-events-none";

export const BTN_SECONDARY =
  "inline-flex items-center justify-center gap-2 text-[13px] font-bold text-navy bg-white px-4 py-2.5 rounded-xl " +
  "border border-line hover:border-navy/30 hover:bg-bg-soft active:scale-[0.98] focus-visible:outline-none " +
  "focus-visible:ring-2 focus-visible:ring-navy/20 focus-visible:ring-offset-2 transition-all " +
  "disabled:opacity-50 disabled:pointer-events-none";

/** Surface for every panel: one border, one radius, one shadow. */
export const SURFACE = "bg-white rounded-2xl border border-line";

type IconTone = "neutral" | "primary" | "danger";

const ICON_TONES: Record<IconTone, string> = {
  neutral: "text-muted hover:text-navy hover:border-navy/30 focus-visible:ring-navy/20",
  primary: "text-blue hover:border-blue/40 hover:bg-blue-soft focus-visible:ring-blue/40",
  danger: "text-red hover:border-red/40 hover:bg-red-soft focus-visible:ring-red/30",
};

/**
 * A square action button for table rows.
 *
 * `title` and `aria-label` are both required rather than optional: the control
 * is an icon with no text, so without them it is unusable with a screen reader
 * and ambiguous with a mouse. Making them part of the type means a new action
 * cannot be added without them.
 */
export function IconButton({
  icon,
  label,
  tone = "neutral",
  href,
  onClick,
  disabled,
}: {
  icon: string;
  label: string;
  tone?: IconTone;
  href?: string;
  onClick?: () => void;
  disabled?: boolean;
}) {
  const classes =
    "w-8 h-8 rounded-lg border border-line bg-white flex items-center justify-center transition-all " +
    "active:scale-90 focus-visible:outline-none focus-visible:ring-2 disabled:opacity-40 " +
    "disabled:pointer-events-none " +
    ICON_TONES[tone];

  if (href) {
    return (
      <Link href={href} title={label} aria-label={label} className={classes}>
        <Icon name={icon} className="w-4 h-4" />
      </Link>
    );
  }
  return (
    <button type="button" onClick={onClick} disabled={disabled} title={label} aria-label={label} className={classes}>
      <Icon name={icon} className="w-4 h-4" />
    </button>
  );
}

/** Title, one line of context, and the page's single primary action. */
export function PageHeader({
  title,
  subtitle,
  action,
}: {
  title: string;
  subtitle?: string;
  action?: { href: string; label: string };
}) {
  return (
    <div className="flex flex-wrap items-start justify-between gap-4 mb-5">
      <div className="min-w-0">
        <h2 className="font-display font-extrabold text-navy text-[22px] leading-tight">{title}</h2>
        {subtitle && <p className="text-[13px] text-muted mt-1">{subtitle}</p>}
      </div>
      {action && (
        <Link href={action.href} className={`${BTN_PRIMARY} shrink-0`}>
          <span className="text-[15px] leading-none -mt-px">+</span>
          {action.label}
        </Link>
      )}
    </div>
  );
}

/**
 * Shown when a table has nothing in it -- and it distinguishes the two reasons,
 * because they need different things from the reader. An empty resource wants
 * the create action; a search that matched nothing wants the search cleared, and
 * offering "create" there would be answering a question nobody asked.
 */
export function EmptyState({
  icon = "search",
  title,
  message,
  action,
}: {
  icon?: string;
  title: string;
  message: string;
  action?: { label: string; onClick: () => void } | { label: string; href: string };
}) {
  return (
    <div className="px-6 py-14 flex flex-col items-center text-center">
      <span className="w-12 h-12 rounded-2xl bg-bg-soft text-subtle flex items-center justify-center mb-4">
        <Icon name={icon} className="w-6 h-6" />
      </span>
      <p className="font-display font-bold text-navy text-[15px]">{title}</p>
      <p className="text-[13px] text-muted mt-1.5 max-w-sm">{message}</p>
      {action && (
        <div className="mt-5">
          {"href" in action ? (
            <Link href={action.href} className={BTN_SECONDARY}>
              {action.label}
            </Link>
          ) : (
            <button type="button" onClick={action.onClick} className={BTN_SECONDARY}>
              {action.label}
            </button>
          )}
        </div>
      )}
    </div>
  );
}

export type ToastTone = "success" | "error";

/**
 * Replaces the red paragraph that used to sit above the table.
 *
 * Inline text has two problems on these screens: after saving, the reader's
 * attention is on the dialog or the row they just changed, not the top of the
 * page -- and a failure that appears somewhere they are not looking reads as
 * nothing happening at all. Errors do not auto-dismiss; a message you can miss
 * is worse than one you have to close.
 */
export function Toast({
  tone,
  message,
  onClose,
}: {
  tone: ToastTone;
  message: string;
  onClose: () => void;
}) {
  useEffect(() => {
    if (tone === "error") return;
    const timer = setTimeout(onClose, 4000);
    return () => clearTimeout(timer);
  }, [tone, onClose]);

  const isError = tone === "error";
  return (
    <div
      role="status"
      aria-live="polite"
      className={`fixed bottom-5 right-5 z-[120] max-w-sm flex items-start gap-3 rounded-2xl border px-4 py-3.5 shadow-card animate-slide-in ${
        isError ? "bg-white border-red/30" : "bg-white border-green/30"
      }`}
    >
      <span
        className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 ${
          isError ? "bg-red-soft text-red" : "bg-green-soft text-green"
        }`}
      >
        <Icon name={isError ? "shield" : "check"} className="w-4 h-4" />
      </span>
      <p className="text-[13px] text-ink leading-snug flex-1 pt-1">{message}</p>
      <button
        type="button"
        onClick={onClose}
        aria-label="Dismiss"
        className="w-6 h-6 rounded-md text-subtle hover:text-navy hover:bg-bg-soft flex items-center justify-center shrink-0 transition-colors"
      >
        <Icon name="close" className="w-3.5 h-3.5" />
      </button>
    </div>
  );
}
