-- Turns the two invariants this schema relies on into something the database
-- itself can assert, instead of a scan somebody has to remember to run.
--
-- Background: both invariants have already been violated in production data.
--   * V58 shipped a gapped sort_order and it surfaced as a live
--     NullPointerException on /colleges/nit-patna (@OrderColumn materializes
--     nulls into the List when the sequence has holes).
--   * exam_colleges silently fell 72 rows behind college_exams (repaired in
--     V75) because the mirroring logic lives in CollegeService, while the
--     migrations that seeded the NITs, IITs and medical colleges wrote SQL
--     directly and never went through it.
--
-- The second one is the lesson: an invariant enforced in only ONE of several
-- write paths is not an invariant. This function is callable from any write
-- path, and afterMigrate.sql runs it on every single migration.
--
-- Returns zero rows when healthy, one row per problem otherwise.

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
    -- Mirrored relationships still stored as two tables. Remove a pair here
    -- when it gets collapsed to a single table (V76 did this for
    -- career_stages/stage_careers), since a collapsed relationship cannot
    -- drift by construction.
    pairs      text[][] := ARRAY[
        ARRAY['career_exams',  'career_slug',  'exam_slug', 'exam_careers',  'career_slug',  'exam_slug'],
        ARRAY['college_exams', 'college_slug', 'exam_slug', 'exam_colleges', 'college_slug', 'exam_slug']
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
        -- Convention in this schema: the owning side is the first column
        -- (exam_colleges -> exam_slug, career_exams -> career_slug).
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

COMMENT ON FUNCTION check_relationship_integrity() IS
    'Returns one row per relationship-integrity violation; zero rows means healthy. Run automatically by afterMigrate.sql.';
