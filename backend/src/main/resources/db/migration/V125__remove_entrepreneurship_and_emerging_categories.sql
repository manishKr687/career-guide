-- Removes the Entrepreneurship and Emerging Careers categories, the last two
-- that held no careers.
--
-- WHY THESE ARE NOT FILLED LIKE THE OTHER SIX. Every career row in this catalog
-- is a FIELD OF STUDY: it has degrees, an entrance route and a published pay
-- scale. Neither of these is one.
--
--   Entrepreneurship has no admission, no qualification and no employer, so no
--   pay scale exists anywhere to source a salary range from. Inventing one is the
--   single thing this catalog has consistently refused to do -- see V113's empty
--   NIRF columns, V120 leaving out Company Secretaryship, V121's note on
--   actuarial science. It belongs as a specialization under Management &
--   Business, or as a Founder job role, where no salary claim is required of it.
--
--   Emerging Careers is a label for a moving set rather than a discipline.
--   Whatever is genuinely emerging already lives under its parent field --
--   Artificial Intelligence & Machine Learning is a specialization of CSE/IT, and
--   that is where a student looking for it should land. A category defined as
--   "whatever is new this year" either sits empty or quietly rots, which is
--   precisely what happened to the Branch layer removed in V116.
--
-- An empty category is not merely unused furniture: the assessment scores toward
-- it, so it can be returned as a reader's leading field and then offer them
-- nothing. That was demonstrated before V124 -- a trades-leaning submission named
-- Skilled Trades first with zero careers behind it. After this migration no
-- category in the catalog is empty, so that failure mode is gone rather than
-- merely reduced.
--
-- NOTHING ELSE POINTS AT EITHER. Verified across every table with a
-- category_slug: 0 careers, 0 degrees, 0 exams, 0 subjects. Only assessment
-- weights, 4 and 5 respectively.
--
-- THE MERGE RULE, WHICH IS THE ONLY REAL DECISION HERE.
--
-- V119 moved it-software's seven weights with a plain UPDATE because none of them
-- collided. Here 5 of 9 do: options 13, 23, 29 and 35 already weight
-- engineering-technology, and option 22 already weights management-business. A
-- plain UPDATE would violate the primary key.
--
-- So: GREATEST(existing, incoming), not a sum. Every weight in this table is
-- either 1 or 2 -- there is no 3 anywhere, and the highest total any single option
-- carries is 3. Summing would produce weights of 3 on the colliding options,
-- making them pull harder toward their category than any option in the data,
-- which would change scoring rather than preserve it. Taking the larger stays
-- inside the established scale.
--
-- What that costs is one point of signal on each colliding option -- and it is
-- the right thing to lose, because those options ALREADY weight the target
-- category. A reader picking option 13 was being counted toward
-- engineering-technology once for the field and again for it being "emerging":
-- the same inclination, scored twice. Option 35 is the case where this matters
-- and works: emerging-careers weighted it 2 while engineering-technology
-- weighted it 1, so the merge raises it to 2 rather than discarding the stronger
-- signal.
--
-- Cluster behaviour is unchanged, which is checkable rather than hoped for.
-- AssessmentFlow's CATEGORY_TO_CLUSTER maps entrepreneurship and
-- management-business both to cluster-business, and emerging-careers and
-- engineering-technology both to cluster-tech, so no reader can be routed to a
-- different follow-up question. The two dead entries are removed from that map in
-- the same change.

-- 1. Raise the target where it already has a weight.
UPDATE assessment_option_weights t
SET weight = GREATEST(t.weight, s.weight)
FROM assessment_option_weights s
WHERE s.category_slug IN ('entrepreneurship', 'emerging-careers')
  AND s.option_id = t.option_id
  AND t.category_slug = CASE s.category_slug
                            WHEN 'entrepreneurship' THEN 'management-business'
                            ELSE 'engineering-technology' END;

-- 2. Carry across the ones with no target weight yet.
INSERT INTO assessment_option_weights (option_id, category_slug, weight)
SELECT s.option_id,
       CASE s.category_slug WHEN 'entrepreneurship' THEN 'management-business'
                            ELSE 'engineering-technology' END,
       s.weight
FROM assessment_option_weights s
WHERE s.category_slug IN ('entrepreneurship', 'emerging-careers')
ON CONFLICT (option_id, category_slug) DO NOTHING;

-- 3. Drop the old rows, then the categories.
DELETE FROM assessment_option_weights
WHERE category_slug IN ('entrepreneurship', 'emerging-careers');

DELETE FROM categories WHERE slug IN ('entrepreneurship', 'emerging-careers');

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM categories WHERE slug IN ('entrepreneurship', 'emerging-careers');
    IF n <> 0 THEN RAISE EXCEPTION '% of the two categories survived', n; END IF;

    -- Written per table rather than trusting the foreign keys, because a missed
    -- repoint on a nullable column would fail silently rather than block.
    SELECT (SELECT count(*) FROM careers  WHERE category_slug IN ('entrepreneurship', 'emerging-careers'))
         + (SELECT count(*) FROM degrees  WHERE category_slug IN ('entrepreneurship', 'emerging-careers'))
         + (SELECT count(*) FROM exams    WHERE category_slug IN ('entrepreneurship', 'emerging-careers'))
         + (SELECT count(*) FROM subjects WHERE category_slug IN ('entrepreneurship', 'emerging-careers'))
         + (SELECT count(*) FROM assessment_option_weights WHERE category_slug IN ('entrepreneurship', 'emerging-careers'))
      INTO n;
    IF n <> 0 THEN RAISE EXCEPTION '% row(s) still reference a removed category', n; END IF;

    -- No option may have lost its scoring entirely.
    SELECT count(*) INTO n FROM assessment_options o
    WHERE NOT EXISTS (SELECT 1 FROM assessment_option_weights w WHERE w.option_id = o.id);
    IF n > 0 THEN
        RAISE EXCEPTION '% assessment option(s) now carry no weights at all', n;
    END IF;

    -- Every remaining weight must name a category that exists.
    SELECT count(*) INTO n FROM assessment_option_weights w
    WHERE NOT EXISTS (SELECT 1 FROM categories c WHERE c.slug = w.category_slug);
    IF n > 0 THEN RAISE EXCEPTION '% weight(s) name a category that does not exist', n; END IF;

    -- The merge must not have invented a weight outside the scale the rest of the
    -- table uses. If this fires, a sum crept in where GREATEST was intended.
    SELECT count(*) INTO n FROM assessment_option_weights WHERE weight NOT IN (1, 2);
    IF n > 0 THEN
        RAISE EXCEPTION '% weight(s) fall outside the 1-2 scale every other weight uses', n;
    END IF;

    -- THE POINT OF THE WHOLE EXERCISE: the assessment may no longer name a field
    -- it has nothing to show for. This is the assertion that keeps it true.
    SELECT count(*) INTO n FROM (
        SELECT DISTINCT w.category_slug FROM assessment_option_weights w
        WHERE NOT EXISTS (SELECT 1 FROM careers c WHERE c.category_slug = w.category_slug)) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% category/categories can still be recommended with no careers behind them', n;
    END IF;

    -- And no category anywhere is empty.
    SELECT count(*) INTO n FROM categories cat
    WHERE NOT EXISTS (SELECT 1 FROM careers c WHERE c.category_slug = cat.slug);
    IF n > 0 THEN RAISE EXCEPTION '% category/categories hold no careers', n; END IF;
END $$;
