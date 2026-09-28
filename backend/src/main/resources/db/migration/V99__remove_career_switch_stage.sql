-- Removes the Career Switch stage.
--
-- It had become an empty page. Its content came entirely from the careers
-- list, and once that section was dropped from the stage template there was
-- nothing left underneath the hero:
--
--   stage                  careers  exams  streams   left on the page
--   after-10th                  10      2        4   streams + exams
--   after-12th                  42      5        0   exams
--   graduation                  35      4        0   exams
--   post-graduation             11      3        0   exams
--   working-professional         8      4        0   exams
--   career-switch                8      0        0   NOTHING
--
-- Alone among the six it has no exams and no streams, so it rendered a
-- heading, a tagline and then jumped straight to "Explore Other Stages". A
-- live page with no content is worse than a missing one.
--
-- This removes the stage, not the idea. Switching careers is a real user
-- journey, but it is not a *stage* in the same sense as the other five --
-- those are points on an education timeline (after 10th, after 12th, after a
-- degree), whereas a career switch can happen at any of them. Modelling it as
-- a sixth sibling was a category error, and it showed: the stage had no exams
-- because there is no "career switch entrance exam", and no streams because
-- you do not pick a stream when changing jobs at 30. If it comes back it
-- should be a differently-shaped feature, not a stage row.
--
-- WHAT GOES WITH IT
--
-- career_stages.stage_slug is ON DELETE CASCADE, so the 8 career links go
-- automatically. That is safe here specifically because career-switch is the
-- LAST stage (sort_order 5) and therefore the highest sort_order in every one
-- of those 8 careers' sequences -- verified before writing this. Removing a
-- middle stage would punch holes in career_stages.sort_order and trigger the
-- V58 @OrderColumn NPE; this one leaves each sequence dense at 0..n-2. The
-- assertion below is what makes that a checked fact rather than an assumption.
--
-- No stage_exams or stage_streams rows exist for it, so nothing else moves.
--
-- The 8 careers keep all their other stages; none of them is left with none.

DO $$
DECLARE bad int;
BEGIN
    -- Guard the cascade: if career-switch is not last for some career, the
    -- delete would leave a gap and this migration must not run as written.
    SELECT count(*) INTO bad
    FROM career_stages cs
    WHERE cs.stage_slug = 'career-switch'
      AND cs.sort_order <> (SELECT max(sort_order) FROM career_stages x
                            WHERE x.career_slug = cs.career_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION 'career-switch is not the last stage for % career(s); deleting it would gap career_stages.sort_order', bad;
    END IF;

    IF EXISTS (SELECT 1 FROM stage_exams WHERE stage_slug = 'career-switch')
       OR EXISTS (SELECT 1 FROM stage_streams WHERE stage_slug = 'career-switch') THEN
        RAISE EXCEPTION 'career-switch has exam or stream links that would be silently cascaded away';
    END IF;
END $$;

DELETE FROM stages WHERE slug = 'career-switch';

DO $$
DECLARE bad int;
BEGIN
    IF EXISTS (SELECT 1 FROM stages WHERE slug = 'career-switch') THEN
        RAISE EXCEPTION 'career-switch stage was not removed';
    END IF;

    SELECT count(*) INTO bad FROM stages;
    IF bad <> 5 THEN
        RAISE EXCEPTION 'expected 5 stages remaining, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM career_stages WHERE stage_slug = 'career-switch';
    IF bad > 0 THEN
        RAISE EXCEPTION '% career_stages row(s) survived the cascade', bad;
    END IF;

    -- No career may be left with no stage at all -- that would drop it out of
    -- every stage page silently.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_stages cs WHERE cs.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) now have no stage', bad;
    END IF;

    -- The whole reason the cascade was safe.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_stages
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_stages.sort_order is not dense for % career(s)', bad;
    END IF;
END $$;
