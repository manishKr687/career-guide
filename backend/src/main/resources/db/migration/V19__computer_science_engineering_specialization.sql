-- Adds "Computer Science & Engineering" as a specialization shared across
-- all 4 IT & Software careers (Data Scientist, Software Engineer,
-- Cybersecurity Analyst, Cloud Architect) -- all of which now live under
-- Engineering & Technology as of V18 -- so it sits inside that category the
-- same way every other specialization does: transitively, through the
-- careers it's linked to (a specialization has no category of its own).
--
-- Unlike every specialization added so far, this one is deliberately shared
-- by several careers rather than being one career's private sub-discipline
-- (Aerospace's 5, or each of these same 4 careers' own specific
-- specializations from V17 -- e.g. Frontend/Backend/Mobile for Software
-- Engineer). It represents the common computing foundation underneath all
-- four, not a fourth sub-topic replacing what they already have -- so it's
-- ADDED to each career's existing specialization list, not a replacement.
-- The schema already supported this (career_specializations is a plain
-- many-to-many); this is just the first specialization to actually use that.
--
-- career_specializations rows below continue each of the 4 careers'
-- existing sort_order sequence (they already have 2-3 specializations from
-- V17) rather than colliding with them. specialization_courses/
-- specialization_exams start fresh at 0 since this specialization slug is
-- brand new.

INSERT INTO specializations (slug, name, description, icon) VALUES (
    'computer-science-engineering',
    'Computer Science & Engineering',
    'The core computing discipline -- algorithms, systems and software fundamentals -- that underlies every IT & Software career, from software development to data science, cybersecurity and cloud architecture.',
    'code'
);

INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-scientist', 'computer-science-engineering', 3) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('software-engineer', 'computer-science-engineering', 3) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cybersecurity-analyst', 'computer-science-engineering', 3) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cloud-architect', 'computer-science-engineering', 2) ON CONFLICT DO NOTHING;

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('computer-science-engineering', 'btech-cse', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('computer-science-engineering', 'mca', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('computer-science-engineering', 'diploma-cs', 2) ON CONFLICT DO NOTHING;

INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('computer-science-engineering', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('computer-science-engineering', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('computer-science-engineering', 'gate', 2) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('computer-science-engineering', 'bitsat', 3) ON CONFLICT DO NOTHING;
