-- Resolves the two names that existed as both a Career and a Specialization.
--
--   industrial-engineering     career, AND a specialization of Mechanical
--   environmental-engineering  career, AND a specialization of Civil
--
-- Same slug, same name, two tables -- the duplicate-concept problem the V93
-- `concept_collision` check surfaced.
--
-- WHY THE CAREER WINS, AND WHY THIS IS NOT A CLOSE CALL
--
-- It looks like a genuine "which one is it?" question -- Industrial
-- Engineering really is both a standalone B.Tech branch and something a
-- Mechanical student can branch into. But the data is not ambiguous at all:
--
--                        as Career                          as Specialization
--   industrial-eng       7 specs, 7 job roles, 2 degrees,   1 job role,
--                        2 stages, 1 stream                 0 colleges
--   environmental-eng    5 specs, 5 job roles, 2 degrees,   1 job role,
--                        2 stages, 1 stream                 0 colleges
--
-- The career rows carry the whole model. The specialization rows are stubs
-- that were never filled in. This is a leftover, not a modelling decision.
--
-- NOTHING IS LOST. Each specialization's single job role is already linked
-- directly in career_job_roles, on BOTH sides -- verified before writing this
-- and re-asserted below:
--
--   mechanical-engineering    -> industrial-engineer      already present
--   civil-engineering         -> environmental-engineer   already present
--   industrial-engineering    -> industrial-engineer      already present
--   environmental-engineering -> environmental-engineer   already present
--
-- So deleting the specialization removes no reachable job role from any
-- career page. The one thing that does go is the statement "Industrial
-- Engineering is a sub-field of Mechanical Engineering". That is true and
-- worth keeping eventually, but it is a career-to-career relation, and
-- duplicating the concept into `specializations` is the wrong way to say it.
-- If that pathway is wanted later it should be a real relation, not a
-- second row meaning the same thing.
--
-- career_specializations is @OrderColumn-backed (Career.relatedSpecializations)
-- and the FK is ON DELETE CASCADE, so removing the specialization silently
-- punches a hole in its parent's sort_order -- mechanical drops 11 -> 10,
-- civil 9 -> 8. Re-densified below; without that the next page load of
-- /careers/mechanical-engineering would hit the V58 @OrderColumn NPE.

DELETE FROM specializations
WHERE slug IN ('industrial-engineering', 'environmental-engineering');

-- Close the sort_order gaps the cascade just created. ROW_NUMBER over the
-- surviving rows in their existing order preserves the curated sequence.
WITH renumbered AS (
    SELECT career_slug, specialization_slug,
           ROW_NUMBER() OVER (PARTITION BY career_slug ORDER BY sort_order) - 1 AS new_order
    FROM career_specializations
    WHERE career_slug IN ('mechanical-engineering', 'civil-engineering')
)
UPDATE career_specializations cs
SET sort_order = r.new_order
FROM renumbered r
WHERE cs.career_slug = r.career_slug
  AND cs.specialization_slug = r.specialization_slug;

DO $$
DECLARE bad int;
BEGIN
    IF EXISTS (SELECT 1 FROM careers c
               JOIN specializations s ON lower(s.name) = lower(c.title)) THEN
        RAISE EXCEPTION 'a name still exists as both a career and a specialization';
    END IF;

    -- The four job-role links that justified the delete must all survive.
    SELECT count(*) INTO bad FROM (VALUES
        ('mechanical-engineering',    'industrial-engineer'),
        ('civil-engineering',         'environmental-engineer'),
        ('industrial-engineering',    'industrial-engineer'),
        ('environmental-engineering', 'environmental-engineer')
    ) AS v(career_slug, job_role_slug)
    WHERE NOT EXISTS (
        SELECT 1 FROM career_job_roles cj
        WHERE cj.career_slug = v.career_slug AND cj.job_role_slug = v.job_role_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% job role link(s) were lost by the delete', bad;
    END IF;

    -- Both careers must still exist -- the delete targeted specializations
    -- only, and a typo'd slug could have taken the wrong thing.
    SELECT count(*) INTO bad FROM (VALUES
        ('industrial-engineering'), ('environmental-engineering')
    ) AS v(slug)
    WHERE NOT EXISTS (SELECT 1 FROM careers c WHERE c.slug = v.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) were deleted by mistake', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_specializations
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_specializations.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
