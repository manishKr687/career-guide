-- Merges twelve employers that exist twice under different slugs.
--
-- The catalog holds each of these organisations as two rows: one under its plain
-- name, and one with the abbreviation appended.
--
--     reserve-bank-of-india      Reserve Bank of India          3 references
--     reserve-bank-of-india-rbi  Reserve Bank of India (RBI)    0 references
--
-- The pattern is identical across all twelve: the plain row carries every
-- reference and the suffixed twin carries none. So a reader on the Industries
-- page sees "Reserve Bank of India" twice, one of which leads nowhere, and the
-- dashboard counts the dead one among its 126 employers that nothing links to.
--
-- These are not near-matches. Each pair is the same organisation with a
-- parenthetical abbreviation:
--
--     Coal India Limited (CIL)                      Larsen & Toubro (L&T)
--     Hindustan Aeronautics Limited (HAL)           Reserve Bank of India (RBI)
--     Hindustan Unilever (HUL)                      State Bank of India (SBI)
--     Indian Oil Corporation (IOCL)                 Taj Hotels (IHCL)
--     ISRO (Indian Space Research Organisation)     Tata Institute of Fundamental Research (TIFR)
--
-- TWO OF THE TWELVE ARE A JUDGMENT RATHER THAN AN OBVIOUS DUPLICATE, and are
-- called out rather than buried:
--
--     Government Hospitals  vs  Government Hospitals (State Health Departments)
--     Government of India   vs  Government of India (Central Secretariat)
--
-- The qualifier in each narrows the scope rather than abbreviating the name, so
-- these are arguably two different things. They are merged anyway, because as an
-- EMPLOYER label the distinction does not help a reader deciding where a career
-- leads, and because the narrower row has no references at all -- keeping an
-- unreferenced duplicate to preserve a distinction nothing uses is how the
-- Branch layer survived as long as it did. If the distinction is ever wanted,
-- it belongs on the referenced row, not on a second one beside it.
--
-- The canonical row is the one already referenced, so nothing that currently
-- points anywhere changes. References are repointed first regardless -- ISRO is
-- the one pair where BOTH rows have zero references, and writing the repoint
-- unconditionally means the migration does not depend on that staying true.

-- Repoint anything pointing at a duplicate. NOT EXISTS rather than ON CONFLICT
-- so the intent reads plainly and no conflict target has to match an index.
INSERT INTO career_industries (career_slug, industry_slug)
SELECT ci.career_slug, d.canonical
FROM career_industries ci
JOIN (VALUES
    ('coal-india-limited-cil', 'coal-india-limited'),
    ('government-hospitals-state-health-departments', 'government-hospitals'),
    ('government-of-india-central-secretariat', 'government-of-india'),
    ('hindustan-aeronautics-limited-hal', 'hindustan-aeronautics-limited'),
    ('hindustan-unilever-hul', 'hindustan-unilever'),
    ('indian-oil-corporation-iocl', 'indian-oil-corporation'),
    ('isro-indian-space-research-organisation', 'isro'),
    ('larsen-toubro-l-t', 'larsen-toubro'),
    ('reserve-bank-of-india-rbi', 'reserve-bank-of-india'),
    ('state-bank-of-india-sbi', 'state-bank-of-india'),
    ('taj-hotels-ihcl', 'taj-hotels'),
    ('tata-institute-of-fundamental-research-tifr', 'tata-institute-of-fundamental-research')
) AS d(duplicate, canonical) ON d.duplicate = ci.industry_slug
WHERE NOT EXISTS (
    SELECT 1 FROM career_industries x
    WHERE x.career_slug = ci.career_slug AND x.industry_slug = d.canonical);

INSERT INTO job_role_industries (job_role_slug, industry_slug)
SELECT jri.job_role_slug, d.canonical
FROM job_role_industries jri
JOIN (VALUES
    ('coal-india-limited-cil', 'coal-india-limited'),
    ('government-hospitals-state-health-departments', 'government-hospitals'),
    ('government-of-india-central-secretariat', 'government-of-india'),
    ('hindustan-aeronautics-limited-hal', 'hindustan-aeronautics-limited'),
    ('hindustan-unilever-hul', 'hindustan-unilever'),
    ('indian-oil-corporation-iocl', 'indian-oil-corporation'),
    ('isro-indian-space-research-organisation', 'isro'),
    ('larsen-toubro-l-t', 'larsen-toubro'),
    ('reserve-bank-of-india-rbi', 'reserve-bank-of-india'),
    ('state-bank-of-india-sbi', 'state-bank-of-india'),
    ('taj-hotels-ihcl', 'taj-hotels'),
    ('tata-institute-of-fundamental-research-tifr', 'tata-institute-of-fundamental-research')
) AS d(duplicate, canonical) ON d.duplicate = jri.industry_slug
WHERE NOT EXISTS (
    SELECT 1 FROM job_role_industries x
    WHERE x.job_role_slug = jri.job_role_slug AND x.industry_slug = d.canonical);

-- specialization_industries carries sort_order, so a repointed row is appended
-- at the end of that specialization's list rather than colliding with a position.
INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order)
SELECT si.specialization_slug, d.canonical,
       COALESCE((SELECT max(sort_order) + 1 FROM specialization_industries x
                 WHERE x.specialization_slug = si.specialization_slug), 0)
FROM specialization_industries si
JOIN (VALUES
    ('coal-india-limited-cil', 'coal-india-limited'),
    ('government-hospitals-state-health-departments', 'government-hospitals'),
    ('government-of-india-central-secretariat', 'government-of-india'),
    ('hindustan-aeronautics-limited-hal', 'hindustan-aeronautics-limited'),
    ('hindustan-unilever-hul', 'hindustan-unilever'),
    ('indian-oil-corporation-iocl', 'indian-oil-corporation'),
    ('isro-indian-space-research-organisation', 'isro'),
    ('larsen-toubro-l-t', 'larsen-toubro'),
    ('reserve-bank-of-india-rbi', 'reserve-bank-of-india'),
    ('state-bank-of-india-sbi', 'state-bank-of-india'),
    ('taj-hotels-ihcl', 'taj-hotels'),
    ('tata-institute-of-fundamental-research-tifr', 'tata-institute-of-fundamental-research')
) AS d(duplicate, canonical) ON d.duplicate = si.industry_slug
WHERE NOT EXISTS (
    SELECT 1 FROM specialization_industries x
    WHERE x.specialization_slug = si.specialization_slug AND x.industry_slug = d.canonical);

-- The duplicates go. Every join table referencing industries is ON DELETE
-- CASCADE, so the old rows clean themselves up now that the canonical ones carry
-- the references.
DELETE FROM industries WHERE slug IN (
    'coal-india-limited-cil',
    'government-hospitals-state-health-departments',
    'government-of-india-central-secretariat',
    'hindustan-aeronautics-limited-hal',
    'hindustan-unilever-hul',
    'indian-oil-corporation-iocl',
    'isro-indian-space-research-organisation',
    'larsen-toubro-l-t',
    'reserve-bank-of-india-rbi',
    'state-bank-of-india-sbi',
    'taj-hotels-ihcl',
    'tata-institute-of-fundamental-research-tifr');

-- Re-densify the specialization lists the repoint appended to.
WITH ranked AS (
    SELECT specialization_slug, industry_slug,
           row_number() OVER (PARTITION BY specialization_slug ORDER BY sort_order, industry_slug) - 1 AS rn
    FROM specialization_industries)
UPDATE specialization_industries si SET sort_order = r.rn
FROM ranked r
WHERE si.specialization_slug = r.specialization_slug AND si.industry_slug = r.industry_slug;

DO $$
DECLARE n int; leftover text;
BEGIN
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, leftover
    FROM industries WHERE slug IN (
        'coal-india-limited-cil', 'government-hospitals-state-health-departments',
        'government-of-india-central-secretariat', 'hindustan-aeronautics-limited-hal',
        'hindustan-unilever-hul', 'indian-oil-corporation-iocl',
        'isro-indian-space-research-organisation', 'larsen-toubro-l-t',
        'reserve-bank-of-india-rbi', 'state-bank-of-india-sbi', 'taj-hotels-ihcl',
        'tata-institute-of-fundamental-research-tifr');
    IF n > 0 THEN RAISE EXCEPTION '% duplicate industry row(s) survived: %', n, leftover; END IF;

    -- The canonical rows must all still be here. A typo in a canonical slug above
    -- would have deleted a duplicate without repointing anything to a real row.
    SELECT count(*) INTO n FROM (VALUES
        ('coal-india-limited'), ('government-hospitals'), ('government-of-india'),
        ('hindustan-aeronautics-limited'), ('hindustan-unilever'), ('indian-oil-corporation'),
        ('isro'), ('larsen-toubro'), ('reserve-bank-of-india'), ('state-bank-of-india'),
        ('taj-hotels'), ('tata-institute-of-fundamental-research')
    ) AS v(slug)
    WHERE NOT EXISTS (SELECT 1 FROM industries i WHERE i.slug = v.slug);
    IF n > 0 THEN RAISE EXCEPTION '% canonical industry row(s) are missing', n; END IF;

    -- And no pair of industries may still normalise to the same name. This is the
    -- check that would have caught the problem in the first place, so it stays.
    SELECT count(*) INTO n FROM (
        SELECT regexp_replace(lower(regexp_replace(name, '\s*\([^)]*\)', '', 'g')), '[^a-z0-9]', '', 'g') AS key
        FROM industries GROUP BY 1 HAVING count(*) > 1) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% industry name(s) still appear more than once once abbreviations are stripped', n;
    END IF;
END $$;
