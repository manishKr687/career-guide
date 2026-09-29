#!/usr/bin/env bash
#
# Loads a content export produced by export-content.sh into a database.
#
# IT REFUSES TO RUN IF THE TARGET HAS USERS, and that is the whole point of the
# script rather than an inconvenience.
#
# Replacing the catalog means clearing the catalog tables first, and
# user_saved_careers, user_saved_colleges, user_saved_exams and user_roadmaps all
# carry ON DELETE CASCADE onto the content they point at. So on a database with
# real people on it, this would not merely replace the catalog -- it would delete
# every saved career and every roadmap step along the way, silently, because a
# cascade reports nothing.
#
# That makes this safe for exactly one job: the FIRST load into a new
# environment, before anyone has signed up. Which is what you need to go live.
#
# Once production has users, pushing content needs a different mechanism -- an
# upsert that updates rows in place and leaves foreign keys intact, rather than a
# replace. This script does not pretend to be that, and the refusal below is what
# stops it being used as though it were.
#
# Usage:
#   ./import-content.sh backups/content-20260929-1430.sql
#   TARGET_HOST=prod.example TARGET_DB=careerguide ./import-content.sh file.sql
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: ./import-content.sh <content-export.sql>" >&2
  exit 1
fi

CONTAINER="${CONTAINER:-careerguide-postgres}"
DB="${DB:-careerguide}"
DB_USER="${DB_USER:-careerguide}"

psql_t() { docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB" -t -A "$@"; }

# --- The guard -------------------------------------------------------------

USER_ROWS=$(psql_t -c "SELECT count(*) FROM users;" 2>/dev/null || echo "ERR")
REQ_ROWS=$(psql_t -c "SELECT count(*) FROM counselling_requests;" 2>/dev/null || echo "ERR")

if [ "$USER_ROWS" = "ERR" ]; then
  echo "Could not reach the target database. Is it running?" >&2
  exit 1
fi

if [ "$USER_ROWS" != "0" ] || [ "$REQ_ROWS" != "0" ]; then
  cat >&2 <<EOF

REFUSING TO IMPORT.

  users:                $USER_ROWS
  counselling requests: $REQ_ROWS

This target has real data on it. Replacing the catalog here would cascade
through user_saved_careers, user_saved_colleges, user_saved_exams and
user_roadmaps, deleting people's saved items and roadmaps without reporting it.

This script only loads content into an empty environment. To update the catalog
on a live site you need an upsert-based sync, which is a different tool.

If you are certain -- for example restoring a staging copy you do not mind
losing -- take a backup first and re-run with:

  ALLOW_DESTRUCTIVE=1 ./import-content.sh $FILE

EOF
  [ "${ALLOW_DESTRUCTIVE:-}" = "1" ] || exit 1
  echo "ALLOW_DESTRUCTIVE=1 set -- proceeding anyway." >&2
fi

# --- The load --------------------------------------------------------------

# The content tables, derived the same way the export derives them so the two
# cannot drift apart.
TABLES=$(psql_t -c "
  SELECT string_agg(format('%I', tablename), ', ' ORDER BY tablename)
  FROM pg_tables
  WHERE schemaname = 'public'
    AND NOT (tablename = 'flyway_schema_history'
             OR tablename = 'counselling_requests'
             OR tablename = 'users'
             OR tablename LIKE 'user\\_%');")

echo "Clearing and reloading the catalog..."

# One transaction: a failure part-way leaves the catalog as it was rather than
# half-replaced. TRUNCATE ... CASCADE is what makes the guard above necessary.
{
  echo "BEGIN;"
  echo "TRUNCATE TABLE $TABLES CASCADE;"
  cat "$FILE"
  echo "COMMIT;"
} | docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB" -v ON_ERROR_STOP=1 -q

echo
echo "Done. Verifying:"
psql_t -c "
  SELECT 'careers: ' || (SELECT count(*) FROM careers)
      || ', exams: ' || (SELECT count(*) FROM exams)
      || ', colleges: ' || (SELECT count(*) FROM colleges)
      || ', specializations: ' || (SELECT count(*) FROM specializations);"

# The same check the application runs on every boot. If the import left the
# catalog inconsistent, better to hear it now than from a failed deploy.
echo "Relationship integrity:"
psql_t -c "SELECT severity || ': ' || kind || ' ' || subject FROM check_relationship_integrity();" \
  || echo "  (check_relationship_integrity not present -- run the migrations first)"
