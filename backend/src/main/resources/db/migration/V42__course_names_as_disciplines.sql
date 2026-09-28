-- Reworks the Course naming convention per direct request: Course.name
-- should hold a pure discipline/subject name ("Chemical Engineering",
-- "Computer Science and Engineering"), with the degree/qualification label
-- ("B.Tech", "Diploma", "B.Ed", ...) carried separately by course_type_slug
-- (see V33__course_types.sql, CourseType.java).
--
-- V33 already backfilled course_type_slug for the courses whose name
-- unambiguously named one of its original 10 seeded types (B.Tech ->
-- b-tech, "Diploma in ..." -> diploma, "MBA (...)" -> mba, etc) and
-- deliberately left everything else NULL rather than guessing. This
-- migration finishes that job: it adds 16 more course types for every
-- degree shape V33 left unmatched (BDS, MBBS, the law/arts/design/nursing
-- UG degrees, ITI trades, the bootcamp, B.Ed, and the non-CS M.A./M.Sc
-- postgrads), backfills course_type_slug for those rows, and rewrites
-- every affected course's name to the bare discipline.
--
-- One deliberate exception: 'any-graduate-degree' ("Any Bachelor's
-- Degree") stays exactly as-is, course_type_slug NULL. It represents
-- "no restriction on stream" for UPSC/defence exams -- there is no single
-- degree or discipline to split it into, and forcing one would misstate
-- what the row means.
--
-- B.Sc Agriculture / B.Sc Nursing reuse the existing 'b-sc' type rather
-- than getting a new one, same as the reasoning for reusing 'diploma'
-- across all six diploma courses. BA LLB and LLB (3-Year) both become the
-- discipline "Law" but keep two distinct course types (ba-llb vs llb)
-- since they're different-length, different-entry-point degrees.

INSERT INTO course_types (slug, name, description, level) VALUES
    ('ba',       'B.A.',    'Bachelor of Arts.',                          'Undergraduate'),
    ('b-com',    'B.Com',   'Bachelor of Commerce.',                      'Undergraduate'),
    ('b-des',    'B.Des',   'Bachelor of Design.',                        'Undergraduate'),
    ('b-ed',     'B.Ed',    'Bachelor of Education.',                     'Postgraduate'),
    ('b-pharm',  'B.Pharm', 'Bachelor of Pharmacy.',                      'Undergraduate'),
    ('ba-llb',   'BA LLB',  'Integrated 5-year BA + LLB law degree.',     'Undergraduate'),
    ('bba',      'BBA',     'Bachelor of Business Administration.',       'Undergraduate'),
    ('bds',      'BDS',     'Bachelor of Dental Surgery.',                'Undergraduate'),
    ('bhm',      'BHM',     'Bachelor of Hotel Management.',              'Undergraduate'),
    ('bjmc',     'BJMC',    'Bachelor of Journalism & Mass Communication.', 'Undergraduate'),
    ('bootcamp', 'Bootcamp','Short-term, intensive project-based program.', 'Short-term'),
    ('iti',      'ITI',     'Industrial Training Institute vocational trade.', 'ITI'),
    ('llb',      'LLB',     '3-year law degree for graduates of any discipline.', 'Undergraduate'),
    ('ma',       'M.A.',    'Master of Arts.',                            'Postgraduate'),
    ('msc',      'M.Sc',    'Master of Science.',                         'Postgraduate'),
    ('mbbs',     'MBBS',    'Bachelor of Medicine, Bachelor of Surgery.', 'Undergraduate');

-- Backfill course_type_slug for the rows V33 left NULL (except
-- any-graduate-degree, see note above).
UPDATE courses SET course_type_slug = 'ba' WHERE slug = 'ba-humanities';
UPDATE courses SET course_type_slug = 'b-com' WHERE slug = 'bcom';
UPDATE courses SET course_type_slug = 'b-des' WHERE slug = 'bdes';
UPDATE courses SET course_type_slug = 'b-ed' WHERE slug = 'bed';
UPDATE courses SET course_type_slug = 'b-pharm' WHERE slug = 'bpharm';
UPDATE courses SET course_type_slug = 'b-sc' WHERE slug IN ('bsc-agriculture', 'bsc-nursing');
UPDATE courses SET course_type_slug = 'ba-llb' WHERE slug = 'ballb';
UPDATE courses SET course_type_slug = 'bba' WHERE slug = 'bba';
UPDATE courses SET course_type_slug = 'bds' WHERE slug = 'bds';
UPDATE courses SET course_type_slug = 'bhm' WHERE slug = 'bhm';
UPDATE courses SET course_type_slug = 'bjmc' WHERE slug = 'bjmc';
UPDATE courses SET course_type_slug = 'bootcamp' WHERE slug = 'web-dev-bootcamp';
UPDATE courses SET course_type_slug = 'iti' WHERE slug IN ('iti-electrician', 'iti-plumber');
UPDATE courses SET course_type_slug = 'llb' WHERE slug = 'llb';
UPDATE courses SET course_type_slug = 'ma' WHERE slug = 'ma-history';
UPDATE courses SET course_type_slug = 'msc' WHERE slug IN ('msc-science', 'msc-psychology');
UPDATE courses SET course_type_slug = 'mbbs' WHERE slug = 'mbbs';

-- Rewrite names to bare disciplines. 'any-graduate-degree' is intentionally
-- absent from this list -- see the note at the top of this file.
UPDATE courses SET name = 'AI & Machine Learning' WHERE slug = 'ai-ml-cert';
UPDATE courses SET name = 'Humanities' WHERE slug = 'ba-humanities';
UPDATE courses SET name = 'Commerce' WHERE slug = 'bcom';
UPDATE courses SET name = 'Design' WHERE slug = 'bdes';
UPDATE courses SET name = 'Education' WHERE slug = 'bed';
UPDATE courses SET name = 'Pharmacy' WHERE slug = 'bpharm';
UPDATE courses SET name = 'Agriculture' WHERE slug = 'bsc-agriculture';
UPDATE courses SET name = 'Nursing' WHERE slug = 'bsc-nursing';
UPDATE courses SET name = 'Aerospace Engineering' WHERE slug = 'btech-aerospace';
UPDATE courses SET name = 'Biomedical Engineering' WHERE slug = 'btech-biomedical';
UPDATE courses SET name = 'Chemical Engineering' WHERE slug = 'btech-chemical';
UPDATE courses SET name = 'Civil Engineering' WHERE slug = 'btech-civil';
UPDATE courses SET name = 'Computer Science and Engineering' WHERE slug = 'btech-cse';
UPDATE courses SET name = 'Electrical Engineering' WHERE slug = 'btech-electrical';
UPDATE courses SET name = 'Electronics & Communication Engineering' WHERE slug = 'btech-ece';
UPDATE courses SET name = 'Environmental Engineering' WHERE slug = 'btech-environmental';
UPDATE courses SET name = 'Marine Engineering / Naval Architecture' WHERE slug = 'btech-marine';
UPDATE courses SET name = 'Mechanical Engineering' WHERE slug = 'btech-mech';
UPDATE courses SET name = 'Mechatronics Engineering' WHERE slug = 'btech-mechatronics';
UPDATE courses SET name = 'Mining Engineering' WHERE slug = 'btech-mining';
UPDATE courses SET name = 'Law' WHERE slug = 'ballb';
UPDATE courses SET name = 'Business Administration' WHERE slug = 'bba';
UPDATE courses SET name = 'Dental Surgery' WHERE slug = 'bds';
UPDATE courses SET name = 'Hotel Management' WHERE slug = 'bhm';
UPDATE courses SET name = 'Journalism & Mass Communication' WHERE slug = 'bjmc';
UPDATE courses SET name = 'Chartered Accountancy' WHERE slug = 'ca-course';
UPDATE courses SET name = 'Cloud Computing (AWS/Azure/GCP)' WHERE slug = 'cloud-computing-cert';
UPDATE courses SET name = 'Company Secretary' WHERE slug = 'cs-course';
UPDATE courses SET name = 'Cybersecurity' WHERE slug = 'cybersecurity-cert';
UPDATE courses SET name = 'Data Science' WHERE slug = 'data-science-cert';
UPDATE courses SET name = 'Digital Marketing' WHERE slug = 'digital-marketing-cert';
UPDATE courses SET name = 'Civil Engineering' WHERE slug = 'diploma-civil';
UPDATE courses SET name = 'Computer Science' WHERE slug = 'diploma-cs';
UPDATE courses SET name = 'Electrical Engineering' WHERE slug = 'diploma-electrical';
UPDATE courses SET name = 'Electronics Engineering' WHERE slug = 'diploma-ece';
UPDATE courses SET name = 'Graphic Design' WHERE slug = 'graphic-design-diploma';
UPDATE courses SET name = 'Mechanical Engineering' WHERE slug = 'diploma-mech';
UPDATE courses SET name = 'Entrepreneurship & Startup' WHERE slug = 'entrepreneurship-cert';
UPDATE courses SET name = 'Fitness & Sports Science' WHERE slug = 'fitness-cert';
UPDATE courses SET name = 'Full-Stack Web Development' WHERE slug = 'web-dev-bootcamp';
UPDATE courses SET name = 'General Nursing & Midwifery' WHERE slug = 'gnm-diploma';
UPDATE courses SET name = 'HR Management' WHERE slug = 'hr-management-cert';
UPDATE courses SET name = 'Electrician' WHERE slug = 'iti-electrician';
UPDATE courses SET name = 'Plumber' WHERE slug = 'iti-plumber';
UPDATE courses SET name = 'Law' WHERE slug = 'llb';
UPDATE courses SET name = 'History' WHERE slug = 'ma-history';
UPDATE courses SET name = 'Physics / Chemistry / Biology' WHERE slug = 'msc-science';
UPDATE courses SET name = 'Psychology (Clinical)' WHERE slug = 'msc-psychology';
UPDATE courses SET name = 'Finance' WHERE slug = 'mba-finance';
UPDATE courses SET name = 'General Management' WHERE slug = 'mba-general';
UPDATE courses SET name = 'Medicine & Surgery' WHERE slug = 'mbbs';
UPDATE courses SET name = 'Computer Applications' WHERE slug = 'mca';
UPDATE courses SET name = 'Sciences' WHERE slug = 'phd-science';
UPDATE courses SET name = 'Product Management' WHERE slug = 'product-management-cert';
UPDATE courses SET name = 'Sustainability & ESG' WHERE slug = 'sustainability-cert';
UPDATE courses SET name = 'UX Design' WHERE slug = 'ux-design-cert';
