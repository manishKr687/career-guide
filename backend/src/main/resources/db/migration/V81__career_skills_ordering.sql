-- Step 1 of 2 in giving skills a single source of truth.
--
-- careers.skills (text[]) and career_skills (the relation to Skill) have both
-- described the same thing since V24, and BOTH are independently editable --
-- CareerUpsertRequest accepts each separately and the admin form renders two
-- controls, one of which says outright that it is "separate from the
-- free-text Skills tags above". They agree today only because V50's import
-- wrote them consistently: 254 array entries, 254 relation rows, zero content
-- disagreements.
--
-- The relation could not simply replace the array because it lost ordering:
-- career_skills had no sort_order and Career.relatedSkills was an unordered
-- Set, while the array carries a curated "most central skill first" sequence
-- (all 42 careers are in a custom order; none is alphabetical). This
-- migration moves that ordering into the relation, which is the last thing
-- the array held that the relation did not. V82 then drops the column.
--
-- Merging now is lossless precisely because the two still agree. Once they
-- diverge it stops being mechanical and becomes a per-career judgement about
-- which side wins -- so this only ever gets more expensive to do.
--
-- Position comes from the array's own ordinality, matched case-insensitively
-- because the array preserves display casing while skills.name is the
-- canonical form. ORDINALITY is 1-based; @OrderColumn wants 0-based.

ALTER TABLE career_skills ADD COLUMN sort_order INTEGER;

UPDATE career_skills cs
SET sort_order = src.ord - 1
FROM (
    SELECT c.slug AS career_slug, s.slug AS skill_slug, x.ord
    FROM careers c
    CROSS JOIN LATERAL unnest(c.skills) WITH ORDINALITY AS x(name, ord)
    JOIN skills s ON lower(s.name) = lower(x.name)
) src
WHERE cs.career_slug = src.career_slug
  AND cs.skill_slug  = src.skill_slug;

-- Refuse to continue on a partial backfill. A NULL here means a career_skills
-- row whose skill is absent from that career's array, i.e. the two sources
-- had already diverged and this merge would be silently picking a winner.
DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM career_skills WHERE sort_order IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career_skills row(s) have no position in careers.skills -- the two sources have diverged, resolve by hand before merging', bad;
    END IF;

    -- Career.relatedSkills becomes an @OrderColumn list, so the sequence must
    -- be dense 0..n-1 per career or Hibernate materializes nulls into it (V58).
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_skills
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_skills.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;

ALTER TABLE career_skills ALTER COLUMN sort_order SET NOT NULL;
