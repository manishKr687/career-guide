-- Splits Science into PCM / PCB / PCMB.
--
-- V92 gave each stream its careers, and immediately exposed why four streams
-- are not enough: Science carries 29 of the 42 careers. A student who picks
-- it is shown 16 engineering careers and 4 medical ones together, when in
-- reality their 11th-grade subject choice decides which of those two sets is
-- open and closes the other almost completely.
--
--   PCM   Physics, Chemistry, Mathematics  -> engineering, architecture,
--                                             the maths-based sciences
--   PCB   Physics, Chemistry, Biology      -> medicine, nursing, pharmacy,
--                                             the life sciences
--   PCMB  all four                         -> both, at the cost of a heavier
--                                             workload
--
-- That fork is the single highest-stakes decision an Indian 10th-class
-- student makes, and until now the model could not express it: "Science" was
-- a leaf. Telling a PCB student they can pursue Mechanical Engineering is not
-- a cosmetic inaccuracy -- B.Tech admission requires Mathematics, so it is
-- simply wrong.
--
-- WHY A SEPARATE TABLE RATHER THAN MORE STREAM ROWS
--
-- PCM is not a sibling of Science, it is inside it. Adding PCM and PCB as
-- `streams` rows would flatten a real hierarchy and break the existing
-- question "which stream did you take?" -- user_profiles.stream_slug and
-- stage_streams both expect the four canonical answers. A child table keeps
-- Science/Commerce/Arts/Vocational intact and adds detail underneath.
--
-- Combinations are OPTIONAL per stream, and only Science gets them here.
-- Commerce could plausibly split into with-Maths / without-Maths (it matters
-- for B.Sc Statistics and some economics programmes), but that gate is soft --
-- most commerce degrees accept either -- and inventing a distinction the data
-- cannot yet justify is how the degrees table ended up with 90 unreferenced
-- rows. Arts and Vocational have no standard named combinations at all. A
-- stream with no combinations is a leaf, exactly as today.
--
-- THE CAREER SPLIT, AND THE ONE RULE BEHIND IT
--
-- Membership follows the 12th-subject requirement of the career's own entry
-- qualification, not a general sense of topic:
--
--   PCM (23)  all 16 engineering (B.Tech requires Mathematics) + Architecture
--             (B.Arch/NATA requires Mathematics) + Chemistry, Mathematics,
--             Physics, Statistics + Agriculture, Forestry (ICAR-AIEEA accepts
--             PCM or PCB)
--   PCB (10)  Medicine, Nursing, Pharmacy, Physiotherapy (all require
--             Biology) + Biology, Chemistry + Agriculture, Forestry
--             + Biotechnology (the B.Sc route, as opposed to B.Tech)
--             + Sports Science
--   PCMB      the union, by construction -- taking all four subjects opens
--             both sets, so it is derived rather than listed
--
-- Four careers sit in both: Chemistry, Agriculture, Forestry and
-- Biotechnology genuinely have two entry routes. 23 + 10 - 4 = 29, which is
-- every Science career, asserted below -- a career that fell into neither
-- would silently vanish for students who picked a combination.
--
-- Biomedical Engineering is PCM-only despite the medical subject matter: its
-- entry is B.Tech (V90), which needs Mathematics, not Biology. Sports Science
-- is PCB-only: B.Sc Sports Science normally requires Biology.
--
-- stream_combinations has a bare `slug` column, so the integrity function's
-- sort_order scan correctly skips it (that check targets join tables, which
-- have no `slug` of their own).

CREATE TABLE stream_combinations (
    slug        VARCHAR(64)  PRIMARY KEY,
    stream_slug VARCHAR(64)  NOT NULL REFERENCES streams (slug) ON DELETE CASCADE,
    name        VARCHAR(160) NOT NULL,
    short_name  VARCHAR(32)  NOT NULL,
    description TEXT         NOT NULL,
    sort_order  INTEGER      NOT NULL DEFAULT 0
);

CREATE INDEX idx_stream_combinations_stream ON stream_combinations (stream_slug);

CREATE TABLE combination_careers (
    combination_slug VARCHAR(64) NOT NULL REFERENCES stream_combinations (slug) ON DELETE CASCADE,
    career_slug      VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    PRIMARY KEY (combination_slug, career_slug)
);

CREATE INDEX idx_combination_careers_career ON combination_careers (career_slug);

INSERT INTO stream_combinations (slug, stream_slug, name, short_name, description, sort_order) VALUES
    ('pcm', 'science', 'Physics, Chemistry, Mathematics', 'PCM',
     'The engineering route. Opens B.Tech and B.Arch admission and the mathematics-based sciences. Does not qualify you for MBBS or other Biology-gated programmes.',
     0),
    ('pcb', 'science', 'Physics, Chemistry, Biology', 'PCB',
     'The medical and life-sciences route. Opens MBBS, BDS, nursing, pharmacy and physiotherapy. Does not qualify you for B.Tech, which requires Mathematics.',
     1),
    ('pcmb', 'science', 'Physics, Chemistry, Mathematics, Biology', 'PCMB',
     'All four subjects, keeping both the engineering and medical routes open. The heaviest workload of the three, usually chosen when the decision is genuinely undecided.',
     2);

-- PCM: Mathematics-gated entry routes.
INSERT INTO combination_careers (combination_slug, career_slug)
SELECT 'pcm', slug FROM careers WHERE category_slug = 'engineering-technology'
UNION
SELECT 'pcm', slug FROM careers WHERE slug IN (
    'architecture',
    'chemistry', 'mathematics', 'physics', 'statistics',
    'agriculture', 'forestry'
);

-- PCB: Biology-gated entry routes.
INSERT INTO combination_careers (combination_slug, career_slug)
SELECT 'pcb', slug FROM careers WHERE slug IN (
    'medicine', 'nursing', 'pharmacy', 'physiotherapy',
    'biology', 'chemistry',
    'agriculture', 'forestry',
    'biotechnology',
    'sports-science'
);

-- PCMB: the union, derived rather than listed -- taking all four subjects
-- cannot open fewer doors than taking three of them.
INSERT INTO combination_careers (combination_slug, career_slug)
SELECT DISTINCT 'pcmb', career_slug FROM combination_careers
WHERE combination_slug IN ('pcm', 'pcb');

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM combination_careers WHERE combination_slug = 'pcm';
    IF bad <> 23 THEN
        RAISE EXCEPTION 'expected 23 PCM careers, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM combination_careers WHERE combination_slug = 'pcb';
    IF bad <> 10 THEN
        RAISE EXCEPTION 'expected 10 PCB careers, found %', bad;
    END IF;

    -- The combinations must cover the Science stream exactly. A career in the
    -- stream but in no combination would disappear the moment a student picks
    -- one; a career in a combination but not the stream would appear from
    -- nowhere.
    SELECT count(*) INTO bad FROM stream_careers sc
    WHERE sc.stream_slug = 'science'
      AND NOT EXISTS (SELECT 1 FROM combination_careers cc
                      WHERE cc.career_slug = sc.career_slug AND cc.combination_slug = 'pcmb');
    IF bad > 0 THEN
        RAISE EXCEPTION '% science career(s) are in no combination', bad;
    END IF;

    SELECT count(*) INTO bad FROM combination_careers cc
    WHERE NOT EXISTS (SELECT 1 FROM stream_careers sc
                      WHERE sc.career_slug = cc.career_slug AND sc.stream_slug = 'science');
    IF bad > 0 THEN
        RAISE EXCEPTION '% combination career(s) are not in the science stream', bad;
    END IF;

    SELECT count(*) INTO bad FROM combination_careers WHERE combination_slug = 'pcmb';
    IF bad <> 29 THEN
        RAISE EXCEPTION 'expected PCMB to cover all 29 science careers, found %', bad;
    END IF;

    -- A combination leading nowhere would render as a dead card.
    SELECT count(*) INTO bad FROM stream_combinations sc
    WHERE NOT EXISTS (SELECT 1 FROM combination_careers cc WHERE cc.combination_slug = sc.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% combination(s) lead to no careers', bad;
    END IF;
END $$;
