-- Reverts V89's changes to career_degrees and college_degrees.
--
-- V89 gave three link tables a subject_slug, and gave these two a surrogate
-- `id` in place of their composite primary key. The key change was necessary
-- at the time: the natural key would have become (career, degree, subject),
-- subject is nullable, and a nullable column cannot sit in a PRIMARY KEY.
--
-- That was built for a Career -> (Degree, Subject) model that was then
-- deliberately dropped. Subject stays a separate source of truth, but a
-- career links to degrees exactly as before -- "M.Sc (Physics)" is not
-- something a career says. Subject belongs only where a qualification rule
-- names one, which is exam_career_degrees.
--
-- So on these two tables the surrogate key now buys nothing and costs
-- clarity: every other join table in this schema is keyed by its natural
-- columns, and a reader finding a lone `id` here would reasonably assume it
-- exists for a reason. It does not, any more.
--
-- Safe because all three subject_slug columns are still entirely NULL --
-- nothing ever wrote one, verified before writing this and re-asserted
-- below. No data is lost; this is a shape change only.
--
-- exam_career_degrees KEEPS its subject_slug. That is the one place a
-- subject is meant to appear, it is nullable and unused today, and it never
-- needed a key change because subject is a plain attribute there rather than
-- part of the key (V89's header explains that asymmetry).
--
-- `subjects` itself is untouched: 34 rows, the Subject entity, its DTO,
-- service and controllers all stay. The table currently has no consumer,
-- which is a known and accepted state -- it is a prerequisite for structured
-- qualification rules, not a feature on its own.
--
-- Dropping `id` drops the primary key with it, so the composite key is
-- recreated afterwards. The COALESCE unique index is dropped too: with
-- subject_slug gone it would be exactly the composite key, stated twice.

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM career_degrees WHERE subject_slug IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees has % row(s) with a subject -- dropping the column would lose data', bad;
    END IF;

    SELECT count(*) INTO bad FROM college_degrees WHERE subject_slug IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'college_degrees has % row(s) with a subject -- dropping the column would lose data', bad;
    END IF;
END $$;

-- Row counts captured before the shape change and compared after, rather
-- than asserted against literals -- a DROP COLUMN should never move them, and
-- a derived check keeps saying so no matter how the data grows first.
CREATE TEMP TABLE v96_before ON COMMIT DROP AS
SELECT (SELECT count(*) FROM career_degrees)  AS career_degrees,
       (SELECT count(*) FROM college_degrees) AS college_degrees;

-- ---------------------------------------------------------- career_degrees
DROP INDEX IF EXISTS uq_career_degrees_natural;
DROP INDEX IF EXISTS idx_career_degrees_career;

ALTER TABLE career_degrees DROP COLUMN subject_slug;
ALTER TABLE career_degrees DROP COLUMN id;
ALTER TABLE career_degrees ADD PRIMARY KEY (career_slug, degree_slug);

-- --------------------------------------------------------- college_degrees
DROP INDEX IF EXISTS uq_college_degrees_natural;
DROP INDEX IF EXISTS idx_college_degrees_college;

ALTER TABLE college_degrees DROP COLUMN subject_slug;
ALTER TABLE college_degrees DROP COLUMN id;
ALTER TABLE college_degrees ADD PRIMARY KEY (college_slug, degree_slug);

DO $$
DECLARE bad int;
BEGIN
    -- The composite key must be back on both, or a duplicate (career, degree)
    -- pair could be inserted -- which @OrderColumn would then render twice.
    SELECT count(*) INTO bad FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND constraint_type = 'PRIMARY KEY'
      AND table_name IN ('career_degrees', 'college_degrees');
    IF bad <> 2 THEN
        RAISE EXCEPTION 'expected a primary key on both tables, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM information_schema.columns
    WHERE table_schema = 'public'
      AND column_name IN ('id', 'subject_slug')
      AND table_name IN ('career_degrees', 'college_degrees');
    IF bad > 0 THEN
        RAISE EXCEPTION '% leftover column(s) on the reverted tables', bad;
    END IF;

    -- exam_career_degrees must NOT have been caught by the revert.
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'exam_career_degrees'
          AND column_name = 'subject_slug') THEN
        RAISE EXCEPTION 'exam_career_degrees lost its subject_slug -- it should have been kept';
    END IF;

    -- Nothing may have been dropped along with the columns.
    SELECT count(*) INTO bad FROM career_degrees;
    IF bad <> (SELECT career_degrees FROM v96_before) THEN
        RAISE EXCEPTION 'career_degrees row count changed: was %, now %',
            (SELECT career_degrees FROM v96_before), bad;
    END IF;

    SELECT count(*) INTO bad FROM college_degrees;
    IF bad <> (SELECT college_degrees FROM v96_before) THEN
        RAISE EXCEPTION 'college_degrees row count changed: was %, now %',
            (SELECT college_degrees FROM v96_before), bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
