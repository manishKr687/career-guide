#!/usr/bin/env bash
# Restores the CareerGuide Postgres database from a .sql file previously
# created by backup-db.sh (or backup-db.ps1). This OVERWRITES the current
# database contents.
#
# Usage (from the backend/ folder):
#   ./scripts/restore-db.sh careerguide_20260917_120000.sql
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
FILE="${1:?Usage: restore-db.sh <filename-in-backend/backups>}"

if [ ! -f "$BACKEND_DIR/backups/$FILE" ]; then
  echo "Backup file not found: $BACKEND_DIR/backups/$FILE" >&2
  exit 1
fi

echo "This will overwrite the current careerguide database with the contents of $FILE."
read -r -p "Type 'yes' to continue: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

cd "$BACKEND_DIR"
docker compose exec postgres sh -c "psql -U careerguide -d careerguide -f /backups/$FILE"
echo "Restored from backend/backups/$FILE"
