-- Repairs display-order drift in college_career_degrees and
-- exam_career_degrees, found by extending the sort_order integrity scan
-- (first run for V58) to cover these two @OrderBy-mapped tables as well.
--
-- Neither table can crash the way the @OrderColumn tables V58 fixed can --
-- @OrderBy just orders by the column's current value at read time, so a
-- duplicate or gap never corrupts a Hibernate list. But it does mean cards
-- can render in a jumbled order: e.g. iit-bombay had four
-- college_career_degrees rows all at sort_order=0, because V55's original
-- seed copied career_colleges.sort_order directly (that value is scoped
-- per CAREER -- "iit-bombay is career_colleges' 1st row for
-- computer-science-and-engineering, AND for mechanical-engineering, AND
-- civil-engineering, AND electrical-engineering" -- all correctly 0 in
-- their own per-career sequence, but not unique once collected per
-- COLLEGE instead). Renumbers every college's/exam's group densely from
-- 0, preserving relative order (ties broken by career_slug/degree_slug
-- for a stable, deterministic result) -- a no-op for any group that's
-- already clean.

UPDATE college_career_degrees ccd
SET sort_order = renumbered.new_order
FROM (
    SELECT college_slug, career_slug, degree_slug,
           ROW_NUMBER() OVER (PARTITION BY college_slug ORDER BY sort_order, career_slug, degree_slug) - 1 AS new_order
    FROM college_career_degrees
) renumbered
WHERE ccd.college_slug = renumbered.college_slug
  AND ccd.career_slug = renumbered.career_slug
  AND ccd.degree_slug = renumbered.degree_slug
  AND ccd.sort_order <> renumbered.new_order;

UPDATE exam_career_degrees ecd
SET sort_order = renumbered.new_order
FROM (
    SELECT exam_slug, career_slug, degree_slug,
           ROW_NUMBER() OVER (PARTITION BY exam_slug ORDER BY sort_order, career_slug, degree_slug) - 1 AS new_order
    FROM exam_career_degrees
) renumbered
WHERE ecd.exam_slug = renumbered.exam_slug
  AND ecd.career_slug = renumbered.career_slug
  AND ecd.degree_slug = renumbered.degree_slug
  AND ecd.sort_order <> renumbered.new_order;
