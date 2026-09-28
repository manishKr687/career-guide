-- Adds the subject degrees that psychology, sociology and public
-- administration were missing, and links them properly.
--
-- V84 filled the career_degrees gap for 13 careers, but for these three the
-- catalog had no subject-specific degree at all, so they were linked to the
-- generic "B.A." and "M.A." rows. That was technically true and practically
-- useless: it filled the Education field without answering it, and clicking
-- through landed on a generic B.A. page that tells a psychology student
-- nothing. Filling a slot so nobody notices the gap is precisely what V83
-- removed the templated `education` column for.
--
-- The right fix is the one the catalog already models for every comparable
-- field: a real subject triplet, exactly like ba-economics / ma-economics /
-- phd-economics (V44/V70/V71). Eight rows below, following that pattern --
-- same title format, same icon-per-subject convention, same level values,
-- and category_slug matching where the corresponding CAREER sits in the
-- taxonomy (V71's rule).
--
-- On public administration's category: its degrees are filed under `law`
-- because the Public Administration CAREER is filed there. Subject-wise
-- `government-civil-services` arguably fits better, but splitting the two
-- would mean the same field is grouped differently depending on whether you
-- browse careers or degrees. If Public Administration ever gets its own
-- career category, these two rows should move with it.
--
-- M.Phil in Clinical Psychology is deliberately NOT added, despite being the
-- practice-licensing route in India: its status has been in flux since UGC's
-- 2023 M.Phil discontinuation and the RCI's own transition, and this catalog
-- does not add rows whose current accuracy cannot be confirmed. Better absent
-- than wrong.

INSERT INTO degrees (slug, title, description, icon, preparation_strategy, level, category_slug) VALUES
    ('ba-psychology', 'B.A. (Psychology)',
     'A 3-year undergraduate arts degree in Psychology covering cognitive, social, developmental and abnormal psychology alongside research methods and statistics -- the standard first step toward counselling, clinical or organisational practice.',
     'bulb',
     'Admission is largely 12th-marks-based or through CUET at central and many state universities.',
     'Undergraduate', 'arts-humanities'),

    ('ma-psychology', 'M.A. (Psychology)',
     'A 2-year postgraduate degree specialising in one branch of psychology -- clinical, counselling, organisational or social -- and the usual minimum qualification for psychologist roles.',
     'bulb',
     'Entry is through university entrance tests or CUET-PG, with a psychology bachelor''s normally required.',
     'Postgraduate', 'arts-humanities'),

    ('phd-psychology', 'PhD in Psychology',
     'A research doctorate in Psychology, typically 3-5 years, for candidates heading into academia, research or specialised practice.',
     'flask',
     'Entry is through university research-entrance tests, often with UGC-NET or JRF qualification.',
     'Doctoral', 'arts-humanities'),

    ('ba-sociology', 'B.A. (Sociology)',
     'A 3-year undergraduate arts degree in Sociology -- social structures, institutions, inequality and research methods -- a common route into research, the development sector and civil-services preparation.',
     'users',
     'Admission is largely 12th-marks-based or through CUET at central and many state universities.',
     'Undergraduate', 'arts-humanities'),

    ('ma-sociology', 'M.A. (Sociology)',
     'A 2-year postgraduate degree deepening sociological theory and empirical research methods, and the usual prerequisite for research or teaching roles.',
     'users',
     'Entry is through university entrance tests or CUET-PG.',
     'Postgraduate', 'arts-humanities'),

    ('phd-sociology', 'PhD in Sociology',
     'A research doctorate in Sociology, typically 3-5 years, for candidates heading into academia, policy research or the development sector.',
     'flask',
     'Entry is through university research-entrance tests, often with UGC-NET or JRF qualification.',
     'Doctoral', 'arts-humanities'),

    ('ba-public-administration', 'B.A. (Public Administration)',
     'A 3-year undergraduate arts degree covering public policy, governance, administrative theory and the structure of Indian government.',
     'building',
     'Admission is largely 12th-marks-based or through CUET at central and many state universities.',
     'Undergraduate', 'law'),

    ('ma-public-administration', 'M.A. (Public Administration)',
     'A 2-year postgraduate degree in governance, public policy and administrative systems, commonly taken alongside civil-services preparation.',
     'building',
     'Entry is through university entrance tests or CUET-PG; the syllabus overlaps heavily with the UPSC Public Administration optional.',
     'Postgraduate', 'law')
ON CONFLICT DO NOTHING;

-- Replace the generic B.A./M.A. links wholesale rather than adding alongside
-- them: career_degrees is @OrderColumn-backed, so rewriting the whole set per
-- career is what keeps sort_order dense 0..n-1.
DELETE FROM career_degrees WHERE career_slug IN ('psychology', 'sociology', 'public-administration');

INSERT INTO career_degrees (career_slug, degree_slug, sort_order) VALUES
    ('psychology',            'ba-psychology',            0),
    ('psychology',            'ma-psychology',            1),
    ('psychology',            'phd-psychology',           2),
    ('sociology',             'ba-sociology',             0),
    ('sociology',             'ma-sociology',             1),
    ('sociology',             'phd-sociology',            2),
    ('public-administration', 'ba-public-administration', 0),
    ('public-administration', 'ma-public-administration', 1);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have no degree mapping', bad;
    END IF;

    -- No career should still be leaning on the generic B.A./M.A. rows as its
    -- entire education answer; those exist for genuinely undifferentiated
    -- arts degrees, not as a stand-in for a missing subject degree.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING bool_and(degree_slug IN ('ba', 'ma'))
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) are still mapped only to the generic B.A./M.A.', bad;
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
