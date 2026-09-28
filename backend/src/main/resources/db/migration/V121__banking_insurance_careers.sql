-- Fills the Banking & Insurance category, which had zero careers.
--
-- Third of the empty categories, and the one the assessment pointed at: after
-- V120 filled Commerce & Finance, a commerce-leaning submission returned
-- banking-insurance as its SECOND field, still with nothing behind it.
--
-- Adds one industry sector row, `insurance`. The catalog had 26 sectors and no
-- insurance among them, while carrying IRDAI as an employer -- so insurance
-- careers would otherwise have had to file themselves under Banking, which is a
-- different industry with a different regulator.
--
-- WHY THESE TWO, AND WHAT IS LEFT OUT
--
--   banking    The discipline of taking deposits, lending, and moving money,
--              entered through a commerce or management degree plus a
--              recruitment exam. ibps-po and ibps-so-it were already in the
--              catalog, categorised Banking, with no career pointing at them.
--   insurance  Underwriting and pricing risk, and settling claims against it --
--              a separate industry under a separate regulator (IRDAI), not a
--              product line of banking.
--
-- Actuarial Science is deliberately ABSENT, and for two reasons rather than one.
-- It has no degree route in this catalog: `statistics` and `mathematics` exist as
-- subjects but neither has a degree_subjects pair, so "B.Sc (Statistics)" is not
-- yet expressible, and inventing the pair here would be scope this migration has
-- no business claiming. And its pay is unsourceable -- the Institute of Actuaries
-- of India publishes exam structure, not earnings. Same judgment as Company
-- Secretaryship in V120: it waits for a real figure rather than shipping a guess.
--
-- SOURCES. Retrieved 2026-09-28. The schema records no provenance, so this header
-- is the audit trail.
--
--   banking -- the 12th Bipartite Settlement, the industry-wide wage agreement
--   between the Indian Banks' Association and the officers' unions, signed
--   8 March 2024. This is a negotiated instrument covering every public sector
--   bank, not a survey:
--       Scale I (Assistant Manager)  basic 48,480 / month
--       Scale VII (General Manager)  highest stage 1,87,960 / month
--     https://www.pw.live/jaiib-caiib/exams/12th-bipartite-settlement
--     https://testbook.com/ibps-po/salary-job-profile
--
--   insurance -- Life Insurance Corporation's published pay scale for Assistant
--   Administrative Officer, from its recruitment notification:
--       88,635 - 4385(14) - 150025 - 4750(4) - 169025
--     so basic runs 88,635 to 1,69,025 / month across the scale.
--     https://testbook.com/lic-aao/salary-job-profile
--     https://www.careerpower.in/blog/lic-aao-salary
--
-- HOW THE LPA RANGES WERE DERIVED -- same method as V118 and V120, so all three
-- batches are comparable. BASIC PAY ONLY, monthly figure x 12, excluding DA, HRA
-- and city compensatory allowance because they vary by posting and move with
-- every revision.
--
--       banking     48,480 x 12 = 5.82L  ->  1,87,960 x 12 = 22.56L
--       insurance   88,635 x 12 = 10.64L ->  1,69,025 x 12 = 20.28L
--
-- ONE CAVEAT THAT THE READER NEEDS, NOT JUST THIS FILE. Insurance's floor of
-- 10.64L is the LIC AAO scale minimum, and AAO is a competitive graduate officer
-- post -- it sits ABOVE what private-sector or agency-side entry pays, for which
-- no official figure exists. A floor that high, presented bare, would read as
-- "insurance starts at 10.6 LPA", which is not true of the field. So the caveat
-- is written into the career's highlights, where the reader sees it, rather than
-- being buried in a migration comment nobody opens.

INSERT INTO industries (slug, name, is_sector) VALUES ('insurance', 'Insurance', true);

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES
(
    'banking',
    'Banking',
    'banking-insurance',
    'Banking -- specializations, skills & career paths',
    'High Demand',
    'Professionals in Banking assess and sanction loans, manage a branch''s deposits and customer relationships, check transactions against regulatory limits, and move through the officer scales into branch, regional and zonal management.',
    '₹5.82L – ₹22.56L / year',
    5.82, 22.56,
    ARRAY['Probationary Officer', 'Assistant Manager (Scale I)', 'Manager (Scale II)', 'Chief Manager', 'General Manager'],
    'bank',
    'Banking is the business of holding deposits, lending them out, and moving money safely between people and firms. In India it is unusually structured as a career: public sector banks recruit graduates of any discipline through common written exams, pay on a scale negotiated industry-wide rather than individually, and promote through seven numbered officer grades. That makes it one of the few fields where the entry route, the pay and the progression are all published in advance. A commerce or management degree helps, but the exam is the real gate.',
    ARRAY[
        'Pay is set by an industry-wide settlement, not negotiated per job',
        'Recruitment is through common written exams open to graduates of any discipline',
        'Seven published officer scales, from Assistant Manager to General Manager',
        'Branch networks mean posts exist in every district, not only in metros'
    ],
    ARRAY['Corporate Offices', 'Government Bodies', 'Branch Networks', 'Hybrid'],
    0
),
(
    'insurance',
    'Insurance',
    'banking-insurance',
    'Insurance -- specializations, skills & career paths',
    'Stable',
    'Professionals in Insurance price and underwrite risk, decide what a policy will and will not cover, investigate and settle claims, and design products against regulatory and actuarial constraints.',
    '₹10.64L – ₹20.28L / year',
    10.64, 20.28,
    ARRAY['Assistant Administrative Officer', 'Administrative Officer', 'Assistant Divisional Manager', 'Divisional Manager', 'Zonal Manager'],
    'shield',
    'Insurance is the business of pricing uncertainty: working out what a risk is worth, what to charge for carrying it, and what to pay when it materialises. It is a separate industry from banking under a separate regulator, IRDAI, and the work divides into underwriting, claims and product design. The public sector insurers recruit graduates through their own officer exams, while the private side hires into underwriting and distribution. Being a field built on statistics applied to real populations, it rewards people comfortable with both numbers and people.',
    ARRAY[
        'A distinct industry under its own regulator, IRDAI -- not a banking product line',
        'Underwriting, claims and product design are genuinely different career tracks',
        'The salary range shown is the LIC AAO officer scale, the public-sector graduate route -- private-sector and agency entry typically starts lower',
        'Actuarial qualifications raise the ceiling substantially'
    ],
    ARRAY['Corporate Offices', 'Government Bodies', 'Field Work', 'Hybrid'],
    1
);

INSERT INTO career_degrees (career_slug, degree_slug, subject_slug, sort_order) VALUES
    ('banking',   'b-com', NULL, 0),
    ('banking',   'bba',   NULL, 1),
    ('banking',   'mba',   NULL, 2),
    ('insurance', 'b-com', NULL, 0),
    ('insurance', 'bba',   NULL, 1),
    ('insurance', 'mba',   NULL, 2);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('banking',   'ibps-po',    0),
    ('banking',   'ibps-so-it', 1),
    ('banking',   'cuet',       2),
    ('insurance', 'cuet',       0);

-- The mirror. career_exams and exam_careers are the last mirrored pair in the
-- schema; the boot-time integrity check fails the container if they disagree, so
-- both sides are written and sort_order continues each exam's existing sequence.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug,
       COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = ce.exam_slug), 0)
         + row_number() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
FROM career_exams ce
WHERE ce.career_slug IN ('banking', 'insurance');

-- sort_order is NOT NULL with no default here and density 0..n-1 per career is
-- asserted on every boot, so positions are written out.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('banking', 'financial-analysis', 0),
    ('banking', 'customer-service', 1),
    ('banking', 'compliance', 2),
    ('banking', 'attention-to-detail', 3),
    ('banking', 'communication', 4),
    ('banking', 'risk-assessment', 5),
    ('insurance', 'risk-assessment', 0),
    ('insurance', 'negotiation', 1),
    ('insurance', 'customer-service', 2),
    ('insurance', 'data-analysis', 3),
    ('insurance', 'compliance', 4),
    ('insurance', 'communication', 5);

-- No sort_order on career_industries, unlike career_skills above.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('banking', 'banking'),
    ('banking', 'fintech'),
    ('banking', 'government'),
    ('banking', 'reserve-bank-of-india'),
    ('banking', 'national-bank-for-agriculture-and-rural-development'),
    ('insurance', 'insurance'),
    ('insurance', 'banking'),
    ('insurance', 'irdai-insurance-regulatory-and-development-authority'),
    ('insurance', 'government');

DO $$
DECLARE n int;
BEGIN
    -- Scoped to the slugs this migration inserts, not a count of the category, so
    -- a later migration adding a third career here cannot retro-fail this one.
    SELECT count(*) INTO n FROM careers
    WHERE slug IN ('banking', 'insurance') AND category_slug = 'banking-insurance';
    IF n <> 2 THEN RAISE EXCEPTION 'expected both new careers in banking-insurance, found %', n; END IF;

    SELECT count(*) INTO n FROM industries WHERE slug = 'insurance' AND is_sector;
    IF n <> 1 THEN RAISE EXCEPTION 'the insurance sector row is missing'; END IF;

    -- The completeness gate, same as V118 and V120.
    SELECT count(*) INTO n FROM careers c
    WHERE c.slug IN ('banking', 'insurance')
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d    WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e      WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s     WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN RAISE EXCEPTION '% new career(s) fall short of the completeness gate', n; END IF;

    -- The caveat about insurance's floor has to reach the page, not just this
    -- file. If the highlight is ever edited away, the range becomes misleading
    -- without anything saying so.
    SELECT count(*) INTO n FROM careers
    WHERE slug = 'insurance'
      AND EXISTS (SELECT 1 FROM unnest(highlights) h WHERE h LIKE '%private-sector and agency entry typically starts lower%');
    IF n <> 1 THEN
        RAISE EXCEPTION 'insurance must carry the highlight qualifying its salary floor as the LIC AAO officer scale';
    END IF;

    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n; END IF;
END $$;
