-- Fills the Government & Civil Services category, which had zero careers, by
-- moving one career that was misfiled and adding one that was missing.
--
-- PUBLIC ADMINISTRATION WAS FILED UNDER LAW, and not only in the wrong category:
-- its work_environments read "Law Firms, Corporate Legal Teams, Courts,
-- Chambers", which are the Law category's environments applied wholesale to
-- everything under it. A public administrator does not work in a court or a
-- chambers; they work in a secretariat. Its salary range was also an unsourced
-- 3L-25L, and its highlights were empty. So this moves it, corrects the
-- environments, sources the pay and gives it highlights -- the category was the
-- least of what was wrong with it.
--
-- POLITICAL SCIENCE WAS MISSING ENTIRELY -- not a career, not even a subject,
-- despite being one of the most-taken degrees in Indian universities and the
-- most popular optional in the civil services exam. Added here with its subject
-- row and its degree pairs, following the pattern economics uses: a generic
-- degree family plus the subject it is taken in, composed into
-- "B.A. (Political Science)" at render time.
--
-- WHY THESE TWO ARE DISTINCT, since both lead to the civil service. Public
-- Administration studies how the state is organised and run -- budgeting,
-- personnel, service delivery. Political Science studies power itself -- how it
-- is won, constrained and contested. They share an exam and diverge everywhere
-- else: one produces administrators, the other produces academics, analysts and
-- journalists as readily as officers. Their pay anchors reflect that split.
--
-- SOURCES. Retrieved 2026-09-28. The schema records no provenance, so this
-- header is the audit trail.
--
--   public-administration -- the 7th CPC pay matrix for the UPSC Civil Services
--   cadres (IAS/IPS), which is the recognised route:
--       entry (Junior Time Scale)  Level 10, basic 56,100 / month
--       Cabinet Secretary          Level 18, fixed 2,50,000 / month
--     https://vajiramandravi.com/upsc-exam/ias-salary/
--     https://byjus.com/free-ias-prep/ias-salary/
--
--   political-science -- the UGC academic pay matrix, the route this discipline
--   most distinctively leads to:
--       Assistant Professor (NET-qualified)  Academic Level 10, basic 57,700
--       Professor                            Academic Level 14, 1,44,200 to 2,18,200
--     https://7thpaycommissionnews.in/ugc-pay-revision-as-per-7th-pay-commission/
--     https://testbook.com/government-teacher-jobs/professor-salary
--
-- HOW THE LPA RANGES WERE DERIVED -- BASIC PAY ONLY, monthly x 12, excluding DA,
-- HRA and transport, the same method as V118, V120 and V121 so all four batches
-- are comparable.
--
--       public-administration  56,100 x 12 = 6.73L  ->  2,50,000 x 12 = 30.00L
--       political-science      57,700 x 12 = 6.92L  ->  2,18,200 x 12 = 26.18L
--
-- Public Administration's growth_path is extended to Cabinet Secretary so the
-- ladder reaches the post its ceiling is taken from; ending at Secretary while
-- quoting the apex figure would not match.

-- 1. The subject moves too, so the category the degree title inherits is right.
UPDATE subjects SET category_slug = 'government-civil-services'
WHERE slug = 'public-administration';

INSERT INTO subjects (slug, title, description, icon, category_slug) VALUES
    ('political-science',
     'Political Science',
     'The study of power and government: political theory, comparative politics, public policy and international relations.',
     'scale',
     'government-civil-services');

INSERT INTO degree_subjects (degree_slug, subject_slug) VALUES
    ('ba',  'political-science'),
    ('ma',  'political-science'),
    ('phd', 'political-science');

-- 2. Public Administration: moved, and corrected.
UPDATE careers SET
    category_slug = 'government-civil-services',
    salary_range = '₹6.73L – ₹30L / year',
    salary_min_lpa = 6.73,
    salary_max_lpa = 30.00,
    -- Was "Law Firms, Corporate Legal Teams, Courts, Chambers" -- the Law
    -- category's environments, inherited by everything filed under it.
    work_environments = ARRAY['Government Bodies', 'Corporate Offices', 'Field Work', 'Universities'],
    growth_path = ARRAY['Administrative Trainee', 'Section Officer', 'Deputy Secretary', 'Joint Secretary', 'Secretary', 'Cabinet Secretary'],
    highlights = ARRAY[
        'Entered through the UPSC Civil Services Examination, open to any graduate',
        'Pay follows the published 7th CPC matrix, from Level 10 to the apex scale',
        'The syllabus doubles as a civil services optional subject',
        'Postings span districts, state secretariats and central ministries'
    ]
WHERE slug = 'public-administration';

-- 3. Political Science: new.
INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES (
    'political-science',
    'Political Science',
    'government-civil-services',
    'Political Science -- specializations, skills & career paths',
    'Stable',
    'Professionals in Political Science research how institutions and power actually behave, teach it, analyse policy and elections for governments, media and think tanks, and write the arguments that public debate is conducted with.',
    '₹6.92L – ₹26.18L / year',
    6.92, 26.18,
    ARRAY['Research Assistant', 'Assistant Professor', 'Associate Professor', 'Professor', 'Policy Adviser'],
    'scale',
    'Political Science studies power: how governments are formed and constrained, why institutions hold or fail, how policy is actually made rather than how it is described. It is a research discipline before it is a route to office -- the training is in theory, comparative method and argument. In India it is entered through a BA and MA, with UGC-NET the gate into university teaching, and it is the most-taken optional in the civil services examination. The same skills read across into policy research, journalism and international organisations, which is why the degree travels further than its name suggests.',
    ARRAY[
        'The most popular optional subject in the UPSC civil services examination',
        'UGC-NET is the gate into university teaching, on the published academic pay matrix',
        'Reads across into policy research, journalism and international organisations',
        'Entered through BA and MA -- no professional qualification required'
    ],
    ARRAY['Universities', 'Government Bodies', 'Media Houses', 'NGOs'],
    1
);

INSERT INTO career_degrees (career_slug, degree_slug, subject_slug, sort_order) VALUES
    ('political-science', 'ba',  'political-science', 0),
    ('political-science', 'ma',  'political-science', 1),
    ('political-science', 'phd', 'political-science', 2);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('political-science', 'cuet', 0),
    ('political-science', 'ugc-net', 1),
    ('political-science', 'upsc-cse', 2);

-- Public Administration may already be linked to upsc-cse; guard rather than
-- assume, since a duplicate would violate the primary key.
INSERT INTO career_exams (career_slug, exam_slug, sort_order)
SELECT 'public-administration', 'upsc-cse',
       COALESCE((SELECT max(sort_order) + 1 FROM career_exams WHERE career_slug = 'public-administration'), 0)
WHERE NOT EXISTS (
    SELECT 1 FROM career_exams WHERE career_slug = 'public-administration' AND exam_slug = 'upsc-cse');

-- The mirror: career_exams and exam_careers are compared on every boot.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT p.exam_slug, p.career_slug,
       COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = p.exam_slug), 0)
         + row_number() OVER (PARTITION BY p.exam_slug ORDER BY p.career_slug) - 1
FROM (
    SELECT ce.exam_slug, ce.career_slug
    FROM career_exams ce
    WHERE ce.career_slug IN ('political-science', 'public-administration')
      AND NOT EXISTS (SELECT 1 FROM exam_careers x
                      WHERE x.exam_slug = ce.exam_slug AND x.career_slug = ce.career_slug)
) p;

-- sort_order is NOT NULL with no default and density 0..n-1 per career is
-- asserted on boot.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('political-science', 'research', 0),
    ('political-science', 'analytical-thinking', 1),
    ('political-science', 'report-writing', 2),
    ('political-science', 'communication', 3),
    ('political-science', 'data-analysis', 4);

-- No sort_order on career_industries.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('political-science', 'government'),
    ('political-science', 'education'),
    ('political-science', 'research-and-development'),
    ('political-science', 'social-development'),
    ('political-science', 'media-entertainment');

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM careers
    WHERE slug IN ('political-science', 'public-administration')
      AND category_slug = 'government-civil-services';
    IF n <> 2 THEN RAISE EXCEPTION 'expected both careers in government-civil-services, found %', n; END IF;

    -- The environments must no longer be the Law category's.
    SELECT count(*) INTO n FROM careers
    WHERE slug = 'public-administration'
      AND EXISTS (SELECT 1 FROM unnest(work_environments) w WHERE w IN ('Courts', 'Chambers', 'Law Firms'));
    IF n > 0 THEN RAISE EXCEPTION 'public-administration still carries Law work environments'; END IF;

    -- Law keeps its own career; this must not have emptied a category to fill one.
    SELECT count(*) INTO n FROM careers WHERE category_slug = 'law';
    IF n < 1 THEN RAISE EXCEPTION 'the law category was left empty by the move'; END IF;

    -- The completeness gate, same as V118, V120 and V121.
    SELECT count(*) INTO n FROM careers c
    WHERE c.slug IN ('political-science', 'public-administration')
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d    WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e      WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s     WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN RAISE EXCEPTION '% career(s) fall short of the completeness gate', n; END IF;

    -- Every degree row must name a pair that exists, or the page shows a bare
    -- "B.A." with no subject.
    SELECT count(*) INTO n FROM career_degrees cd
    WHERE cd.career_slug IN ('political-science', 'public-administration')
      AND cd.subject_slug IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM degree_subjects ds
                      WHERE ds.degree_slug = cd.degree_slug AND ds.subject_slug = cd.subject_slug);
    IF n > 0 THEN RAISE EXCEPTION '% degree row(s) name a degree/subject pair that does not exist', n; END IF;

    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n; END IF;
END $$;
