-- Extends every IIT with M.Tech and PhD -- confirmed universal across the
-- group the same way V61 confirmed it for NITs, spot-checked here against
-- IIT Goa's and IIT Dharwad's own program pages (the newest, smallest
-- IITs): both run M.Tech (paired to their existing core departments) and
-- PhD across multiple departments. M.Arch is added only for the 2 IITs
-- V63 gave a B.Arch (iit-bhu-varanasi, iit-roorkee).
--
-- Same pairing logic as V61: M.Tech joins every existing (IIT, discipline,
-- b-tech) row as a second degree for the same department; M.Arch joins
-- every existing (IIT, architecture, b-arch) row. Not extended to
-- business-administration -- MBA is already this catalog's terminal
-- degree for that career. PhD (phd-engineering) is institution-wide only,
-- not paired to a specific discipline, same reasoning as V61.
--
-- college_career_degrees pairings are derived from existing rows (not
-- hand-listed). All sort_order values are computed relative to each row's
-- current max, using ROW_NUMBER (not a bare MAX+1 subquery) wherever
-- multiple new rows can share a college_slug within one statement -- see
-- V62's comment on why, and the duplicate/gap bug fixed in V58.

-- ---------------------------------------------------------------------
-- college_degrees: phd-engineering (all 23), m-tech (all 23), m-arch (the
-- 2 B.Arch IITs).
-- ---------------------------------------------------------------------
INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'phd-engineering',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('iit-bombay'), ('iit-delhi'), ('iit-madras'), ('iit-ism-dhanbad'), ('iit-kharagpur'),
    ('iit-kanpur'), ('iit-guwahati'), ('iit-roorkee'), ('iit-jodhpur'), ('iit-hyderabad'),
    ('iit-gandhinagar'), ('iit-ropar'), ('iit-patna'), ('iit-bhubaneswar'), ('iit-indore'),
    ('iit-mandi'), ('iit-bhu-varanasi'), ('iit-palakkad'), ('iit-tirupati'), ('iit-bhilai'),
    ('iit-dharwad'), ('iit-jammu'), ('iit-goa')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'm-tech',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('iit-bombay'), ('iit-delhi'), ('iit-madras'), ('iit-ism-dhanbad'), ('iit-kharagpur'),
    ('iit-kanpur'), ('iit-guwahati'), ('iit-roorkee'), ('iit-jodhpur'), ('iit-hyderabad'),
    ('iit-gandhinagar'), ('iit-ropar'), ('iit-patna'), ('iit-bhubaneswar'), ('iit-indore'),
    ('iit-mandi'), ('iit-bhu-varanasi'), ('iit-palakkad'), ('iit-tirupati'), ('iit-bhilai'),
    ('iit-dharwad'), ('iit-jammu'), ('iit-goa')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'm-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('iit-bhu-varanasi'), ('iit-roorkee')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- college_career_degrees: m-tech for every existing IIT b-tech discipline
-- row, m-arch for every existing IIT b-arch row -- derived, not
-- hand-listed.
-- ---------------------------------------------------------------------
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT src.college_slug, src.career_slug, 'm-tech',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = src.college_slug)
       + ROW_NUMBER() OVER (PARTITION BY src.college_slug ORDER BY src.career_slug)
FROM college_career_degrees src
WHERE src.degree_slug = 'b-tech' AND src.college_slug LIKE 'iit-%'
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT src.college_slug, src.career_slug, 'm-arch',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = src.college_slug)
       + ROW_NUMBER() OVER (PARTITION BY src.college_slug ORDER BY src.career_slug)
FROM college_career_degrees src
WHERE src.degree_slug = 'b-arch' AND src.college_slug LIKE 'iit-%'
ON CONFLICT DO NOTHING;
