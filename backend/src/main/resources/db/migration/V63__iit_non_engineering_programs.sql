-- Adds the non-engineering programs a subset of IITs are confirmed to run
-- alongside their core engineering B.Tech branches: B.Arch (Architecture)
-- and a Department-of-Management-Studies-style MBA. Same "don't guess past
-- what's confidently known" bar as V60 (the NIT equivalent) and V62: only
-- institutes with a direct, corroborated source are linked here.
--
-- B.Arch: iit-bhu-varanasi ("Architecture, Planning and Design" is one of
-- its 11 engineering departments) and iit-roorkee (its own department
-- listing names "Architecture and Planning" as a distinct academic unit).
-- Neither was confirmed for any of the other 21 IITs in this pass.
--
-- MBA-equivalent, via each institute's own Department/School of
-- Management Studies, confirmed individually: iit-bombay (Shailesh J.
-- Mehta School of Management), iit-delhi (Department of Management
-- Studies), iit-madras, iit-kharagpur (Vinod Gupta School of Management),
-- iit-roorkee (Department of Management Studies), iit-kanpur (Department
-- of Industrial and Management Engineering), iit-ism-dhanbad, iit-jodhpur.
-- Left out: the other 15 IITs, where a management program couldn't be
-- confirmed from a direct source in this pass -- absence here means "not
-- yet verified", not "confirmed absent", same caveat V60 documented.
--
-- All sort_order values are computed relative to each row's current max
-- (never a hardcoded literal), same discipline as V59-V62.

-- ---------------------------------------------------------------------
-- college_degrees: b-arch and mba, appended after each college's existing
-- degree(s).
-- ---------------------------------------------------------------------
INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'b-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('iit-bhu-varanasi'), ('iit-roorkee')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'mba',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('iit-bombay'), ('iit-delhi'), ('iit-madras'), ('iit-kharagpur'), ('iit-roorkee'),
    ('iit-kanpur'), ('iit-ism-dhanbad'), ('iit-jodhpur')
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
    ('iit-bhu-varanasi'), ('iit-roorkee')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT 'business-administration', v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = 'business-administration')
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('iit-bombay'), ('iit-delhi'), ('iit-madras'), ('iit-kharagpur'), ('iit-roorkee'),
    ('iit-kanpur'), ('iit-ism-dhanbad'), ('iit-jodhpur')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- college_career_degrees: the actual (college, career, degree) triples.
-- ---------------------------------------------------------------------
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT v.college_slug, 'architecture', 'b-arch',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = v.college_slug)
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('iit-bhu-varanasi'), ('iit-roorkee')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT v.college_slug, 'business-administration', 'mba',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = v.college_slug)
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('iit-bombay'), ('iit-delhi'), ('iit-madras'), ('iit-kharagpur'), ('iit-roorkee'),
    ('iit-kanpur'), ('iit-ism-dhanbad'), ('iit-jodhpur')
) AS v(college_slug)
ON CONFLICT DO NOTHING;
