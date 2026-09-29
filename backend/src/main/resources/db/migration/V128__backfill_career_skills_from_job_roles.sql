-- Backfills career_skills from the skills of each career's job roles.
--
-- THE GAP. job_role_skills holds 741 links across 247 roles; career_skills held
-- 322 across 55 careers. The result is that 162 of 413 skills are listed by no
-- career at all, so their pages say a skill leads nowhere -- and the ones
-- missing are not obscure. AWS, Azure, automation-plc and blueprint-reading are
-- all attached to job roles and to no career, which means a reader browsing
-- skills cannot get from "AWS" back to Computer Science.
--
-- THE DERIVATION. A career owns job roles; a job role needs skills; therefore a
-- skill needed by any role under a career is a skill of that career. That adds
-- 340 links the catalog already implied but never recorded.
--
-- THIS IS A BACKFILL, NOT A DERIVED VIEW, and the distinction matters because
-- this codebase has been bitten by stored duplicates before -- the exam/career
-- mirror pair, and the Branch layer nothing maintained.
--
-- career_skills is an OWNED relation: it is editable from the admin form as a
-- multiselect, and an editor is expected to curate it. So it cannot be replaced
-- by a read-time join without making that field meaningless. What this migration
-- does is seed it with what an editor would otherwise have typed by hand,
-- leaving them free to prune. The consequence, recorded honestly: if a job
-- role's skills change later, career_skills does not follow. That is drift, and
-- it is acceptable only because the column is curated rather than computed --
-- if it ever stops being curated, the right fix is a read-time join, not a
-- second backfill.
--
-- ORDER. Existing rows keep their positions, so any curation already done
-- survives. New rows follow, most-central first: a skill needed by eight of a
-- career's roles is ordered above one needed by a single role, since that is
-- the better answer to "what does this field actually use". Ties break on slug
-- so the result is deterministic rather than dependent on physical row order.
--
-- sort_order is NOT NULL with no default and the boot-time check asserts density
-- 0..n-1 per career, so everything is renumbered at the end.

INSERT INTO career_skills (career_slug, skill_slug, sort_order)
SELECT d.career_slug, d.skill_slug,
       -- Positioned after everything the career already had.
       COALESCE((SELECT max(sort_order) + 1 FROM career_skills x WHERE x.career_slug = d.career_slug), 0)
         + row_number() OVER (PARTITION BY d.career_slug ORDER BY d.role_count DESC, d.skill_slug) - 1
FROM (
    SELECT cjr.career_slug, jrs.skill_slug, count(DISTINCT cjr.job_role_slug) AS role_count
    FROM career_job_roles cjr
    JOIN job_role_skills jrs ON jrs.job_role_slug = cjr.job_role_slug
    WHERE NOT EXISTS (
        SELECT 1 FROM career_skills cs
        WHERE cs.career_slug = cjr.career_slug AND cs.skill_slug = jrs.skill_slug)
    GROUP BY cjr.career_slug, jrs.skill_slug
) d;

-- Renumber every affected career so sort_order is dense from 0. The insert above
-- appends from each career's previous maximum, which is dense only if the
-- existing rows were -- this makes it true regardless.
WITH ranked AS (
    SELECT career_slug, skill_slug,
           row_number() OVER (PARTITION BY career_slug ORDER BY sort_order, skill_slug) - 1 AS rn
    FROM career_skills)
UPDATE career_skills cs SET sort_order = r.rn
FROM ranked r
WHERE cs.career_slug = r.career_slug AND cs.skill_slug = r.skill_slug;

DO $$
DECLARE n int;
BEGIN
    -- Nothing the catalog implies may still be missing.
    SELECT count(*) INTO n FROM (
        SELECT DISTINCT cjr.career_slug, jrs.skill_slug
        FROM career_job_roles cjr JOIN job_role_skills jrs ON jrs.job_role_slug = cjr.job_role_slug
        EXCEPT SELECT career_slug, skill_slug FROM career_skills) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% (career, skill) pair(s) are still implied by the job roles but not recorded', n;
    END IF;

    -- Density, which the boot check enforces and an append-then-forget would break.
    SELECT count(*) INTO n FROM (
        SELECT career_slug FROM career_skills
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% career(s) have a gapped skill order', n;
    END IF;

    -- The point of the exercise: fewer skills that no career lists.
    SELECT count(*) INTO n FROM skills s
    WHERE NOT EXISTS (SELECT 1 FROM career_skills cs WHERE cs.skill_slug = s.slug);
    IF n >= 162 THEN
        RAISE EXCEPTION 'orphan skills did not fall below the previous 162; found %', n;
    END IF;

    -- And no skill may have been attached to a career that does not exist.
    SELECT count(*) INTO n FROM career_skills cs
    WHERE NOT EXISTS (SELECT 1 FROM careers c WHERE c.slug = cs.career_slug)
       OR NOT EXISTS (SELECT 1 FROM skills s WHERE s.slug = cs.skill_slug);
    IF n > 0 THEN RAISE EXCEPTION '% career_skills row(s) point at something that does not exist', n; END IF;
END $$;
