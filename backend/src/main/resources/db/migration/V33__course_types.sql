-- Adds course_types, a genuinely missing lookup identified by matching two
-- uploaded documents against this codebase: "CareerGuide -- PostgreSQL
-- Database Schema" (section 8, course_types) and "CareerGuide -- Sample
-- Master Data & Seed SQL" (section 7), which supplies the actual 10 rows
-- seeded below.
--
-- Today courses.level only buckets into 6 coarse groups (Undergraduate,
-- Postgraduate, Diploma, Certification, ITI, Short-term); course_types adds
-- a finer, named degree-type layer (B.Tech vs B.E. vs BCA, all three
-- "Undergraduate") without touching that existing column or any of the 57
-- existing course rows' data.
--
-- course_type_slug is backfilled only where a course's name unambiguously
-- names one of these 10 degree types (a "B.Tech ..." course -> b-tech, a
-- "... Certification" course -> certificate, "Diploma in ..." -> diploma,
-- "MBA (...)" -> mba, the MCA/Ph.D courses -> mca/phd). Courses whose name
-- doesn't match one of the seed doc's 10 types (BDS, MBBS, the law/arts/
-- design/nursing UG degrees, ITI trades, the bootcamp, B.Ed, and the
-- non-CS M.A./M.Sc postgrads) are left with course_type_slug = NULL rather
-- than guessing -- same discipline as every prior migration's backfill.

CREATE TABLE course_types (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    level       VARCHAR(32)
);

INSERT INTO course_types (slug, name, description, level) VALUES
    ('b-tech',      'B.Tech',      'Bachelor of Technology.',                'Undergraduate'),
    ('b-e',         'B.E.',        'Bachelor of Engineering.',               'Undergraduate'),
    ('bca',         'BCA',         'Bachelor of Computer Applications.',     'Undergraduate'),
    ('b-sc',        'B.Sc',        'Bachelor of Science.',                   'Undergraduate'),
    ('mca',         'MCA',         'Master of Computer Applications.',       'Postgraduate'),
    ('m-tech',      'M.Tech',      'Master of Technology.',                  'Postgraduate'),
    ('mba',         'MBA',         'Master of Business Administration.',     'Postgraduate'),
    ('diploma',     'Diploma',     'Diploma level education.',               'Diploma'),
    ('certificate', 'Certificate', 'Professional certificate program.',      'Certification'),
    ('phd',         'PhD',         'Doctoral research program.',             'Postgraduate');

ALTER TABLE courses ADD COLUMN course_type_slug VARCHAR(64) REFERENCES course_types(slug);

UPDATE courses SET course_type_slug = 'b-tech'
    WHERE name LIKE 'B.Tech %';

UPDATE courses SET course_type_slug = 'mba'
    WHERE name LIKE 'MBA %';

UPDATE courses SET course_type_slug = 'mca'
    WHERE slug = 'mca';

UPDATE courses SET course_type_slug = 'phd'
    WHERE slug = 'phd-science';

UPDATE courses SET course_type_slug = 'diploma'
    WHERE slug IN ('diploma-civil', 'diploma-cs', 'diploma-ece', 'diploma-electrical', 'diploma-mech', 'graphic-design-diploma', 'gnm-diploma');

UPDATE courses SET course_type_slug = 'certificate'
    WHERE level = 'Certification';

CREATE INDEX idx_courses_course_type ON courses(course_type_slug);
