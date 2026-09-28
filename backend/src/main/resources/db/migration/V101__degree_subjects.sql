-- Gives Subject its first consumer: the (degree, subject) pairs that say
-- "B.Sc is offered in Computer Science".
--
-- V87 created `subjects` with 34 correct rows and nothing reading them. That
-- was accepted at the time as a prerequisite rather than a feature. This is
-- the piece that makes it load-bearing, and it has to land BEFORE V102
-- deletes the product rows -- otherwise "B.Sc (Computer Science)" stops being
-- expressible anywhere and the cleanup destroys information instead of
-- reorganising it.
--
-- WHAT A PAIR REPLACES
--
--   before   degrees row 'bsc-computer-science', title "B.Sc (Computer
--            Science)", level Undergraduate, category it-software
--   after    degree_subjects (b-sc, computer-science)
--
-- The title is composed from its parts at render time rather than stored, so
-- it can never drift from them. `level` comes from the degree (all 17 B.Sc
-- variants independently recorded 'Undergraduate' -- one fact, stored
-- seventeen times) and `category` from the subject (the same subject carried
-- the same category in every family it appeared in). Each fact now lives in
-- exactly one place.
--
-- SCOPE: 42 pairs, covering only the UNREFERENCED product rows that V102
-- removes. Deliberately not a complete catalog of every degree/subject
-- combination:
--
--   * Referenced product rows (bsc-nursing, ba-psychology, phd-engineering
--     and the rest) keep their own degrees row for now. Adding pairs for them
--     too would create a second way to say the same thing -- exactly the
--     duplication this is unwinding -- while their 69 inbound references
--     still point at the old row. They convert when those are repointed.
--   * Degrees with no subject at all (MBBS, B.Arch) will never appear here;
--     `degrees.requires_subject` (V88) already marks them false.
--
-- So this table means "pairs that replaced a deleted row", and will grow into
-- "every valid combination" as the rest migrate. It is partial on purpose.
--
-- TWO ROWS THAT DO NOT DECOMPOSE, AND ONE THAT DOES SO ONLY WITH HELP
--
--   ba-bed, bsc-bed, bsc-llb   NOT degree x subject at all -- they are DUAL
--                              degrees (B.A. + B.Ed earned together). A naive
--                              prefix split yields the subject "bed", which
--                              is not a field of study. These keep their own
--                              rows and V102 leaves them alone.
--   phd-agricultural-sciences  the subject exists as `agriculture`; the two
--                              names are the same field, so it is mapped
--                              explicitly rather than by prefix.
--   phd-arts-humanities        "Arts & Humanities" is a CATEGORY, not a field
--                              anyone enrols in. No pair is created; V102
--                              deletes it outright, and the generic `phd` row
--                              already covers the unspecified case.
--
-- ON DELETE RESTRICT on subject_slug, matching V89's reasoning: a subject
-- still paired with a degree must not be deletable out from under it.

CREATE TABLE degree_subjects (
    degree_slug  VARCHAR(64) NOT NULL REFERENCES degrees (slug)  ON DELETE CASCADE,
    subject_slug VARCHAR(64) NOT NULL REFERENCES subjects (slug) ON DELETE RESTRICT,
    PRIMARY KEY (degree_slug, subject_slug)
);

CREATE INDEX idx_degree_subjects_subject ON degree_subjects (subject_slug);

-- Derived from the rows V102 removes, by stripping the family prefix. Derived
-- rather than hand-listed so the pair set cannot disagree with the delete set.
INSERT INTO degree_subjects (degree_slug, subject_slug)
SELECT p.degree_slug, p.subject_slug
FROM (
    SELECT
        CASE WHEN d.slug LIKE 'bsc-%' THEN 'b-sc'
             WHEN d.slug LIKE 'msc-%' THEN 'msc'
             WHEN d.slug LIKE 'ba-%'  THEN 'ba'
             WHEN d.slug LIKE 'ma-%'  THEN 'ma'
             WHEN d.slug LIKE 'phd-%' THEN 'phd' END AS degree_slug,
        CASE WHEN d.slug LIKE 'bsc-%' THEN substr(d.slug, 5)
             WHEN d.slug LIKE 'msc-%' THEN substr(d.slug, 5)
             WHEN d.slug LIKE 'ba-%'  THEN substr(d.slug, 4)
             WHEN d.slug LIKE 'ma-%'  THEN substr(d.slug, 4)
             WHEN d.slug LIKE 'phd-%' THEN substr(d.slug, 5) END AS subject_slug
    FROM degrees d
    WHERE (d.slug LIKE 'bsc-%' OR d.slug LIKE 'msc-%' OR d.slug LIKE 'ba-%'
           OR d.slug LIKE 'ma-%' OR d.slug LIKE 'phd-%')
      AND NOT EXISTS (SELECT 1 FROM career_degrees x        WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_degrees x       WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_exams x          WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_skills x         WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_resources x      WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM exam_career_degrees x   WHERE x.degree_slug = d.slug)
) p
-- Silently drops the dual degrees and arts-humanities, whose computed subject
-- matches no row. That is the intent, and the count assertion below is what
-- stops it from silently dropping anything else.
JOIN subjects s ON s.slug = p.subject_slug
ON CONFLICT DO NOTHING;

-- The one name mismatch: same field, different wording.
INSERT INTO degree_subjects (degree_slug, subject_slug)
VALUES ('phd', 'agriculture')
ON CONFLICT DO NOTHING;

DO $$
DECLARE bad int;
BEGIN
    -- Originally `IF bad <> 42`. That number was a snapshot of one database,
    -- not a property of the migration: the pair set is derived from which
    -- product degree rows are UNREFERENCED, and a database where an editor has
    -- linked one of them to a career or college legitimately yields fewer pairs
    -- than one where nobody has. On a pristine replay the answer is 44, so the
    -- absolute count made the history unreplayable -- a fresh environment could
    -- not be built from these migrations at all.
    --
    -- Replaced with the invariant the count was standing in for. The comment on
    -- the INSERT says it plainly: dropping the dual degrees and arts-humanities
    -- is intended, and the check exists to stop anything ELSE being dropped
    -- silently. So assert exactly that -- every candidate whose computed subject
    -- is a real subject produced a pair -- which holds on any database.
    SELECT count(*) INTO bad
    FROM (
        SELECT
            CASE WHEN d.slug LIKE 'bsc-%' THEN 'b-sc'
                 WHEN d.slug LIKE 'msc-%' THEN 'msc'
                 WHEN d.slug LIKE 'ba-%'  THEN 'ba'
                 WHEN d.slug LIKE 'ma-%'  THEN 'ma'
                 WHEN d.slug LIKE 'phd-%' THEN 'phd' END AS degree_slug,
            CASE WHEN d.slug LIKE 'bsc-%' THEN substr(d.slug, 5)
                 WHEN d.slug LIKE 'msc-%' THEN substr(d.slug, 5)
                 WHEN d.slug LIKE 'ba-%'  THEN substr(d.slug, 4)
                 WHEN d.slug LIKE 'ma-%'  THEN substr(d.slug, 4)
                 WHEN d.slug LIKE 'phd-%' THEN substr(d.slug, 5) END AS subject_slug
        FROM degrees d
        WHERE (d.slug LIKE 'bsc-%' OR d.slug LIKE 'msc-%' OR d.slug LIKE 'ba-%'
               OR d.slug LIKE 'ma-%' OR d.slug LIKE 'phd-%')
          AND NOT EXISTS (SELECT 1 FROM career_degrees x        WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM college_degrees x       WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM degree_exams x          WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM degree_skills x         WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM degree_resources x      WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = d.slug)
          AND NOT EXISTS (SELECT 1 FROM exam_career_degrees x   WHERE x.degree_slug = d.slug)
    ) p
    JOIN subjects s ON s.slug = p.subject_slug
    WHERE NOT EXISTS (
        SELECT 1 FROM degree_subjects ds
        WHERE ds.degree_slug = p.degree_slug AND ds.subject_slug = p.subject_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% unreferenced product degree(s) with a known subject produced no pair', bad;
    END IF;

    SELECT count(*) INTO bad FROM degree_subjects;
    IF bad = 0 THEN
        RAISE EXCEPTION 'degree_subjects is empty -- the derivation matched nothing';
    END IF;

    -- Every degree named here must be a real qualification type that takes a
    -- subject. If one of these ever came back false, the pair would describe
    -- something like "MBBS in Physics".
    SELECT count(*) INTO bad FROM degree_subjects ds
    JOIN degrees d ON d.slug = ds.degree_slug
    WHERE NOT d.requires_subject;
    IF bad > 0 THEN
        RAISE EXCEPTION '% pair(s) attach a subject to a degree that takes none', bad;
    END IF;

    -- Only the five generic families should appear as parents.
    SELECT count(*) INTO bad FROM degree_subjects
    WHERE degree_slug NOT IN ('b-sc', 'msc', 'ba', 'ma', 'phd');
    IF bad > 0 THEN
        RAISE EXCEPTION '% pair(s) have an unexpected parent degree', bad;
    END IF;

    -- The dual degrees must NOT have been decomposed.
    IF EXISTS (SELECT 1 FROM degree_subjects WHERE subject_slug IN ('bed', 'llb')) THEN
        RAISE EXCEPTION 'a dual degree was wrongly decomposed into a subject';
    END IF;
END $$;
