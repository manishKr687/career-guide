-- Closes the 25 (career, job_role) gaps V93 surfaced, and promotes both new
-- boundary checks from `warn` to `error`.
--
-- THE RULE BEING ESTABLISHED
--
-- career_job_roles is a SUPERSET of the specialization path, not a cache of
-- it. Before this migration the two disagreed both ways:
--
--   both agree      200
--   direct only      79   career offers a role no specialization of it does
--   indirect only    25   <- fixed here
--
-- The 79 are legitimate and deliberately kept: a career can offer generalist
-- roles that belong to no single specialization -- "Mechanical Engineer" is
-- not specific to Robotics. That is exactly why this is a superset rule and
-- career_job_roles cannot simply be dropped and derived.
--
-- The 25 are bugs. In each one a specialization offers a job role that its
-- own parent career does not list, so the role is unreachable from the career
-- page while being reachable from a child of it. Every pair below was checked
-- against its path: all are plain omissions, not modelling disagreements --
-- cloud-computing is a specialization of Information Technology and offers
-- Cloud Engineer, so IT offers Cloud Engineer.
--
-- Inserted explicitly rather than with the INSERT ... SELECT that generated
-- them, so the list is reviewable and this migration keeps doing the same
-- thing if the specialization data changes later.
--
-- career_job_roles has no sort_order column (Career.jobRoles is a Set, owned
-- by JobRole.careers) -- plain inserts, no density to maintain.
--
-- PROMOTION TO `error`
--
-- V93 graded these `warn` because the violations already existed and a hard
-- error would have failed the boot that installed the check. Both are clean
-- as of this migration -- V94 resolved the 2 collisions, this closes the 25 --
-- so they become errors. That was the point of grading rather than omitting:
-- a warning is a staging state, and leaving it to scroll past on every boot
-- is how the mirror-table drift went unnoticed for ten migrations.

INSERT INTO career_job_roles (career_slug, job_role_slug) VALUES
    ('agriculture',                      'biotechnologist'),
    ('biology',                          'biotechnology-researcher'),
    ('biomedical-engineering',           'medical-physicist'),
    ('biotechnology',                    'agricultural-scientist'),
    ('biotechnology',                    'geneticist'),
    ('biotechnology',                    'pharmaceutical-scientist'),
    ('business-administration',          'data-analyst'),
    ('chemical-engineering',             'bioprocess-engineer'),
    ('chemical-engineering',             'materials-engineer'),
    ('chemical-engineering',             'sustainability-engineer'),
    ('chemistry',                        'biotechnology-researcher'),
    ('chemistry',                        'materials-scientist'),
    ('civil-engineering',                'urban-planner'),
    ('computer-science-and-engineering', 'cloud-administrator'),
    ('computer-science-and-engineering', 'embedded-engineer'),
    ('human-resource-management',        'hr-specialist'),
    ('industrial-engineering',           'operations-research-analyst'),
    ('industrial-engineering',           'production-engineer'),
    ('information-technology',           'cloud-engineer'),
    ('information-technology',           'database-administrator'),
    ('law',                              'tax-consultant'),
    ('manufacturing-engineering',        'cad-engineer'),
    ('marketing',                        'copywriter'),
    ('mechanical-engineering',           'cad-cam-engineer'),
    ('sports-science',                   'sports-physiotherapist')
ON CONFLICT DO NOTHING;

-- Promote jobrole_not_in_career and concept_collision to `error`. Only those
-- two severity literals change; the rest is V93's function restated, since
-- CREATE OR REPLACE takes the whole definition.
CREATE OR REPLACE FUNCTION check_relationship_integrity()
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
        severity := 'error';
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
        severity := 'error';
        kind     := 'concept_collision';
        subject  := 'careers <-> specializations';
        detail   := format('%s name(s) exist as both a career and a specialization: %s',
                           bad, sample);
        RETURN NEXT;
    END IF;

    -- 5. Naming convention: fields are gerunds, roles are agent nouns.
    --    Stays `warn` -- it is a heuristic and can false-positive.
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

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM (
        SELECT DISTINCT cs.career_slug, sj.job_role_slug
        FROM career_specializations cs
        JOIN specialization_job_roles sj ON sj.specialization_slug = cs.specialization_slug
        EXCEPT
        SELECT career_slug, job_role_slug FROM career_job_roles
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% specialization job role(s) still missing from their career', bad;
    END IF;

    -- The 79 generalist direct-only pairs must NOT have been swept away: this
    -- is a superset rule, and losing them would mean it had been applied as
    -- an equality rule by mistake.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug, job_role_slug FROM career_job_roles
        EXCEPT
        SELECT DISTINCT cs.career_slug, sj.job_role_slug
        FROM career_specializations cs
        JOIN specialization_job_roles sj ON sj.specialization_slug = cs.specialization_slug
    ) x;
    IF bad < 79 THEN
        RAISE EXCEPTION 'expected at least 79 generalist career job roles, found % -- the superset rule was applied as equality', bad;
    END IF;

    -- Both promoted checks must now be clean, or the next boot fails.
    SELECT count(*) INTO bad FROM check_relationship_integrity() WHERE severity = 'error';
    IF bad > 0 THEN
        RAISE EXCEPTION '% integrity error(s) remain after promotion', bad;
    END IF;
END $$;
