-- Fills exam mode and minimum eligibility for the exams where both could be
-- sourced. Both columns were null for all 31.
--
-- "Can I even sit this?" is the first question a student asks about an exam, and
-- the exam page had no answer to it. Mode matters nearly as much: whether a paper
-- is taken on a computer or on paper changes how you prepare for it.
--
-- ELEVEN OF THIRTY-ONE. Everything below was read from a search of current
-- sources on 2026-09-29; the other twenty are left null rather than filled from
-- memory or by inference from the exam's level. A plausible-sounding eligibility
-- line is worse than a blank one here -- a student who is told they qualify and
-- does not will find out after paying the fee.
--
-- The ones left empty, and why: the recruitment exams (IBPS PO, IBPS SO, SEBI
-- Grade A, RRB JE, ISRO ICRB) publish eligibility per notification and it shifts
-- between cycles; the design and specialist entrances (BITSAT, UCEED, NID DAT,
-- NCHM JEE, IMU-CET, ICAR) and the professional ones (CA Foundation, CSEET, PMP)
-- were not covered by the searches run. None is hard to add later -- this
-- migration is a first pass, not a closed set.
--
-- SYLLABUS_OVERVIEW IS LEFT ENTIRELY NULL. A syllabus is several hundred words
-- per exam and summarising one into a sentence from a search result is where
-- invention would creep in fastest. It needs its own pass against each exam's
-- official information bulletin.
--
-- SOURCES, retrieved 2026-09-29:
--   JEE Main, NEET UG, CUET   https://www.pw.live/iit-jee/exams/jee-2026-exam-mode-change
--                             https://www.shiksha.com/medicine-health-sciences/articles/neet-eligibility-criteria-blogId-22479
--                             https://www.pw.live/cuet/exams/cuet-cbt-exam-mode
--   GATE                      https://gate2026.iitg.ac.in/eligibility-criteria.html
--   CAT                       https://collegedunia.com/exams/cat/eligibility
--   CLAT                      https://grad.hitbullseye.com/info-zone/clat-2026.php
--   UPSC CSE, NDA, CDS        https://www.pw.live/defence/exams/cds-eligibility
--   UGC-NET, CSIR-NET         https://ugcnetonline.in/eligibility.php
--                             https://www.pw.live/csir-net/exams/csir-net-eligibility
--
-- NEET UG's mode records a transition rather than a state: it is pen-and-paper
-- for 2026 and moves to computer-based from 2027. Recording only one of those
-- would be out of date within a year in one direction or the other.

UPDATE exams SET mode = v.mode, eligibility_min_qualification = v.eligibility
FROM (VALUES
    ('jee-main', 'Computer-based (CBT)',
     'Passed Class 12 (or appearing) with at least five subjects including Physics, Chemistry and Mathematics. No minimum percentage to sit the exam, but NITs, IIITs and CFTIs require 75% in Class 12 (65% for SC/ST) or a top-20-percentile board rank.'),

    ('neet-ug', 'Pen and paper (CBT from 2027)',
     'Passed Class 12 (or appearing) with Physics, Chemistry and Biology. Minimum age 17 years.'),

    ('cuet', 'Computer-based (CBT)',
     'Passed Class 12 (or appearing) from a recognised board. NTA sets no minimum percentage; individual universities set their own.'),

    ('gate', 'Computer-based (CBT)',
     'Currently in the third or a later year of any undergraduate degree, or already holding a government-approved degree in Engineering, Technology, Architecture, Science, Commerce, Arts or Humanities. No age limit and no cap on attempts.'),

    ('cat', 'Computer-based (CBT)',
     'Bachelor''s degree with at least 50% aggregate (45% for SC, ST and PwD), or in the final year of one. No age limit and no cap on attempts.'),

    ('clat', 'Pen and paper',
     'Passed 10+2 in any stream with at least 45% marks (40% for SC/ST) for the undergraduate programme.'),

    ('upsc-cse', 'Pen and paper',
     'A degree from a recognised university. Final-year candidates may sit the preliminary examination.'),

    ('cds-exam', 'Pen and paper',
     'A degree from a recognised university, and unmarried. Age 19-24 for IMA and INA, 19-25 for OTA.'),

    ('nda-exam', 'Pen and paper',
     'Passed 10+2 (or appearing in the final year), and unmarried. Physics and Mathematics are required for the Air Force and Navy wings.'),

    ('ugc-net', 'Computer-based (CBT)',
     'A master''s degree or equivalent with at least 55% marks (50% for OBC-NCL, SC, ST, PwD and third gender). Candidates in the final year may apply.'),

    ('csir-net', 'Computer-based (CBT)',
     'A master''s degree or equivalent in a science subject with at least 55% marks (50% for OBC-NCL, SC, ST, PwD and third gender).')
) AS v(slug, mode, eligibility)
WHERE exams.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM exams WHERE mode IS NOT NULL;
    IF n <> 11 THEN RAISE EXCEPTION 'expected 11 exams with a mode, found % -- a slug did not match', n; END IF;

    -- The two fields are filled together here, so a row with one and not the
    -- other means a VALUES row was malformed.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM exams
    WHERE (mode IS NULL) <> (eligibility_min_qualification IS NULL);
    IF n > 0 THEN
        RAISE EXCEPTION '% exam(s) have a mode without eligibility or the reverse: %', n, bad;
    END IF;

    -- Mode is a short controlled phrase, not free prose. If a future edit puts a
    -- sentence here the exam page's mode chip will overflow.
    SELECT count(*), string_agg(DISTINCT mode, ' | ') INTO n, bad
    FROM exams
    WHERE mode IS NOT NULL
      AND mode NOT IN ('Computer-based (CBT)', 'Pen and paper', 'Pen and paper (CBT from 2027)');
    IF n > 0 THEN RAISE EXCEPTION '% exam(s) use an unexpected mode value: %', n, bad; END IF;

    -- Eligibility must actually say something; a stub would read as answered.
    SELECT count(*) INTO n FROM exams
    WHERE eligibility_min_qualification IS NOT NULL
      AND length(btrim(eligibility_min_qualification)) < 40;
    IF n > 0 THEN RAISE EXCEPTION '% eligibility line(s) are too short to be useful', n; END IF;
END $$;
