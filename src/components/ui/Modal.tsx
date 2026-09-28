"use client";

import { useEffect, useRef } from "react";
import { createPortal } from "react-dom";
import Icon from "@/components/ui/Icon";

/**
 * The `Modal` primitive from the UI architecture doc's design-system
 * section. Closes on Escape or a backdrop click, moves focus to the panel
 * on open, and is rendered via a portal so it always sits above the rest of
 * the page regardless of where it's mounted in the tree. No focus-trap
 * library -- Escape + backdrop-click covers the common case without a new
 * dependency; revisit if a real accessibility audit calls for a full trap.
 */
export default function Modal({
  open,
  onClose,
  title,
  children,
}: {
  open: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}) {
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    panelRef.current?.focus();
    function onKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, [open, onClose]);

  if (!open || typeof document === "undefined") return null;

  return createPortal(
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-navy/40 backdrop-blur-[2px]"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        tabIndex={-1}
        className="relative bg-white rounded-2xl shadow-card w-full max-w-md p-6 outline-none"
      >
        <div className="flex items-start justify-between mb-4">
          <h2 id="modal-title" className="font-display font-bold text-navy text-[17px]">
            {title}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="Close"
            className="w-8 h-8 -mt-1 -mr-1 flex items-center justify-center text-subtle hover:text-navy transition-colors"
          >
            <Icon name="close" className="w-5 h-5" />
          </button>
        </div>
        {children}
      </div>
    </div>,
    document.body
  );
}
