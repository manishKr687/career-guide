-- Undoes V19 and replaces it with what was actually asked for: "Computer
-- Science & Engineering" is not a specialization -- it's an engineering
-- branch in its own right, on par with Mechanical/Civil/Electrical/etc.
-- under Engineering & Technology, the same way B.Tech CSE is one of the
-- standard engineering degrees alongside B.Tech Mechanical, B.Tech Civil,
-- and so on.
--
-- Data Scientist, Software Engineer, Cybersecurity Analyst and Cloud
-- Architect stay exactly as they are -- full standalone careers with their
-- own salary ranges, growth paths and top recruiters, none of which have a
-- home on the leaner Specialization entity (name/description/icon/courses/
-- exams only). Converting them into specializations would have discarded
-- that content for no real gain, so per the final decision this migration
-- does not touch them at all.

-- ---------------------------------------------------------------------
-- Undo V19: the "Computer Science & Engineering" specialization was the
-- wrong shape for this. Deleting the row cascades to its
-- career_specializations / specialization_courses / specialization_exams
-- rows (all FK'd ON DELETE CASCADE from specializations.slug, see V16).
-- ---------------------------------------------------------------------

DELETE FROM specializations WHERE slug = 'computer-science-engineering';

-- ---------------------------------------------------------------------
-- New career: Computer Science Engineer, under Engineering & Technology.
-- sort_order 16 continues that category's existing 0..15 sequence (see
-- V18, which brought it to 16 careers).
-- ---------------------------------------------------------------------

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, education, skills,
    typical_work, salary_range, growth_path, icon, description, sort_order,
    top_recruiters
) VALUES (
    'computer-science-engineer',
    'Computer Science Engineer',
    'engineering-technology',
    'Algorithms · Systems · Software Foundations',
    'High Demand',
    'B.Tech / B.E in Computer Science & Engineering',
    ARRAY['Data Structures & Algorithms', 'Operating Systems', 'Computer Networks', 'Programming Fundamentals'],
    'Applying core computer science -- algorithms, operating systems, databases and networks -- across roles from software development to data science, cybersecurity and cloud infrastructure',
    '₹4L – ₹45L / year',
    ARRAY['Engineering Trainee', 'Junior Engineer', 'Senior Engineer', 'Tech Lead', 'Engineering Director'],
    'monitor',
    'Computer Science & Engineering is the broadest of the engineering branches: a B.Tech CSE graduate leaves with a grounding in algorithms, operating systems, databases and networks that opens into nearly every corner of the tech industry, rather than one fixed job title. Where it leads varies widely -- some graduates go straight into building software, others specialize into data science, cybersecurity, cloud infrastructure or AI/ML (each of which is its own career on CareerGuide). It is consistently one of India''s most sought-after engineering degrees, with the widest range of recruiters and career paths of any single branch.',
    16,
    ARRAY['Tata Consultancy Services (TCS)', 'Infosys', 'Google India', 'Microsoft India', 'Amazon']
);

-- career_courses / career_exams / career_stages / career_colleges: all
-- brand-new (career_slug = 'computer-science-engineer') groups, so each
-- starts fresh at 0 -- no gap risk.

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('computer-science-engineer', 'btech-cse', 0);
INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('computer-science-engineer', 'mca', 1);
INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('computer-science-engineer', 'diploma-cs', 2);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('computer-science-engineer', 'jee-main', 0);
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('computer-science-engineer', 'jee-advanced', 1);
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('computer-science-engineer', 'gate', 2);
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('computer-science-engineer', 'bitsat', 3);

INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('computer-science-engineer', 'after-12th', 0);
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('computer-science-engineer', 'graduation', 1);

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('computer-science-engineer', 'iit-bombay', 0);
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('computer-science-engineer', 'iit-madras', 1);

-- Reverse rows: Course.relatedCareers / Exam.relatedCareers / Stage.relatedCareers
-- are separate @OrderColumn-mapped lists grouped by course_slug/exam_slug/
-- stage_slug (not career_slug), so -- learned from V14 -- each continues
-- that OTHER side's existing max instead of colliding with it:
--   course_careers: btech-cse max was 3, mca max was 1, diploma-cs max was 0
--   exam_careers: jee-main max was 11, jee-advanced max was 4, gate max was 11, bitsat max was 0
--   stage_careers: after-12th max was 5, graduation max was 5

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-cse', 'computer-science-engineer', 4);
INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('mca', 'computer-science-engineer', 2);
INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('diploma-cs', 'computer-science-engineer', 1);

INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'computer-science-engineer', 12);
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-advanced', 'computer-science-engineer', 5);
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'computer-science-engineer', 12);
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('bitsat', 'computer-science-engineer', 1);

INSERT INTO stage_careers (stage_slug, career_slug, sort_order) VALUES ('after-12th', 'computer-science-engineer', 6);
INSERT INTO stage_careers (stage_slug, career_slug, sort_order) VALUES ('graduation', 'computer-science-engineer', 6);
