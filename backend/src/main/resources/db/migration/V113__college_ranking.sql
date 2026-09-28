-- Gives colleges a place to record an NIRF ranking.
--
-- The listing wants a rank badge, a "Top Colleges" rail and a rank filter, and
-- nothing in `colleges` could support any of them.
--
-- SHIPS EMPTY. Same call as V110's salary bands and V112's exam dates, for the
-- same reason: this is a published figure I would be recalling rather than
-- reading. NIRF publishes a dozen separate league tables each year -- Overall,
-- Engineering, Medical, Management, Law, University -- and a college's rank
-- differs between them. IIT Madras is 1st in both Overall and Engineering
-- 2024, but IISc is 2nd Overall and not in the Engineering table at all.
-- Writing "#2" against IISc without saying which table is worse than writing
-- nothing, and writing 90 ranks from memory would put unverified numbers in
-- front of students on a page whose whole job is helping them choose.
--
-- So the columns, the admin fields and the UI all ship; the numbers come from
-- the official tables. Every part of the page that depends on a rank is
-- conditional, so the page is complete without them and gains three features
-- the moment they are entered.
--
-- `category` is NOT optional alongside the rank, which is the point: a rank
-- without its table is ambiguous, and the CHECK below refuses the pair.
--
-- NOT ADDED: average fees and placement rate, which the mock also shows per
-- college. Both vary by PROGRAMME, not by institution -- IIT Delhi's B.Tech
-- fee and its M.Tech fee are different numbers, and a placement rate is per
-- branch per year. Hanging a single value off the college would average away
-- the thing a student is actually asking about. They belong on
-- college_degrees, which already exists as the college-programme row, if and
-- when there is a source for them.

ALTER TABLE colleges
    ADD COLUMN nirf_rank integer,
    ADD COLUMN nirf_category varchar(32),
    ADD COLUMN nirf_year smallint;

ALTER TABLE colleges ADD CONSTRAINT colleges_nirf_complete CHECK (
    (nirf_rank IS NULL AND nirf_category IS NULL AND nirf_year IS NULL)
    OR (nirf_rank > 0 AND nirf_category IS NOT NULL AND nirf_year IS NOT NULL)
);

ALTER TABLE colleges ADD CONSTRAINT colleges_nirf_category_known CHECK (
    nirf_category IS NULL OR nirf_category IN (
        'Overall', 'Engineering', 'Medical', 'Management', 'Law',
        'University', 'Pharmacy', 'Architecture', 'Dental', 'Research'
    )
);

ALTER TABLE colleges ADD CONSTRAINT colleges_nirf_year_sane CHECK (
    nirf_year IS NULL OR (nirf_year >= 2016 AND nirf_year <= 2100)
);

-- One rank per college per table would need a separate table; a college
-- appearing in both Overall and Engineering can only record one here. That is
-- deliberate for now -- the page shows a single badge -- and the unique index
-- below at least stops two rows claiming the same rank in the same table.
CREATE UNIQUE INDEX uq_colleges_nirf_rank
    ON colleges (nirf_category, nirf_year, nirf_rank)
    WHERE nirf_rank IS NOT NULL;

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM colleges WHERE nirf_rank IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'colleges NIRF ranking should ship empty, found % ranked row(s)', bad;
    END IF;

    SELECT count(*) INTO bad FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'colleges'
      AND column_name IN ('nirf_rank', 'nirf_category', 'nirf_year');
    IF bad <> 3 THEN
        RAISE EXCEPTION 'expected 3 new ranking columns, found %', bad;
    END IF;
END $$;
