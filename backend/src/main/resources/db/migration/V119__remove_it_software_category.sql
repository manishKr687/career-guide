-- Removes the IT & Software category, repointing its content to
-- Engineering & Technology.
--
-- WHY. It has held zero careers since the taxonomy settled -- Computer Science &
-- Engineering and Information Technology are both filed under Engineering &
-- Technology, and the computing subjects one level down are specializations of
-- them. A category with nothing in it is not merely empty furniture on the
-- browse page: the assessment scores toward it, so it can be returned as a
-- reader's leading field and then offer them nothing to read.
--
-- IT IS NOT EMPTY, THOUGH, AND NOTHING HERE IS DELETED BUT THE CATEGORY ROW.
-- Three kinds of live content point at it, and the foreign keys carry no
-- ON DELETE CASCADE, so each has to be repointed first:
--
--   2 degrees   bca, mca -- the non-engineering computing route
--   5 subjects  computer-science, information-technology, data-science,
--               artificial-intelligence, cybersecurity -- these compose degree
--               titles like "B.Sc (Computer Science)" via degree_subjects
--   7 assessment option weights
--
-- WHY ENGINEERING & TECHNOLOGY IS THE TARGET. It is where this catalog already
-- files the computing careers, so a reader following a computing subject or a
-- BCA/MCA degree lands among the careers those routes actually lead to. BCA and
-- MCA are not formally engineering qualifications in the Indian system; the
-- category here is a browsing aid, not a claim about accreditation, and
-- splitting computing across two categories is what produced this problem.
--
-- THE ASSESSMENT IS UNAFFECTED, and that is checkable rather than hopeful.
-- AssessmentFlow's CATEGORY_TO_CLUSTER maps both `it-software` and
-- `engineering-technology` to the same cluster, `cluster-tech`, so moving the
-- weights cannot change which follow-up question a reader is asked. Verified
-- too that none of the seven options already carried an engineering-technology
-- weight, so every move is a clean update with nothing to merge -- had any
-- collided, summing or keeping the larger would have been a judgment about
-- scoring, not a mechanical repoint.

UPDATE degrees  SET category_slug = 'engineering-technology' WHERE category_slug = 'it-software';
UPDATE subjects SET category_slug = 'engineering-technology' WHERE category_slug = 'it-software';

UPDATE assessment_option_weights
SET category_slug = 'engineering-technology'
WHERE category_slug = 'it-software';

DELETE FROM categories WHERE slug = 'it-software';

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM categories WHERE slug = 'it-software';
    IF n <> 0 THEN RAISE EXCEPTION 'it-software category survived'; END IF;

    -- Nothing anywhere may still name it. Written per table rather than trusting
    -- the foreign keys, because a missed repoint on a nullable column would fail
    -- silently rather than blocking the delete.
    SELECT (SELECT count(*) FROM careers  WHERE category_slug = 'it-software')
         + (SELECT count(*) FROM degrees  WHERE category_slug = 'it-software')
         + (SELECT count(*) FROM exams    WHERE category_slug = 'it-software')
         + (SELECT count(*) FROM subjects WHERE category_slug = 'it-software')
         + (SELECT count(*) FROM assessment_option_weights WHERE category_slug = 'it-software')
      INTO n;
    IF n <> 0 THEN RAISE EXCEPTION '% row(s) still reference it-software', n; END IF;

    -- The degrees and subjects moved rather than vanished.
    SELECT count(*) INTO n FROM degrees WHERE slug IN ('bca', 'mca')
      AND category_slug = 'engineering-technology';
    IF n <> 2 THEN RAISE EXCEPTION 'bca/mca did not land in engineering-technology (found %)', n; END IF;

    SELECT count(*) INTO n FROM subjects
    WHERE slug IN ('computer-science', 'information-technology', 'data-science',
                   'artificial-intelligence', 'cybersecurity')
      AND category_slug = 'engineering-technology';
    IF n <> 5 THEN RAISE EXCEPTION '% of 5 computing subjects moved', n; END IF;

    -- No assessment option may have lost its scoring. An option with weights
    -- before must still have weights, or a question silently stops counting.
    SELECT count(*) INTO n FROM assessment_options o
    WHERE EXISTS (SELECT 1 FROM assessment_option_weights w WHERE w.option_id = o.id)
      AND NOT EXISTS (SELECT 1 FROM assessment_option_weights w
                      WHERE w.option_id = o.id
                        AND EXISTS (SELECT 1 FROM categories c WHERE c.slug = w.category_slug));
    IF n > 0 THEN
        RAISE EXCEPTION '% assessment option(s) have weights naming no existing category', n;
    END IF;

    -- Every degree_subjects pair must still resolve; the subjects moved, and a
    -- broken pair would take "B.Sc (Computer Science)" with it.
    SELECT count(*) INTO n FROM degree_subjects ds
    WHERE NOT EXISTS (SELECT 1 FROM subjects s WHERE s.slug = ds.subject_slug);
    IF n > 0 THEN RAISE EXCEPTION '% degree/subject pair(s) lost their subject', n; END IF;
END $$;
