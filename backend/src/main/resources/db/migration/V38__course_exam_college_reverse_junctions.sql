-- Adds course_colleges and exam_colleges, the two reverse-direction junction
-- tables confirmed via information_schema.tables to be genuinely missing
-- (college_courses and college_exams already exist, but the reverse
-- direction does not) -- mirroring this project's own established
-- convention of storing every many-to-many relationship in both directions
-- (already used for career_courses/course_careers, career_exams/
-- exam_careers, etc). Both new tables are backfilled from the existing
-- college_courses/college_exams data, so no new relationships are invented.

CREATE TABLE course_colleges (
    course_slug  VARCHAR(64) NOT NULL REFERENCES courses(slug) ON DELETE CASCADE,
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges(slug) ON DELETE CASCADE,
    sort_order   INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (course_slug, college_slug)
);

CREATE TABLE exam_colleges (
    exam_slug    VARCHAR(64) NOT NULL REFERENCES exams(slug) ON DELETE CASCADE,
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges(slug) ON DELETE CASCADE,
    sort_order   INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (exam_slug, college_slug)
);

INSERT INTO course_colleges (course_slug, college_slug, sort_order)
    SELECT course_slug, college_slug, sort_order FROM college_courses;

INSERT INTO exam_colleges (exam_slug, college_slug, sort_order)
    SELECT exam_slug, college_slug, sort_order FROM college_exams;
