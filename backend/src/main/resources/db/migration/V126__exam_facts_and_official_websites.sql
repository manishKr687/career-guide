-- Corrects the exam catalog against official sources, and fills in
-- official_website, which was empty for all 31 rows.
--
-- The column has existed since the exam detail page was built and nothing was
-- ever put in it, so every exam page has been telling a reader about an exam
-- without telling them where to actually apply for it. That is the single most
-- useful fact an exam page can carry and it was the one thing missing.
--
-- THREE EXAMS WERE MATERIALLY OUT OF DATE. This is the part that matters more
-- than the URLs: a student can lose a year preparing for an exam that no longer
-- runs, and all three were presented as live and annual.
--
--   ntse           Stalled since 2021 and never resumed. NCERT's own notice
--                  says the scheme "was approved till March 31, 2021" and that
--                  further implementation "has been stalled till further
--                  orders". The 2020-21 cycle was the last one completed. It is
--                  kept rather than deleted -- the record is still what a reader
--                  searching for NTSE needs to find -- but it now says so.
--                  https://www.thefela.org/news/details/ncert-stalls-ntse-scheme-till-further-orders
--
--   icar-aieea     The undergraduate exam was discontinued after 2022.
--                  Agriculture UG admission now runs through CUET (ICAR-UG),
--                  conducted by NTA; AIEEA continues for postgraduate entry
--                  only. The row described the UG exam, so it is re-pointed to
--                  what AIEEA actually is now, and its level moves from
--                  Undergraduate to Postgraduate.
--                  https://news.careers360.com/no-aieea-ug-this-year-agriculture-courses-admissions-through-cuet-decides-icar
--
--   cs-foundation  Discontinued on 3 February 2020 and replaced by CSEET, the
--                  CS Executive Entrance Test, under the Company Secretaries
--                  (Amendment) Regulations 2020. Registration to the Foundation
--                  Programme ceased entirely. CSEET runs four times a year --
--                  January, May, July and November -- not twice.
--                  https://www.shiksha.com/accounting-commerce/articles/cs-foundation-programme-replaced-with-cseet-blogId-30291
--
-- THE SLUG STAYS `cs-foundation` even though the exam is now CSEET, for the
-- reason V119 kept `computer-science-and-engineering` when that career became
-- CSE/IT: there is no redirect layer in this application, so renaming the slug
-- 404s every existing link for a cosmetic gain. The name, full name and
-- description all say CSEET; only the URL remembers the old exam.
--
-- neet-pg's conducting body is corrected to the National Board of Examinations
-- in Medical Sciences (NBEMS), which is the body's name and how it identifies
-- itself at natboard.edu.in.
--
-- HOW THE WEBSITES WERE ESTABLISHED. Each URL was fetched and its page title
-- checked, rather than written from memory: jeeadv.ac.in returns "JEE (Advanced)
-- 2026", iimcat.ac.in returns "CAT 2026", uceed.iitb.ac.in returns "UCEED 2026",
-- and so on. Two official sites block automated requests but identify themselves
-- in the error page (natboard.edu.in as NBEMS, pmi.org as PMI), which is enough.
-- Four were confirmed by search where this network could not reach them
-- (cuet.nta.nic.in, ctet.nic.in, exams.nta.nic.in/nchm-jee, ncert.nic.in).
--
-- FOUR EXAMS ARE LEFT WITHOUT A WEBSITE, deliberately:
--
--   gate                    The organising IIT rotates every year, so any URL
--                           recorded here is wrong within twelve months. A stale
--                           official link is worse than none.
--   polytechnic-cet         Conducted separately by each state's technical
--   judicial-services-exam  education board / public service commission. There
--                           is no single official site to point at, and picking
--                           one state's would mislead every other state's
--                           readers.
--   rrb-je                  Has one: the central application portal. Included.
--
-- Retrieved 2026-09-29.

UPDATE exams SET official_website = v.url FROM (VALUES
    ('jee-main',       'https://jeemain.nta.nic.in'),
    ('jee-advanced',   'https://jeeadv.ac.in'),
    ('neet-ug',        'https://neet.nta.nic.in'),
    ('neet-pg',        'https://natboard.edu.in'),
    ('cuet',           'https://cuet.nta.nic.in'),
    ('ugc-net',        'https://ugcnet.nta.nic.in'),
    ('csir-net',       'https://csirnet.nta.nic.in'),
    ('ctet',           'https://ctet.nic.in'),
    ('bitsat',         'https://www.bitsadmission.com'),
    ('clat',           'https://consortiumofnlus.ac.in'),
    ('cat',            'https://iimcat.ac.in'),
    ('upsc-cse',       'https://upsc.gov.in'),
    ('nda-exam',       'https://upsc.gov.in'),
    ('cds-exam',       'https://upsc.gov.in'),
    ('ibps-po',        'https://www.ibps.in'),
    ('ibps-so-it',     'https://www.ibps.in'),
    ('ca-foundation',  'https://www.icai.org'),
    ('cs-foundation',  'https://www.icsi.edu'),
    ('pmp',            'https://www.pmi.org'),
    ('uceed',          'https://www.uceed.iitb.ac.in'),
    ('sebi-grade-a',   'https://www.sebi.gov.in'),
    ('imu-cet',        'https://www.imu.edu.in'),
    ('nid-dat',        'https://admissions.nid.edu'),
    ('icar-aieea',     'https://icar.org.in'),
    ('nchmct-jee',     'https://exams.nta.nic.in/nchm-jee/'),
    ('isro-icrb',      'https://www.isro.gov.in'),
    ('rrb-je',         'https://www.rrbapply.gov.in'),
    ('ntse',           'https://ncert.nic.in')
) AS v(slug, url)
WHERE exams.slug = v.slug;

-- NTSE: suspended, not running.
UPDATE exams SET
    frequency = 'Suspended since 2021',
    description = 'A two-stage scholarship exam for Class 10 students that awarded a scholarship '
        || 'continuing through higher education. NOT CURRENTLY RUNNING: the National Talent Search '
        || 'Scheme was approved only to 31 March 2021 and NCERT stalled it pending renewal, so the '
        || '2020-21 cycle was the last one completed. The Ministry of Education has discussed '
        || 'relaunching it in a revised form, but no exam has been held since. Check NCERT before '
        || 'planning around it.'
WHERE slug = 'ntse';

-- ICAR AIEEA: UG went to CUET; AIEEA is a postgraduate exam now.
UPDATE exams SET
    name = 'ICAR AIEEA (PG)',
    full_name = 'ICAR All India Entrance Examination for Admission (Postgraduate)',
    level = 'Postgraduate',
    conducted_by = 'National Testing Agency (NTA) for ICAR',
    description = 'Entrance exam for postgraduate programmes at ICAR-recognised agricultural '
        || 'universities. The undergraduate AIEEA was discontinued after 2022 -- admission to B.Sc '
        || '(Hons) Agriculture and allied undergraduate programmes now runs through CUET (ICAR-UG), '
        || 'so school leavers should sit CUET rather than this.'
WHERE slug = 'icar-aieea';

-- CS Foundation: replaced by CSEET in 2020.
UPDATE exams SET
    name = 'CSEET',
    full_name = 'CS Executive Entrance Test',
    frequency = 'Four times a year (January, May, July, November)',
    -- 'Quarterly' rather than a new value: exams_frequency_type_known is a CHECK
    -- over a fixed vocabulary, and four sittings a year is what Quarterly means.
    frequency_type = 'Quarterly',
    description = 'The qualifying test for entry to the Company Secretary Executive Programme. It '
        || 'replaced the CS Foundation Programme on 3 February 2020 under the Company Secretaries '
        || '(Amendment) Regulations, after which registration to the Foundation Programme ceased. '
        || 'The URL still says cs-foundation because this catalog does not rename slugs; the exam is '
        || 'CSEET.'
WHERE slug = 'cs-foundation';

UPDATE exams SET conducted_by = 'National Board of Examinations in Medical Sciences (NBEMS)'
WHERE slug = 'neet-pg';

DO $$
DECLARE n int; missing text;
BEGIN
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, missing
    FROM exams WHERE official_website IS NULL OR official_website = '';
    -- Exactly the three with no single official site, plus GATE's rotating host.
    IF n <> 3 THEN
        RAISE EXCEPTION 'expected 3 exams without a website (gate, polytechnic-cet, judicial-services-exam), found %: %', n, missing;
    END IF;
    IF EXISTS (SELECT 1 FROM exams WHERE slug IN ('gate', 'polytechnic-cet', 'judicial-services-exam')
               AND official_website IS NOT NULL AND official_website <> '') THEN
        RAISE EXCEPTION 'one of the deliberately-empty exams was given a website';
    END IF;

    -- Every URL must be https and have no trailing whitespace; the exam page
    -- renders these as links and a malformed one is a dead link on a live page.
    SELECT count(*) INTO n FROM exams
    WHERE official_website IS NOT NULL
      AND (official_website NOT LIKE 'https://%' OR official_website <> btrim(official_website));
    IF n > 0 THEN
        RAISE EXCEPTION '% official_website value(s) are not clean https URLs', n;
    END IF;

    -- The three corrected exams must no longer describe themselves as current.
    SELECT count(*) INTO n FROM exams
    WHERE slug = 'ntse' AND description NOT LIKE '%NOT CURRENTLY RUNNING%';
    IF n > 0 THEN RAISE EXCEPTION 'ntse must state that it is not running'; END IF;

    SELECT count(*) INTO n FROM exams WHERE slug = 'icar-aieea' AND level <> 'Postgraduate';
    IF n > 0 THEN RAISE EXCEPTION 'icar-aieea must be postgraduate now'; END IF;

    SELECT count(*) INTO n FROM exams WHERE slug = 'cs-foundation' AND name <> 'CSEET';
    IF n > 0 THEN RAISE EXCEPTION 'cs-foundation must be renamed CSEET'; END IF;
END $$;
