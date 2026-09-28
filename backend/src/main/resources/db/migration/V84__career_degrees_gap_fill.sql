-- Fills career_degrees for the 13 careers that had no degree mapping at all.
--
-- V83 made the Degrees domain the single source of truth for education, which
-- immediately exposed how incomplete that source was: medicine had no link to
-- MBBS, nursing none to B.Sc Nursing, law none to LLB -- all degrees that have
-- existed in the catalog since V44. The old careers.education column hid this,
-- because its templated sentence ("Bachelor's or professional degree in
-- <title>...") rendered identically whether or not any real data existed
-- underneath. Removing the placeholder is what surfaced the gap.
--
-- Every pair below is a direct, uncontroversial match between a career and a
-- degree that already exists in the 135-row catalog -- no new degrees are
-- created and nothing is invented.
--
-- Three careers (psychology, sociology, public-administration) get only the
-- generic B.A./M.A.: the catalog has no subject-specific rows for them
-- (no "BA Psychology", no MPA), and inventing degree rows to make this table
-- look fuller would be the same mistake V83 just undid. Generic but true
-- beats specific but fabricated.
--
-- Career.relatedDegrees is @OrderColumn-backed, so sort_order must be dense
-- 0..n-1 per career; the ordinality below provides that, ordered
-- undergraduate-first so the list reads as a progression.

INSERT INTO career_degrees (career_slug, degree_slug, sort_order)
SELECT p.career_slug, p.degree_slug, p.ord - 1
FROM (
    SELECT career_slug, degree_slug, ROW_NUMBER() OVER (PARTITION BY career_slug) AS ord
    FROM (VALUES
        ('architecture',                      'b-arch'),
        ('architecture',                      'm-arch'),
        ('design',                            'b-des'),
        ('design',                            'bfa'),
        ('design',                            'm-des'),
        ('hospitality-management',            'bhm'),
        ('hospitality-management',            'bhmct'),
        ('hospitality-management',            'm-hotel-management'),
        ('journalism-and-mass-communication', 'bjmc'),
        ('journalism-and-mass-communication', 'ba-journalism'),
        ('journalism-and-mass-communication', 'ma-journalism'),
        ('law',                               'ba-llb'),
        ('law',                               'llb'),
        ('law',                               'llm'),
        ('medicine',                          'mbbs'),
        ('medicine',                          'md'),
        ('medicine',                          'ms-surgery'),
        ('nursing',                           'gnm'),
        ('nursing',                           'bsc-nursing'),
        ('nursing',                           'msc-nursing'),
        ('pharmacy',                          'dpharm'),
        ('pharmacy',                          'bpharm'),
        ('pharmacy',                          'mpharm'),
        ('physiotherapy',                     'bpt'),
        ('physiotherapy',                     'mpt'),
        ('psychology',                        'ba'),
        ('psychology',                        'ma'),
        ('public-administration',             'ba'),
        ('public-administration',             'ma'),
        ('sociology',                         'ba'),
        ('sociology',                         'ma'),
        ('tourism',                           'ba-tourism'),
        ('tourism',                           'bttm'),
        ('tourism',                           'mttm')
    ) AS v(career_slug, degree_slug)
) p
ON CONFLICT DO NOTHING;

DO $$
DECLARE bad int;
BEGIN
    -- Every career now has at least one degree: that is the point of making
    -- Degrees the single source of truth for the Education field.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) still have no degree mapping', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
