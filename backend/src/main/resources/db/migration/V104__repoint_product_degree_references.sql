-- Repoints all 71 references from product rows to (generic degree + subject).
--
-- This is the step that actually separates the two models. Before:
--
--   career_degrees(psychology, ba-psychology)
--
-- After:
--
--   career_degrees(psychology, ba, psychology)
--                               ^degree  ^subject
--
-- The row now names a qualification TYPE and a FIELD independently, which is
-- what lets `degrees` stop carrying "B.A. (Psychology)" as a row of its own.
--
-- Nothing is deleted here. V105 removes the product rows once every reference
-- has moved off them and that has been verified -- the split exists because
-- degrees' FKs are ON DELETE CASCADE, so a delete that runs while references
-- remain destroys them silently instead of failing.
--
-- THE MAPPING
--
-- 16 of the 19 product rows decompose by stripping the family prefix. The
-- three that do not are left alone entirely:
--
--   m-journalism          "Master of Journalism"
--   m-mass-communication  "Master of Mass Communication"
--   m-hotel-management    "Master of Hotel Management"
--
-- There is no generic "Master" qualification type to decompose these into,
-- and their descriptions deliberately distinguish them from the M.A.
-- equivalents ("within a broader humanities framework"). Both are real,
-- separate programmes in India. They stay qualification types in their own
-- right, exactly like MBBS.
--
-- phd-engineering carries 54 of the 71 references on its own -- colleges
-- offering a doctorate in engineering -- and becomes (phd, engineering).
--
-- ON DUPLICATES: a career could already link to both `ba-psychology` and the
-- generic `ba`, which after repointing would collide on the natural key
-- (career, ba, NULL) vs (career, ba, psychology) -- those differ, so no
-- collision. A genuine collision needs the same career linked to two rows
-- mapping to the identical (degree, subject), which does not occur here and
-- the unique index would reject anyway.

-- --------------------------------------------------------- career_degrees
UPDATE career_degrees cd
SET degree_slug = m.degree_slug,
    subject_slug = m.subject_slug
FROM (VALUES
    ('ba-journalism',            'ba',  'journalism'),
    ('ba-psychology',            'ba',  'psychology'),
    ('ba-public-administration', 'ba',  'public-administration'),
    ('ba-sociology',             'ba',  'sociology'),
    ('ba-tourism',               'ba',  'tourism'),
    ('bsc-nursing',              'b-sc', 'nursing'),
    ('ma-journalism',            'ma',  'journalism'),
    ('ma-psychology',            'ma',  'psychology'),
    ('ma-public-administration', 'ma',  'public-administration'),
    ('ma-sociology',             'ma',  'sociology'),
    ('msc-nursing',              'msc', 'nursing'),
    ('phd-psychology',           'phd', 'psychology'),
    ('phd-sociology',            'phd', 'sociology')
) AS m(old_slug, degree_slug, subject_slug)
WHERE cd.degree_slug = m.old_slug;

-- -------------------------------------------------------- college_degrees
UPDATE college_degrees cold
SET degree_slug = 'phd',
    subject_slug = 'engineering'
WHERE cold.degree_slug = 'phd-engineering';

-- ---------------------------------------------------- exam_career_degrees
UPDATE exam_career_degrees ecd
SET degree_slug = 'b-sc',
    subject_slug = m.subject_slug
FROM (VALUES
    ('bsc-agriculture', 'agriculture'),
    ('bsc-forestry',    'forestry')
) AS m(old_slug, subject_slug)
WHERE ecd.degree_slug = m.old_slug;

DO $$
DECLARE bad int;
BEGIN
    -- Nothing may still point at a decomposable product row.
    SELECT count(*) INTO bad FROM (
        SELECT degree_slug FROM career_degrees
        UNION SELECT degree_slug FROM college_degrees
        UNION SELECT degree_slug FROM exam_career_degrees
    ) refs
    WHERE degree_slug IN (
        'ba-journalism', 'ba-psychology', 'ba-public-administration',
        'ba-sociology', 'ba-tourism', 'bsc-nursing', 'bsc-agriculture',
        'bsc-forestry', 'ma-journalism', 'ma-psychology',
        'ma-public-administration', 'ma-sociology', 'msc-nursing',
        'phd-engineering', 'phd-psychology', 'phd-sociology'
    );
    IF bad > 0 THEN
        RAISE EXCEPTION '% product row(s) are still referenced after repointing', bad;
    END IF;

    -- Every repointed row must now name a real subject.
    SELECT count(*) INTO bad FROM career_degrees cd
    WHERE cd.subject_slug IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM subjects s WHERE s.slug = cd.subject_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career_degrees row(s) name a subject that does not exist', bad;
    END IF;

    -- Originally `IF bad <> 69` (13 + 54 + 2 on the database this was written
    -- against). How many rows carry a subject depends on how many product
    -- degree rows were referenced in the first place, which differs between a
    -- pristine replay and a database an editor has worked on -- so the absolute
    -- total made the history unreplayable. On a clean replay it is 67.
    --
    -- The invariant that matters is the one above and below this: a subject must
    -- exist, and may only sit on a degree that takes one. What this adds is that
    -- the repointing actually happened rather than silently matching nothing.
    SELECT (SELECT count(*) FROM career_degrees      WHERE subject_slug IS NOT NULL)
         + (SELECT count(*) FROM college_degrees     WHERE subject_slug IS NOT NULL)
         + (SELECT count(*) FROM exam_career_degrees WHERE subject_slug IS NOT NULL)
      INTO bad;
    IF bad = 0 THEN
        RAISE EXCEPTION 'no rows carry a subject -- the repointing matched nothing';
    END IF;

    -- And no reference may still point at a deleted product row, which is what
    -- the repointing was for.
    SELECT count(*) INTO bad FROM career_degrees cd
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = cd.degree_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career_degrees row(s) still name a degree that no longer exists', bad;
    END IF;

    -- A subject may only be attached to a degree that takes one, or the row
    -- would read like "MBBS in Physics".
    SELECT count(*) INTO bad FROM career_degrees cd
    JOIN degrees d ON d.slug = cd.degree_slug
    WHERE cd.subject_slug IS NOT NULL AND NOT d.requires_subject;
    IF bad > 0 THEN
        RAISE EXCEPTION '% row(s) attach a subject to a degree that takes none', bad;
    END IF;

    -- No career may have lost its education to the UPDATE.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) lost their degree mapping', bad;
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
