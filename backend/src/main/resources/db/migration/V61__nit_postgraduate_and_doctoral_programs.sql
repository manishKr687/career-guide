-- Extends every NIT with the postgraduate/doctoral programs that (unlike
-- B.Arch/MBA in V60) ARE true of the whole group, not institute-specific:
-- every NIT -- including the newest, smallest ones -- runs M.Tech and PhD
-- programs, spot-checked here against NIT Sikkim's and NIT Mizoram's own
-- admissions pages (both confirm M.Tech via GATE and PhD across multiple
-- specializations, including the same core departments V59 already linked
-- them to). M.Arch is added only for the 11 NITs V56/V57/V60 already gave
-- a B.Arch, since a Master's in Architecture naturally follows from having
-- the department at all, not from being an NIT per se.
--
-- Each higher degree is paired only with the discipline(s) the institute
-- is already confirmed to teach: M.Tech joins every existing (NIT, core
-- engineering discipline, b-tech) row as a second degree for the same
-- department (mirroring nit-patna's CSE b-tech+m-tech precedent from V56,
-- now generalized); M.Arch joins every existing (NIT, architecture,
-- b-arch) row the same way. Not extended to business-administration --
-- MBA is already this catalog's terminal degree for that career, there's
-- no separate "M.Tech in management" to pair it with.
--
-- PhD is added at the college_degrees (institution-wide) level only, not
-- paired to a specific discipline via college_career_degrees -- which
-- specific departments run a doctoral program at each of 31 institutes
-- would need per-institute, per-department verification, same reasoning
-- V56 used for not discipline-pairing nit-patna's own pre-existing 'phd'
-- row. Uses phd-engineering (not the generic 'phd' nit-patna already has)
-- since every other NIT here is getting this fresh, and phd-engineering is
-- the more precise catalog entry for an engineering institute; nit-patna
-- is left with its existing 'phd' row rather than adding a second,
-- overlapping doctoral-degree entry to the same college.
--
-- college_career_degrees pairings are derived from existing rows (not
-- hand-listed) so the 31-institute x 5-discipline cross product can't
-- drift from what V59/V60 actually seeded. All sort_order values are
-- still computed relative to each row's current max, same discipline as
-- V59/V60, to avoid the duplicate/gap bug fixed in V58.

-- ---------------------------------------------------------------------
-- college_degrees: phd-engineering (all 31, no-op for none -- none have
-- it yet), m-tech (all 31, no-op for nit-patna which already has it),
-- m-arch (the 11 B.Arch NITs).
-- ---------------------------------------------------------------------
INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'phd-engineering',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-warangal'), ('nit-patna'), ('nit-surathkal'), ('nit-bhopal'),
    ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'), ('nit-srinagar'), ('nit-silchar'),
    ('nit-allahabad'), ('nit-surat'), ('nit-calicut'), ('nit-rourkela'), ('nit-jaipur'),
    ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'), ('nit-raipur'), ('nit-agartala'),
    ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'), ('nit-manipur'), ('nit-meghalaya'),
    ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'), ('nit-sikkim'), ('nit-uttarakhand'),
    ('nit-andhra-pradesh')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'm-tech',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-trichy'), ('nit-warangal'), ('nit-patna'), ('nit-surathkal'), ('nit-bhopal'),
    ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'), ('nit-srinagar'), ('nit-silchar'),
    ('nit-allahabad'), ('nit-surat'), ('nit-calicut'), ('nit-rourkela'), ('nit-jaipur'),
    ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'), ('nit-raipur'), ('nit-agartala'),
    ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'), ('nit-manipur'), ('nit-meghalaya'),
    ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'), ('nit-sikkim'), ('nit-uttarakhand'),
    ('nit-andhra-pradesh')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'm-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('nit-patna'), ('nit-trichy'), ('nit-calicut'), ('nit-rourkela'), ('nit-raipur'),
    ('nit-bhopal'), ('nit-nagpur'), ('nit-jaipur'), ('nit-allahabad'), ('nit-hamirpur'),
    ('nit-kurukshetra')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- college_career_degrees: m-tech for every existing NIT b-tech discipline
-- row, m-arch for every existing NIT b-arch row -- derived, not hand-listed.
-- ---------------------------------------------------------------------
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT src.college_slug, src.career_slug, 'm-tech',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_career_degrees ccd WHERE ccd.college_slug = src.college_slug)
FROM college_career_degrees src
WHERE src.degree_slug = 'b-tech' AND src.college_slug LIKE 'nit-%'
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT src.college_slug, src.career_slug, 'm-arch',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_career_degrees ccd WHERE ccd.college_slug = src.college_slug)
FROM college_career_degrees src
WHERE src.degree_slug = 'b-arch' AND src.college_slug LIKE 'nit-%'
ON CONFLICT DO NOTHING;
