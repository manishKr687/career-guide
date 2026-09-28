-- Ad-hoc relationship integrity check.
--
--   docker compose exec -T postgres psql -U careerguide -d careerguide \
--     -f /dev/stdin < scripts/check-relationship-integrity.sql
--
-- The logic itself lives in the check_relationship_integrity() function
-- (created in V77) so that this script and the afterMigrate callback can
-- never disagree about what "healthy" means. afterMigrate.sql already runs
-- the same function on every boot and fails startup on a violation, so this
-- script is only for looking at the current state by hand -- for instance
-- after editing data directly in psql, which bypasses both Flyway and the
-- service layer.
--
-- Zero rows returned = healthy.

-- Errors first: those fail startup, warnings only get logged (V93).

SELECT severity, kind, subject, detail
FROM check_relationship_integrity()
ORDER BY severity, kind, subject;

\echo ''
\echo '(zero rows above = healthy; error = fails boot, warn = logged only)'
