-- Makes exams filterable: a field, a level, and a normalised frequency.
--
-- The exams listing needs three facets and none of them could be built on
-- what was there.
--
-- 1. `category` MIXES TWO AXES. Its eight values are "After 12th",
--    "Undergraduate Entrance", "Postgraduate Entrance", "After 10th" -- which
--    say WHEN you sit the exam -- alongside "Government", "Banking",
--    "Defence", "Professional", which say what FIELD it belongs to. Filtering
--    by field is impossible while both live in one column: NEET-UG is "After
--    12th" and nothing records that it is a medical exam.
--
--    It is also free text, while this application already has a `categories`
--    table holding exactly the taxonomy wanted (engineering-technology,
--    medical-healthcare, law, ...). So the field axis becomes a real FK and
--    the existing column keeps the stage axis, which is genuinely useful and
--    is what /exams filters on today.
--
-- 2. `frequency` IS FREE TEXT, 10 distinct values across 34 rows: "Once a
--    year", "Once a year (as notified)", "Once a year (state-wise)" and "Once
--    a year (Class 10)" are four separate strings meaning the same thing. A
--    facet built on it would offer four identical-looking "annual" options.
--    `frequency_type` normalises it to four buckets; the original string stays
--    as the human detail, because "(state-wise)" is worth saying on the page.
--
-- 3. THERE IS NO LEVEL. `exam_type` (Admission / Recruitment / Eligibility)
--    describes what the exam IS, not what it gets you, and
--    `eligibility_min_qualification` is free text describing what you need
--    BEFORE it. Neither answers "is this an undergraduate entrance or a job
--    exam", which is the first cut a student makes.
--
-- All three are assigned per exam below rather than derived. 34 rows is small
-- enough to be read and checked, and the derivations that looked possible are
-- wrong in specific cases: eligibility "Bachelor's Degree" covers both CAT (a
-- postgraduate entrance) and UPSC CSE (a job exam), and "12th Pass" covers
-- both NEET-UG and CLAT, which sit in different fields.
--
-- NOT ADDED: exam dates. The mock shows months on each card ("Jan, Apr"), and
-- a `typical_months` column would be the easy way to get them. It would also
-- be wrong within a year -- exam calendars shift, and a stale month on a
-- listing page is the kind of error a student plans around. Dates belong in a
-- per-year exam_sessions table with a session year, which is a bigger model
-- than this page needs; the card shows the conducting body instead.

ALTER TABLE exams
    ADD COLUMN category_slug varchar(64) REFERENCES categories(slug),
    ADD COLUMN level varchar(24),
    ADD COLUMN frequency_type varchar(24);

CREATE INDEX idx_exams_category_slug ON exams (category_slug);
CREATE INDEX idx_exams_level ON exams (level);

UPDATE exams e SET
    category_slug = v.category_slug,
    level = v.level,
    frequency_type = v.frequency_type
FROM (VALUES
    -- slug, field (NULL where the exam spans every field), level, frequency
    ('bitsat',                 'engineering-technology',    'Undergraduate', 'Biannual'),
    ('jee-main',               'engineering-technology',    'Undergraduate', 'Biannual'),
    ('jee-advanced',           'engineering-technology',    'Undergraduate', 'Annual'),
    ('gate',                   'engineering-technology',    'Postgraduate',  'Annual'),
    ('imu-cet',                'engineering-technology',    'Undergraduate', 'Annual'),
    ('polytechnic-cet',        'engineering-technology',    'Diploma',       'Annual'),
    ('rrb-je',                 'engineering-technology',    'Recruitment',   'As notified'),
    ('isro-icrb',              'engineering-technology',    'Recruitment',   'Annual'),

    -- Design, not engineering: UCEED and NID DAT are design aptitude tests,
    -- and NATA admits to B.Arch, which sits under Design & Creative here.
    ('uceed',                  'design-creative',           'Undergraduate', 'Annual'),
    ('nid-dat',                'design-creative',           'Undergraduate', 'Annual'),
    ('nata',                   'design-creative',           'Undergraduate', 'Annual'),

    ('neet-ug',                'medical-healthcare',        'Undergraduate', 'Annual'),
    ('neet-pg',                'medical-healthcare',        'Postgraduate',  'Annual'),

    ('cat',                    'management-business',       'Postgraduate',  'Annual'),
    ('pmp',                    'management-business',       'Certification', 'Rolling'),

    ('nimcet',                 'it-software',               'Postgraduate',  'Annual'),

    ('clat',                   'law',                       'Undergraduate', 'Annual'),
    ('judicial-services-exam', 'law',                       'Recruitment',   'As notified'),

    ('upsc-cse',               'government-civil-services', 'Recruitment',   'Annual'),
    ('sebi-grade-a',           'government-civil-services', 'Recruitment',   'Annual'),

    ('cds-exam',               'defence',                   'Recruitment',   'Biannual'),
    ('nda-exam',               'defence',                   'Recruitment',   'Biannual'),

    ('ibps-po',                'banking-insurance',         'Recruitment',   'Annual'),
    ('ibps-so-it',             'banking-insurance',         'Recruitment',   'Annual'),

    ('ca-foundation',          'commerce-finance',          'Certification', 'Biannual'),
    ('cs-foundation',          'commerce-finance',          'Certification', 'Biannual'),

    ('ctet',                   'education-teaching',        'Certification', 'Biannual'),
    ('ugc-net',                'education-teaching',        'Research',      'Biannual'),

    ('csir-net',               'science-research',          'Research',      'Biannual'),
    ('jrf',                    'science-research',          'Research',      'Biannual'),

    ('icar-aieea',             'agriculture',               'Undergraduate', 'Annual'),
    ('nchmct-jee',             'hospitality-tourism',       'Undergraduate', 'Annual'),

    -- No field: CUET admits to every discipline in the central universities,
    -- and NTSE is a general school-level talent search. Tagging either with
    -- one category would be a claim the exam itself does not make.
    ('cuet',                   NULL,                        'Undergraduate', 'Annual'),
    ('ntse',                   NULL,                        'School',        'Annual')
) AS v(slug, category_slug, level, frequency_type)
WHERE e.slug = v.slug;

ALTER TABLE exams ALTER COLUMN level SET NOT NULL;
ALTER TABLE exams ALTER COLUMN frequency_type SET NOT NULL;

ALTER TABLE exams ADD CONSTRAINT exams_level_known CHECK (
    level IN ('School', 'Diploma', 'Undergraduate', 'Postgraduate',
              'Research', 'Certification', 'Recruitment')
);

ALTER TABLE exams ADD CONSTRAINT exams_frequency_type_known CHECK (
    frequency_type IN ('Annual', 'Biannual', 'Quarterly', 'Monthly', 'Rolling', 'As notified')
);

DO $$
DECLARE bad int; missing text;
BEGIN
    -- The NOT NULL above would already have failed, but this names the rows.
    SELECT count(*), string_agg(slug, ', ') INTO bad, missing FROM exams
    WHERE level IS NULL OR frequency_type IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% exam(s) were missed by the seed: %', bad, missing;
    END IF;

    -- Only the two deliberately field-less exams may lack a category.
    SELECT count(*), string_agg(slug, ', ') INTO bad, missing FROM exams
    WHERE category_slug IS NULL AND slug NOT IN ('cuet', 'ntse');
    IF bad > 0 THEN
        RAISE EXCEPTION '% exam(s) got no field category: %', bad, missing;
    END IF;

    -- The normalised frequency must agree with the prose it came from: every
    -- exam whose text says "twice" is Biannual, and no exam whose text says
    -- "Once a year" was bucketed as anything else. A silent mismatch here is
    -- the exact failure the normalisation exists to prevent.
    SELECT count(*), string_agg(slug, ', ') INTO bad, missing FROM exams
    WHERE (frequency ILIKE '%twice%' AND frequency_type <> 'Biannual')
       OR (frequency ILIKE 'once a year%' AND frequency_type <> 'Annual');
    IF bad > 0 THEN
        RAISE EXCEPTION '% exam(s) have a frequency_type contradicting their frequency text: %', bad, missing;
    END IF;

    SELECT count(*) INTO bad FROM exams;
    IF bad <> 34 THEN
        RAISE EXCEPTION 'expected 34 exams, found % -- the seed above is keyed by slug and would need updating', bad;
    END IF;

    -- Every level bucket must hold something; an empty facet is a dead
    -- control on the page.
    SELECT count(*) INTO bad FROM (VALUES
        ('School'), ('Diploma'), ('Undergraduate'), ('Postgraduate'),
        ('Research'), ('Certification'), ('Recruitment')
    ) AS v(level)
    WHERE NOT EXISTS (SELECT 1 FROM exams e WHERE e.level = v.level);
    IF bad > 0 THEN
        RAISE EXCEPTION '% exam level(s) have no exams -- remove them or assign one', bad;
    END IF;
END $$;
