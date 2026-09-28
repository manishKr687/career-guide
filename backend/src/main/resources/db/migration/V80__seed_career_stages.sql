-- Re-seeds career_stages, empty since V49 truncated it during the career
-- taxonomy rebuild. V50's replacement taxonomy never restored the relation,
-- so Career.stageSlugs has been [] for all 42 careers and every one of the 6
-- stage pages has been listing zero careers -- the entire "Choose Your Stage"
-- journey has been dead since V49.
--
-- The pre-V49 seed data still exists (backend/seed-json/careers.json) but
-- cannot be restored: it describes 47 careers at JOB-ROLE grain
-- (doctor-mbbs, bank-po, ias-officer) while V50 moved the catalog to
-- FIELD-OF-STUDY grain (medicine, finance, public-administration). Zero slugs
-- overlap. It is used below only as a guide to the original authorial intent,
-- which was: list a career under a stage when someone AT that stage can
-- meaningfully enter or advance in the field.
--
-- Three of the six stages are derived from real data rather than asserted,
-- so they stay correct as the catalog grows and can be re-derived:
--
--   after-10th  <- the career links to an exam categorised "After 10th"
--                  (polytechnic-cet). Deliberately narrow: only fields with a
--                  genuine post-10th diploma route qualify, which is why this
--                  lands on 3 engineering fields and not on all 16. To add a
--                  field later, link the exam -- do not edit this migration.
--   after-12th  <- every career: all 42 are entered through a bachelor's.
--   graduation  <- the career links to a Postgraduate Entrance exam (GATE,
--                  CAT, NEET-PG ...) or to a post-degree recruitment or
--                  professional exam (Government, Banking, Defence,
--                  Professional).
--
-- The remaining three cannot be derived from anything in the schema -- no
-- column encodes "is this field realistically enterable mid-career" -- so
-- they are explicit lists, chosen to match how the original author used them
-- (ux-designer/digital-marketing/hr-manager/entrepreneur were career-switch;
-- data-scientist/investment-banker/cloud-architect were working-professional;
-- research-scientist/psychologist/professor were post-graduation):
--
--   post-graduation       research or clinical specialisation is a normal
--                         destination, not an optional extra
--   working-professional  an established mid-career upskilling market exists
--   career-switch         entry without starting a fresh degree is realistic
--
-- sort_order is dense 0..n-1 per career, following the canonical stage order
-- from the stages table -- Career.stages is @OrderColumn, so a gap here is a
-- NullPointerException later (V58). afterMigrate.sql verifies this.

INSERT INTO career_stages (career_slug, stage_slug, sort_order)
SELECT
    p.career_slug,
    p.stage_slug,
    ROW_NUMBER() OVER (PARTITION BY p.career_slug ORDER BY st.sort_order) - 1
FROM (
    -- derived: post-10th diploma route genuinely exists
    SELECT DISTINCT ce.career_slug, 'after-10th' AS stage_slug
    FROM career_exams ce
    JOIN exams e ON e.slug = ce.exam_slug
    WHERE e.category = 'After 10th'

    UNION
    -- derived: every field in this catalog has a bachelor's entry
    SELECT slug, 'after-12th' FROM careers

    UNION
    -- derived: a PG entrance, or a recruitment/professional exam taken after
    -- a degree, means the field is enterable or advanceable at graduation
    SELECT DISTINCT ce.career_slug, 'graduation'
    FROM career_exams ce
    JOIN exams e ON e.slug = ce.exam_slug
    WHERE e.category IN ('Postgraduate Entrance', 'Government', 'Banking', 'Defence', 'Professional')

    UNION
    -- the 4 careers with no exam links at all; each has a real master's route
    -- (M.Pharm, MPT, M.Sc Sports Science, MTTM) so graduation applies
    SELECT unnest(ARRAY['pharmacy', 'physiotherapy', 'sports-science', 'tourism']), 'graduation'

    UNION
    SELECT unnest(ARRAY[
        'biology', 'chemistry', 'mathematics', 'physics', 'statistics',
        'biotechnology', 'psychology', 'sociology',
        'agriculture', 'forestry', 'medicine'
    ]), 'post-graduation'

    UNION
    SELECT unnest(ARRAY[
        'computer-science-and-engineering', 'information-technology',
        'business-administration', 'finance', 'marketing',
        'human-resource-management', 'accounting', 'design'
    ]), 'working-professional'

    UNION
    SELECT unnest(ARRAY[
        'computer-science-and-engineering', 'information-technology',
        'design', 'marketing', 'human-resource-management',
        'business-administration', 'sports-science',
        'journalism-and-mass-communication'
    ]), 'career-switch'
) p
JOIN stages st ON st.slug = p.stage_slug;

-- Guard: every stage page must now have something on it. The whole point of
-- this migration is that "Choose Your Stage" stops being a dead end, so an
-- empty stage means the rules above missed one.
DO $$
DECLARE empty_stages text;
BEGIN
    SELECT string_agg(s.slug, ', ' ORDER BY s.sort_order) INTO empty_stages
    FROM stages s
    WHERE NOT EXISTS (SELECT 1 FROM career_stages cs WHERE cs.stage_slug = s.slug);

    IF empty_stages IS NOT NULL THEN
        RAISE EXCEPTION 'stage(s) still have no careers: %', empty_stages;
    END IF;
END $$;
