-- Adds the missing master's step for the five pure-science careers.
--
-- biology, chemistry, mathematics, physics and statistics each mapped to
-- b-sc -> phd, skipping M.Sc entirely. That is simply wrong for India, where
-- the M.Sc is the standard step between a bachelor's and doctoral research,
-- and it was invisible while careers.education rendered a template sentence
-- over the top of it (dropped in V83).
--
-- Fixed with 5 link rows, NOT with new degree rows. An earlier plan here was
-- to create bsc-physics / msc-physics / phd-physics triplets for each of the
-- five, i.e. 15 new rows. That is the wrong direction: the degrees table
-- already carries 64 rows that bake a subject into the slug
-- (ba-economics, bsc-horticulture, ...) plus 66 more where the subject is
-- fused into the qualification (MBBS, BDS, BVSc), against only 13 pure
-- qualification types. Materialising the qualification x subject product as
-- rows is what got it there, and each new row also duplicates `level`
-- (all 16 bsc-* rows independently record "Undergraduate") and `category`.
--
-- The generic `msc` row already exists and career_degrees already expresses
-- the pairing, so "M.Sc in Physics" is career_degrees(physics, msc) today --
-- no new degree needed.
--
-- Going forward: treat degrees as qualification TYPES and let the subject
-- come from the relation. A proper Degree x Subject split (with `level` on
-- Degree and `category` on Subject, where they belong) is the real fix and
-- is a much larger piece of work -- 98 of the 143 current degree rows have
-- no career to attach a subject to, which is exactly why subjects ended up
-- baked into slugs in the first place.
--
-- career_degrees is @OrderColumn-backed, so each career's set is rewritten
-- rather than appended -- appending would order it B.Sc / PhD / M.Sc and
-- leave sort_order non-dense.

DELETE FROM career_degrees
WHERE career_slug IN ('biology', 'chemistry', 'mathematics', 'physics', 'statistics');

INSERT INTO career_degrees (career_slug, degree_slug, sort_order) VALUES
    ('biology',     'b-sc', 0), ('biology',     'msc', 1), ('biology',     'phd', 2),
    ('chemistry',   'b-sc', 0), ('chemistry',   'msc', 1), ('chemistry',   'phd', 2),
    ('mathematics', 'b-sc', 0), ('mathematics', 'msc', 1), ('mathematics', 'phd', 2),
    ('physics',     'b-sc', 0), ('physics',     'msc', 1), ('physics',     'phd', 2),
    ('statistics',  'b-sc', 0), ('statistics',  'msc', 1), ('statistics',  'phd', 2);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have no degree mapping', bad;
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
