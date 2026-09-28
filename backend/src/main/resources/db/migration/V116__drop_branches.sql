-- Removes Branch, an abandoned grouping layer between Category and Career.
--
-- V23 introduced `branches` as a sub-division of one category: twelve rows,
-- all under engineering-technology, e.g. "Computing & IT". It assigned them
-- to 13 careers by slug -- mechanical-engineer, civil-engineer,
-- computer-science-engineer and so on.
--
-- Every one of those career slugs was later deleted and replaced by a
-- differently-slugged career (mechanical-engineer -> mechanical-engineering),
-- and the branch assignments were never redone. No migration ever cleared
-- careers.branch_slug; the rows holding the values simply went away. The
-- state at the time of this migration:
--
--     branches: 12     careers: 42     careers with a branch: 0
--
-- So this drops a table nothing references and a column nothing populates.
--
-- WHY REMOVE RATHER THAN RE-SEED. The layer is redundant on both sides.
-- `categories` already groups careers coarsely (20 of them, every career
-- filed under one), and `specializations` groups them finely (263 rows, with
-- their own pages and relationships). Branch sat between the two covering
-- 1 of the 20 categories, had no admin form field -- so it could only ever be
-- populated by hand-written SQL -- and rendered nowhere the reader could see,
-- since the career page's branch tag is skipped when branch_slug is null.
--
-- This is deliberately destructive and not reversible under a forward-only
-- migration history. It is safe here only because the affected data is
-- provably empty; the assertion below re-checks that rather than trusting
-- this comment, so if some later migration populates branch_slug before this
-- one runs on another database, it fails instead of silently discarding work.

DO $$
DECLARE assigned int;
BEGIN
    SELECT count(branch_slug) INTO assigned FROM careers;
    IF assigned > 0 THEN
        RAISE EXCEPTION
            'refusing to drop branches: % career(s) still reference one', assigned;
    END IF;
END $$;

-- The FK lives on careers, so the column goes first and `branches` is then
-- unreferenced.
ALTER TABLE careers DROP COLUMN branch_slug;
DROP TABLE branches;

DO $$
DECLARE leftover int;
BEGIN
    SELECT count(*) INTO leftover FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'branches';
    IF leftover <> 0 THEN
        RAISE EXCEPTION 'branches table still present';
    END IF;

    SELECT count(*) INTO leftover FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'careers' AND column_name = 'branch_slug';
    IF leftover <> 0 THEN
        RAISE EXCEPTION 'careers.branch_slug still present';
    END IF;
END $$;
