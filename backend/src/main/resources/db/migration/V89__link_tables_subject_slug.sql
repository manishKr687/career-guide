-- Gives the qualification link tables a place to record the subject.
--
-- "M.Sc" + "Physics" is only expressible if the row that selects the degree
-- can also carry the subject. That is this migration.
--
-- WHY THE PRIMARY KEY CHANGES ON TWO OF THEM
--
-- career_degrees is keyed (career_slug, degree_slug), so a career can hold at
-- most one row per degree. That is fatal for the new model: a data-science
-- career should be able to say "B.Sc in Computer Science OR B.Sc in
-- Statistics OR B.Sc in Mathematics", which is three rows sharing a degree.
-- Same for college_degrees: a college offering M.Tech offers it in a dozen
-- branches, not one.
--
-- The natural key is therefore (career, degree, subject). But subject is
-- OPTIONAL -- MBBS takes none -- and a nullable column cannot participate in
-- a PRIMARY KEY. So these two tables get a surrogate `id` plus a unique index
-- over COALESCE(subject_slug, ''), which enforces exactly the natural key
-- while tolerating the null.
--
-- This is deliberately NOT the SlugTripleId @EmbeddedId pattern used by
-- college_career_degrees and exam_career_degrees. That pattern requires every
-- key component to be non-null, which is precisely what optional-subject
-- rules out. Using a surrogate here is not an inconsistency to be tidied up
-- later; it is the consequence of the column being nullable.
--
-- exam_career_degrees is treated differently on purpose: it gets subject_slug
-- as a plain nullable attribute and keeps its existing triple key. Only 2 of
-- its rows reference a doomed degree, and widening an @EmbeddedId to four
-- parts would mean a SlugQuadId and a rewrite of working code for no present
-- benefit. The accepted limitation: one subject per (exam, career, degree).
-- If an exam ever needs to name two subjects for the same career and degree,
-- this table gets the same surrogate treatment as the two above.
--
-- college_career_degrees is untouched -- none of its rows reference any of
-- the 62 degrees being removed, so it has nothing to repoint.
--
-- ON DELETE RESTRICT on the new subject FKs, not CASCADE. The existing FKs
-- into `degrees` are ON DELETE CASCADE, which is exactly why the removal in
-- V91 has to be sequenced so carefully -- a stray DELETE silently takes the
-- links with it instead of raising. Subjects should not repeat that mistake:
-- deleting a subject that is still in use must fail loudly.
--
-- Everything here is nullable and additive. No existing row changes and no
-- existing row becomes invalid. The repoint happens in V90.

-- ---------------------------------------------------------- career_degrees
ALTER TABLE career_degrees
    ADD COLUMN subject_slug VARCHAR(64) REFERENCES subjects (slug) ON DELETE RESTRICT;

ALTER TABLE career_degrees DROP CONSTRAINT career_degrees_pkey;
ALTER TABLE career_degrees ADD COLUMN id BIGSERIAL PRIMARY KEY;

CREATE UNIQUE INDEX uq_career_degrees_natural
    ON career_degrees (career_slug, degree_slug, COALESCE(subject_slug, ''));

CREATE INDEX idx_career_degrees_career ON career_degrees (career_slug);

-- --------------------------------------------------------- college_degrees
ALTER TABLE college_degrees
    ADD COLUMN subject_slug VARCHAR(64) REFERENCES subjects (slug) ON DELETE RESTRICT;

ALTER TABLE college_degrees DROP CONSTRAINT college_degrees_pkey;
ALTER TABLE college_degrees ADD COLUMN id BIGSERIAL PRIMARY KEY;

CREATE UNIQUE INDEX uq_college_degrees_natural
    ON college_degrees (college_slug, degree_slug, COALESCE(subject_slug, ''));

CREATE INDEX idx_college_degrees_college ON college_degrees (college_slug);

-- ----------------------------------------------------- exam_career_degrees
ALTER TABLE exam_career_degrees
    ADD COLUMN subject_slug VARCHAR(64) REFERENCES subjects (slug) ON DELETE RESTRICT;

DO $$
DECLARE bad int;
BEGIN
    -- The surrogate key must not have changed row counts or collapsed
    -- anything: these three tables held 1049 / 54 / 2 rows before.
    SELECT count(*) INTO bad FROM career_degrees WHERE subject_slug IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees should have no subjects yet, found %', bad;
    END IF;

    -- The natural-key index must actually be doing its job: every existing
    -- (career, degree) pair is still unique with a null subject.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug, degree_slug FROM career_degrees
        GROUP BY career_slug, degree_slug HAVING count(*) > 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% duplicate (career, degree) pair(s) survived the key change', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT college_slug, degree_slug FROM college_degrees
        GROUP BY college_slug, degree_slug HAVING count(*) > 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% duplicate (college, degree) pair(s) survived the key change', bad;
    END IF;

    -- @OrderColumn contract: sort_order must stay dense 0..n-1 per owner.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_degrees
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_degrees.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
