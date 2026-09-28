-- Fills the Education & Teaching category, which had zero careers.
--
-- Nine of the twenty categories are empty; this is the first of them, chosen
-- because it needs no new supporting rows and overlaps nothing. The degrees
-- (b-ed, b-el-ed, m-ed, bped, mped), the exams (ctet, ugc-net) and the
-- industries (education as a sector, plus four employers) were all already in
-- the catalog with nothing pointing at them.
--
-- SOURCES. Every figure below is traceable, because the schema has nowhere to
-- record provenance and this header is therefore the only audit trail. Retrieved
-- 2026-09-28.
--
--   Pay: 7th Central Pay Commission pay matrix levels, as published for
--   Kendriya Vidyalaya Sangathan teaching posts (KVS is central government, so
--   these are official scales rather than survey estimates):
--       PRT       Level 6   basic  35,400 - 1,12,400 / month
--       TGT       Level 7   basic  44,900 - 1,42,400 / month
--       PGT       Level 8   basic  47,600 - 1,51,100 / month
--       Principal Level 12  basic  78,800 - 2,09,200 / month
--     https://www.pw.live/teaching/exams/kvs-teacher-salary
--     https://prepp.in/kvs-recruitment-exam/salary
--
--   Qualifications: NCTE is the statutory regulator; its minimum-qualification
--   gazette notifications define which degree admits to which teaching level.
--     https://web.ncte.gov.in/page/minimum-qualifications-of-teachers
--   Route summary (D.El.Ed / B.El.Ed -> primary, graduation + B.Ed -> TGT,
--   post-graduation + B.Ed -> PGT, CTET/TET as the eligibility test):
--     https://en.wikipedia.org/wiki/Teacher_Eligibility_Test
--
-- HOW THE LPA RANGES WERE DERIVED, since the honest answer matters more than a
-- confident-looking number. They are BASIC PAY ONLY, converted from the monthly
-- matrix figures above (x12), and therefore UNDERSTATE actual earnings -- DA
-- (55% of basic as of January 2026), HRA and transport allowance are excluded
-- because they vary by posting city and change with every DA revision, so
-- baking them in would produce a figure that is wrong within months. A career's
-- floor is its entry level's matrix minimum; its ceiling is the top of the
-- highest post that career normally reaches.
--
--       education            PRT floor  35,400x12 = 4.25L   Principal ceiling 2,09,200x12 = 25.10L
--       elementary-education PRT floor  35,400x12 = 4.25L   Headmaster/L8 ceiling 1,51,100x12 = 18.13L
--       physical-education   TGT floor  44,900x12 = 5.39L   PGT ceiling 1,51,100x12 = 18.13L
--       special-education    TGT floor  44,900x12 = 5.39L   PGT ceiling 1,51,100x12 = 18.13L
--
-- Private-school pay is deliberately not represented. It ranges from below the
-- government floor to well above its ceiling, no official aggregate exists, and
-- the commercial salary aggregators that publish estimates do not permit their
-- figures being republished. A wide invented range would be worse than a narrow
-- sourced one.
--
-- `demand` uses the existing vocabulary (High Demand / Stable / Evergreen /
-- Competitive / Emerging) rather than a new value. Teaching is Evergreen: the
-- posts exist in every district in perpetuity, which is a different claim from
-- "High Demand" and the catalog already distinguishes the two.

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES
(
    'education',
    'Education',
    'education-teaching',
    'Education -- specializations, skills & career paths',
    'Evergreen',
    'Professionals in Education teach a subject to secondary and senior secondary classes, plan lessons against a board syllabus, assess student work and take on pastoral responsibility for a class, progressing into coordination and school leadership.',
    '₹4.25L – ₹25L / year',
    4.25, 25.10,
    ARRAY['Trained Graduate Teacher (TGT)', 'Post Graduate Teacher (PGT)', 'Subject Coordinator', 'Vice Principal', 'Principal'],
    'teach',
    'Education is the discipline of teaching and learning: how a subject is broken down, sequenced and assessed so that a class of thirty actually learns it. In India the route runs through a bachelor''s degree in the subject followed by a B.Ed, with a Teacher Eligibility Test for government posts. It is the largest organised profession in the country -- every district recruits every year -- and the pay scales for government posts are fixed and published rather than negotiated.',
    ARRAY['Government posts follow published 7th CPC pay matrix levels', 'CTET or a state TET is the gateway to government school posts', 'Recruitment happens in every district, not only in metros'],
    ARRAY['Schools', 'Government Bodies', 'Universities', 'Coaching Centres'],
    0
),
(
    'elementary-education',
    'Elementary Education',
    'education-teaching',
    'Elementary Education -- specializations, skills & career paths',
    'Evergreen',
    'Professionals in Elementary Education teach all subjects to classes I to V, build foundational literacy and numeracy, work with parents on a child''s progress and advance into primary-school coordination and headship.',
    '₹4.25L – ₹18.13L / year',
    4.25, 18.13,
    ARRAY['Primary Teacher (PRT)', 'Senior Primary Teacher', 'Primary Coordinator', 'Headmaster'],
    'cap',
    'Elementary Education is a separate discipline from secondary teaching, not a junior version of it. A primary teacher teaches every subject to one class rather than one subject to every class, and the training is about how children first acquire reading, writing and number sense. Its own qualifications reflect that: a D.El.Ed diploma or a four-year B.El.Ed degree, rather than a subject degree plus B.Ed.',
    ARRAY['A distinct qualification route: D.El.Ed or B.El.Ed, not subject degree + B.Ed', 'Foundational literacy and numeracy is a stated national priority', 'One teacher covers all subjects for a single class'],
    ARRAY['Schools', 'Government Bodies', 'NGOs'],
    1
),
(
    'physical-education',
    'Physical Education',
    'education-teaching',
    'Physical Education -- specializations, skills & career paths',
    'Stable',
    'Professionals in Physical Education run games and fitness periods, coach school teams for inter-school and district competition, teach the theory paper at senior secondary level and manage sports facilities and events.',
    '₹5.39L – ₹18.13L / year',
    5.39, 18.13,
    ARRAY['Physical Education Teacher', 'Sports Coach', 'Head of Physical Education', 'Sports Director'],
    'trophy',
    'Physical Education is taught as a subject with its own degrees -- B.P.Ed and M.P.Ed -- and its own board paper at senior secondary level, which is why it sits here rather than under Sports & Fitness. The work combines instruction with coaching: the same person who teaches the theory syllabus usually prepares the school''s teams and runs its annual sports meet.',
    ARRAY['Has its own degrees (B.P.Ed, M.P.Ed) and its own board subject', 'Combines classroom teaching with competitive coaching', 'CBSE requires a physical education teacher at every school'],
    ARRAY['Schools', 'Fitness Centres', 'Universities', 'Government Bodies'],
    2
),
(
    'special-education',
    'Special Education',
    'education-teaching',
    'Special Education -- specializations, skills & career paths',
    'Emerging',
    'Professionals in Special Education assess individual learning needs, write and review individualised education plans, adapt teaching material for specific disabilities and work alongside therapists and mainstream class teachers.',
    '₹5.39L – ₹18.13L / year',
    5.39, 18.13,
    ARRAY['Special Educator', 'Senior Special Educator', 'Resource Room Coordinator', 'Head of Inclusion'],
    'heart',
    'Special Education is the practice of teaching students with disabilities and specific learning difficulties, whether in a resource room or alongside a mainstream class. It is regulated separately from general teaching: practitioners register with the Rehabilitation Council of India, and the qualification is a B.Ed in Special Education in a named disability area. Demand is growing because inclusive education is now a statutory requirement rather than a school''s choice, and trained special educators are in short supply.',
    ARRAY['Requires registration with the Rehabilitation Council of India', 'Inclusive education is a statutory requirement, not optional', 'Qualification is disability-specific, not general'],
    ARRAY['Schools', 'Clinics', 'NGOs', 'Freelance'],
    3
);

-- Degrees. Ordered, so sort_order is positional and dense per career.
INSERT INTO career_degrees (career_slug, degree_slug, sort_order) VALUES
    ('education', 'b-ed', 0),
    ('education', 'm-ed', 1),
    ('elementary-education', 'b-el-ed', 0),
    ('elementary-education', 'b-ed', 1),
    ('physical-education', 'bped', 0),
    ('physical-education', 'mped', 1),
    ('special-education', 'b-ed', 0),
    ('special-education', 'm-ed', 1);

-- Exams. CTET for school posts; UGC-NET only where the route continues into
-- higher education, which is true for the two that have a master's route.
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('education', 'ctet', 0),
    ('education', 'ugc-net', 1),
    ('elementary-education', 'ctet', 0),
    ('physical-education', 'ctet', 0),
    ('special-education', 'ctet', 0);

INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug,
       row_number() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
             + COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = ce.exam_slug), 0)
FROM career_exams ce
WHERE ce.career_slug IN ('education', 'elementary-education', 'physical-education', 'special-education');

-- Skills. sort_order is NOT NULL with no default here, and the boot-time
-- integrity check auto-discovers this table and asserts the values are dense
-- 0..n-1 per career, so they are written out positionally rather than left to a
-- default.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('education', 'communication', 0),
    ('education', 'classroom-management', 1),
    ('education', 'curriculum-design', 2),
    ('education', 'public-speaking', 3),
    ('education', 'patience', 4),
    ('elementary-education', 'patience', 0),
    ('elementary-education', 'classroom-management', 1),
    ('elementary-education', 'communication', 2),
    ('elementary-education', 'empathy', 3),
    ('physical-education', 'leadership', 0),
    ('physical-education', 'communication', 1),
    ('physical-education', 'teamwork', 2),
    ('physical-education', 'classroom-management', 3),
    ('special-education', 'empathy', 0),
    ('special-education', 'patience', 1),
    ('special-education', 'counselling', 2),
    ('special-education', 'adaptability', 3),
    ('special-education', 'communication', 4);

-- Industries: the sector plus the employers already in the catalog for it.
-- No sort_order on this table, unlike career_skills above.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('education', 'education'),
    ('education', 'government-schools-state-education-departments'),
    ('education', 'dav-public-schools'),
    ('education', 'delhi-public-school-dps-society'),
    ('elementary-education', 'education'),
    ('elementary-education', 'government-schools-state-education-departments'),
    ('physical-education', 'education'),
    ('physical-education', 'government-schools-state-education-departments'),
    ('special-education', 'education'),
    ('special-education', 'schools-colleges-counselling-roles');

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM careers WHERE category_slug = 'education-teaching';
    IF n <> 4 THEN
        RAISE EXCEPTION 'expected 4 Education & Teaching careers, found %', n;
    END IF;

    -- The quality gate this batch was written to: no career ships without a
    -- salary, at least two degrees, an exam, and three skills. A stub is worse
    -- than an absence, because an absence is visible on the admin dashboard and
    -- a stub looks finished.
    SELECT count(*) INTO n FROM careers c
    WHERE c.category_slug = 'education-teaching'
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN
        RAISE EXCEPTION '% new career(s) fall short of the completeness gate', n;
    END IF;

    -- career_exams and exam_careers are a mirror pair that the boot-time
    -- integrity check compares; a one-sided insert here would fail startup.
    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n;
    END IF;
END $$;
