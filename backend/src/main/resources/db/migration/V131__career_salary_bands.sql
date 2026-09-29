-- Fills career_salary_bands, which was empty for all 55 careers.
--
-- V110 created the table and shipped it empty, because per-level pay is a
-- statistical claim it would not invent. The career page has a salary section
-- that falls back to showing only the overall range when there are no bands, so
-- every career has been answering "what does this pay" with a single figure
-- spanning an entire working life -- 6.73L to 30L tells a school leaver almost
-- nothing about what they would earn in year one versus year twenty.
--
-- NO NEW RESEARCH AND NO SPLITTING OF RANGES. Every figure below is a pay-matrix
-- cell already sourced and recorded in the header of the migration that created
-- the career -- V118, V120, V121, V122, V123, V124. The overall range in
-- `careers` was derived from the floor of the entry post and the ceiling of the
-- top post; this records the posts in between, which is the information that was
-- thrown away when it was flattened to a single range.
--
-- Dividing a range into thirds and calling them Entry/Mid/Senior would have
-- filled all 55 careers in ten lines. It would also have been fabrication: the
-- boundaries would carry no meaning and the numbers would look researched.
--
-- ONLY THIRTEEN CAREERS GET BANDS, being the ones where a published pay matrix
-- names the posts. The other forty-two keep their overall range and no bands,
-- because for a private-sector field there is no official per-level scale to
-- read -- and the page already handles the absence.
--
-- max_lpa IS NULL WHERE THE CEILING WAS NOT PUBLISHED. The column is nullable for
-- exactly this: an Assistant Professor's Level 10 entry cell is published as
-- 57,700 without the level's top cell, so the band records the floor and leaves
-- the ceiling unstated rather than guessing one. SalaryRange's composeOpenEnded
-- already renders that as "from X".
--
-- All figures are BASIC PAY, monthly cell x 12, excluding DA, HRA and transport
-- -- the same method as the overall ranges, so a band and its career's range are
-- read off the same scale.

INSERT INTO career_salary_bands (career_slug, band, min_lpa, max_lpa, sort_order) VALUES
    -- Education: 7th CPC levels 6, 7, 8 and 12 (V118). Both bounds published.
    ('education', 'Trained Graduate Teacher (Level 7)', 5.39, 17.09, 0),
    ('education', 'Post Graduate Teacher (Level 8)', 5.71, 18.13, 1),
    ('education', 'Vice Principal / Principal (Level 12)', 9.46, 25.10, 2),

    ('elementary-education', 'Primary Teacher (Level 6)', 4.25, 13.49, 0),
    ('elementary-education', 'Headmaster (Level 8)', 5.71, 18.13, 1),

    ('physical-education', 'Trained Graduate Teacher (Level 7)', 5.39, 17.09, 0),
    ('physical-education', 'Post Graduate Teacher (Level 8)', 5.71, 18.13, 1),

    ('special-education', 'Trained Graduate Teacher (Level 7)', 5.39, 17.09, 0),
    ('special-education', 'Post Graduate Teacher (Level 8)', 5.71, 18.13, 1),

    -- Commerce: SSC CGL levels 5 and 8 (V120). Both bounds published.
    ('commerce', 'Auditor / Accountant (Level 5)', 3.50, 11.08, 0),
    ('commerce', 'Assistant Audit Officer (Level 8)', 5.71, 18.13, 1),

    -- Skilled trades: RRB Technician Level 2, then the supervisory grade reached
    -- by departmental examination (V124). `band` is varchar(48), too short to
    -- carry that condition in the label -- but V124 already states it in the
    -- career's highlights ("departmental exams lead to supervisory grades on
    -- Level 6"), which is where the reader meets it anyway.
    ('electrical-trades', 'Technician (Level 2)', 2.39, 7.58, 0),
    ('electrical-trades', 'Junior Engineer (Level 6)', 4.25, 13.49, 1),
    ('welding-and-fabrication', 'Technician (Level 2)', 2.39, 7.58, 0),
    ('welding-and-fabrication', 'Junior Engineer (Level 6)', 4.25, 13.49, 1),

    -- Academic ladder: UGC academic levels 10 and 14 (V122, V123). Level 10's
    -- ceiling is not published in the source, so max is left unstated.
    ('political-science', 'Assistant Professor (Academic Level 10)', 6.92, NULL, 0),
    ('political-science', 'Professor (Academic Level 14)', 17.30, 26.18, 1),
    ('defence-studies', 'Assistant Professor (Academic Level 10)', 6.92, NULL, 0),
    ('defence-studies', 'Professor (Academic Level 14)', 17.30, 26.18, 1),

    -- Civil services and defence: entry cell and the apex, which is a fixed
    -- figure rather than a band, so min and max are the same (V122, V123).
    ('public-administration', 'Junior Time Scale (Level 10)', 6.73, NULL, 0),
    ('public-administration', 'Cabinet Secretary (Level 18, fixed)', 30.00, 30.00, 1),
    ('defence-services', 'Lieutenant (Level 10)', 6.73, NULL, 0),
    ('defence-services', 'Apex (fixed)', 30.00, 30.00, 1),

    -- Economics: Indian Economic Service entry and Principal Adviser (V120).
    ('economics', 'Indian Economic Service, entry (Level 10)', 6.73, NULL, 0),
    ('economics', 'Principal Adviser', 21.86, NULL, 1),

    -- Banking: the 12th Bipartite Settlement publishes Scale I as a full scale
    -- and Scale VII only as its highest stage (V121).
    ('banking', 'Officer Scale I (Assistant Manager)', 5.82, 10.31, 0),
    ('banking', 'Scale VII (General Manager), highest stage', 22.56, 22.56, 1);

-- V124 capped the two trades careers at the top of Pay Level 2 (7.58L) and left
-- the supervisory grade out of the range, reasoning that quoting it "would
-- describe the best case as the expected one". Bands change that calculus: the
-- progression is now a labelled second step that a reader can see is conditional,
-- rather than an inflated headline figure. So the range is extended to cover what
-- the career reaches, and the band -- not the range -- carries the detail.
--
-- Without this the last assertion below fires, which is how the contradiction
-- was found: a band paying more than its career's stated maximum means the two
-- were written against different assumptions.
UPDATE careers SET
    salary_max_lpa = 13.49,
    salary_range = '₹2.39L – ₹13.49L / year'
WHERE slug IN ('electrical-trades', 'welding-and-fabrication');

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(DISTINCT career_slug) INTO n FROM career_salary_bands;
    IF n <> 13 THEN RAISE EXCEPTION 'expected bands for 13 careers, found %', n; END IF;

    -- Every band must belong to a career that exists.
    SELECT count(*) INTO n FROM career_salary_bands b
    WHERE NOT EXISTS (SELECT 1 FROM careers c WHERE c.slug = b.career_slug);
    IF n > 0 THEN RAISE EXCEPTION '% band(s) name a career that does not exist', n; END IF;

    -- Dense from 0 per career: uq_career_salary_bands_natural is on
    -- (career_slug, sort_order), and the entity maps this list positionally.
    SELECT count(*) INTO n FROM (
        SELECT career_slug FROM career_salary_bands
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1) x;
    IF n > 0 THEN RAISE EXCEPTION '% career(s) have a gapped band order', n; END IF;

    -- Bands must ascend. A later band paying less than an earlier one means the
    -- posts were listed out of order, which would read as a demotion.
    SELECT count(*), string_agg(DISTINCT career_slug, ', ') INTO n, bad FROM (
        SELECT career_slug, min_lpa,
               lag(min_lpa) OVER (PARTITION BY career_slug ORDER BY sort_order) AS prev
        FROM career_salary_bands) t
    WHERE prev IS NOT NULL AND min_lpa < prev;
    IF n > 0 THEN RAISE EXCEPTION '% band(s) pay less than the band below them: %', n, bad; END IF;

    -- No band may sit outside its career's own overall range, which would mean
    -- the two were read off different scales.
    SELECT count(*), string_agg(b.career_slug || '/' || b.band, ', ') INTO n, bad
    FROM career_salary_bands b JOIN careers c ON c.slug = b.career_slug
    WHERE c.salary_min_lpa IS NOT NULL
      AND (b.min_lpa < c.salary_min_lpa OR COALESCE(b.max_lpa, b.min_lpa) > c.salary_max_lpa);
    IF n > 0 THEN
        RAISE EXCEPTION '% band(s) fall outside their career''s overall range: %', n, bad;
    END IF;
END $$;
