-- Removes the Working Professional stage, narrowing Stages to the student
-- timeline: After 10th -> After 12th -> Graduation -> Post-Graduation.
--
-- With career-switch gone (V99), the remaining five split cleanly into two
-- different kinds of thing. Four are points in education, each with a real
-- decision attached -- which stream, which degree, which entrance exam.
-- Working Professional is not one of those: it describes employment status,
-- not a step in the timeline, and the "decision" it offers (upskill) has no
-- admission gate behind it. Keeping it made Stages answer two questions at
-- once.
--
-- UNLIKE V99, THIS ONE DESTROYS CONTENT IF DONE NAIVELY
--
-- career-switch was safe to delete outright because it had nothing attached
-- but careers. This stage has four exams, and stage_exams.stage_slug is ON
-- DELETE CASCADE, so a bare DELETE would take all four links with it without
-- raising. Three of the four are on NO other stage:
--
--   gate           on 2 stages  -> survives, only loses this link
--   ibps-so-it     on 1 stage   -> would vanish from the stage taxonomy
--   cs-foundation  on 1 stage   -> would vanish
--   pmp            on 1 stage   -> would vanish
--
-- Those three would still exist under /exams, but would no longer be reachable
-- from any stage -- a silent content loss of exactly the kind V99's own guard
-- was written to prevent. So they are re-homed first, not deleted.
--
-- The new home for each is read off its own eligibility text rather than
-- chosen by feel:
--
--   cs-foundation  "12th Pass"                                   -> after-12th
--   ibps-so-it     "B.Tech/B.E. or MCA"                          -> graduation
--   pmp            "Bachelor's Degree + Project Management ..."  -> graduation
--
-- PMP also wants years of experience, which no stage models; graduation is
-- the earliest stage at which it becomes reachable at all, which is the
-- question a stage page answers.
--
-- CAREER LINKS
--
-- The 8 career links cascade away, and that is safe for the same reason as
-- V99: working-professional is the LAST stage for every one of those 8
-- careers (it was sort_order 4, and career-switch at 5 is already gone), so
-- each sequence stays dense at 0..n-2. Guarded below rather than assumed.

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad
    FROM career_stages cs
    WHERE cs.stage_slug = 'working-professional'
      AND cs.sort_order <> (SELECT max(sort_order) FROM career_stages x
                            WHERE x.career_slug = cs.career_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION 'working-professional is not the last stage for % career(s); deleting it would gap career_stages.sort_order', bad;
    END IF;

    IF EXISTS (SELECT 1 FROM stage_streams WHERE stage_slug = 'working-professional') THEN
        RAISE EXCEPTION 'working-professional has stream links that would be silently cascaded away';
    END IF;
END $$;

-- Re-home the three exams BEFORE the delete, so none is ever stage-less.
INSERT INTO stage_exams (stage_slug, exam_slug, sort_order)
SELECT 'after-12th', 'cs-foundation',
       (SELECT max(sort_order) + 1 FROM stage_exams WHERE stage_slug = 'after-12th')
WHERE NOT EXISTS (SELECT 1 FROM stage_exams
                  WHERE stage_slug = 'after-12th' AND exam_slug = 'cs-foundation');

INSERT INTO stage_exams (stage_slug, exam_slug, sort_order)
SELECT 'graduation', v.exam_slug,
       (SELECT max(sort_order) FROM stage_exams WHERE stage_slug = 'graduation')
       + ROW_NUMBER() OVER (ORDER BY v.exam_slug)
FROM (VALUES ('ibps-so-it'), ('pmp')) AS v(exam_slug)
WHERE NOT EXISTS (SELECT 1 FROM stage_exams se
                  WHERE se.stage_slug = 'graduation' AND se.exam_slug = v.exam_slug);

DELETE FROM stages WHERE slug = 'working-professional';

DO $$
DECLARE bad int;
BEGIN
    IF EXISTS (SELECT 1 FROM stages WHERE slug = 'working-professional') THEN
        RAISE EXCEPTION 'working-professional stage was not removed';
    END IF;

    SELECT count(*) INTO bad FROM stages;
    IF bad <> 4 THEN
        RAISE EXCEPTION 'expected 4 stages remaining, found %', bad;
    END IF;

    -- The point of the re-homing: no exam that had a stage may have lost it.
    SELECT count(*) INTO bad FROM (VALUES
        ('gate'), ('ibps-so-it'), ('cs-foundation'), ('pmp')
    ) AS v(exam_slug)
    WHERE NOT EXISTS (SELECT 1 FROM stage_exams se WHERE se.exam_slug = v.exam_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% exam(s) lost their last stage link', bad;
    END IF;

    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_stages cs WHERE cs.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) now have no stage', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_stages
        GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_stages.sort_order is not dense for % career(s)', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT stage_slug FROM stage_exams
        GROUP BY stage_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'stage_exams.sort_order is not dense for % stage(s)', bad;
    END IF;
END $$;
