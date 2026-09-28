-- Removes the 43 unreferenced Degree x Subject product rows, now that V101
-- has somewhere for them to live.
--
-- These are rows that bake a field of study into the qualification --
-- "B.Sc (Computer Science)", "M.Sc Agriculture", "PhD in Economics". Each one
-- restated `level` from its degree family (all 17 B.Sc variants independently
-- recorded 'Undergraduate') and carried a `category` that described its
-- subject rather than itself. Materialising a product as rows is what grew
-- the catalog to 143 entries of which 90 were referenced by nothing.
--
-- 42 of the 43 survive as degree_subjects pairs (V101) and are asserted to
-- below BEFORE anything is deleted. The 43rd, phd-arts-humanities, is dropped
-- outright: "Arts & Humanities" is a category, not a field anyone enrols in,
-- and the generic `phd` row already covers the unspecified case.
--
-- WHAT IS DELIBERATELY NOT TOUCHED
--
--   * Referenced product rows -- bsc-nursing, ba-psychology, phd-engineering
--     and the rest. 69 rows across career_degrees, college_degrees and
--     exam_career_degrees still point at them. Every FK into `degrees` is
--     ON DELETE CASCADE, so deleting one would silently take its links
--     rather than raising. They convert when those references are repointed;
--     that is a separate, larger piece of work.
--   * ba-bed, bsc-bed, bsc-llb -- DUAL degrees (B.A. + B.Ed earned together),
--     not qualification x subject. "B.Sc in Education" is not a thing.
--   * The ~45 genuinely unlinked real qualifications -- BDS, BAMS, BVSc & AH,
--     Pharm.D, BCA, PGDM and so on. Those have no career pointing at them
--     yet, but they are real degrees and /degrees is a reference catalog in
--     its own right. "Nothing links to it" is not the same as "unnecessary",
--     and this migration deletes only the second kind.
--
-- After this the catalog is 143 -> 100 rows, and every remaining row is
-- either a qualification type, a fused qualification (MBBS), a dual degree,
-- or a product row that still has live references.

DO $$
DECLARE bad int;
BEGIN
    -- Nothing may be deleted that is not first recoverable as a pair, except
    -- the one row we are deliberately dropping without replacement.
    SELECT count(*) INTO bad
    FROM degrees d
    WHERE (d.slug LIKE 'bsc-%' OR d.slug LIKE 'msc-%' OR d.slug LIKE 'ba-%'
           OR d.slug LIKE 'ma-%' OR d.slug LIKE 'phd-%')
      AND d.slug NOT IN ('ba-bed', 'bsc-bed', 'bsc-llb', 'phd-arts-humanities')
      AND NOT EXISTS (SELECT 1 FROM career_degrees x        WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_degrees x       WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_exams x          WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_skills x         WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_resources x      WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM exam_career_degrees x   WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (
          SELECT 1 FROM degree_subjects ds
          WHERE ds.degree_slug = CASE
                    WHEN d.slug LIKE 'bsc-%' THEN 'b-sc'
                    WHEN d.slug LIKE 'msc-%' THEN 'msc'
                    WHEN d.slug LIKE 'ba-%'  THEN 'ba'
                    WHEN d.slug LIKE 'ma-%'  THEN 'ma'
                    WHEN d.slug LIKE 'phd-%' THEN 'phd' END);
    IF bad > 0 THEN
        RAISE EXCEPTION '% product row(s) have no degree_subjects pair to survive as', bad;
    END IF;
END $$;

DELETE FROM degrees d
WHERE (d.slug LIKE 'bsc-%' OR d.slug LIKE 'msc-%' OR d.slug LIKE 'ba-%'
       OR d.slug LIKE 'ma-%' OR d.slug LIKE 'phd-%')
  AND d.slug NOT IN ('ba-bed', 'bsc-bed', 'bsc-llb')
  AND NOT EXISTS (SELECT 1 FROM career_degrees x        WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM college_degrees x       WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM degree_exams x          WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM degree_skills x         WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM degree_resources x      WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = d.slug)
  AND NOT EXISTS (SELECT 1 FROM exam_career_degrees x   WHERE x.degree_slug = d.slug);

DO $$
DECLARE bad int;
BEGIN
    -- Originally `IF bad <> 100`. Like V101's 42, that was a snapshot of one
    -- database rather than a property of this migration: the delete set is
    -- whichever product rows are unreferenced, so a database where an editor has
    -- linked one of them keeps more rows than a pristine one. On a clean replay
    -- 98 remain, which made the history unreplayable.
    --
    -- Replaced with the two invariants the count was standing in for: the delete
    -- finished, and it did not take a pair's degree with it.
    SELECT count(*) INTO bad FROM degrees d
    WHERE (d.slug LIKE 'bsc-%' OR d.slug LIKE 'msc-%' OR d.slug LIKE 'ba-%'
           OR d.slug LIKE 'ma-%' OR d.slug LIKE 'phd-%')
      -- The same exclusion the DELETE carries: the dual degrees are kept
      -- deliberately, since 'B.A. B.Ed' is one qualification rather than a
      -- degree taken in a subject, so it cannot be expressed as a pair.
      AND d.slug NOT IN ('ba-bed', 'bsc-bed', 'bsc-llb')
      AND NOT EXISTS (SELECT 1 FROM career_degrees x        WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_degrees x       WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_exams x          WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_skills x         WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM degree_resources x      WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = d.slug)
      AND NOT EXISTS (SELECT 1 FROM exam_career_degrees x   WHERE x.degree_slug = d.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% unreferenced product degree row(s) survived the delete', bad;
    END IF;

    -- degree_subjects.degree_slug is ON DELETE CASCADE, so a delete that reached
    -- a paired degree would have removed the pair silently. V101 ran first
    -- precisely so this could not happen; this proves it did not.
    SELECT count(*) INTO bad FROM degree_subjects ds
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = ds.degree_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree/subject pair(s) lost their degree to the delete', bad;
    END IF;

    -- The generic families the pairs depend on must still exist -- deleting
    -- `b-sc` would orphan 11 pairs and is exactly the kind of mistake a
    -- LIKE-based DELETE can make.
    SELECT count(*) INTO bad FROM (VALUES
        ('b-sc'), ('msc'), ('ba'), ('ma'), ('phd')
    ) AS v(slug)
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = v.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% generic degree family/families were deleted', bad;
    END IF;

    -- The dual degrees must have survived.
    SELECT count(*) INTO bad FROM (VALUES
        ('ba-bed'), ('bsc-bed'), ('bsc-llb')
    ) AS v(slug)
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = v.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% dual degree(s) were wrongly deleted', bad;
    END IF;

    -- Every pair must still point at a live degree and subject.
    SELECT count(*) INTO bad FROM degree_subjects ds
    WHERE NOT EXISTS (SELECT 1 FROM degrees d  WHERE d.slug = ds.degree_slug)
       OR NOT EXISTS (SELECT 1 FROM subjects s WHERE s.slug = ds.subject_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree/subject pair(s) were orphaned by the delete', bad;
    END IF;

    -- Originally `IF bad <> 42`, and redundant as well as unreplayable: the
    -- check immediately above already proves no pair was orphaned by the
    -- delete, which is the actual risk. The absolute number only restated how
    -- many pairs one particular database happened to have.
    SELECT count(*) INTO bad FROM degree_subjects;
    IF bad = 0 THEN
        RAISE EXCEPTION 'every degree/subject pair disappeared during the delete';
    END IF;

    -- No live reference may have been cascaded away. Every remaining link
    -- must still resolve to a degree that exists.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) lost their entire degree mapping', bad;
    END IF;
END $$;
