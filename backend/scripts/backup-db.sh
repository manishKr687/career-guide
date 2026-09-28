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
echo "Backup written to backend/backups/$FILENAME"
