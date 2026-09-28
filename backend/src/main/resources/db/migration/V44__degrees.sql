-- Adds Degree, the replacement for the removed Courses section (V43): a
-- general pursuit guide per degree/qualification type (B.Tech, Diploma,
-- B.Ed, ...) rather than one row per discipline. Each degree links to real
-- entrance exams, skills and resources via proper relations (see
-- Degree.java) instead of free text, matching every other entity in this
-- schema.
--
-- Content scope for this pass (per direct request): the ~10 degree types
-- actually in common use across current careers get real entrance-exam/
-- skill/resource content. Slugs deliberately reuse the old course_types
-- slugs (b-tech, diploma, b-ed, mba, mca, b-sc, b-com, bba, phd,
-- certificate) since they name the same degree concept and V43 already
-- dropped that table, so there's no collision.
--
-- resources was seeded with zero rows before this migration (Resource.java:
-- "No content seeded yet"), so a handful of real, well-known resources are
-- added here too -- otherwise every degree's resource relation would be
-- permanently empty.

CREATE TABLE degrees (
    slug                  VARCHAR(64) PRIMARY KEY,
    title                 VARCHAR(160) NOT NULL,
    description           TEXT NOT NULL,
    icon                  VARCHAR(32) NOT NULL,
    preparation_strategy  TEXT
);

CREATE TABLE degree_exams (
    degree_slug VARCHAR(64) NOT NULL REFERENCES degrees(slug) ON DELETE CASCADE,
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams(slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (degree_slug, exam_slug)
);

CREATE TABLE degree_skills (
    degree_slug VARCHAR(64) NOT NULL REFERENCES degrees(slug) ON DELETE CASCADE,
    skill_slug  VARCHAR(64) NOT NULL REFERENCES skills(slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (degree_slug, skill_slug)
);

CREATE TABLE degree_resources (
    degree_slug   VARCHAR(64) NOT NULL REFERENCES degrees(slug) ON DELETE CASCADE,
    resource_slug VARCHAR(64) NOT NULL REFERENCES resources(slug) ON DELETE CASCADE,
    sort_order    INT NOT NULL DEFAULT 0,
    PRIMARY KEY (degree_slug, resource_slug)
);

INSERT INTO resources (slug, title, resource_type, description, content_url, author, published_at) VALUES
    ('ncert-textbooks', 'NCERT Textbooks & Study Material', 'Website', 'Official NCERT textbooks and syllabi for Class 11-12 Physics, Chemistry, Maths and Biology -- the base for most engineering, medical and science entrance exams.', 'https://ncert.nic.in', 'NCERT', NULL),
    ('ugc-portal', 'UGC -- University Grants Commission', 'Website', 'India''s higher-education regulator; publishes NET/JRF eligibility rules, PhD regulations and recognised-university lists.', 'https://www.ugc.gov.in', 'UGC', NULL),
    ('nta-exam-portal', 'National Testing Agency (NTA)', 'Website', 'Conducts JEE Main, CUET, CSIR-NET and other national entrance exams -- official notifications, syllabi and application windows.', 'https://nta.ac.in', 'NTA', NULL),
    ('jee-prep-strategy', 'JEE Main & Advanced Preparation Strategy', 'Guide', 'A structured approach to JEE prep: NCERT-first for concepts, previous-year papers for practice, and full mock tests in the final few months.', NULL, NULL, NULL),
    ('cat-prep-strategy', 'CAT Preparation Strategy', 'Guide', 'Covers the three CAT sections -- VARC, DILR, Quant -- with fundamentals first, then timed sectional practice, then full-length mocks.', NULL, NULL, NULL),
    ('net-prep-roadmap', 'UGC-NET / CSIR-NET Preparation Roadmap', 'Guide', 'How to structure preparation for the NET eligibility test for Assistant Professor / JRF: paper pattern, subject-wise weightage and revision cycles.', NULL, NULL, NULL),
    ('ctet-prep-guide', 'CTET Preparation Guide', 'Guide', 'Covers CTET''s Child Development & Pedagogy section plus subject-specific papers, using NCERT pedagogy chapters as the core reference.', NULL, NULL, NULL),
    ('polytechnic-entrance-guide', 'Polytechnic Diploma Entrance Guide', 'Guide', 'What state polytechnic/diploma entrance tests (after 10th) typically cover, and how they differ from JEE-style engineering entrances.', NULL, NULL, NULL),
    ('coding-fundamentals-resources', 'Free Programming Fundamentals Resources', 'Website', 'Community-maintained, free resources for learning programming fundamentals and data structures ahead of MCA/BCA-style computing programs.', NULL, NULL, NULL),
    ('commerce-accounting-basics', 'Commerce & Accounting Fundamentals', 'Article', 'A primer on financial accounting, taxation basics and business-law concepts that B.Com and BBA coursework builds on.', NULL, NULL, NULL);

INSERT INTO degrees (slug, title, description, icon, preparation_strategy) VALUES
    ('b-tech', 'B.Tech', 'A 4-year undergraduate engineering degree (Bachelor of Technology) -- the primary route into most engineering careers in India, entered after 12th with Physics, Chemistry and Maths.', 'cap', 'Build a strong NCERT foundation in Physics, Chemistry and Maths through Class 11-12, then move to previous-year JEE papers and timed mock tests in the final few months. Most aspirants prepare for 1-2 years alongside school, often with coaching or structured self-study; JEE Advanced (for the IITs) demands a noticeably harder problem-solving level than JEE Main.'),
    ('diploma', 'Diploma', 'A 3-year polytechnic diploma in engineering, typically entered right after 10th standard -- a faster, more hands-on alternative to a 4-year B.Tech, often followed by lateral entry into a B.Tech''s 2nd year.', 'book', 'State polytechnic entrance tests focus on 10th-standard Maths and Science rather than the calculus-heavy JEE syllabus, so preparation is shorter and more school-syllabus-aligned. Most students prepare over a few months using state board textbooks and previous-year polytechnic CET papers.'),
    ('b-ed', 'B.Ed', 'A 2-year professional degree (Bachelor of Education) required to teach in most Indian schools, entered after a Bachelor''s degree.', 'teach', 'Admission is usually through a state or university-level B.Ed entrance test (increasingly via CUET at many universities), testing general aptitude, teaching aptitude and the graduate''s subject area. After completing the degree, most states also require passing CTET or a state TET to be eligible for government teaching posts.'),
    ('mba', 'MBA', 'A 2-year postgraduate management degree, usually entered after a Bachelor''s degree via an entrance exam like CAT, and a common step toward leadership and strategy roles across industries.', 'brief', 'CAT preparation typically runs 6-12 months across three sections -- Verbal Ability & Reading Comprehension, Data Interpretation & Logical Reasoning, and Quantitative Ability. A common approach is fundamentals first, then timed sectional tests and full-length mocks in the last few months; final selection at top B-schools also weighs group discussions and personal interviews.'),
    ('mca', 'MCA', 'A 2-year postgraduate computing degree (Master of Computer Applications) for graduates with a Mathematics background, deepening software development and systems expertise.', 'code', 'Most MCA admissions go through CUET-PG or university-specific entrance tests covering mathematics, logical reasoning and basic computer awareness. Building programming fundamentals and data-structures knowledge beforehand -- even informally -- makes the coursework itself much easier to keep up with.'),
    ('b-sc', 'B.Sc', 'A 3-year undergraduate science degree, usually in Physics, Chemistry, Biology, Mathematics or a related discipline, and a common base for research, teaching or further postgraduate study.', 'flask', 'Admission is largely 12th-standard-marks-based or through CUET at central and many state universities, so preparation centers on scoring well in board exams plus CUET''s general test and the relevant domain subject test.'),
    ('b-com', 'B.Com', 'A 3-year undergraduate commerce degree covering accounting, finance, taxation and business law -- the traditional base for careers in accounting, banking and finance.', 'chart', 'Most B.Com admissions are 12th-marks-based or via CUET at many universities; building comfort with basic accounting and quantitative aptitude ahead of time makes the first-year coursework considerably easier.'),
    ('bba', 'BBA', 'A 3-year undergraduate business degree covering management fundamentals -- marketing, HR, finance and operations -- often a stepping stone toward an MBA.', 'brief', 'Many BBA programs admit via 12th-standard marks, CUET, or a university-specific management aptitude test covering general awareness, reasoning and basic quantitative skills.'),
    ('phd', 'PhD', 'A research doctorate, typically 3-5 years, culminating in a thesis based on original research -- required for university faculty roles and many senior research positions.', 'flask', 'Eligibility usually requires clearing UGC-NET or CSIR-NET (JRF for a funded position) or a university-specific research entrance test, plus a strong Master''s-level academic record. Preparation centers on the subject paper plus a general research-aptitude paper, alongside identifying a research area and prospective guide.'),
    ('certificate', 'Certificate', 'A short-term professional certification (a few months to about a year) in a specific in-demand skill area -- cloud computing, data science, digital marketing, cybersecurity and similar -- usually pursued alongside or after a degree rather than as a replacement for one.', 'bulb', 'Unlike a degree, most certifications have no formal entrance exam -- admission is usually open, sometimes with a basic prerequisite (e.g. some programming exposure for a data-science certificate). The real preparation is picking a program with genuine hands-on projects and industry recognition rather than just a certificate of completion.');

INSERT INTO degree_exams (degree_slug, exam_slug, sort_order) VALUES
    ('b-tech', 'jee-main', 0), ('b-tech', 'jee-advanced', 1), ('b-tech', 'bitsat', 2),
    ('diploma', 'polytechnic-cet', 0),
    ('b-ed', 'cuet', 0), ('b-ed', 'ctet', 1),
    ('mba', 'cat', 0),
    ('mca', 'cuet', 0),
    ('b-sc', 'cuet', 0),
    ('b-com', 'cuet', 0),
    ('bba', 'cuet', 0),
    ('phd', 'ugc-net', 0), ('phd', 'csir-net', 1);

INSERT INTO degree_skills (degree_slug, skill_slug, sort_order) VALUES
    ('b-tech', 'mathematics', 0), ('b-tech', 'problem-solving', 1), ('b-tech', 'programming-fundamentals', 2), ('b-tech', 'technical-drawing', 3), ('b-tech', 'cad-cam', 4),
    ('diploma', 'technical-drawing', 0), ('diploma', 'blueprint-reading', 1), ('diploma', 'measurement-tools', 2), ('diploma', 'problem-solving', 3), ('diploma', 'manufacturing-processes', 4),
    ('b-ed', 'classroom-management', 0), ('b-ed', 'curriculum-design', 1), ('b-ed', 'communication', 2), ('b-ed', 'patience', 3), ('b-ed', 'mentorship', 4),
    ('mba', 'leadership', 0), ('mba', 'strategic-planning', 1), ('mba', 'business-acumen', 2), ('mba', 'financial-planning', 3), ('mba', 'negotiation', 4),
    ('mca', 'programming-fundamentals', 0), ('mca', 'data-structures', 1), ('mca', 'database-management', 2), ('mca', 'problem-solving', 3), ('mca', 'python', 4),
    ('b-sc', 'mathematics', 0), ('b-sc', 'research', 1), ('b-sc', 'analytical-thinking', 2), ('b-sc', 'statistics', 3), ('b-sc', 'scientific-writing', 4),
    ('b-com', 'accounting', 0), ('b-com', 'financial-reporting', 1), ('b-com', 'taxation', 2), ('b-com', 'business-communication', 3), ('b-com', 'excel', 4),
    ('bba', 'business-acumen', 0), ('bba', 'communication', 1), ('bba', 'leadership', 2), ('bba', 'teamwork', 3), ('bba', 'strategic-thinking', 4),
    ('phd', 'research', 0), ('phd', 'academic-writing', 1), ('phd', 'critical-analysis', 2), ('phd', 'subject-mastery', 3), ('phd', 'scientific-writing', 4),
    ('certificate', 'problem-solving', 0), ('certificate', 'adaptability', 1), ('certificate', 'communication', 2), ('certificate', 'critical-thinking', 3);

INSERT INTO degree_resources (degree_slug, resource_slug, sort_order) VALUES
    ('b-tech', 'ncert-textbooks', 0), ('b-tech', 'nta-exam-portal', 1), ('b-tech', 'jee-prep-strategy', 2),
    ('diploma', 'polytechnic-entrance-guide', 0), ('diploma', 'ncert-textbooks', 1),
    ('b-ed', 'ctet-prep-guide', 0), ('b-ed', 'ncert-textbooks', 1),
    ('mba', 'cat-prep-strategy', 0),
    ('mca', 'coding-fundamentals-resources', 0), ('mca', 'nta-exam-portal', 1),
    ('b-sc', 'ncert-textbooks', 0), ('b-sc', 'nta-exam-portal', 1),
    ('b-com', 'commerce-accounting-basics', 0), ('b-com', 'nta-exam-portal', 1),
    ('bba', 'nta-exam-portal', 0), ('bba', 'commerce-accounting-basics', 1),
    ('phd', 'net-prep-roadmap', 0), ('phd', 'ugc-portal', 1),
    ('certificate', 'coding-fundamentals-resources', 0);
