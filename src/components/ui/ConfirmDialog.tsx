"use client";

import Modal from "@/components/ui/Modal";
import Button from "@/components/ui/Button";

/**
 * A `Modal` specialized for "are you sure?" confirmations -- replaces the
 * browser's native `window.confirm(...)`, which is unstyled, blocks the
 * whole tab, and can't be disabled while an async action (the delete
 * request) is in flight. See `AdminResourceList`/`AdminCounsellingInbox` for
 * the call sites this replaced.
 */
export default function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = "Delete",
  busy = false,
  onConfirm,
  onCancel,
}: {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  busy?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal open={open} onClose={onCancel} title={title}>
      <p className="text-[13.5px] text-muted mb-6">{message}</p>
      <div className="flex justify-end gap-3">
        <Button variant="secondary" onClick={onCancel} disabled={busy}>
          Cancel
        </Button>
        <Button variant="danger" onClick={onConfirm} disabled={busy}>
          {busy ? "Deleting..." : confirmLabel}
        </Button>
      </div>
    </Modal>
  );
}
