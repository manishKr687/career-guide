-- Deletes the last 16 product rows, completing the Degree / Subject split.
--
-- After this, `degrees` contains qualification TYPES only. There is no
-- "B.A. (Psychology)" row anywhere: a course's education is a choice of a
-- degree AND a subject, and the combined title is composed from the two at
-- render time rather than stored.
--
-- Safe only because V104 moved all 69 references off these rows first, and
-- asserted it. Every FK into `degrees` is ON DELETE CASCADE, so running this
-- before the repoint would have silently deleted 69 links instead of
-- refusing. The pre-check below re-asserts that independently rather than
-- trusting the previous migration ran.
--
-- The three "Master of X" rows are NOT deleted: with no generic "Master"
-- qualification type to decompose into, and descriptions that deliberately
-- distinguish them from the M.A. equivalents, they are qualification types in
-- their own right -- the same reasoning that keeps MBBS whole.
--
-- degree_subjects gains the 16 corresponding pairs, so every combination that
-- existed as a row still exists as a pair. That is what makes this a
-- reorganisation rather than a deletion: "B.A. (Psychology)" remains
-- expressible, it is just no longer a row of its own.

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM (
        SELECT degree_slug FROM career_degrees
        UNION SELECT degree_slug FROM college_degrees
        UNION SELECT degree_slug FROM exam_career_degrees
        UNION SELECT degree_slug FROM college_career_degrees
        UNION SELECT degree_slug FROM degree_exams
        UNION SELECT degree_slug FROM degree_skills
        UNION SELECT degree_slug FROM degree_resources
    ) refs
    WHERE degree_slug IN (
        'ba-journalism', 'ba-psychology', 'ba-public-administration',
        'ba-sociology', 'ba-tourism', 'bsc-nursing', 'bsc-agriculture',
        'bsc-forestry', 'ma-journalism', 'ma-psychology',
        'ma-public-administration', 'ma-sociology', 'msc-nursing',
        'phd-engineering', 'phd-psychology', 'phd-sociology'
    );
    IF bad > 0 THEN
        RAISE EXCEPTION '% product row(s) are still referenced; deleting would cascade those links away', bad;
    END IF;
END $$;

-- Preserve every combination as a pair before removing the rows.
INSERT INTO degree_subjects (degree_slug, subject_slug) VALUES
    ('ba',   'journalism'),
    ('ba',   'psychology'),
    ('ba',   'public-administration'),
    ('ba',   'sociology'),
    ('ba',   'tourism'),
    ('b-sc', 'nursing'),
    ('b-sc', 'agriculture'),
    ('b-sc', 'forestry'),
    ('ma',   'journalism'),
    ('ma',   'psychology'),
    ('ma',   'public-administration'),
    ('ma',   'sociology'),
    ('msc',  'nursing'),
    ('phd',  'engineering'),
    ('phd',  'psychology'),
    ('phd',  'sociology')
ON CONFLICT DO NOTHING;

DELETE FROM degrees WHERE slug IN (
    'ba-journalism', 'ba-psychology', 'ba-public-administration',
    'ba-sociology', 'ba-tourism', 'bsc-nursing', 'bsc-agriculture',
    'bsc-forestry', 'ma-journalism', 'ma-psychology',
    'ma-public-administration', 'ma-sociology', 'msc-nursing',
    'phd-engineering', 'phd-psychology', 'phd-sociology'
);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM degrees;
    IF bad <> 84 THEN
        RAISE EXCEPTION 'expected 84 degrees remaining, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM degree_subjects;
    IF bad <> 58 THEN
        RAISE EXCEPTION 'expected 58 degree/subject pairs, found %', bad;
    END IF;

    -- THE POINT OF THE WHOLE EXERCISE: no degrees row may bake a subject into
    -- itself any more. The generic families and the genuine compound
    -- qualifications are the only things that may still match these prefixes.
    SELECT count(*) INTO bad FROM degrees
    WHERE (slug LIKE 'ba-%' OR slug LIKE 'bsc-%' OR slug LIKE 'ma-%'
           OR slug LIKE 'msc-%' OR slug LIKE 'phd-%')
      AND slug NOT IN ('ba-bed', 'bsc-bed', 'bsc-llb', 'ba-llb');
    IF bad > 0 THEN
        RAISE EXCEPTION '% product row(s) survived', bad;
    END IF;

    -- Nothing may have been cascaded away.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) lost their education', bad;
    END IF;

    SELECT count(*) INTO bad FROM college_degrees WHERE degree_slug = 'phd' AND subject_slug = 'engineering';
    IF bad <> 54 THEN
        RAISE EXCEPTION 'expected 54 colleges offering PhD in Engineering, found %', bad;
    END IF;

    -- Every pair must resolve on both sides.
    SELECT count(*) INTO bad FROM degree_subjects ds
    WHERE NOT EXISTS (SELECT 1 FROM degrees d  WHERE d.slug = ds.degree_slug)
       OR NOT EXISTS (SELECT 1 FROM subjects s WHERE s.slug = ds.subject_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% orphaned degree/subject pair(s)', bad;
    END IF;
END $$;
