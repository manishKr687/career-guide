-- Completes the post-10th polytechnic route: 3 careers -> 10.
--
-- The After-10th stage page shows "Careers to Explore at This Stage" with
-- exactly three entries -- Civil, Electrical and Mechanical Engineering.
-- That is a strange answer to "what can I do after 10th?", and it looked
-- arbitrary, but it is not: V80 derives the stage from careers linked to an
-- exam categorised 'After 10th', which is polytechnic-cet alone, and only
-- those three were ever linked to it.
--
-- V80's own header says how to fix this: "To add a field later, link the
-- exam -- do not edit this migration." So this links the exam.
--
-- WHICH CAREERS, AND WHY NOT ALL 12 WITH A DIPLOMA
--
-- Twelve careers have a Diploma-level entry in career_degrees, but only ten
-- belong here. Nursing (GNM) and Pharmacy (D.Pharm) are diploma routes that
-- require 10+2 -- they are post-TWELFTH diplomas and are correctly absent
-- from a post-tenth stage. The polytechnic engineering diploma is the one
-- that genuinely admits students straight after class 10.
--
-- So the set is derived: careers in engineering-technology that have a
-- Diploma-level qualification. That is exactly the 10 already visible in the
-- Vocational stream, minus nothing -- and deriving it means adding a diploma
-- route to another engineering career puts it here automatically, rather
-- than depending on someone remembering this file exists.
--
-- THREE TABLES, NOT ONE
--
--   career_exams   the link itself
--   exam_careers   its mirror -- the last mirrored pair in the schema, and
--                  the integrity check fails the boot if they disagree. This
--                  is precisely the drift that went unnoticed for ten
--                  migrations before V75/V77.
--   career_stages  V80 derived this once and it does not re-derive itself,
--                  so the stage rows are written here too.
--
-- All three carry sort_order and all three are @OrderColumn-backed, so each
-- insert has to land at a dense position: appended per career for
-- career_exams, appended per exam for exam_careers, and -- because After-10th
-- sorts BEFORE After-12th -- inserted mid-sequence for career_stages, which
-- is why that one is renumbered wholesale afterwards rather than appended.

-- ------------------------------------------------------- career_exams link
-- One row per career, so a correlated max()+1 is safe here: no two inserted
-- rows share a career_slug and could collide on the same sort_order.
INSERT INTO career_exams (career_slug, exam_slug, sort_order)
SELECT d.career_slug, 'polytechnic-cet',
       (SELECT coalesce(max(ce.sort_order), -1) + 1
        FROM career_exams ce WHERE ce.career_slug = d.career_slug)
FROM (
    SELECT DISTINCT cd.career_slug
    FROM career_degrees cd
    JOIN degrees dg ON dg.slug = cd.degree_slug
    JOIN careers c  ON c.slug  = cd.career_slug
    WHERE dg.level = 'Diploma'
      AND c.category_slug = 'engineering-technology'
) d
WHERE NOT EXISTS (
    SELECT 1 FROM career_exams ce
    WHERE ce.career_slug = d.career_slug AND ce.exam_slug = 'polytechnic-cet');

-- ------------------------------------------------------- exam_careers mirror
-- All rows share one exam_slug, so max()+1 would hand them all the same
-- sort_order -- ROW_NUMBER spreads them instead.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT 'polytechnic-cet', d.career_slug,
       (SELECT coalesce(max(sort_order), -1) FROM exam_careers WHERE exam_slug = 'polytechnic-cet')
       + ROW_NUMBER() OVER (ORDER BY d.career_slug)
FROM (
    SELECT DISTINCT cd.career_slug
    FROM career_degrees cd
    JOIN degrees dg ON dg.slug = cd.degree_slug
    JOIN careers c  ON c.slug  = cd.career_slug
    WHERE dg.level = 'Diploma'
      AND c.category_slug = 'engineering-technology'
) d
WHERE NOT EXISTS (
    SELECT 1 FROM exam_careers ec
    WHERE ec.career_slug = d.career_slug AND ec.exam_slug = 'polytechnic-cet');

-- --------------------------------------------------------- career_stages
INSERT INTO career_stages (career_slug, stage_slug, sort_order)
SELECT d.career_slug, 'after-10th', 0
FROM (
    SELECT DISTINCT cd.career_slug
    FROM career_degrees cd
    JOIN degrees dg ON dg.slug = cd.degree_slug
    JOIN careers c  ON c.slug  = cd.career_slug
    WHERE dg.level = 'Diploma'
      AND c.category_slug = 'engineering-technology'
) d
WHERE NOT EXISTS (
    SELECT 1 FROM career_stages cs
    WHERE cs.career_slug = d.career_slug AND cs.stage_slug = 'after-10th');

-- Renumber every career's stages into chronological order. Applied to the
-- whole table rather than just the affected careers: it is V80's own rule
-- restated, so it is a no-op wherever the data is already right, and it
-- self-heals any career whose sequence has drifted since.
WITH ordered AS (
    SELECT cs.career_slug, cs.stage_slug,
           ROW_NUMBER() OVER (PARTITION BY cs.career_slug ORDER BY st.sort_order) - 1 AS n
    FROM career_stages cs
    JOIN stages st ON st.slug = cs.stage_slug
)
UPDATE career_stages cs
SET sort_order = o.n
FROM ordered o
WHERE cs.career_slug = o.career_slug
  AND cs.stage_slug = o.stage_slug
  AND cs.sort_order <> o.n;

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM career_stages WHERE stage_slug = 'after-10th';
    IF bad <> 10 THEN
        RAISE EXCEPTION 'expected 10 careers on after-10th, found %', bad;
    END IF;

    -- Nursing and Pharmacy have diploma routes but require 10+2 -- they must
    -- NOT have been swept in by the derivation.
    IF EXISTS (SELECT 1 FROM career_stages
               WHERE stage_slug = 'after-10th'
                 AND career_slug IN ('nursing', 'pharmacy')) THEN
        RAISE EXCEPTION 'a post-12th diploma career was added to the after-10th stage';
    END IF;

    -- The stage is derived from the exam link, so the two must agree exactly
    -- or the next person to re-derive V80's rule gets a different answer.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_stages WHERE stage_slug = 'after-10th'
        EXCEPT
        SELECT career_slug FROM career_exams WHERE exam_slug = 'polytechnic-cet'
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% after-10th career(s) have no polytechnic-cet link', bad;
    END IF;

    -- Mirror agreement. afterMigrate checks this too, but failing here names
    -- the migration that broke it.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career_exams row(s) missing from the exam_careers mirror', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_stages
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_stages.sort_order is not dense for % career(s)', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_exams
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_exams.sort_order is not dense for % career(s)', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT exam_slug FROM exam_careers
        GROUP BY exam_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'exam_careers.sort_order is not dense for % exam(s)', bad;
    END IF;
END $$;
