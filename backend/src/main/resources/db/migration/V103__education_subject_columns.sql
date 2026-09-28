-- Lets a qualification link name its subject, so Degree and Subject can
-- finally be fully separate models.
--
-- The goal: `degrees` holds qualification TYPES only -- B.A., not
-- "B.A. (Psychology)". A course's education is then a CHOICE of two things,
-- a degree and a subject, rather than a lookup of a pre-combined row.
--
-- 19 product rows still block that. They survived V102 because they have 71
-- live references and every FK into `degrees` is ON DELETE CASCADE, so
-- deleting one would silently take its links:
--
--   college_degrees       54   all phd-engineering
--   career_degrees        13   ba-psychology, ma-sociology, bsc-nursing, ...
--   exam_career_degrees    2   bsc-agriculture, bsc-forestry
--
-- Those references can only move to (generic degree + subject) once the link
-- rows can hold a subject. This migration adds that capacity and nothing
-- else; V104 repoints, V105 deletes.
--
-- ON THE CHURN: V89 added these exact columns, they were scoped out, and V96
-- removed them. This re-adds them because the requirement changed -- Subject
-- is now wanted on career education, which is what V89 anticipated and V96
-- undid. Recording it here so the sequence reads as a reversal rather than
-- as someone going in circles.
--
-- WHY A SURROGATE KEY AGAIN
--
-- career_degrees is keyed (career_slug, degree_slug), which allows one row
-- per degree per career. That is fatal here: a data-science career must be
-- able to say "B.Sc in Computer Science OR B.Sc in Statistics", which is two
-- rows sharing a degree. The natural key becomes (career, degree, subject) --
-- but subject is OPTIONAL, since MBBS takes none, and a nullable column
-- cannot sit in a PRIMARY KEY. So: surrogate `id`, plus a unique index over
-- COALESCE(subject_slug, '') enforcing exactly the natural key while
-- tolerating the null. Same for college_degrees, where one college offers
-- M.Tech in a dozen branches.
--
-- exam_career_degrees already kept its subject_slug through V96 and needs no
-- change: subject is a plain attribute there, not part of the key.
--
-- ON DELETE RESTRICT on the subject FKs, deliberately unlike the CASCADE on
-- degree_slug: a subject still in use must fail loudly rather than take
-- meaning out of rows silently. That CASCADE is the reason V102/V104/V105
-- have to be sequenced so carefully in the first place.
--
-- Everything here is nullable and additive. No row changes.

-- ---------------------------------------------------------- career_degrees
ALTER TABLE career_degrees
    ADD COLUMN subject_slug VARCHAR(64) REFERENCES subjects (slug) ON DELETE RESTRICT;

ALTER TABLE career_degrees DROP CONSTRAINT career_degrees_pkey;
ALTER TABLE career_degrees ADD COLUMN id BIGSERIAL PRIMARY KEY;

CREATE UNIQUE INDEX uq_career_degrees_natural
    ON career_degrees (career_slug, degree_slug, COALESCE(subject_slug, ''));

-- --------------------------------------------------------- college_degrees
ALTER TABLE college_degrees
    ADD COLUMN subject_slug VARCHAR(64) REFERENCES subjects (slug) ON DELETE RESTRICT;

ALTER TABLE college_degrees DROP CONSTRAINT college_degrees_pkey;
ALTER TABLE college_degrees ADD COLUMN id BIGSERIAL PRIMARY KEY;

CREATE UNIQUE INDEX uq_college_degrees_natural
    ON college_degrees (college_slug, degree_slug, COALESCE(subject_slug, ''));

DO $$
DECLARE bad int;
BEGIN
    -- The key change must not have collapsed or duplicated anything.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug, degree_slug FROM career_degrees
        GROUP BY career_slug, degree_slug HAVING count(*) > 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% duplicate (career, degree) pair(s) after the key change', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT college_slug, degree_slug FROM college_degrees
        GROUP BY college_slug, degree_slug HAVING count(*) > 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% duplicate (college, degree) pair(s) after the key change', bad;
    END IF;

    -- Nothing may carry a subject yet; V104 does the repointing.
    SELECT count(*) INTO bad FROM career_degrees WHERE subject_slug IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees already has % subject(s) set', bad;
    END IF;

    -- @OrderColumn contract still holds.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
