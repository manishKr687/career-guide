-- Adds 3 specializations to Computer Science Engineer (added in V20), the
-- same way V17 gave every other career its own specializations. CS&E's own
-- description already names its foundations as "algorithms, operating
-- systems, databases and networks" -- these 3 specializations are exactly
-- that core, minus the 4 already-separate careers (Software Engineer, Data
-- Scientist, Cybersecurity Analyst, Cloud Architect) that a CSE graduate
-- might branch into afterward. Those aren't modeled as specializations of
-- Computer Science Engineer: a specialization is a narrower sub-topic of
-- ONE career, not a pointer to a sibling career with its own salary/
-- growth-path/recruiters, so pointing at them here would be the same
-- category error V19 made in the other direction.
--
-- All 3 slugs are brand new, so specialization_courses/specialization_exams
-- (grouped by specialization_slug, per Specialization.java's @OrderColumn
-- mapping) start fresh at 0 -- no gap risk. career_specializations is
-- grouped by career_slug (Career is the owning side, see V17/V19/V20), and
-- computer-science-engineer has zero existing rows there, so this is also a
-- fresh 0..2 sequence.

INSERT INTO specializations (slug, name, description, icon) VALUES (
    'data-structures-algorithms',
    'Data Structures & Algorithms',
    'Designs efficient algorithms and data structures to solve complex computational problems -- the analytical core of every CS discipline.',
    'chip'
);

INSERT INTO specializations (slug, name, description, icon) VALUES (
    'systems-programming',
    'Systems Programming & Operating Systems',
    'Builds the low-level software -- operating systems, kernels and compilers -- that every other application runs on top of.',
    'gear'
);

INSERT INTO specializations (slug, name, description, icon) VALUES (
    'database-systems',
    'Database Systems & Engineering',
    'Designs and manages the relational and NoSQL databases that store and serve an application''s data.',
    'layers'
);

INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('computer-science-engineer', 'data-structures-algorithms', 0);
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('computer-science-engineer', 'systems-programming', 1);
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('computer-science-engineer', 'database-systems', 2);

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('data-structures-algorithms', 'btech-cse', 0);
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('data-structures-algorithms', 'diploma-cs', 1);
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('data-structures-algorithms', 'gate', 0);

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('systems-programming', 'btech-cse', 0);
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('systems-programming', 'mca', 1);
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('systems-programming', 'gate', 0);

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('database-systems', 'btech-cse', 0);
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('database-systems', 'mca', 1);
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('database-systems', 'gate', 0);
