-- Adds the missing master's step to the 16 engineering careers.
--
-- Exactly the same gap V86 fixed for the five pure sciences, in the other
-- half of the catalog. Every engineering career stopped at B.Tech (plus
-- Diploma for ten of them), so `m-tech` -- the second-most-referenced degree
-- in the whole catalog, with 361 college rows pointing at it -- was linked to
-- ZERO careers. A student reading any engineering career page saw no
-- postgraduate route at all, while a student reading Physics saw
-- B.Sc / M.Sc / PhD.
--
-- The gap was invisible for the same reason V86's was: careers.education used
-- to render a templated sentence over the top of whatever was actually linked
-- (dropped in V83), so nobody could see that the relation underneath said
-- only "B.Tech".
--
-- NO new degree rows -- `m-tech` and `msc` already exist. This is 48 link
-- rows and nothing else.
--
-- ON PhD: deliberately not added to any engineering career. `phd` is
-- currently linked to exactly 5 careers (biology, chemistry, mathematics,
-- physics, statistics -- V86), all of them fields where a doctorate is a
-- practising requirement, not merely an available option. No engineering
-- career requires one to work as an engineer. A PhD route exists in every
-- branch, but listing it on all 16 would turn the marker from "you need this"
-- into "this exists", which is not what the Education field answers.
--
-- ON B.E. / M.E.: `b-eng` and `m-eng` stay unlinked. Anna University, VTU and
-- others award B.E. where IITs/NITs award B.Tech, but it is the same
-- qualification -- listing both would double every row below to say one
-- thing twice.
--
-- ON biotechnology: it is the one career here with a genuine science route
-- as well as an engineering one (it already had B.Tech AND B.Sc), so it gets
-- both masters -- M.Tech for the engineering ladder, M.Sc for the science
-- one. Leaving M.Sc off would give it a B.Sc entry with no step above it.
--
-- ORDERING: undergraduate entry first, then postgraduate, with Diploma last.
-- Diploma is below B.Tech in level but is an alternative entry route rather
-- than a step in the main progression, and the existing rows already placed
-- it last -- this keeps that reading.
--
-- career_degrees is @OrderColumn-backed (Career.relatedDegrees), so each
-- career's set is rewritten wholesale rather than appended: appending M.Tech
-- would order civil-engineering as B.Tech / Diploma / M.Tech and, worse,
-- leave sort_order non-dense, which is the exact shape that caused the V58
-- Hibernate NPE.

DELETE FROM career_degrees
WHERE career_slug IN (
    'aerospace-engineering', 'biomedical-engineering', 'biotechnology',
    'chemical-engineering', 'civil-engineering',
    'computer-science-and-engineering', 'electrical-engineering',
    'electronics-and-communication-engineering', 'environmental-engineering',
    'industrial-engineering', 'information-technology',
    'manufacturing-engineering', 'mechanical-engineering',
    'metallurgical-and-materials-engineering', 'mining-engineering',
    'petroleum-engineering'
);

INSERT INTO career_degrees (career_slug, degree_slug, sort_order) VALUES
    ('aerospace-engineering',                     'b-tech',  0),
    ('aerospace-engineering',                     'm-tech',  1),

    ('biomedical-engineering',                    'b-tech',  0),
    ('biomedical-engineering',                    'm-tech',  1),

    ('biotechnology',                             'b-tech',  0),
    ('biotechnology',                             'b-sc',    1),
    ('biotechnology',                             'm-tech',  2),
    ('biotechnology',                             'msc',     3),

    ('chemical-engineering',                      'b-tech',  0),
    ('chemical-engineering',                      'm-tech',  1),
    ('chemical-engineering',                      'diploma', 2),

    ('civil-engineering',                         'b-tech',  0),
    ('civil-engineering',                         'm-tech',  1),
    ('civil-engineering',                         'diploma', 2),

    ('computer-science-and-engineering',          'b-tech',  0),
    ('computer-science-and-engineering',          'b-sc',    1),
    ('computer-science-and-engineering',          'm-tech',  2),
    ('computer-science-and-engineering',          'mca',     3),
    ('computer-science-and-engineering',          'diploma', 4),

    ('electrical-engineering',                    'b-tech',  0),
    ('electrical-engineering',                    'm-tech',  1),
    ('electrical-engineering',                    'diploma', 2),

    ('electronics-and-communication-engineering', 'b-tech',  0),
    ('electronics-and-communication-engineering', 'm-tech',  1),
    ('electronics-and-communication-engineering', 'diploma', 2),

    ('environmental-engineering',                 'b-tech',  0),
    ('environmental-engineering',                 'm-tech',  1),

    ('industrial-engineering',                    'b-tech',  0),
    ('industrial-engineering',                    'm-tech',  1),

    ('information-technology',                    'b-tech',  0),
    ('information-technology',                    'b-sc',    1),
    ('information-technology',                    'm-tech',  2),
    ('information-technology',                    'mca',     3),
    ('information-technology',                    'diploma', 4),

    ('manufacturing-engineering',                 'b-tech',  0),
    ('manufacturing-engineering',                 'm-tech',  1),
    ('manufacturing-engineering',                 'diploma', 2),

    ('mechanical-engineering',                    'b-tech',  0),
    ('mechanical-engineering',                    'm-tech',  1),
    ('mechanical-engineering',                    'diploma', 2),

    ('metallurgical-and-materials-engineering',   'b-tech',  0),
    ('metallurgical-and-materials-engineering',   'm-tech',  1),
    ('metallurgical-and-materials-engineering',   'diploma', 2),

    ('mining-engineering',                        'b-tech',  0),
    ('mining-engineering',                        'm-tech',  1),
    ('mining-engineering',                        'diploma', 2),

    ('petroleum-engineering',                     'b-tech',  0),
    ('petroleum-engineering',                     'm-tech',  1);

DO $$
DECLARE bad int;
BEGIN
    -- The point of the migration: every engineering career now has M.Tech.
    SELECT count(*) INTO bad FROM careers c
    WHERE c.category_slug = 'engineering-technology'
      AND NOT EXISTS (
          SELECT 1 FROM career_degrees cd
          WHERE cd.career_slug = c.slug AND cd.degree_slug = 'm-tech');
    IF bad > 0 THEN
        RAISE EXCEPTION '% engineering career(s) still have no master''s step', bad;
    END IF;

    -- The DELETE above is broad; nothing may have lost its B.Tech entry.
    SELECT count(*) INTO bad FROM careers c
    WHERE c.category_slug = 'engineering-technology'
      AND NOT EXISTS (
          SELECT 1 FROM career_degrees cd
          WHERE cd.career_slug = c.slug AND cd.degree_slug = 'b-tech');
    IF bad > 0 THEN
        RAISE EXCEPTION '% engineering career(s) lost their B.Tech entry', bad;
    END IF;

    SELECT count(*) INTO bad FROM career_degrees cd
    JOIN careers c ON c.slug = cd.career_slug
    WHERE c.category_slug = 'engineering-technology';
    IF bad <> 48 THEN
        RAISE EXCEPTION 'expected 48 engineering career_degrees rows, found %', bad;
    END IF;

    -- No career anywhere lost its mapping to the DELETE.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have no degree mapping', bad;
    END IF;

    -- @OrderColumn contract: dense 0..n-1 per career, catalog-wide.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
