-- Fills NIRF ranks, which were empty for all 90 colleges.
--
-- V113 added nirf_rank, nirf_category and nirf_year with a CHECK that all three
-- are set together, and then deliberately shipped no data: the rank is a
-- statistical claim and the migration would not invent one. That was right, and
-- the consequence has been that the rank badge, the ranking filter and the Top
-- Ranked rail have all been dead since -- the college pages have been the least
-- informative in the catalog, because rank is the first thing anyone asks about
-- a college.
--
-- SOURCE. India Rankings 2025, published by the National Institutional Ranking
-- Framework, Ministry of Education. This is the government's own ranking, freely
-- published, and the only one with any official standing in India -- which is
-- exactly why the column is worth filling from it and was not worth filling from
-- a magazine list.
--
--   Engineering  https://www.nirfindia.org/Rankings/2025/EngineeringRanking.html
--   Medical      https://www.nirfindia.org/Rankings/2025/MedicalRanking.html
--   University   https://www.nirfindia.org/Rankings/2025/UniversityRanking.html
--   Management   https://www.nirfindia.org/Rankings/2025/ManagementRanking.html
--   Law          https://www.nirfindia.org/Rankings/2025/LawRanking.html
--
-- Retrieved 2026-09-29. Every rank below was read off those pages; none is from
-- memory. A first extraction of the engineering table silently dropped nine NITs
-- whose official names begin with a founder rather than with "National Institute
-- of Technology" -- Malaviya, Visvesvaraya, Motilal Nehru, Maulana Azad, Sardar
-- Vallabhbhai, Dr B R Ambedkar -- so the full table was re-read and matched by
-- hand.
--
-- WHICH RANKING EACH COLLEGE GETS. NIRF publishes a separate table per
-- discipline and an institution can appear in several, so the category is chosen
-- by what the catalog row actually IS, not by its `type`:
--
--   * A medical college gets its Medical rank even where the catalog types it
--     University -- Amrita Institute of Medical Sciences, Saveetha Medical
--     College, KIMS Bhubaneswar and others are typed University but are medical
--     colleges, and a reader looking at them wants the medical ranking.
--   * A university gets its University rank even where it also appears in the
--     Medical table. BHU is 6th in Medical and 6th in University; the row is the
--     university, so University is the honest label.
--
-- WHERE NIRF RANKS THE PARENT AND THE CATALOG HOLDS A CONSTITUENT COLLEGE, the
-- parent's rank is used: NIRF ranks "Datta Meghe Institute of Higher Education
-- and Research" where this catalog holds its constituent Jawaharlal Nehru
-- Medical College, Wardha. This is the convention every ranking site uses and it
-- is what a reader means by "where does this college rank", but it is an
-- inference rather than a direct reading, so it is recorded here.
--
-- FIFTEEN COLLEGES GET NO RANK, and that is a finding rather than a gap:
--   * IIT Goa and nine NITs (Agartala, Andhra Pradesh, Arunachal Pradesh, Goa,
--     Manipur, Mizoram, Nagaland, Sikkim, Uttarakhand) are outside the
--     Engineering top 100. They sit in the 101+ bands, which NIRF publishes as
--     ranges rather than positions -- "rank 101-150" is not a rank and this
--     column stores an integer, so recording one would mean inventing a
--     precision NIRF does not claim.
--   * Indian Maritime University, IHM Pusa and NID Ahmedabad have no table they
--     belong to among those fetched.
--   * The ITI and the polytechnic have no NIRF category at all; NIRF does not
--     rank them.

UPDATE colleges SET nirf_rank = v.rank, nirf_category = v.cat, nirf_year = 2025
FROM (VALUES
    -- Engineering
    ('iit-madras', 1, 'Engineering'),        ('iit-delhi', 2, 'Engineering'),
    ('iit-bombay', 3, 'Engineering'),        ('iit-kanpur', 4, 'Engineering'),
    ('iit-kharagpur', 5, 'Engineering'),     ('iit-roorkee', 6, 'Engineering'),
    ('iit-hyderabad', 7, 'Engineering'),     ('iit-guwahati', 8, 'Engineering'),
    ('nit-trichy', 9, 'Engineering'),        ('iit-bhu-varanasi', 10, 'Engineering'),
    ('iit-indore', 12, 'Engineering'),       ('nit-rourkela', 13, 'Engineering'),
    ('iit-ism-dhanbad', 15, 'Engineering'),  ('nit-surathkal', 17, 'Engineering'),
    ('iit-patna', 19, 'Engineering'),        ('nit-calicut', 21, 'Engineering'),
    ('iit-gandhinagar', 25, 'Engineering'),  ('iit-mandi', 26, 'Engineering'),
    ('iit-jodhpur', 27, 'Engineering'),      ('nit-warangal', 28, 'Engineering'),
    ('iit-ropar', 32, 'Engineering'),        ('iit-bhubaneswar', 39, 'Engineering'),
    ('nit-jaipur', 42, 'Engineering'),       ('nit-nagpur', 44, 'Engineering'),
    ('nit-durgapur', 49, 'Engineering'),     ('nit-silchar', 50, 'Engineering'),
    ('nit-patna', 53, 'Engineering'),        ('nit-jalandhar', 55, 'Engineering'),
    ('iit-jammu', 56, 'Engineering'),        ('iit-tirupati', 57, 'Engineering'),
    ('nit-allahabad', 62, 'Engineering'),    ('iit-palakkad', 64, 'Engineering'),
    ('nit-delhi', 65, 'Engineering'),        ('nit-surat', 66, 'Engineering'),
    ('iit-bhilai', 72, 'Engineering'),       ('nit-srinagar', 73, 'Engineering'),
    ('iit-dharwad', 77, 'Engineering'),      ('nit-bhopal', 81, 'Engineering'),
    ('nit-jamshedpur', 82, 'Engineering'),   ('nit-meghalaya', 83, 'Engineering'),
    ('nit-kurukshetra', 85, 'Engineering'),  ('nit-raipur', 86, 'Engineering'),
    ('nit-hamirpur', 97, 'Engineering'),     ('nit-puducherry', 99, 'Engineering'),

    -- Medical
    ('aiims-delhi', 1, 'Medical'),                 ('cmc-vellore', 3, 'Medical'),
    ('jipmer-puducherry', 4, 'Medical'),           ('nimhans-bangalore', 7, 'Medical'),
    ('kgmu-lucknow', 8, 'Medical'),                ('amrita-kochi', 9, 'Medical'),
    ('kmc-manipal', 10, 'Medical'),                ('saveetha-chennai', 11, 'Medical'),
    ('dy-patil-pune', 12, 'Medical'),              ('aiims-rishikesh', 13, 'Medical'),
    ('aiims-bhubaneswar', 14, 'Medical'),          ('madras-medical-college', 16, 'Medical'),
    ('srm-medical-college', 18, 'Medical'),        ('aiims-jodhpur', 19, 'Medical'),
    ('datta-meghe-wardha', 20, 'Medical'),         ('sri-ramachandra-chennai', 21, 'Medical'),
    ('vmmc-safdarjung-delhi', 22, 'Medical'),      ('ipgmer-kolkata', 23, 'Medical'),
    ('kims-bhubaneswar', 24, 'Medical'),           ('aiims-bhopal', 25, 'Medical'),
    ('maulana-azad-medical-college', 26, 'Medical'), ('aiims-patna', 27, 'Medical'),
    ('st-johns-bengaluru', 30, 'Medical'),

    -- University
    ('du-delhi', 5, 'University'),          ('bhu-varanasi', 6, 'University'),
    ('amu-aligarh', 10, 'University'),      ('soa-bhubaneswar', 15, 'University'),

    -- Management
    ('iim-ahmedabad', 1, 'Management'),     ('iim-bangalore', 2, 'Management'),

    -- Law
    ('nlsiu-bangalore', 1, 'Law'),          ('nalsar-hyderabad', 3, 'Law')
) AS v(slug, rank, cat)
WHERE colleges.slug = v.slug;

DO $$
DECLARE n int; leftover text;
BEGIN
    SELECT count(*) INTO n FROM colleges WHERE nirf_rank IS NOT NULL;
    IF n <> 75 THEN
        RAISE EXCEPTION 'expected 75 ranked colleges, found % -- a slug in the list above did not match', n;
    END IF;

    -- Every VALUES row must have found a college. A typo would otherwise update
    -- nothing and pass unnoticed, which is how a rank goes missing quietly.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, leftover
    FROM colleges
    WHERE nirf_rank IS NULL
      AND slug NOT IN ('iit-goa', 'nit-agartala', 'nit-andhra-pradesh', 'nit-arunachal-pradesh',
                       'nit-goa', 'nit-manipur', 'nit-mizoram', 'nit-nagaland', 'nit-sikkim',
                       'nit-uttarakhand', 'imu-chennai', 'nchm-pusa', 'nid-ahmedabad',
                       'iti-mumbai', 'govt-polytechnic-mumbai');
    IF n > 0 THEN
        RAISE EXCEPTION '% college(s) unexpectedly have no rank: %', n, leftover;
    END IF;

    -- No two colleges may hold the same position in the same table. A duplicate
    -- means a row was matched to the wrong institute.
    SELECT count(*) INTO n FROM (
        SELECT nirf_category, nirf_rank FROM colleges
        WHERE nirf_rank IS NOT NULL
        GROUP BY nirf_category, nirf_rank HAVING count(*) > 1) x;
    IF n > 0 THEN
        RAISE EXCEPTION '% duplicate (category, rank) pair(s) -- two colleges cannot share a position', n;
    END IF;

    -- The CHECK enforces all-three-or-none, but not that the year is the one
    -- this migration sourced.
    SELECT count(*) INTO n FROM colleges WHERE nirf_rank IS NOT NULL AND nirf_year <> 2025;
    IF n > 0 THEN RAISE EXCEPTION '% rank(s) are not from the 2025 tables', n; END IF;
END $$;
