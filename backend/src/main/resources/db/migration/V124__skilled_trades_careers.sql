-- Fills the Skilled Trades category, which had zero careers, and adds the ITI
-- qualification the catalog was missing.
--
-- Sixth empty category, and the first that needed groundwork rather than just
-- careers: there was no ITI degree row. The Industrial Training Institute
-- certificate is the entry qualification for most of the trades in India and the
-- catalog could not express it, so every skilled-trade career would have had to
-- claim a polytechnic diploma it does not require.
--
-- WHY THIS CATEGORY MATTERS MORE THAN ITS SIZE SUGGESTS. Every other category
-- here is entered through a degree. Skilled Trades is the one route in this
-- catalog that opens straight after class 10, which is exactly the reader the
-- After-10th stage exists for -- and both careers are filed into that stage
-- below, so the stage page and the exam page now agree with each other.
--
-- THE TWO CAREERS are trade families rather than job titles, so the hierarchy
-- holds: Electrical Trades has wireman, lineman and maintenance electrician as
-- roles beneath it, not as competing careers.
--
-- SOURCES. Retrieved 2026-09-28.
--
--   Railway Recruitment Board Technician Grade III, whose advertised
--   qualification is matriculation plus ITI -- the clearest published scale for
--   an ITI-qualified post:
--       Pay Level 2, basic 19,900 / month, progressing to 63,200 within the level
--     https://prepp.in/rrb-technician-exam/salary
--     https://www.careerpower.in/blog/rrb-technician-salary
--
-- HOW THE LPA RANGE WAS DERIVED. Basic pay only, monthly x 12, the same method as
-- V118 and V120-V123.
--
--       19,900 x 12 = 2.39L  ->  63,200 x 12 = 7.58L
--
-- THE CEILING IS DELIBERATELY THE TOP OF PAY LEVEL 2, NOT OF THE ROUTE. A
-- technician who passes departmental examinations moves to supervisory grades --
-- Senior Technician and then Junior Engineer on Level 6, which runs to
-- 1,12,400 a month -- so the real ceiling is far higher than 7.58L. That
-- progression is not quoted in the range because it depends on clearing further
-- exams, and a range that assumes them would describe the best case as the
-- expected one. It is stated in the highlights instead, where the reader sees
-- both the floor and the way past it. The same reasoning as excluding Military
-- Service Pay in V123, applied in the opposite direction.

-- Shaped like `diploma` and `certificate`, the other generic qualification
-- families: category_slug left NULL because the qualification is not itself tied
-- to one field, and requires_subject true because an ITI certificate is always
-- taken in a named trade. No trade subjects are created here -- that is the
-- natural next step, and this migration has no business claiming it -- but the
-- flag means "ITI (Electrician)" becomes expressible the moment they are.
INSERT INTO degrees (slug, title, description, icon, level, requires_subject, category_slug) VALUES
    ('iti',
     'ITI Certificate',
     'A one- or two-year National Trade Certificate from an Industrial Training Institute, entered straight after class 10 in a named trade such as Electrician, Fitter or Welder. Recognised nationally and the standard entry qualification for skilled technical work.',
     'wrench',
     'Certificate',
     true,
     NULL);

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES
(
    'electrical-trades',
    'Electrical Trades',
    'skilled-trades',
    'Electrical Trades -- specializations, skills & career paths',
    'Evergreen',
    'Workers in the Electrical Trades install and terminate wiring, fault-find and repair motors, panels and control gear, maintain supply equipment to safety standards, and progress into supervision and contracting.',
    '₹2.39L – ₹7.58L / year',
    2.39, 7.58,
    ARRAY['Trade Apprentice', 'Technician', 'Senior Technician', 'Supervisor', 'Junior Engineer'],
    'bolt',
    'The Electrical Trades cover the physical work of electricity: wiring buildings, maintaining motors and panels, keeping supply equipment safe and running. Entry is an ITI trade certificate in Electrician or Wireman, which can be started straight after class 10 -- two years, and the qualification is recognised nationally. It is one of the few routes in this catalog where the skill transfers directly into self-employment: a licensed electrical contractor needs no employer. Demand does not follow economic cycles the way office work does, because buildings and machines need maintaining regardless.',
    ARRAY[
        'Entered through an ITI certificate straight after class 10 -- no degree required',
        'Nationally recognised trade certificate, portable between states and employers',
        'Departmental exams lead to supervisory grades on Level 6, well above the range shown',
        'One of the few routes where licensing supports self-employment as a contractor'
    ],
    ARRAY['Project Sites', 'Manufacturing Plants', 'Field Work', 'Freelance'],
    0
),
(
    'welding-and-fabrication',
    'Welding & Fabrication',
    'skilled-trades',
    'Welding & Fabrication -- specializations, skills & career paths',
    'Stable',
    'Workers in Welding & Fabrication read drawings and set out material, cut and join metal to specified tolerances, work to welding procedure and inspection standards, and move into inspection, supervision and specialised process work.',
    '₹2.39L – ₹7.58L / year',
    2.39, 7.58,
    ARRAY['Trade Apprentice', 'Welder', 'Senior Welder', 'Welding Inspector', 'Fabrication Supervisor'],
    'wrench',
    'Welding and fabrication is the work of cutting and joining metal to a specification that will be tested -- structural steel, pressure vessels, pipelines, shipyards. Entry is an ITI certificate in Welder or Sheet Metal Worker after class 10. What separates a welder''s earnings is certification rather than seniority: qualifying to a particular process and position, and passing the tests that let you work on pressure or structural jobs, changes what work you can take. Inspection and non-destructive testing are the usual step past the torch.',
    ARRAY[
        'Entered through an ITI certificate straight after class 10',
        'Earnings track process certification, not years served',
        'Inspection and non-destructive testing are the usual progression',
        'Structural, pipeline and shipyard work each require their own qualification'
    ],
    ARRAY['Manufacturing Plants', 'Project Sites', 'Field Work', 'Shift Work'],
    1
);

-- Both trades are entered through ITI; the polytechnic diploma is the alternative
-- route into the same work, which is why each career carries both.
INSERT INTO career_degrees (career_slug, degree_slug, subject_slug, sort_order) VALUES
    ('electrical-trades',       'iti',     NULL, 0),
    ('electrical-trades',       'diploma', NULL, 1),
    ('welding-and-fabrication', 'iti',     NULL, 0),
    ('welding-and-fabrication', 'diploma', NULL, 1);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('electrical-trades',       'polytechnic-cet', 0),
    ('welding-and-fabrication', 'polytechnic-cet', 0);

-- The mirror, compared on every boot.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug,
       COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = ce.exam_slug), 0)
         + row_number() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
FROM career_exams ce
WHERE ce.career_slug IN ('electrical-trades', 'welding-and-fabrication');

-- The stage rows. V80 derives After-10th from careers linked to an exam
-- categorised 'After 10th', but it ran long ago and does not re-derive itself --
-- V98's header makes the same point when it adds its own stage rows. Without
-- these, a career linked to polytechnic-cet would be absent from the very stage
-- that exam defines. sort_order follows the canonical stage order, and
-- Career.stages is @OrderColumn so it must be dense from 0.
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES
    ('electrical-trades',       'after-10th', 0),
    ('electrical-trades',       'after-12th', 1),
    ('welding-and-fabrication', 'after-10th', 0),
    ('welding-and-fabrication', 'after-12th', 1);

-- sort_order is NOT NULL with no default and density is asserted on boot.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('electrical-trades', 'attention-to-detail', 0),
    ('electrical-trades', 'problem-solving', 1),
    ('electrical-trades', 'physical-fitness', 2),
    ('electrical-trades', 'discipline', 3),
    ('electrical-trades', 'teamwork', 4),
    ('welding-and-fabrication', 'attention-to-detail', 0),
    ('welding-and-fabrication', 'physical-fitness', 1),
    ('welding-and-fabrication', 'discipline', 2),
    ('welding-and-fabrication', 'problem-solving', 3),
    ('welding-and-fabrication', 'teamwork', 4);

-- No sort_order on career_industries.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('electrical-trades', 'energy-utilities'),
    ('electrical-trades', 'construction-infrastructure'),
    ('electrical-trades', 'manufacturing'),
    ('welding-and-fabrication', 'manufacturing'),
    ('welding-and-fabrication', 'construction-infrastructure'),
    ('welding-and-fabrication', 'automotive');

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM careers
    WHERE slug IN ('electrical-trades', 'welding-and-fabrication') AND category_slug = 'skilled-trades';
    IF n <> 2 THEN RAISE EXCEPTION 'expected both new careers in skilled-trades, found %', n; END IF;

    SELECT count(*) INTO n FROM degrees WHERE slug = 'iti';
    IF n <> 1 THEN RAISE EXCEPTION 'the ITI degree row is missing'; END IF;

    -- The completeness gate, same as V118 and V120-V123.
    SELECT count(*) INTO n FROM careers c
    WHERE c.slug IN ('electrical-trades', 'welding-and-fabrication')
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d    WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e      WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s     WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN RAISE EXCEPTION '% new career(s) fall short of the completeness gate', n; END IF;

    -- A career linked to an After-10th exam must appear in the After-10th stage.
    -- This is the inconsistency V98 had to go back and fix; asserting it here
    -- means these two cannot reintroduce it.
    SELECT count(*) INTO n FROM career_exams ce
    JOIN exams e ON e.slug = ce.exam_slug
    WHERE e.category = 'After 10th'
      AND NOT EXISTS (SELECT 1 FROM career_stages cs
                      WHERE cs.career_slug = ce.career_slug AND cs.stage_slug = 'after-10th');
    IF n > 0 THEN
        RAISE EXCEPTION '% career(s) link an After-10th exam but are missing from the After-10th stage', n;
    END IF;

    -- The range stops at the top of Pay Level 2, so the route past it has to be
    -- stated on the page or the ceiling reads as a dead end.
    SELECT count(*) INTO n FROM careers
    WHERE slug = 'electrical-trades'
      AND EXISTS (SELECT 1 FROM unnest(highlights) h WHERE h LIKE '%above the range shown%');
    IF n <> 1 THEN
        RAISE EXCEPTION 'electrical-trades must carry the highlight explaining that supervisory grades exceed its quoted range';
    END IF;

    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n; END IF;
END $$;
