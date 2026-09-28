-- Adds the non-engineering programs a subset of NITs are confirmed to run
-- alongside their core engineering B.Tech branches: B.Arch (Architecture)
-- and a Department-of-Management-Studies MBA (Business Administration).
--
-- Same "don't guess past what's confidently known" bar as V53/V56/V57/V59:
-- unlike the five core engineering branches (true of every NIT, V59), which
-- NITs run B.Arch or an MBA varies institute to institute and isn't a
-- single fact true of the whole group, so only institutes with a direct,
-- corroborated source are linked here -- not all 31.
--
-- B.Arch, cross-checked across JoSAA B.Arch counselling sources (10 NITs
-- run it): nit-trichy, nit-calicut, nit-rourkela, nit-raipur, nit-bhopal,
-- nit-nagpur, nit-jaipur, nit-allahabad, nit-hamirpur, nit-kurukshetra.
-- (nit-patna already has this, added in V56/V57 -- not repeated here.)
--
-- MBA via each institute's own Department/School of Management Studies
-- page, confirmed individually rather than assumed group-wide: nit-trichy,
-- nit-calicut, nit-surat, nit-warangal, nit-rourkela. Left out: institutes
-- where a management program couldn't be confirmed from a direct source in
-- this pass (e.g. nit-jamshedpur) -- absence here means "not yet verified",
-- not "confirmed absent".
--
-- All sort_order values are computed relative to each row's current max
-- (never a hardcoded literal), same discipline V59 followed, specifically
-- to avoid the duplicate/gap bug fixed in V58.

-- ---------------------------------------------------------------------
-- college_degrees: b-arch and mba, appended after each college's existing
-- degree(s). Two separate statements (not one combined list) so the mba
-- insert's MAX-based sort_order correctly accounts for a b-arch row this
-- same migration just added to a college that gets both (nit-trichy,
-- nit-calicut, nit-rourkela).
-- ---------------------------------------------------------------------
INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'b-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-rourkela'), ('nit-raipur'), ('nit-bhopal'),
    ('nit-nagpur'), ('nit-jaipur'), ('nit-allahabad'), ('nit-hamirpur'), ('nit-kurukshetra')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'mba',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-surat'), ('nit-warangal'), ('nit-rourkela')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- career_colleges: architecture and business-administration, appended
-- relative to each career's current max sort_order.
-- ---------------------------------------------------------------------
INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT 'architecture', v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = 'architecture')
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-rourkela'), ('nit-raipur'), ('nit-bhopal'),
    ('nit-nagpur'), ('nit-jaipur'), ('nit-allahabad'), ('nit-hamirpur'), ('nit-kurukshetra')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT 'business-administration', v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = 'business-administration')
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-surat'), ('nit-warangal'), ('nit-rourkela')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- college_career_degrees: the actual (college, career, degree) triples.
-- @OrderBy, not @OrderColumn (see College.java), so a MAX+1-per-college
-- scalar subquery is safe here without any density/uniqueness invariant.
-- ---------------------------------------------------------------------
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT v.college_slug, 'architecture', 'b-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_career_degrees ccd WHERE ccd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-rourkela'), ('nit-raipur'), ('nit-bhopal'),
    ('nit-nagpur'), ('nit-jaipur'), ('nit-allahabad'), ('nit-hamirpur'), ('nit-kurukshetra')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT v.college_slug, 'business-administration', 'mba',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_career_degrees ccd WHERE ccd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-calicut'), ('nit-surat'), ('nit-warangal'), ('nit-rourkela')
) AS v(college_slug)
ON CONFLICT DO NOTHING;
