-- Fills the Commerce & Finance category, which had zero careers.
--
-- Second of the empty categories, after Education & Teaching in V118. Like that
-- one it needs no new supporting rows: the degrees (b-com, m-com, and the ba/ma
-- families paired with the `economics` subject), the exams (cuet, ca-foundation,
-- sebi-grade-a) and the industry sectors are all already in the catalog.
--
-- It also removes one of the seven categories the assessment can name as a
-- reader's leading field while having nothing to show them.
--
-- WHY ONLY TWO CAREERS, AND WHICH TWO
--
-- Commerce & Finance sits next to Management & Business, which already holds
-- accounting, finance, business-administration, marketing and
-- human-resource-management. Adding "Finance" or "Accounting" here would be the
-- same overlap that put Computer Science in two categories, so the set is
-- restricted to disciplines with no home yet:
--
--   economics  A social science with its own degrees and its own method. It was
--              missing entirely -- `economics` existed as a SUBJECT, paired with
--              five degree families, with no career to reach it from.
--   commerce   The B.Com/M.Com discipline itself: how business is recorded,
--              taxed and regulated. Distinct from Accounting, which is the
--              professional practice one enters through it.
--
-- Company Secretaryship is deliberately ABSENT despite cs-foundation already
-- being in the catalog and ICSI being a statutory body. The reason is pay: the
-- only official figure published for it is ICSI's prescribed minimum stipend for
-- trainees, Rs 5,000 per month
-- (https://www.icsi.edu/media/filer_public/82/4a/824a88a3-2ef7-42ab-98f9-fa7a631ea29e/stipend_payable_students_during_trainingperiod_2.pdf),
-- which is a training allowance and not a career range -- using it as a floor
-- would say 0.6 LPA and mislead every reader. No official aggregate covers a
-- qualified CS's earnings. So it waits for a sourceable figure rather than
-- shipping with an invented one; two sourced careers beat three where one is
-- guessed.
--
-- SOURCES. Retrieved 2026-09-28. The schema records no provenance and this
-- header is the audit trail.
--
--   economics -- Union Public Service Commission's Indian Economic Service, the
--   central government's cadre for economists, on the 7th CPC pay matrix:
--       entry            Level 10, basic 56,100 / month
--       Principal Adviser  basic about 1,82,200 / month
--     https://testbook.com/upsc-ies/salary-job-profile
--     https://competition.careers360.com/articles/ese-salary
--
--   commerce -- Staff Selection Commission's Combined Graduate Level posts,
--   which are the audit and accounts route a commerce graduate enters:
--       Auditor / Accountant       Level 5, basic 29,200 / month
--       Assistant Audit Officer    Level 8, basic 47,600, scale to 1,51,100
--     https://www.studyiq.com/articles/ssc-cgl-salary/
--     https://testbook.com/ssc-cgl-exam/salary-job-profile
--
-- HOW THE LPA RANGES WERE DERIVED -- same method as V118, so the two batches are
-- comparable. BASIC PAY ONLY, monthly figure x 12. DA (55% of basic as of
-- January 2026), HRA and transport allowance are excluded because they vary by
-- posting city and move with every DA revision, so folding them in produces a
-- number that is wrong within months. The floor is the entry post's matrix
-- minimum; the ceiling is the top of the highest post the route normally
-- reaches.
--
--       economics  56,100 x 12 = 6.73L   ->  1,82,200 x 12 = 21.86L
--       commerce   29,200 x 12 = 3.50L   ->  1,51,100 x 12 = 18.13L
--
-- Private-sector pay is not represented, for the reason V118 gives: no official
-- aggregate exists and the commercial salary aggregators that estimate it do not
-- permit their figures being republished.
--
-- `demand` uses the existing vocabulary. Commerce is Evergreen -- every firm
-- needs its books kept, in every district, permanently. Economics is Stable
-- rather than High Demand: the specialist posts are real but far fewer, and
-- overstating it would be the kind of encouraging noise this catalog avoids.

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES
(
    'economics',
    'Economics',
    'commerce-finance',
    'Economics -- specializations, skills & career paths',
    'Stable',
    'Professionals in Economics build and test models of how people, firms and governments behave, turn data into forecasts and policy advice, and write the analysis that budgets, interest rates and regulation are argued from.',
    '₹6.73L – ₹21.86L / year',
    6.73, 21.86,
    ARRAY['Research Assistant', 'Economist', 'Senior Economist', 'Economic Adviser', 'Principal Adviser'],
    'chart',
    'Economics studies how limited resources get allocated -- why prices move, why some countries grow faster, what a tax change actually does. It is closer to a quantitative social science than to commerce: the training is in theory, statistics and econometrics, and the work is modelling and argument rather than bookkeeping. In India the clearest route is a BA or B.Sc in Economics followed by a master''s, with the Indian Economic Service the recognised path into government, and banks, regulators and research institutes hiring the same skills. It is also the discipline that most reliably converts a humanities degree into quantitative work.',
    ARRAY[
        'The Indian Economic Service recruits economists directly into government',
        'Entered through BA or B.Sc Economics, then a master''s -- no professional exam required',
        'Econometrics makes it a quantitative route from an arts stream',
        'Employers span government, banks, regulators and research institutes'
    ],
    ARRAY['Government Bodies', 'Universities', 'Consulting Firms', 'Corporate Offices'],
    0
),
(
    'commerce',
    'Commerce',
    'commerce-finance',
    'Commerce -- specializations, skills & career paths',
    'Evergreen',
    'Professionals in Commerce keep and audit the financial record of an organisation, prepare its statutory filings and tax returns, check transactions against the rules that govern them, and move into control and advisory work as they qualify further.',
    '₹3.5L – ₹18.13L / year',
    3.50, 18.13,
    ARRAY['Accounts Assistant', 'Auditor', 'Accountant', 'Assistant Audit Officer', 'Finance Manager'],
    'bank',
    'Commerce is the discipline of how business is recorded, taxed and regulated -- the B.Com route, and the widest-open door in Indian higher education. It sits underneath the professional qualifications rather than competing with them: a commerce degree is what candidates for CA, CS and CMA are studying while they sit those exams, and it is the eligibility for the audit and accounts posts recruited through the Staff Selection Commission. The work rewards precision over flair, and the qualifications stack -- each one taken while working raises the ceiling.',
    ARRAY[
        'The broadest entry route in Indian higher education -- B.Com needs no entrance exam at most universities',
        'Eligibility for the SSC audit and accounts posts, and the base for CA, CS and CMA',
        'Professional qualifications stack on top while you work',
        'Recruiting happens in every district, not only in metros'
    ],
    ARRAY['Corporate Offices', 'Government Bodies', 'Agencies', 'Consulting Firms'],
    1
);

-- Degrees. Economics follows the psychology/journalism pattern -- a generic
-- degree family plus the subject it is taken in, composed into "BA (Economics)"
-- at render time. Commerce has its own degree rows, so no subject is needed.
INSERT INTO career_degrees (career_slug, degree_slug, subject_slug, sort_order) VALUES
    ('economics', 'ba',    'economics', 0),
    ('economics', 'ma',    'economics', 1),
    ('economics', 'phd',   'economics', 2),
    ('commerce',  'b-com', NULL,        0),
    ('commerce',  'm-com', NULL,        1);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('economics', 'cuet', 0),
    ('economics', 'ugc-net', 1),
    ('commerce', 'cuet', 0),
    ('commerce', 'ca-foundation', 1),
    ('commerce', 'sebi-grade-a', 2);

-- The mirror. career_exams and exam_careers are the last mirrored pair in the
-- schema and the boot-time integrity check fails the container if they disagree,
-- so both sides are written and sort_order continues each exam's existing
-- sequence rather than restarting at 0.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug,
       COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = ce.exam_slug), 0)
         + row_number() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
FROM career_exams ce
WHERE ce.career_slug IN ('economics', 'commerce');

-- Skills. sort_order is NOT NULL with no default here and the integrity check
-- asserts density 0..n-1 per career, so positions are written out.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('economics', 'analytical-thinking', 0),
    ('economics', 'statistics', 1),
    ('economics', 'research', 2),
    ('economics', 'data-analysis', 3),
    ('economics', 'report-writing', 4),
    ('economics', 'mathematics', 5),
    ('commerce', 'accounting', 0),
    ('commerce', 'attention-to-detail', 1),
    ('commerce', 'financial-analysis', 2),
    ('commerce', 'compliance', 3),
    ('commerce', 'excel', 4),
    ('commerce', 'business-acumen', 5);

-- No sort_order on career_industries, unlike career_skills above.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('economics', 'government'),
    ('economics', 'banking'),
    ('economics', 'consulting'),
    ('economics', 'research-and-development'),
    ('commerce', 'banking'),
    ('commerce', 'consulting'),
    ('commerce', 'government'),
    ('commerce', 'fintech');

DO $$
DECLARE n int;
BEGIN
    -- Scoped to the two slugs this migration inserts rather than counting the
    -- category, so a later migration adding a third career here cannot retro-fail
    -- this one. That is the mistake V101/V102/V104/V112 made and 0c6d0ff fixed.
    SELECT count(*) INTO n FROM careers
    WHERE slug IN ('economics', 'commerce') AND category_slug = 'commerce-finance';
    IF n <> 2 THEN RAISE EXCEPTION 'expected both new careers in commerce-finance, found %', n; END IF;

    -- The completeness gate this batch was written to, same as V118: a stub looks
    -- finished while an absence is visible on the admin dashboard.
    SELECT count(*) INTO n FROM careers c
    WHERE c.slug IN ('economics', 'commerce')
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d    WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e      WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s     WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN RAISE EXCEPTION '% new career(s) fall short of the completeness gate', n; END IF;

    -- Economics is reachable through a subject pair; if the pair were missing the
    -- page would show a degree with no subject and read as plain "BA".
    SELECT count(*) INTO n FROM career_degrees cd
    WHERE cd.career_slug = 'economics'
      AND NOT EXISTS (SELECT 1 FROM degree_subjects ds
                      WHERE ds.degree_slug = cd.degree_slug AND ds.subject_slug = cd.subject_slug);
    IF n > 0 THEN RAISE EXCEPTION '% economics degree row(s) name a degree/subject pair that does not exist', n; END IF;

    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n; END IF;
END $$;
