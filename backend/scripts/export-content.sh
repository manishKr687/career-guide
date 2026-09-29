#!/usr/bin/env bash
#
# Exports the CATALOG from this database -- the content you author in the admin,
# and nothing that a visitor created.
#
# This exists because the local Postgres is the source of truth for content. The
# migrations seeded it and remain the source of truth for SCHEMA, but from
# go-live onward the catalog is edited in the admin, not in SQL. That makes a
# repeatable content export the thing that gets your work to production.
#
# WHAT IT DELIBERATELY LEAVES OUT: users, the eleven user_* tables, and
# counselling_requests. Those are created by real people on the live site and
# exist nowhere else -- if they were in this file, importing it would overwrite
# them. flyway_schema_history is excluded too: it describes the schema the
# TARGET has applied, and importing one database's history into another is how
# you get a Flyway checksum failure on the next deploy.
#
# The table list is derived, not hard-coded, so a table added later is included
# automatically rather than silently missed.
#
# Usage:
#   ./export-content.sh                   -> backups/content-YYYYMMDD-HHMM.sql
#   ./export-content.sh my-content.sql
set -euo pipefail

CONTAINER="${CONTAINER:-careerguide-postgres}"
DB="${DB:-careerguide}"
DB_USER="${DB_USER:-careerguide}"

OUT="${1:-backups/content-$(date +%Y%m%d-%H%M).sql}"
mkdir -p "$(dirname "$OUT")"

# Everything that is not user-generated and not Flyway's own bookkeeping.
EXCLUDE_SQL="
  tablename = 'flyway_schema_history'
  OR tablename = 'counselling_requests'
  OR tablename = 'users'
  OR tablename LIKE 'user\\_%'
"

TABLES=$(docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB" -t -A -c "
  SELECT tablename FROM pg_tables
  WHERE schemaname = 'public' AND NOT ($EXCLUDE_SQL)
  ORDER BY tablename;")

if [ -z "$TABLES" ]; then
  echo "No content tables found -- is the database up?" >&2
  exit 1
fi

ARGS=()
while IFS= read -r t; do
  [ -n "$t" ] && ARGS+=(--table="public.$t")
done <<< "$TABLES"

echo "Exporting $(echo "$TABLES" | grep -c .) content tables..."

# --data-only because the target's schema comes from Flyway, not from here.
# --column-inserts so the file survives a column being added later: a COPY block
# is positional and breaks the moment the two schemas differ by one column.
docker exec "$CONTAINER" pg_dump -U "$DB_USER" -d "$DB" \
  --data-only --column-inserts --no-owner --no-privileges \
  "${ARGS[@]}" > "$OUT"

echo "Wrote $OUT ($(wc -l < "$OUT") lines)"
echo
echo "Import it with: ./import-content.sh $OUT"
