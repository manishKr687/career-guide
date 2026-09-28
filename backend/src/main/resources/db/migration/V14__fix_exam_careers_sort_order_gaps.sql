-- Fixes a real bug in V12: the reverse exam_careers rows added for the 8 new
-- engineering careers used arbitrary sort_order values (100, 101, 102, ...)
-- to "avoid clashing" with the existing rows for gate / jee-main /
-- jee-advanced / polytechnic-cet, instead of continuing the existing
-- sequence. That's wrong -- Exam.relatedCareers is mapped with
-- @OrderColumn(name = "sort_order"), which Hibernate treats as a dense,
-- zero-based List index. A gap between the old rows (0..N-1) and the new
-- ones (100..107) makes Hibernate try to build a ~100-element List with
-- null placeholders for every missing index, and DtoMapper.toDto(Exam)
-- (via slugs(e.getRelatedCareers(), Career::getSlug)) throws a
-- NullPointerException the moment it hits one of those nulls -- which is
-- exactly the 500 on GET /api/exams/gate (and the other 3 exams, and the
-- GET /api/exams list endpoint, which builds every exam's DTO).
--
-- No other junction table touched by V12/V13 has this problem: every other
-- relation either belongs to a brand-new row (the 8 new careers, 7 new
-- courses, 2 new colleges, 1 new exam) whose own list starts fresh at 0, or
-- is the new career_colleges table, which had no pre-existing rows for
-- anyone. This was confirmed by checking every relevant junction table for
-- sort_order gaps per owning key -- only these 4 exams were affected.
--
-- Fix: renumber just the newly-added rows to continue the existing sequence
-- for each exam, preserving the same relative order they were inserted in.

UPDATE exam_careers SET sort_order = 4  WHERE exam_slug = 'gate' AND career_slug = 'chemical-engineer';
UPDATE exam_careers SET sort_order = 5  WHERE exam_slug = 'gate' AND career_slug = 'aerospace-engineer';
UPDATE exam_careers SET sort_order = 6  WHERE exam_slug = 'gate' AND career_slug = 'biomedical-engineer';
UPDATE exam_careers SET sort_order = 7  WHERE exam_slug = 'gate' AND career_slug = 'environmental-engineer';
UPDATE exam_careers SET sort_order = 8  WHERE exam_slug = 'gate' AND career_slug = 'marine-engineer';
UPDATE exam_careers SET sort_order = 9  WHERE exam_slug = 'gate' AND career_slug = 'mining-engineer';
UPDATE exam_careers SET sort_order = 10 WHERE exam_slug = 'gate' AND career_slug = 'mechatronics-engineer';
UPDATE exam_careers SET sort_order = 11 WHERE exam_slug = 'gate' AND career_slug = 'robotics-engineer';

UPDATE exam_careers SET sort_order = 2 WHERE exam_slug = 'jee-advanced' AND career_slug = 'chemical-engineer';
UPDATE exam_careers SET sort_order = 3 WHERE exam_slug = 'jee-advanced' AND career_slug = 'aerospace-engineer';
UPDATE exam_careers SET sort_order = 4 WHERE exam_slug = 'jee-advanced' AND career_slug = 'mining-engineer';

UPDATE exam_careers SET sort_order = 5  WHERE exam_slug = 'jee-main' AND career_slug = 'chemical-engineer';
UPDATE exam_careers SET sort_order = 6  WHERE exam_slug = 'jee-main' AND career_slug = 'aerospace-engineer';
UPDATE exam_careers SET sort_order = 7  WHERE exam_slug = 'jee-main' AND career_slug = 'biomedical-engineer';
UPDATE exam_careers SET sort_order = 8  WHERE exam_slug = 'jee-main' AND career_slug = 'environmental-engineer';
UPDATE exam_careers SET sort_order = 9  WHERE exam_slug = 'jee-main' AND career_slug = 'mining-engineer';
UPDATE exam_careers SET sort_order = 10 WHERE exam_slug = 'jee-main' AND career_slug = 'mechatronics-engineer';
UPDATE exam_careers SET sort_order = 11 WHERE exam_slug = 'jee-main' AND career_slug = 'robotics-engineer';

UPDATE exam_careers SET sort_order = 5 WHERE exam_slug = 'polytechnic-cet' AND career_slug = 'chemical-engineer';
UPDATE exam_careers SET sort_order = 6 WHERE exam_slug = 'polytechnic-cet' AND career_slug = 'environmental-engineer';
UPDATE exam_careers SET sort_order = 7 WHERE exam_slug = 'polytechnic-cet' AND career_slug = 'mechatronics-engineer';
