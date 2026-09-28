-- Introduces Subject as a separate source of truth from Degree.
--
-- The degrees table currently mixes three different kinds of thing under one
-- roof:
--
--   1. qualification TYPES        -- B.Sc, M.Tech, PhD, MBA        (~81 rows)
--   2. qualification x subject    -- B.A. (Economics), M.Sc Nursing (~62 rows)
--   3. fused qualifications       -- MBBS, BDS, BVSc & AH
--
-- Only (1) is really a degree. Category (2) is a product -- a qualification
-- crossed with a field of study -- that was materialised as rows, which is why
-- the catalog grew to 143 entries of which 90 are referenced by nothing at all.
-- Every such row also re-states facts that belong elsewhere: all 17 B.Sc
-- variants independently record level = 'Undergraduate', and each carries a
-- category that actually describes its SUBJECT, not its qualification.
--
-- Evidence for that last point, and the reason this table is safe to derive:
-- the same subject maps to the same category in every family it appears in --
-- bsc-agriculture, msc-agriculture and phd-agricultural-sciences are all
-- 'agriculture'; bsc-nursing, msc-nursing and phd-nursing are all
-- 'medical-healthcare'. Category is a property of the field of study. It is
-- being read off the existing rows below, not invented.
--
-- Category (3) is deliberately NOT decomposed. "MBBS in Medicine" is not a
-- thing -- the qualification and the field are the same fact. Nor are dual
-- degrees (BSc BEd, BA LLB, B.Tech M.Tech): those are two qualifications
-- earned together, not one qualification plus a subject, and forcing them
-- into this model would produce nonsense like "B.Sc in Education".
--
-- This migration is purely additive: it creates and seeds `subjects` and
-- touches nothing else. No FK points at it yet, no degree row is removed and
-- no existing query changes behaviour. The repointing of career_degrees /
-- college_degrees (both currently @ManyToMany, so both must become join
-- entities before they can carry a subject) and the removal of the 62
-- product rows follow in later migrations, deliberately separated because
-- every FK into `degrees` is ON DELETE CASCADE -- deleting a degree row
-- silently deletes its links rather than raising, so the repoint must be
-- complete and verified before any DELETE runs.
--
-- 34 subjects replace 62 degree rows. Five of them (biology, chemistry,
-- mathematics, physics, statistics) have no corresponding degree row at all:
-- V86 linked those careers to bare b-sc / msc / phd because creating
-- bsc-physics / msc-physics / phd-physics triplets would have made the
-- product problem worse. They get subjects here, which is what finally makes
-- "M.Sc (Physics)" expressible.
--
-- `arts-humanities` is NOT seeded as a subject. phd-arts-humanities exists
-- today, but "Arts & Humanities" is a category -- a grouping of subjects, not
-- a field of study anyone enrols in -- and that row is orphaned (0 careers).
-- It is dropped rather than converted when the removals run.

CREATE TABLE subjects (
    slug          VARCHAR(64)  PRIMARY KEY,
    title         VARCHAR(160) NOT NULL,
    description   TEXT         NOT NULL,
    icon          VARCHAR(32)  NOT NULL,
    category_slug VARCHAR(64)  NOT NULL REFERENCES categories (slug)
);

CREATE INDEX idx_subjects_category ON subjects (category_slug);

INSERT INTO subjects (slug, title, description, icon, category_slug) VALUES
    -- agriculture
    ('agriculture', 'Agriculture',
     'The science and practice of crop production, soil management, animal husbandry and farm economics.',
     'leaf', 'agriculture'),
    ('forestry', 'Forestry',
     'The management and conservation of forests, covering silviculture, wildlife biology and forest economics.',
     'leaf', 'agriculture'),
    ('horticulture', 'Horticulture',
     'The cultivation of fruits, vegetables, flowers and ornamental plants, including post-harvest technology.',
     'leaf', 'agriculture'),

    -- arts & humanities
    ('psychology', 'Psychology',
     'The study of mind and behaviour, spanning cognitive, social, developmental, clinical and organisational branches.',
     'bulb', 'arts-humanities'),
    ('sociology', 'Sociology',
     'The study of social structures, institutions, inequality and collective behaviour, grounded in empirical research methods.',
     'users', 'arts-humanities'),

    -- commerce & finance
    ('economics', 'Economics',
     'The study of production, distribution and consumption, covering microeconomics, macroeconomics and econometrics.',
     'chart', 'commerce-finance'),

    -- design & creative
    ('architecture', 'Architecture',
     'The design of buildings and built environments, combining structural technique, spatial planning and aesthetics.',
     'bld', 'design-creative'),
    ('design', 'Design',
     'The practice of solving problems through form, covering product, communication, interaction and experience design.',
     'palette', 'design-creative'),
    ('fine-arts', 'Fine Arts',
     'The practice and theory of visual art -- painting, sculpture, printmaking and applied art.',
     'palette', 'design-creative'),
    ('urban-planning', 'Urban Planning',
     'The design and regulation of land use, transport, housing and infrastructure in towns and cities.',
     'building', 'design-creative'),

    -- education & teaching
    ('education', 'Education',
     'The study of pedagogy, curriculum, educational psychology and the systems through which teaching is delivered.',
     'teach', 'education-teaching'),

    -- engineering & technology
    ('engineering', 'Engineering',
     'The application of scientific and mathematical principles to design, build and maintain structures, machines and systems.',
     'chip', 'engineering-technology'),

    -- hospitality & tourism
    ('tourism', 'Tourism',
     'The study of travel and destination management, covering tour operations, tourism economics and hospitality services.',
     'plane', 'hospitality-tourism'),
    ('hospitality-management', 'Hospitality Management',
     'The management of hotels, restaurants and service operations, covering front office, F&B and revenue management.',
     'brief', 'hospitality-tourism'),
    ('hotel-management', 'Hotel Management',
     'The operational management of hotels and accommodation, covering housekeeping, catering technology and guest services.',
     'building', 'hospitality-tourism'),

    -- IT & software
    ('artificial-intelligence', 'Artificial Intelligence',
     'The study of machine learning, neural networks, computer vision and natural language processing.',
     'chip', 'it-software'),
    ('computer-science', 'Computer Science',
     'The study of algorithms, data structures, computation theory, operating systems and software engineering.',
     'code', 'it-software'),
    ('cybersecurity', 'Cybersecurity',
     'The study of securing systems and networks, covering cryptography, ethical hacking, forensics and governance.',
     'shield', 'it-software'),
    ('data-science', 'Data Science',
     'The extraction of insight from data, combining statistics, machine learning, data engineering and visualisation.',
     'chart', 'it-software'),
    ('information-technology', 'Information Technology',
     'The application of computing to business, covering networks, databases, systems administration and enterprise software.',
     'monitor', 'it-software'),

    -- law
    ('law', 'Law',
     'The study of legal systems, statutes, jurisprudence and procedure, and their application in practice.',
     'scale', 'law'),
    ('public-administration', 'Public Administration',
     'The study of governance, public policy, administrative theory and the structure of government.',
     'building', 'law'),

    -- management & business
    ('management', 'Management',
     'The study of organisations and their direction, covering strategy, operations, finance, marketing and human resources.',
     'brief', 'management-business'),

    -- media & communication
    ('journalism', 'Journalism',
     'The practice of reporting, editing and publishing news across print, broadcast and digital media.',
     'mega', 'media-communication'),
    ('mass-communication', 'Mass Communication',
     'The study of media systems, advertising, public relations and communication theory.',
     'mega', 'media-communication'),

    -- medical & healthcare
    ('nursing', 'Nursing',
     'The practice and science of patient care, covering clinical nursing, community health and nursing administration.',
     'steth', 'medical-healthcare'),
    ('pharmaceutical-sciences', 'Pharmaceutical Sciences',
     'The study of drug discovery, formulation, pharmacology and regulatory affairs.',
     'flask', 'medical-healthcare'),

    -- sports & fitness
    ('sports-management', 'Sports Management',
     'The business of sport, covering event management, sponsorship, athlete representation and facility operations.',
     'trophy', 'sports-fitness'),
    ('sports-science', 'Sports Science',
     'The study of human performance, covering exercise physiology, biomechanics, sports nutrition and psychology.',
     'pulse', 'sports-fitness'),

    -- science & research
    ('biology', 'Biology',
     'The study of living organisms, spanning cell biology, genetics, ecology, physiology and evolution.',
     'flask', 'science-research'),
    ('chemistry', 'Chemistry',
     'The study of matter and its transformations, covering organic, inorganic, physical and analytical chemistry.',
     'flask', 'science-research'),
    ('mathematics', 'Mathematics',
     'The study of quantity, structure and change, covering algebra, analysis, geometry and applied mathematics.',
     'chart', 'science-research'),
    ('physics', 'Physics',
     'The study of matter, energy and their interactions, covering mechanics, electromagnetism and quantum theory.',
     'flask', 'science-research'),
    ('statistics', 'Statistics',
     'The study of data collection, inference and probability, and their application to research and decision-making.',
     'chart', 'science-research');

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM subjects;
    IF bad <> 34 THEN
        RAISE EXCEPTION 'expected 34 subjects, found %', bad;
    END IF;

    -- Every subject must use an icon the frontend already renders; a new name
    -- here would silently render nothing.
    SELECT count(*) INTO bad FROM subjects s
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.icon = s.icon);
    IF bad > 0 THEN
        RAISE EXCEPTION '% subject(s) use an icon not present in the degrees vocabulary', bad;
    END IF;

    -- 'arts-humanities' is a category, not a field of study. If it ever shows
    -- up as a subject slug, the decomposition has gone wrong.
    IF EXISTS (SELECT 1 FROM subjects WHERE slug = 'arts-humanities') THEN
        RAISE EXCEPTION 'arts-humanities is a category, not a subject';
    END IF;
END $$;
