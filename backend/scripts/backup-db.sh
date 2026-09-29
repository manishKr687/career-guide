#!/usr/bin/env bash
# Dumps the CareerGuide Postgres database (running via docker compose) to a
# timestamped .sql file in backend/backups/.
#
# Usage (from the backend/ folder):
#   ./scripts/backup-db.sh
#   ./scripts/backup-db.sh before-schema-change   # optional label
#
# See backup-db.ps1 for the Windows/PowerShell equivalent and the "Backups"
# section of README.md for what this does and doesn't protect against.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
LABEL="${1:-}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SUFFIX=""
if [ -n "$LABEL" ]; then
  SUFFIX="_$LABEL"
fi
FILENAME="careerguide_${TIMESTAMP}${SUFFIX}.sql"

cd "$BACKEND_DIR"
docker compose exec postgres sh -c "pg_dump -U careerguide -d careerguide --clean --if-exists > /backups/$FILENAME"

# A backup nobody checks is a guess. The redirection above happens inside the
# container, so if pg_dump dies part way through -- disk full, the container
# stopped, a connection dropped -- a truncated file is left behind that looks
# exactly like a good one until the day it is needed. pg_dump writes this
# marker as its last act, so its presence separates a complete dump from a
# partial one.
BACKUP_PATH="$BACKEND_DIR/backups/$FILENAME"
if [ ! -f "$BACKUP_PATH" ]; then
  echo "pg_dump reported success but no file appeared at $BACKUP_PATH." >&2
  exit 1
fi
if ! grep -q '^-- PostgreSQL database dump complete' "$BACKUP_PATH"; then
  SIZE="$(wc -c < "$BACKUP_PATH")"
  rm -f "$BACKUP_PATH"
  echo "Backup was incomplete ($SIZE bytes, no completion marker) and has been deleted." >&2
  echo "Nothing was kept, so this is a failure rather than a bad backup you might later trust." >&2
  exit 1
fi

echo "Backup written to backend/backups/$FILENAME ($(( $(wc -c < "$BACKUP_PATH") / 1024 )) KB, verified complete)"

# Optional pruning, off unless KEEP_DAYS is set:
#   KEEP_DAYS=30 ./scripts/backup-db.sh
# Only unlabelled backups are pruned. A labelled one -- "before-schema-change"
# -- was taken deliberately at a moment someone thought mattered, and an
# automatic cleanup quietly deleting it is exactly the backup you would want back.
if [ -n "${KEEP_DAYS:-}" ] && [ "${KEEP_DAYS}" -gt 0 ] 2>/dev/null; then
  find "$BACKEND_DIR/backups" -maxdepth 1 -type f \
    -regex '.*/careerguide_[0-9]\{8\}_[0-9]\{6\}\.sql' \
    -mtime "+${KEEP_DAYS}" -print -delete | sed 's|.*/|  pruned |'
fi
