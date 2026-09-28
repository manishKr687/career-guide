-- Gives every degree its full name and how long it takes.
--
-- The degrees table held `title` ("B.Tech") and nothing that says what those
-- letters stand for or how many years they cost -- the two things a student
-- comparing qualifications asks first. Both are now columns, and both are
-- seeded for all 76 rows.
--
-- WHY THIS IS SEEDED WHEN V110'S SALARY BANDS WERE NOT.
--
-- These are definitional, not statistical. "B.Tech is a Bachelor of
-- Technology and runs four years" is a fact about the qualification, the same
-- kind of fact as its level, and it is wrong in a way anyone can immediately
-- see. A salary band is a market estimate that reads as researched whether or
-- not anyone researched it, which is why V110 left those empty. The
-- distinction is whether a reader could catch a mistake, and here they could.
--
-- DURATION IS A RANGE, both bounds set, equal where the programme is fixed.
-- "4 years" is min = max = 4; PhD is 3-5; LLM and MLIS are 1-2 depending on
-- the university. NUMERIC(3,1) rather than an integer because the medical
-- qualifications are genuinely half-years: MBBS, BAMS, BHMS, BSMS and BUMS
-- are 4.5 years of study plus a one-year internship, and BPT and BOT are 4
-- plus six months. Rounding those to 5 or 6 would misstate a real commitment.
--
-- NULL DURATION means "not a taught programme with a fixed length", not
-- "unknown". DSc, DLitt and LLD are higher doctorates awarded on a submitted
-- body of published work -- V106's own comment says they are not
-- admission-based -- so any number here would be invented.
--
-- full_title is NULL where `title` already IS the full name (Diploma,
-- Certificate, Master of Hotel Management), rather than repeating it.

ALTER TABLE degrees
    ADD COLUMN full_title varchar(200),
    ADD COLUMN duration_min_years numeric(3,1),
    ADD COLUMN duration_max_years numeric(3,1);

ALTER TABLE degrees ADD CONSTRAINT degrees_duration_sane
    CHECK (
        (duration_min_years IS NULL AND duration_max_years IS NULL)
        OR (duration_min_years > 0 AND duration_max_years >= duration_min_years
            AND duration_max_years <= 10)
    );

UPDATE degrees d SET
    full_title = v.full_title,
    duration_min_years = v.dmin,
    duration_max_years = v.dmax
FROM (VALUES
    -- slug, full title (NULL where `title` is already the full name), min, max
    ('certificate',        NULL,                                                              0.5, 1.0),
    ('diploma',            NULL,                                                              3.0, 3.0),
    ('dpharm',             'Diploma in Pharmacy',                                             2.0, 2.0),
    ('gnm',                'General Nursing and Midwifery',                                   3.0, 3.0),

    -- Higher doctorates take no duration; see the header.
    ('dlitt',              'Doctor of Letters',                                               NULL, NULL),
    ('dsc',                'Doctor of Science',                                               NULL, NULL),
    ('lld',                'Doctor of Laws',                                                  NULL, NULL),
    ('phd',                'Doctor of Philosophy',                                            3.0, 5.0),

    ('llm',                'Master of Laws',                                                  1.0, 2.0),
    ('m-arch',             'Master of Architecture',                                          2.0, 2.0),
    ('m-com',              'Master of Commerce',                                              2.0, 2.0),
    ('m-des',              'Master of Design',                                                2.0, 2.0),
    ('m-ed',               'Master of Education',                                             2.0, 2.0),
    ('m-eng',              'Master of Engineering',                                           2.0, 2.0),
    ('m-hotel-management', NULL,                                                              2.0, 2.0),
    ('m-plan',             'Master of Planning',                                              2.0, 2.0),
    ('m-tech',             'Master of Technology',                                            2.0, 2.0),
    ('ma',                 'Master of Arts',                                                  2.0, 2.0),
    ('mba',                'Master of Business Administration',                               2.0, 2.0),
    ('mca',                'Master of Computer Applications',                                 2.0, 2.0),
    ('md',                 'Doctor of Medicine',                                              3.0, 3.0),
    ('mds',                'Master of Dental Surgery',                                        3.0, 3.0),
    ('mfa',                'Master of Fine Arts',                                             2.0, 2.0),
    ('mjmc',               'Master of Journalism and Mass Communication',                     2.0, 2.0),
    ('mlis',               'Master of Library and Information Science',                       1.0, 2.0),
    ('moptom',             'Master of Optometry',                                             2.0, 2.0),
    ('mpa',                'Master of Performing Arts',                                       2.0, 2.0),
    ('mped',               'Master of Physical Education',                                    2.0, 2.0),
    ('mpharm',             'Master of Pharmacy',                                              2.0, 2.0),
    ('mpt',                'Master of Physiotherapy',                                         2.0, 2.0),
    ('ms-surgery',         'Master of Surgery',                                               3.0, 3.0),
    ('msc',                'Master of Science',                                               2.0, 2.0),
    ('mstat',              'Master of Statistics',                                            2.0, 2.0),
    ('msw',                'Master of Social Work',                                           2.0, 2.0),
    ('mttm',               'Master of Tourism and Travel Management',                         2.0, 2.0),
    ('mvoc',               'Master of Vocation',                                              2.0, 2.0),
    ('mvsc',               'Master of Veterinary Science',                                    2.0, 2.0),

    ('b-arch',             'Bachelor of Architecture',                                        5.0, 5.0),
    ('b-com',              'Bachelor of Commerce',                                            3.0, 3.0),
    ('b-des',              'Bachelor of Design',                                              4.0, 4.0),
    ('b-ed',               'Bachelor of Education',                                           2.0, 2.0),
    ('b-el-ed',            'Bachelor of Elementary Education',                                4.0, 4.0),
    ('b-eng',              'Bachelor of Engineering',                                         4.0, 4.0),
    ('b-plan',             'Bachelor of Planning',                                            4.0, 4.0),
    ('b-sc',               'Bachelor of Science',                                             3.0, 3.0),
    ('b-tech',             'Bachelor of Technology',                                          4.0, 4.0),
    ('b-tech-m-tech',      'Bachelor of Technology and Master of Technology (Dual Degree)',   5.0, 5.0),
    ('ba',                 'Bachelor of Arts',                                                3.0, 3.0),
    ('ba-llb',             'Bachelor of Arts and Bachelor of Legislative Law',                5.0, 5.0),
    -- 4.5 years of study plus a compulsory one-year rotating internship.
    ('bams',               'Bachelor of Ayurvedic Medicine and Surgery',                      5.5, 5.5),
    ('baslp',              'Bachelor of Audiology and Speech Language Pathology',             4.0, 4.0),
    ('bba',                'Bachelor of Business Administration',                             3.0, 3.0),
    ('bca',                'Bachelor of Computer Applications',                               3.0, 3.0),
    ('bds',                'Bachelor of Dental Surgery',                                      5.0, 5.0),
    ('bfa',                'Bachelor of Fine Arts',                                           4.0, 4.0),
    ('bhm',                'Bachelor of Hotel Management',                                    4.0, 4.0),
    ('bhmct',              'Bachelor of Hotel Management and Catering Technology',            4.0, 4.0),
    ('bhms',               'Bachelor of Homeopathic Medicine and Surgery',                    5.5, 5.5),
    ('bjmc',               'Bachelor of Journalism and Mass Communication',                   3.0, 3.0),
    ('blis',               'Bachelor of Library and Information Science',                     1.0, 1.0),
    ('bmath',              'Bachelor of Mathematics',                                         3.0, 3.0),
    ('boptom',             'Bachelor of Optometry',                                           4.0, 4.0),
    -- 4 years plus a six-month internship.
    ('bot',                'Bachelor of Occupational Therapy',                                4.5, 4.5),
    ('bpa',                'Bachelor of Performing Arts',                                     3.0, 4.0),
    ('bped',               'Bachelor of Physical Education',                                  2.0, 2.0),
    ('bpharm',             'Bachelor of Pharmacy',                                            4.0, 4.0),
    ('bpt',                'Bachelor of Physiotherapy',                                       4.5, 4.5),
    ('bsms',               'Bachelor of Siddha Medicine and Surgery',                         5.5, 5.5),
    ('bstat',              'Bachelor of Statistics',                                          3.0, 3.0),
    ('bsw',                'Bachelor of Social Work',                                         3.0, 3.0),
    ('bttm',               'Bachelor of Tourism and Travel Management',                       3.0, 3.0),
    ('bums',               'Bachelor of Unani Medicine and Surgery',                          5.5, 5.5),
    ('bvoc',               'Bachelor of Vocation',                                            3.0, 3.0),
    ('bvsc-ah',            'Bachelor of Veterinary Science and Animal Husbandry',             5.0, 5.0),
    ('llb',                'Bachelor of Legislative Law',                                     3.0, 3.0),
    ('mbbs',               'Bachelor of Medicine and Bachelor of Surgery',                    5.5, 5.5)
) AS v(slug, full_title, dmin, dmax)
WHERE d.slug = v.slug;

DO $$
DECLARE bad int; missing text;
BEGIN
    -- Every degree must have been covered. A slug typo'd above would silently
    -- leave a row untouched, and the only symptom would be a blank card.
    SELECT count(*), string_agg(slug, ', ') INTO bad, missing FROM degrees
    WHERE duration_min_years IS NULL AND slug NOT IN ('dsc', 'dlitt', 'lld');
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree(s) got no duration: %', bad, missing;
    END IF;

    -- The three higher doctorates must NOT have picked one up.
    SELECT count(*) INTO bad FROM degrees
    WHERE slug IN ('dsc', 'dlitt', 'lld') AND duration_min_years IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% higher doctorate(s) were given a duration they do not have', bad;
    END IF;

    -- full_title is only omitted where the title is already the full name.
    SELECT count(*), string_agg(slug, ', ') INTO bad, missing FROM degrees
    WHERE full_title IS NULL
      AND slug NOT IN ('certificate', 'diploma', 'm-hotel-management');
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree(s) got no full title: %', bad, missing;
    END IF;

    -- A full title that just restates the abbreviation helps nobody.
    SELECT count(*) INTO bad FROM degrees WHERE full_title = title;
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree(s) have a full title identical to the title', bad;
    END IF;

    SELECT count(*) INTO bad FROM degrees;
    IF bad <> 76 THEN
        RAISE EXCEPTION 'expected 76 degrees, found % -- the seed above is keyed by slug and would need updating', bad;
    END IF;
END $$;
