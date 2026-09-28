-- Step 1 of 2: stop using exam_colleges. Exam.relatedColleges becomes the
-- inverse side of College.exams (mappedBy = "exams") in this same change, so
-- both directions now read the single table college_exams. V79 drops the
-- now-unused table, once this state has been verified running.
--
-- Why collapse rather than keep repairing: exam_colleges never had a
-- maintainer. CollegeService.applyRequest writes college_exams and nothing
-- else; ExamUpsertRequest has no collegeSlugs field, so the Exam admin form
-- cannot write colleges either. The table was seeded with 20 rows by V38 and
-- then left to rot -- by V75 it was 72 rows behind. Backfilling it (V75) made
-- the API correct, but the next migration that touched college_exams would
-- have started the drift over again.
--
-- Nothing is lost by reading from college_exams instead: V75 reconciled the
-- two, and afterMigrate.sql has asserted on every boot since that they hold
-- exactly the same pairs.
--
-- The mirror-pair check is updated here too, in the same migration. It has
-- to be: once Exam.relatedColleges stops writing exam_colleges, that table
-- stays frozen while college_exams keeps growing, so leaving the pair in the
-- list would fail startup over a table the application no longer uses.
--
-- Only the `pairs` array changes below. The rest is V77's function verbatim,
-- restated because CREATE OR REPLACE FUNCTION takes the whole definition.

CREATE OR REPLACE FUNCTION check_relationship_integrity()
RETURNS TABLE(kind text, subject text, detail text)
LANGUAGE plpgsql
AS $fn$
DECLARE
    r          record;
    owner_col  text;
    bad        int;
    p          text[];
    only_a     int;
    only_b     int;
    -- college_exams/exam_colleges removed in V78 (collapsed onto
    -- college_exams); career_stages/stage_careers was removed in V76. One
    -- mirrored pair left -- career_exams/exam_careers, which is harder to
    -- collapse because BOTH orderings are genuinely used.
    pairs      text[][] := ARRAY[
        ARRAY['career_exams', 'career_slug', 'exam_slug', 'exam_careers', 'career_slug', 'exam_slug']
    ];
BEGIN
    -- 1. sort_order density, for every @OrderColumn-backed join table.
    --
    -- Join tables are identified as: has a sort_order column, has two or
    -- more *_slug columns, and has NO bare `slug` column. That last clause
    -- excludes entity tables -- careers carries category_slug + branch_slug
    -- and would otherwise be scanned, but its sort_order is a global display
    -- order with no per-group density rule.
    FOR r IN
        SELECT c.table_name
        FROM information_schema.columns c
        WHERE c.table_schema = 'public'
          AND c.column_name = 'sort_order'
          AND (
              SELECT count(*) FROM information_schema.columns c2
              WHERE c2.table_schema = 'public'
                AND c2.table_name = c.table_name
                AND c2.column_name LIKE '%\_slug'
          ) >= 2
          AND NOT EXISTS (
              SELECT 1 FROM information_schema.columns c3
              WHERE c3.table_schema = 'public'
                AND c3.table_name = c.table_name
                AND c3.column_name = 'slug'
          )
        ORDER BY c.table_name
    LOOP
        SELECT column_name INTO owner_col
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = r.table_name
          AND column_name <> 'sort_order'
        ORDER BY ordinal_position
        LIMIT 1;

        EXECUTE format(
            'SELECT count(*) FROM (SELECT %I FROM %I GROUP BY %I '
            'HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1) x',
            owner_col, r.table_name, owner_col
        ) INTO bad;

        IF bad > 0 THEN
            kind    := 'gapped_sort_order';
            subject := r.table_name;
            detail  := format('%s group(s) not dense 0..n-1, grouped by %s', bad, owner_col);
            RETURN NEXT;
        END IF;
    END LOOP;

    -- 2. Mirror-table agreement.
    FOREACH p SLICE 1 IN ARRAY pairs
    LOOP
        EXECUTE format(
            'SELECT count(*) FROM (SELECT %I, %I FROM %I EXCEPT SELECT %I, %I FROM %I) x',
            p[2], p[3], p[1], p[5], p[6], p[4]
        ) INTO only_a;

        EXECUTE format(
            'SELECT count(*) FROM (SELECT %I, %I FROM %I EXCEPT SELECT %I, %I FROM %I) x',
            p[5], p[6], p[4], p[2], p[3], p[1]
        ) INTO only_b;

        IF only_a > 0 OR only_b > 0 THEN
            kind    := 'mirror_drift';
            subject := format('%s <-> %s', p[1], p[4]);
            detail  := format('%s row(s) only in %s, %s row(s) only in %s',
                              only_a, p[1], only_b, p[4]);
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$fn$;
