-- Moves the four streams from the After-12th stage to After-10th.
--
-- You CHOOSE a stream after 10th. By the time you are after 12th you already
-- have one, and what you pick then is a degree, a diploma or an entrance
-- exam. The seed data had this backwards: all four rows in stage_streams
-- pointed at after-12th.
--
-- The two stages' own taglines already say so, and have since V1:
--
--   after-10th   "Choose your stream, or a skill-first path"
--   after-12th   "Pick your degree, diploma or entrance exam path"
--
-- The frontend has rendered a "Choose Your Stream" section on the stage page
-- since streams were added (src/app/stage/[slug]/page.tsx, driven by
-- getStreamsByStage) -- so this block has been appearing on the After 12th
-- page, headed "Choose Your Stream", for students who chose two years ago,
-- and has been absent from the one stage whose entire purpose is that choice.
--
-- A data fix, not a code fix: the page, the DTO and the query were all
-- already correct. Only the four link rows were wrong.
--
-- Move rather than duplicate. Leaving after-12th linked as well would put a
-- "Choose Your Stream" heading on a page for people who cannot choose any
-- more; after-12th's own relation to streams is "which one did you finish",
-- which is a different question and not what this table models.

DELETE FROM stage_streams WHERE stage_slug = 'after-12th';

INSERT INTO stage_streams (stage_slug, stream_slug)
SELECT 'after-10th', slug FROM streams
ON CONFLICT DO NOTHING;

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM stage_streams WHERE stage_slug = 'after-10th';
    IF bad <> 4 THEN
        RAISE EXCEPTION 'expected 4 streams on after-10th, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM stage_streams WHERE stage_slug <> 'after-10th';
    IF bad > 0 THEN
        RAISE EXCEPTION '% stream link(s) still attached to another stage', bad;
    END IF;

    -- Every stream must be reachable from the stage where it is chosen;
    -- an orphaned stream would silently vanish from the UI.
    SELECT count(*) INTO bad FROM streams s
    WHERE NOT EXISTS (SELECT 1 FROM stage_streams ss WHERE ss.stream_slug = s.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% stream(s) are not attached to any stage', bad;
    END IF;
END $$;
