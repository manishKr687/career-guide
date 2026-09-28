-- Gives Specialization the two things it needs to be a page in its own right:
-- a description OF THE FIELD, and the two relations it was missing.
--
-- Specialization already had careers, job roles, skills, industries, exams and
-- certifications as reusable relations. Three were absent, and they are the
-- reason a specialization could not carry its own page:
--
--   Specialization -> Degrees        no table at all
--   Specialization -> Resources      no table at all
--   Specialization -> Colleges       college_specializations exists, 0 rows
--
-- DELIBERATELY NOT ADDED: specialization_related.
--
-- "Related specializations" is the sibling set -- the other specializations of
-- the same career. career_specializations already states that: the 16 rows
-- under computer-science-and-engineering ARE Cloud Computing's siblings. A
-- second table listing them again would be the duplicated data this model is
-- trying to avoid, and it would need re-editing every time a specialization is
-- added to a career. It is derived at read time instead.
--
-- DELIBERATELY NOT BULK-SEEDED: the five relations that are still empty for
-- most of the 263 rows.
--
-- The tempting move is to copy each parent career's colleges/exams/skills down
-- onto every one of its specializations -- roughly 3,500 rows, generated in one
-- statement. It would fill the page for all 263. It would also assert things
-- nobody checked: that every college offering CSE teaches Blockchain, that
-- every CSE exam is a Game Development exam. For a career-guidance product
-- those are claims a student acts on, not placeholder text.
--
-- So the relation stays authoritative and thin, and the page falls back to the
-- parent career's data UNDER A LABEL THAT SAYS SO ("Top colleges for Computer
-- Science & Engineering", not "...offering this specialization"). Filling a
-- specialization's own relation then overrides the fallback. That is why these
-- tables can ship empty without leaving 262 pages blank.

-- "What you will learn": what the FIELD covers, as opposed to `description`
-- (one line, used on cards and in search) and `responsibilities` (what a
-- person in the role does day to day). Nullable -- 263 rows do not have one
-- yet, and an empty string would be indistinguishable from a real blank.
ALTER TABLE specializations
    ADD COLUMN overview text;

-- Key highlights: short claims about the field ("High demand across
-- industries"). Same storage as Career.growthPath and
-- Specialization.responsibilities -- there is nothing in the catalog for a
-- highlight to link to, it is descriptive text.
ALTER TABLE specializations
    ADD COLUMN highlights text[] NOT NULL DEFAULT '{}';

-- Specialization -> Degrees, in the same (degree, optional subject) shape as
-- career_degrees since V103, and for the same reason: a degree row is a
-- qualification TYPE, so "B.Tech" alone cannot say "B.Tech in Artificial
-- Intelligence" -- that is degree `b-tech` plus subject `artificial-
-- intelligence`. Reusing the shape means QualificationTitle composes the
-- display string here exactly as it does for careers, instead of a second
-- rule that can drift.
--
-- Surrogate id rather than a composite primary key, again as career_degrees:
-- subject_slug is nullable and a nullable column cannot sit in a PK. The
-- unique index over COALESCE(subject_slug, '') enforces what the composite key
-- would have, while still allowing the same degree twice in two subjects.
CREATE TABLE specialization_degrees (
    specialization_slug varchar(64) NOT NULL REFERENCES specializations(slug) ON DELETE CASCADE,
    degree_slug         varchar(64) NOT NULL REFERENCES degrees(slug)         ON DELETE CASCADE,
    subject_slug        varchar(64)          REFERENCES subjects(slug)        ON DELETE RESTRICT,
    sort_order          integer     NOT NULL DEFAULT 0,
    id                  bigserial   PRIMARY KEY
);

CREATE UNIQUE INDEX uq_specialization_degrees_natural
    ON specialization_degrees (specialization_slug, degree_slug, COALESCE(subject_slug, ''));

-- Specialization -> Resources. Plain two-slug join, the same shape as
-- degree_resources and resource_careers; a resource is already a shared
-- entity, so this only records which specializations it is relevant to.
CREATE TABLE specialization_resources (
    specialization_slug varchar(64) NOT NULL REFERENCES specializations(slug) ON DELETE CASCADE,
    resource_slug       varchar(64) NOT NULL REFERENCES resources(slug)       ON DELETE CASCADE,
    sort_order          integer     NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, resource_slug)
);

-- Both new tables carry sort_order and two *_slug columns and no `slug` of
-- their own, so check_relationship_integrity()'s density rule picks them up
-- automatically -- no registration needed, but any seed must write 0..n-1
-- densely per specialization or the next boot fails.

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'specializations'
      AND column_name IN ('overview', 'highlights');
    IF bad <> 2 THEN
        RAISE EXCEPTION 'expected 2 new specialization columns, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name IN ('specialization_degrees', 'specialization_resources');
    IF bad <> 2 THEN
        RAISE EXCEPTION 'expected 2 new specialization join tables, found %', bad;
    END IF;

    -- The density check must actually see them, or a bad seed ships silently.
    SELECT count(*) INTO bad
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.table_name IN ('specialization_degrees', 'specialization_resources')
      AND c.column_name = 'sort_order'
      AND NOT EXISTS (
          SELECT 1 FROM information_schema.columns c3
          WHERE c3.table_schema = 'public' AND c3.table_name = c.table_name
            AND c3.column_name = 'slug'
      );
    IF bad <> 2 THEN
        RAISE EXCEPTION 'new join tables are not visible to the sort_order density check';
    END IF;
END $$;
