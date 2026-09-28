-- Fills one specialization -- Artificial Intelligence & Machine Learning --
-- across every relation the page reads, so the new Specialization page has a
-- fully-populated case to be built and judged against.
--
-- WHY ONE, NOT 263. Every relation here is a claim a student would act on:
-- which colleges teach this, which exams get you in, which degrees qualify
-- you. Those are researched per field, not generated. AI is filled because it
-- is the one being designed against; the other 262 render through the page's
-- labelled career-level fallback (see V108's header) until someone fills them.
--
-- Nothing here is invented: every college listed runs a real AI/ML programme
-- or centre, every exam is a real route into it, and the four resources are
-- long-standing free courses at stable URLs.

-- --------------------------------------------------------------------------
-- New reference rows the seed needs. All additive; nothing is repointed.
-- --------------------------------------------------------------------------

-- NLP is named on every AI syllabus and was the one core skill missing from
-- the 412-row catalog. skill_type follows the existing 'Technical' value used
-- by machine-learning rather than inventing a category.
INSERT INTO skills (slug, name, skill_type) VALUES
    ('natural-language-processing', 'Natural Language Processing', 'Technical')
ON CONFLICT (slug) DO NOTHING;

-- Two sectors. `industries` already separates sectors from employers via
-- is_sector (10 sectors, 303 employers), so these join the sector side --
-- "Related Industries" on a specialization means the FIELD it is applied in,
-- which is a different question from "who hires for it".
INSERT INTO industries (slug, name, is_sector) VALUES
    ('robotics', 'Robotics', true),
    ('research-and-development', 'Research & Development', true)
ON CONFLICT (slug) DO NOTHING;

-- Four resources. Real, free, and stable enough to hard-code: each has been
-- at the same URL for years and is a standard first recommendation in the
-- field. resource_type reuses the existing Guide/Website/Article vocabulary
-- plus 'Course', which is what three of these actually are -- the column has
-- no constraint and the card renders the value verbatim.
INSERT INTO resources (slug, title, resource_type, description, content_url, author) VALUES
    ('elements-of-ai',
     'Elements of AI',
     'Course',
     'A free introductory course on what AI is, what it can and cannot do, and how it is built -- written for people with no programming background.',
     'https://www.elementsofai.com',
     'University of Helsinki & MinnaLearn'),

    ('google-ml-crash-course',
     'Machine Learning Crash Course',
     'Course',
     'A practical introduction to machine learning covering regression, classification, neural networks and generalisation, with interactive exercises in TensorFlow.',
     'https://developers.google.com/machine-learning/crash-course',
     'Google'),

    ('kaggle-learn',
     'Kaggle Learn',
     'Website',
     'Short hands-on tracks in Python, pandas, machine learning, deep learning and computer vision, each ending in a real dataset exercise.',
     'https://www.kaggle.com/learn',
     'Kaggle'),

    ('fast-ai-practical-deep-learning',
     'Practical Deep Learning for Coders',
     'Course',
     'A code-first deep learning course that builds working models from the first lesson before working back to the underlying theory.',
     'https://course.fast.ai',
     'fast.ai')
ON CONFLICT (slug) DO NOTHING;

-- --------------------------------------------------------------------------
-- The specialization itself.
-- --------------------------------------------------------------------------

-- `description` stays one line: it is what cards and search results show.
-- `overview` is the "what you will learn" body, and answers a different
-- question -- what the field covers, rather than where it sits.
UPDATE specializations SET
    description = 'Artificial Intelligence and Machine Learning is the branch of computer science concerned with building systems that learn from data, reason about it and make decisions -- spanning machine learning, deep learning, natural language processing, computer vision and robotics.',
    overview = 'This specialization covers the mathematics and engineering behind intelligent systems: supervised and unsupervised learning, neural network architectures, natural language processing, computer vision, and the practice of taking a trained model into production. Expect a heavy grounding in linear algebra, probability and statistics alongside Python, and project work on real datasets rather than only theory.',
    highlights = ARRAY[
        'Applied across almost every industry, not just software',
        'Among the fastest-growing hiring areas in India',
        'Research-driven -- the field changes year to year',
        'Skills transfer internationally with little retraining'
    ],
    demand = 'HIGH'
WHERE slug = 'artificial-intelligence-and-machine-learning';

-- --------------------------------------------------------------------------
-- Relations. Every sort_order below is dense 0..n-1 per owning row, because
-- check_relationship_integrity() fails the next boot otherwise.
-- --------------------------------------------------------------------------

-- Education. Degree + optional subject, so these compose as "B.Tech
-- (Artificial Intelligence)" rather than a bare "B.Tech" that says nothing
-- about the field. MCA carries no subject -- the qualification already names
-- its field, the same reason MBBS takes none.
INSERT INTO specialization_degrees (specialization_slug, degree_slug, subject_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'b-tech', 'artificial-intelligence', 0),
    ('artificial-intelligence-and-machine-learning', 'b-sc',   'data-science',            1),
    ('artificial-intelligence-and-machine-learning', 'm-tech', 'artificial-intelligence', 2),
    ('artificial-intelligence-and-machine-learning', 'msc',    'computer-science',        3),
    ('artificial-intelligence-and-machine-learning', 'mca',    NULL,                      4),
    ('artificial-intelligence-and-machine-learning', 'phd',    'computer-science',        5);

-- Entrance exams: the two undergraduate routes (JEE for the IITs/NITs, BITSAT
-- for BITS) and the postgraduate one (GATE).
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'gate',         0),
    ('artificial-intelligence-and-machine-learning', 'jee-main',     1),
    ('artificial-intelligence-and-machine-learning', 'jee-advanced', 2),
    ('artificial-intelligence-and-machine-learning', 'bitsat',       3);

INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'python',                      0),
    ('artificial-intelligence-and-machine-learning', 'machine-learning',            1),
    ('artificial-intelligence-and-machine-learning', 'deep-learning',               2),
    ('artificial-intelligence-and-machine-learning', 'data-analysis',               3),
    ('artificial-intelligence-and-machine-learning', 'natural-language-processing', 4),
    ('artificial-intelligence-and-machine-learning', 'computer-vision',             5),
    ('artificial-intelligence-and-machine-learning', 'mathematics',                 6),
    ('artificial-intelligence-and-machine-learning', 'probability-theory',          7),
    ('artificial-intelligence-and-machine-learning', 'statistics',                  8),
    ('artificial-intelligence-and-machine-learning', 'tensorflow',                  9),
    ('artificial-intelligence-and-machine-learning', 'pytorch',                    10),
    ('artificial-intelligence-and-machine-learning', 'data-structures-algorithms', 11),
    ('artificial-intelligence-and-machine-learning', 'mlops',                      12),
    ('artificial-intelligence-and-machine-learning', 'generative-ai',              13),
    ('artificial-intelligence-and-machine-learning', 'cloud-platforms',            14),
    ('artificial-intelligence-and-machine-learning', 'data-visualization',         15);

INSERT INTO specialization_soft_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'analytical-thinking', 0),
    ('artificial-intelligence-and-machine-learning', 'problem-solving',     1),
    ('artificial-intelligence-and-machine-learning', 'critical-thinking',   2),
    ('artificial-intelligence-and-machine-learning', 'research',            3),
    ('artificial-intelligence-and-machine-learning', 'communication',       4),
    ('artificial-intelligence-and-machine-learning', 'teamwork',            5);

-- Sectors the field is applied in -- all is_sector rows, none are employers.
INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'information-technology',   0),
    ('artificial-intelligence-and-machine-learning', 'healthcare',               1),
    ('artificial-intelligence-and-machine-learning', 'fintech',                  2),
    ('artificial-intelligence-and-machine-learning', 'e-commerce',               3),
    ('artificial-intelligence-and-machine-learning', 'automotive',               4),
    ('artificial-intelligence-and-machine-learning', 'robotics',                 5),
    ('artificial-intelligence-and-machine-learning', 'research-and-development', 6),
    ('artificial-intelligence-and-machine-learning', 'education',                7);

INSERT INTO specialization_resources (specialization_slug, resource_slug, sort_order) VALUES
    ('artificial-intelligence-and-machine-learning', 'elements-of-ai',                  0),
    ('artificial-intelligence-and-machine-learning', 'google-ml-crash-course',          1),
    ('artificial-intelligence-and-machine-learning', 'kaggle-learn',                    2),
    ('artificial-intelligence-and-machine-learning', 'fast-ai-practical-deep-learning', 3);

-- Colleges. college_specializations is keyed (college, specialization) and its
-- sort_order is dense PER COLLEGE -- each of these five gains its first
-- specialization row, so all five are 0. Each runs a named AI/ML programme or
-- research centre rather than merely a CSE department.
INSERT INTO college_specializations (college_slug, specialization_slug, sort_order) VALUES
    ('iit-bombay',    'artificial-intelligence-and-machine-learning', 0),
    ('iit-delhi',     'artificial-intelligence-and-machine-learning', 0),
    ('iit-madras',    'artificial-intelligence-and-machine-learning', 0),
    ('iit-kanpur',    'artificial-intelligence-and-machine-learning', 0),
    ('iit-hyderabad', 'artificial-intelligence-and-machine-learning', 0);

-- --------------------------------------------------------------------------

DO $$
DECLARE
    spec CONSTANT text := 'artificial-intelligence-and-machine-learning';
    bad int;
BEGIN
    SELECT count(*) INTO bad FROM specializations
    WHERE slug = spec AND overview IS NOT NULL AND cardinality(highlights) = 4;
    IF bad <> 1 THEN
        RAISE EXCEPTION 'the AI specialization did not get its overview and highlights';
    END IF;

    -- Each relation must be non-empty AND dense from 0, since a gap here fails
    -- the boot after this one rather than this migration.
    FOR bad IN
        SELECT 1 FROM (
            SELECT 'specialization_degrees' t, min(sort_order) lo, max(sort_order) hi, count(*) n
              FROM specialization_degrees WHERE specialization_slug = spec
            UNION ALL SELECT 'specialization_exams', min(sort_order), max(sort_order), count(*)
              FROM specialization_exams WHERE specialization_slug = spec
            UNION ALL SELECT 'specialization_hard_skills', min(sort_order), max(sort_order), count(*)
              FROM specialization_hard_skills WHERE specialization_slug = spec
            UNION ALL SELECT 'specialization_soft_skills', min(sort_order), max(sort_order), count(*)
              FROM specialization_soft_skills WHERE specialization_slug = spec
            UNION ALL SELECT 'specialization_industries', min(sort_order), max(sort_order), count(*)
              FROM specialization_industries WHERE specialization_slug = spec
            UNION ALL SELECT 'specialization_resources', min(sort_order), max(sort_order), count(*)
              FROM specialization_resources WHERE specialization_slug = spec
        ) x
        WHERE n = 0 OR lo <> 0 OR hi <> n - 1
    LOOP
        RAISE EXCEPTION 'a seeded AI relation is empty or not dense 0..n-1';
    END LOOP;

    SELECT count(*) INTO bad FROM college_specializations WHERE specialization_slug = spec;
    IF bad <> 5 THEN
        RAISE EXCEPTION 'expected 5 colleges for the AI specialization, found %', bad;
    END IF;

    -- The four resources must exist and be linked; a typo would otherwise show
    -- as a quietly shorter list.
    SELECT count(*) INTO bad FROM specialization_resources sr
    JOIN resources r ON r.slug = sr.resource_slug
    WHERE sr.specialization_slug = spec AND r.content_url IS NOT NULL;
    IF bad <> 4 THEN
        RAISE EXCEPTION 'expected 4 linked resources with a URL, found %', bad;
    END IF;

    -- Every industry attached must be a sector, not an employer -- the whole
    -- point of using is_sector here.
    SELECT count(*) INTO bad FROM specialization_industries si
    JOIN industries i ON i.slug = si.industry_slug
    WHERE si.specialization_slug = spec AND NOT i.is_sector;
    IF bad > 0 THEN
        RAISE EXCEPTION '% employer row(s) attached where sectors were intended', bad;
    END IF;

    -- Education must compose to something specific: at least the two AI rows
    -- must carry a subject, or the page shows a bare "B.Tech" again.
    SELECT count(*) INTO bad FROM specialization_degrees
    WHERE specialization_slug = spec AND subject_slug IS NOT NULL;
    IF bad <> 5 THEN
        RAISE EXCEPTION 'expected 5 subject-bearing education rows, found %', bad;
    END IF;
END $$;
