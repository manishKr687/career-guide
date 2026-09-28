-- Fixes the same class of bug V14 already fixed once for exam_careers, now
-- reintroduced by V38 for its two new reverse-junction tables.
--
-- V38 backfilled course_colleges/exam_colleges by copying sort_order
-- straight from college_courses/college_exams:
--
--     INSERT INTO exam_colleges (exam_slug, college_slug, sort_order)
--         SELECT exam_slug, college_slug, sort_order FROM college_exams;
--
-- But that sort_order was assigned per COLLEGE (each college's own list of
-- exams/courses starts at 0), not per exam/course. Course.relatedColleges
-- and Exam.relatedColleges are both mapped with @OrderColumn(name =
-- "sort_order"), which Hibernate treats as a dense, zero-based List index
-- *per owning row* (per exam_slug / per course_slug here) -- so copying a
-- per-college index straight across produces gaps and duplicates once
-- re-grouped by exam/course. A gap makes Hibernate build a List with a null
-- placeholder at the missing index, and DtoMapper.toDto throws a
-- NullPointerException the moment it hits one -- exactly the 500 on
-- GET /api/exams/gate (also GET /api/exams/uceed and GET /api/exams/neet-pg,
-- and several course detail pages, e.g. GET /api/courses/btech-mech).
--
-- Fix: renumber both tables' sort_order to be dense and zero-based per
-- exam_slug / course_slug, ordering ties by the original sort_order (falling
-- back to college_slug for a stable order) rather than reconstructing which
-- college was "first" for each exam/course, which V38's copy already lost
-- and which has no meaningful source of truth to recover.

WITH renumbered AS (
    SELECT exam_slug, college_slug,
           ROW_NUMBER() OVER (PARTITION BY exam_slug ORDER BY sort_order, college_slug) - 1 AS new_sort_order
    FROM exam_colleges
)
UPDATE exam_colleges ec
SET sort_order = r.new_sort_order
FROM renumbered r
WHERE ec.exam_slug = r.exam_slug
  AND ec.college_slug = r.college_slug
  AND ec.sort_order <> r.new_sort_order;

WITH renumbered AS (
    SELECT course_slug, college_slug,
           ROW_NUMBER() OVER (PARTITION BY course_slug ORDER BY sort_order, college_slug) - 1 AS new_sort_order
    FROM course_colleges
)
UPDATE course_colleges cc
SET sort_order = r.new_sort_order
FROM renumbered r
WHERE cc.course_slug = r.course_slug
  AND cc.college_slug = r.college_slug
  AND cc.sort_order <> r.new_sort_order;
