-- Removes the entire Courses feature per direct request ("I don't need
-- Courses section, remove entire section of Courses"). Every course's
-- career-path info already lives on Career (education, relatedExamSlugs,
-- relatedCollegeSlugs, skills) and every one of the 57 existing courses
-- already linked to at least one Career, so nothing needed to be created
-- or "moved" there first -- confirmed by checking live data before writing
-- this migration.
--
-- Drops every join table that references courses.slug first (each has ON
-- DELETE CASCADE from the courses side, but Postgres still refuses to drop
-- a table other tables have a live FK into), then courses itself, then
-- course_types (V33) -- its only consumer was Course, so it's dead too.
-- stream_courses (V29) was never actually mapped in JPA (Stream.java has no
-- Course relation), so it was already a dead table before this migration;
-- it's dropped here anyway since it also FKs into courses.

DROP TABLE IF EXISTS career_courses;
DROP TABLE IF EXISTS course_careers;
DROP TABLE IF EXISTS course_colleges;
DROP TABLE IF EXISTS college_courses;
DROP TABLE IF EXISTS course_exams;
DROP TABLE IF EXISTS exam_courses;
DROP TABLE IF EXISTS specialization_courses;
DROP TABLE IF EXISTS resource_courses;
DROP TABLE IF EXISTS stage_courses;
DROP TABLE IF EXISTS stream_courses;
DROP TABLE IF EXISTS user_saved_courses;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS course_types;
