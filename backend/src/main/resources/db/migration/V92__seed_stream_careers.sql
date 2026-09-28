-- Seeds stream_careers: which careers each 11th/12th stream leads into.
--
-- The table has existed since V29 and has never held a single row. It is not
-- even mapped in Java -- Stream has `stages` but no `careers` field -- so
-- nothing could read it even if it were populated. V91 put the stream cards
-- on the After-10th page where they belong; this gives them somewhere to go.
--
-- SEMANTICS: "primary route", not "everything technically permitted".
--
-- This distinction decides the whole table. A Science student can legally sit
-- CLAT, apply to NID and take a BBA -- so a strict "what is this student
-- allowed to do" reading puts all 42 careers under Science and the filter
-- tells nobody anything. What a 10th-class student actually needs to know is
-- which doors each stream is the normal way through. So:
--
--   * the three academic streams partition all 42 careers exactly once
--   * a career appears under the stream that is its standard entry route
--   * vocational deliberately overlaps -- a diploma is an ALTERNATIVE route
--     into careers the academic streams also reach, not a separate set
--
-- The partition is asserted at the bottom. If a future career is added and
-- assigned to two academic streams or none, the migration's own check would
-- have caught it; the same check belongs in the integrity function later.
--
-- SCIENCE (29) is the only stream with hard subject gates behind it, and they
-- are real: B.Tech and B.Arch need Mathematics, MBBS and B.Sc Nursing need
-- Biology, ICAR-AIEEA accepts PCB or PCM. Those gates are why Science carries
-- two-thirds of the catalog and why splitting it into PCM/PCB later is worth
-- doing -- a PCB student cannot enter any of the 16 engineering careers, and
-- this table cannot yet say so.
--
-- COMMERCE (7) and ARTS (6) are editorial judgement, not derived from data --
-- there is nothing in the schema that records "BBA accepts any stream". They
-- follow the standard Indian mapping: accountancy/business/finance to
-- Commerce; psychology, sociology, public administration, law, journalism and
-- design to Arts. Law and design are the two most arguable -- CLAT and NID
-- DAT are genuinely stream-agnostic -- but Arts is where the humanities
-- preparation for them sits.
--
-- VOCATIONAL (12) is NOT hand-written: it is selected from careers that have
-- a Diploma-level qualification in career_degrees. That keeps it honest and
-- self-maintaining -- add a diploma route to a career and it belongs here by
-- construction, not by someone remembering to edit a list.
--
-- Plain (stream_slug, career_slug) with no sort_order: stream_careers has no
-- such column, and Stream.careers will be a Set ordered by title, same
-- reasoning as Stream.stages (V29's comment).

-- ------------------------------------------------------------------ science
INSERT INTO stream_careers (stream_slug, career_slug)
SELECT 'science', slug FROM careers
WHERE category_slug IN ('engineering-technology', 'science-research',
                        'medical-healthcare', 'agriculture')
   OR slug IN ('architecture', 'sports-science')
ON CONFLICT DO NOTHING;

-- ----------------------------------------------------------------- commerce
INSERT INTO stream_careers (stream_slug, career_slug) VALUES
    ('commerce', 'accounting'),
    ('commerce', 'business-administration'),
    ('commerce', 'finance'),
    ('commerce', 'human-resource-management'),
    ('commerce', 'marketing'),
    ('commerce', 'hospitality-management'),
    ('commerce', 'tourism')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------- arts-humanities
INSERT INTO stream_careers (stream_slug, career_slug) VALUES
    ('arts-humanities', 'psychology'),
    ('arts-humanities', 'sociology'),
    ('arts-humanities', 'public-administration'),
    ('arts-humanities', 'law'),
    ('arts-humanities', 'journalism-and-mass-communication'),
    ('arts-humanities', 'design')
ON CONFLICT DO NOTHING;

-- --------------------------------------------------------------- vocational
-- Derived, not listed: any career with a Diploma-level entry route.
INSERT INTO stream_careers (stream_slug, career_slug)
SELECT DISTINCT 'vocational', cd.career_slug
FROM career_degrees cd
JOIN degrees d ON d.slug = cd.degree_slug
WHERE d.level = 'Diploma'
ON CONFLICT DO NOTHING;

DO $$
DECLARE bad int;
BEGIN
    -- Every career must be reachable from exactly one academic stream:
    -- none orphaned (invisible to a student browsing by stream), none
    -- double-counted (which would mean the partition rule was broken).
    SELECT count(*) INTO bad FROM careers c
    WHERE (SELECT count(*) FROM stream_careers sc
           WHERE sc.career_slug = c.slug
             AND sc.stream_slug IN ('science', 'commerce', 'arts-humanities')) <> 1;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) are not in exactly one academic stream', bad;
    END IF;

    SELECT count(*) INTO bad FROM stream_careers WHERE stream_slug = 'science';
    IF bad <> 29 THEN
        RAISE EXCEPTION 'expected 29 science careers, found %', bad;
    END IF;

    -- Vocational is derived, so this asserts the derivation still matches the
    -- diploma data rather than a number someone typed.
    SELECT count(*) INTO bad FROM stream_careers WHERE stream_slug = 'vocational';
    IF bad <> (SELECT count(DISTINCT cd.career_slug) FROM career_degrees cd
               JOIN degrees d ON d.slug = cd.degree_slug WHERE d.level = 'Diploma') THEN
        RAISE EXCEPTION 'vocational stream does not match the diploma-reachable careers';
    END IF;

    -- No stream may be empty: an empty one renders as a dead card.
    SELECT count(*) INTO bad FROM streams s
    WHERE NOT EXISTS (SELECT 1 FROM stream_careers sc WHERE sc.stream_slug = s.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% stream(s) lead to no careers', bad;
    END IF;
END $$;
