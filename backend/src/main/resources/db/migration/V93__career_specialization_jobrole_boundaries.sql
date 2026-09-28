-- Makes the Career / Specialization / JobRole boundaries checkable.
--
-- The three concepts are real and the data respects them, but only by
-- convention -- nothing in the schema says what distinguishes them:
--
--   Career          a field of work you enter        42 rows
--   Specialization  a sub-field within a career     265 rows
--   JobRole         a title you are hired into      255 rows
--
-- Held consistently across all 562 rows by naming alone: fields are gerunds
-- ("Aerospace Engineering"), roles are agent nouns ("Aerospace Engineer").
-- Zero violations today, and zero enforcement -- which is the same shape as
-- every other problem V75-V77 had to clean up after.
--
-- THE SEVERITY COLUMN
--
-- The function previously returned only conditions that must never occur, and
-- afterMigrate.sql raises on any row. The checks added here describe real but
-- pre-existing problems (25 containment violations, 2 concept collisions), so
-- adding them as hard errors would fail the very boot that installs them.
--
-- So violations are now graded:
--
--   error  must never happen; fails startup (gapped_sort_order, mirror_drift)
--   warn   real problem, reported on every boot, does not block
--
-- `warn` is a staging state, not a parking space. Each one below should be
-- promoted to `error` once its data is fixed -- that is the whole point of
-- grading rather than just leaving the check out.
--
-- Return type changes, so this DROPs rather than REPLACEs.
--
-- --------------------------------------------------------------------------
-- CHECK 3: jobrole_not_in_career
--
-- There are two paths from Career to JobRole and they disagree:
--
--   direct    career_job_roles                                  279 rows
--   indirect  career_specializations -> specialization_job_roles 225 pairs
--
--   both agree      200
--   direct only      79   career offers a role no specialization of it does
--   indirect only    25   <- the violation
--
-- 79 direct-only pairs are legitimate: a career can offer generalist roles
-- that belong to no single specialization. So career_job_roles is a SUPERSET
-- of the indirect path, not a cache of it. The 25 the other way are bugs --
-- a specialization offers a job role that its own career does not list, so
-- the role is invisible on the career page while being reachable from a
-- child of it.
--
-- CHECK 4: concept_collision
--
-- Two names exist as both a Career and a Specialization:
--   industrial-engineering     career, and a specialization of Mechanical
--   environmental-engineering  career, and a specialization of Civil
-- Same slug, same name, two tables. Needs an editorial decision per row.
--
-- CHECK 5: naming_convention
--
-- Deliberately crude, and `warn` for that reason: a gerund job role or an
-- agent-noun career is nearly always a concept filed in the wrong table.
-- False positives are possible ("Polymer" would trip the -er rule) -- that is
-- acceptable for a warning whose job is to make a silent convention visible.

DROP FUNCTION IF EXISTS check_relationship_integrity();

CREATE FUNCTION check_relationship_integrity()
RETURNS TABLE(severity text, kind text, subject text, detail text)
LANGUAGE plpgsql
AS $fn$
DECLARE
    r          record;
    owner_col  text;
    bad        int;
    p          text[];
    only_a     int;
    only_b     int;
    sample     text;
    -- college_exams/exam_colleges was collapsed in V78 and the table dropped
    -- in V79; career_stages/stage_careers went in V76. One mirrored pair
    -- left -- career_exams/exam_careers, where both orderings are genuinely
    -- used. Carried forward from V78, not V77.
    pairs      text[][] := ARRAY[
        ARRAY['career_exams', 'career_slug', 'exam_slug', 'exam_careers', 'career_slug', 'exam_slug']
    ];
BEGIN
    -- 1. sort_order density, for every @OrderColumn-backed join table.
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
          AND column_name NOT IN ('sort_order', 'id', 'subject_slug')
        ORDER BY ordinal_position
        LIMIT 1;

        EXECUTE format(
            'SELECT count(*) FROM (SELECT %I FROM %I GROUP BY %I '
            'HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1) x',
            owner_col, r.table_name, owner_col
        ) INTO bad;

        IF bad > 0 THEN
            severity := 'error';
            kind     := 'gapped_sort_order';
            subject  := r.table_name;
            detail   := format('%s group(s) not dense 0..n-1, grouped by %s', bad, owner_col);
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
            severity := 'error';
            kind     := 'mirror_drift';
            subject  := format('%s <-> %s', p[1], p[4]);
            detail   := format('%s row(s) only in %s, %s row(s) only in %s',
                               only_a, p[1], only_b, p[4]);
            RETURN NEXT;
        END IF;
    END LOOP;

    -- 3. career_job_roles must be a superset of the specialization path.
    SELECT count(*), string_agg(format('%s/%s', career_slug, job_role_slug), ', '
                                ORDER BY career_slug, job_role_slug)
      INTO bad, sample
      FROM (
          SELECT DISTINCT cs.career_slug, sj.job_role_slug
          FROM career_specializations cs
          JOIN specialization_job_roles sj ON sj.specialization_slug = cs.specialization_slug
          EXCEPT
          SELECT career_slug, job_role_slug FROM career_job_roles
      ) x;

    IF bad > 0 THEN
        severity := 'warn';
        kind     := 'jobrole_not_in_career';
        subject  := 'career_job_roles';
        detail   := format('%s (career, job_role) pair(s) reachable via a specialization '
                           'but missing from career_job_roles: %s',
                           bad, left(sample, 400));
        RETURN NEXT;
    END IF;

    -- 4. A name must not be both a Career and a Specialization.
    SELECT count(*), string_agg(c.slug, ', ' ORDER BY c.slug)
      INTO bad, sample
      FROM careers c
      JOIN specializations s ON lower(s.name) = lower(c.title);

    IF bad > 0 THEN
        severity := 'warn';
        kind     := 'concept_collision';
        subject  := 'careers <-> specializations';
        detail   := format('%s name(s) exist as both a career and a specialization: %s',
                           bad, sample);
        RETURN NEXT;
    END IF;

    -- 5. Naming convention: fields are gerunds, roles are agent nouns.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug)
      INTO bad, sample FROM job_roles WHERE name ILIKE '%ing';
    IF bad > 0 THEN
        severity := 'warn';
        kind     := 'naming_convention';
        subject  := 'job_roles';
        detail   := format('%s job role(s) named like a field of study (-ing): %s',
                           bad, left(sample, 300));
        RETURN NEXT;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug)
      INTO bad, sample FROM careers WHERE title ~* '(er|ist)$';
    IF bad > 0 THEN
        severity := 'warn';
        kind     := 'naming_convention';
        subject  := 'careers';
        detail   := format('%s career(s) named like a job title (-er/-ist): %s',
                           bad, left(sample, 300));
        RETURN NEXT;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug)
      INTO bad, sample FROM specializations WHERE name ~* '(er|ist)$';
    IF bad > 0 THEN
        severity := 'warn';
        kind     := 'naming_convention';
        subject  := 'specializations';
        detail   := format('%s specialization(s) named like a job title (-er/-ist): %s',
                           bad, left(sample, 300));
        RETURN NEXT;
    END IF;
END;
$fn$;

COMMENT ON FUNCTION check_relationship_integrity() IS
    'Returns one row per relationship-integrity violation, graded error/warn; zero rows means healthy. Errors fail startup via afterMigrate.sql, warnings are logged. Run automatically on every boot.';
