-- Flyway callback: runs after every successful migrate, on every boot.
--
-- This is the enforcement half of the pair of invariants described in V77.
-- Both had already been violated silently -- a gapped sort_order shipped in
-- V58 and surfaced as a live NullPointerException, and exam_colleges drifted
-- 72 rows behind college_exams across roughly ten migrations before anyone
-- noticed. In both cases the data was wrong the moment the migration ran;
-- what was missing was anything that said so.
--
-- Raising here means a migration that breaks either invariant fails the
-- container startup that applied it, so the author sees it immediately
-- rather than months later via a broken page. That is deliberately strict:
-- the alternative, a NOTICE, is what we effectively had already, and notices
-- get lost in logs.
--
-- Not a versioned migration -- `afterMigrate` is a reserved Flyway callback
-- name, so this file is never applied as V-anything and has no checksum. It
-- is safe to edit, unlike the V* files.

-- V93 graded violations error/warn. Errors still fail startup as before;
-- warnings are printed on every boot but do not block, because they describe
-- pre-existing data problems rather than something the current migration
-- broke. A warning is a staging state -- once its data is fixed the check
-- should be promoted to `error` in check_relationship_integrity(), not left
-- to scroll past forever.

DO $$
DECLARE
    n_err  int;
    n_warn int;
    errs   text;
    warns  text;
BEGIN
    SELECT count(*), string_agg(format('%s [%s] %s', kind, subject, detail), E'\n  ')
      INTO n_err, errs
      FROM check_relationship_integrity() WHERE severity = 'error';

    SELECT count(*), string_agg(format('%s [%s] %s', kind, subject, detail), E'\n  ')
      INTO n_warn, warns
      FROM check_relationship_integrity() WHERE severity = 'warn';

    IF n_warn > 0 THEN
        RAISE WARNING E'relationship integrity -- % warning(s):\n  %', n_warn, warns;
    END IF;

    IF n_err > 0 THEN
        RAISE EXCEPTION E'relationship integrity check failed -- % problem(s):\n  %', n_err, errs
            USING HINT = 'A migration wrote one side of a mirrored relationship, or broke sort_order density. See V77 and backend/scripts/check-relationship-integrity.sql.';
    END IF;

    IF n_warn = 0 THEN
        RAISE NOTICE 'relationship integrity: OK';
    ELSE
        RAISE NOTICE 'relationship integrity: no errors (% warning(s) above)', n_warn;
    END IF;
END $$;
