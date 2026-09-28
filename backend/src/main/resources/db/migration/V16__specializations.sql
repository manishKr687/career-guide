-- Adds "specializations" as a new first-class catalog entity, generic and
-- reusable the same way courses/exams/colleges are -- but for now only
-- populated for Aerospace Engineer, per the user's request. A specialization
-- is a sub-discipline within a career (e.g. Propulsion within Aerospace
-- Engineering) that itself links to the specific existing course(s) and
-- exam(s) that actually cover it, so it's a real relation rather than a
-- plain text tag -- this is the same "does it actually connect to something"
-- bar as courses/exams/colleges, deliberately more than Key Skills or Top
-- Recruiters (which are plain string lists because there's nothing in the
-- catalog for a skill or a company to link to).
--
-- career_specializations mirrors career_colleges: unidirectional (nothing
-- points back from Course/Exam to Specialization), new table, no pre-
-- existing rows to create sort_order gaps against (see V14's postmortem).

CREATE TABLE specializations (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    icon        VARCHAR(32) NOT NULL
);

CREATE TABLE career_specializations (
    career_slug          VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    specialization_slug  VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    sort_order           INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, specialization_slug)
);

CREATE TABLE specialization_courses (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    course_slug          VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, course_slug)
);

CREATE TABLE specialization_exams (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    exam_slug             VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, exam_slug)
);

-- ---------------------------------------------------------------------
-- The 5 sub-disciplines within Aerospace Engineering, matching what the
-- career's own description already names (structures, propulsion,
-- avionics, aerodynamics) plus Space Systems given the ISRO/private-space
-- angle already in its top recruiters.
-- ---------------------------------------------------------------------

INSERT INTO specializations (slug, name, description, icon) VALUES ('aerodynamics', 'Aerodynamics', 'Studies how air flows around aircraft and spacecraft to shape lift, drag and stability — the discipline behind every wing, fuselage and control-surface design.', 'compass');
INSERT INTO specializations (slug, name, description, icon) VALUES ('propulsion', 'Propulsion', 'Covers the design of jet engines and rocket motors that generate the thrust to get aircraft airborne and spacecraft into orbit.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('avionics', 'Avionics', 'The electronics, navigation, communication and flight-control systems that let an aircraft or satellite sense, decide and fly — the aerospace side of embedded electronics.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('aerospace-structures', 'Aerospace Structures', 'Designs the airframes, fuselages and load-bearing structures that must survive flight loads while staying as light as possible.', 'layers');
INSERT INTO specializations (slug, name, description, icon) VALUES ('space-systems', 'Space Systems', 'Focuses on satellites, launch vehicles and spacecraft systems — the specialization most directly aligned with India''s growing space program and private space sector.', 'rocket');

INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('aerospace-engineer', 'aerodynamics', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('aerospace-engineer', 'propulsion', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('aerospace-engineer', 'avionics', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('aerospace-engineer', 'aerospace-structures', 3) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('aerospace-engineer', 'space-systems', 4) ON CONFLICT DO NOTHING;

-- Each specialization connects to whichever existing course(s)/exam(s)
-- actually cover it. Avionics is the one genuinely cross-disciplinary link
-- (it also connects to the ECE course, not just Aerospace itself), and
-- Propulsion/Space Systems connect to ISRO's own recruitment exam (ICRB)
-- rather than the generic engineering entrances, since that's the real
-- route into those two sub-disciplines at ISRO specifically.

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('aerodynamics', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerodynamics', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerodynamics', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerodynamics', 'gate', 2) ON CONFLICT DO NOTHING;

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('propulsion', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('propulsion', 'gate', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('propulsion', 'isro-icrb', 1) ON CONFLICT DO NOTHING;

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('avionics', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('avionics', 'btech-ece', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('avionics', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('avionics', 'gate', 1) ON CONFLICT DO NOTHING;

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('aerospace-structures', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerospace-structures', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerospace-structures', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('aerospace-structures', 'gate', 2) ON CONFLICT DO NOTHING;

INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('space-systems', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('space-systems', 'isro-icrb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('space-systems', 'gate', 1) ON CONFLICT DO NOTHING;

-- While we're here: connect Aerospace Engineer to ISRO's own recruitment
-- exam directly too (career_exams / exam_careers), which was a real gap --
-- the career only linked to the generic engineering entrances before this,
-- not the exam that's most specific to actually working at ISRO.
--
-- Learned from V14: checked each of these four tables' EXISTING rows for
-- their current max sort_order per owning key before picking a value here,
-- rather than assuming 0. isro-icrb already had exam_careers row 0
-- (isro-scientist-engineer) and exam_courses rows 0-3 (btech-cse,
-- btech-electrical, btech-ece, btech-mech), so this continues both at their
-- real next index instead of colliding with them.

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('aerospace-engineer', 'isro-icrb', 3) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('isro-icrb', 'aerospace-engineer', 1) ON CONFLICT DO NOTHING;
INSERT INTO exam_courses (exam_slug, course_slug, sort_order) VALUES ('isro-icrb', 'btech-aerospace', 4) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-aerospace', 'isro-icrb', 3) ON CONFLICT DO NOTHING;
