-- Backfills career_exams, career_skills, career_industries and
-- careers.growth_path for the 42 taxonomy disciplines imported by V50.
--
-- V49 TRUNCATEd career_exams, career_skills, career_industries (and their
-- reverse junction exam_careers) ahead of the V50 re-import, and V50's own
-- INSERT only set 10 columns (slug, title, category_slug, tagline, demand,
-- education, typical_work, salary_range, icon, description) -- it never
-- touched skills, growth_path, or any of these three join tables. Since
-- then nothing has repopulated them: every one of the 42 disciplines shows
-- "No standardized entrance required" on its career page (relatedExams is
-- empty), and the Key Skills / Career Growth Path sections render their
-- headings with nothing underneath (career.skills and career.growth_path
-- are still '{}').
--
-- This migration:
--   1. Sets careers.growth_path (TEXT[]) per discipline -- a short,
--      realistic career-ladder, same shape as the original V4 seed data
--      (e.g. software-engineer's ARRAY['SDE I','SDE II','Senior SDE',
--      'Staff Engineer','Engineering Manager']).
--   2. Sets careers.skills (TEXT[]) per discipline -- this is still the
--      field the career detail page actually renders for both the
--      "Skills" info panel and the "Key Skills" chip list (see
--      src/app/careers/[slug]/page.tsx); relatedSkillSlugs only decides
--      which of those chips link out to /skills/[slug].
--   3. Derives skills/career_skills from the careers.skills values just
--      set, using the exact same slugification expression as V24's
--      original backfill, with ON CONFLICT DO NOTHING against the
--      existing ~197-row skills catalog so a name that already exists
--      (e.g. "Python", "Git", "Statistics") reuses that row instead of
--      duplicating it.
--   4. Derives industries/career_industries the same way, via a temp
--      table of (career_slug, employer name) pairs -- careers.top_
--      recruiters (what V25's original backfill read from) was dropped in
--      V41, so there's no column to unnest here the way V24/V25 could.
--   5. Links career_exams (and its reverse junction exam_careers) against
--      the existing, untouched 30-exam catalog (V6) -- only where an
--      exam's own catalog description is a clean, direct, well-known
--      match for the discipline, same editorial bar V51 set for
--      career_degrees. Both junction tables have a sort_order that
--      Hibernate's @OrderColumn treats as a dense, zero-based list index
--      per owning key (career_slug for career_exams, exam_slug for
--      exam_careers -- see V14's postmortem), which is why both are
--      populated via ROW_NUMBER() rather than hand-picked numbers; since
--      V49 truncated both tables completely, every key starts a fresh
--      sequence at 0, so there's no existing-row gap to worry about.
--
-- Left deliberately unmapped (no exam in the V6 catalog is a clean, direct
-- match per its own description): pharmacy, physiotherapy, tourism,
-- sports-science.

-- ---------------------------------------------------------------------
-- 1. Career Growth Path
-- ---------------------------------------------------------------------

-- engineering-technology
UPDATE careers SET growth_path = ARRAY['Software Engineer Trainee','Software Engineer','Senior Software Engineer','Tech Lead','Engineering Manager'] WHERE slug = 'computer-science-and-engineering';
UPDATE careers SET growth_path = ARRAY['IT Trainee','IT Engineer','Senior IT Engineer','Technical Lead','IT Manager'] WHERE slug = 'information-technology';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Electronics Engineer','Senior Engineer','Lead Engineer','Engineering Manager'] WHERE slug = 'electronics-and-communication-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Electrical Engineer','Senior Engineer','Lead Engineer','Engineering Manager'] WHERE slug = 'electrical-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Mechanical Engineer','Senior Engineer','Lead Engineer','Engineering Manager'] WHERE slug = 'mechanical-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Aerospace Engineer','Senior Engineer','Lead Engineer','Engineering Manager'] WHERE slug = 'aerospace-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Site Engineer','Senior Engineer','Project Manager','Engineering Manager'] WHERE slug = 'civil-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Process Engineer','Senior Engineer','Lead Engineer','Plant Manager'] WHERE slug = 'chemical-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Industrial Engineer','Senior Engineer','Operations Manager','Plant Head'] WHERE slug = 'industrial-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Manufacturing Engineer','Senior Engineer','Production Manager','Plant Head'] WHERE slug = 'manufacturing-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Metallurgical Engineer','Senior Engineer','Lead Engineer','Plant Manager'] WHERE slug = 'metallurgical-and-materials-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Mining Engineer','Senior Engineer','Mine Manager','General Manager'] WHERE slug = 'mining-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Petroleum Engineer','Senior Engineer','Lead Engineer','Operations Manager'] WHERE slug = 'petroleum-engineering';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Biomedical Engineer','Senior Engineer','R&D Lead','Engineering Manager'] WHERE slug = 'biomedical-engineering';
UPDATE careers SET growth_path = ARRAY['Research Trainee','Biotechnologist','Senior Scientist','Research Lead','R&D Manager'] WHERE slug = 'biotechnology';
UPDATE careers SET growth_path = ARRAY['Graduate Engineer Trainee','Environmental Engineer','Senior Engineer','Environmental Consultant','Environmental Manager'] WHERE slug = 'environmental-engineering';

-- science-research
UPDATE careers SET growth_path = ARRAY['Research Assistant','Junior Research Fellow','Scientist','Senior Scientist','Principal Scientist'] WHERE slug = 'physics';
UPDATE careers SET growth_path = ARRAY['Research Assistant','Junior Research Fellow','Scientist','Senior Scientist','Principal Scientist'] WHERE slug = 'chemistry';
UPDATE careers SET growth_path = ARRAY['Research Assistant','Junior Research Fellow','Analyst','Senior Analyst','Lead Analyst'] WHERE slug = 'mathematics';
UPDATE careers SET growth_path = ARRAY['Statistical Assistant','Statistician','Senior Statistician','Data Analytics Lead','Chief Statistician'] WHERE slug = 'statistics';
UPDATE careers SET growth_path = ARRAY['Research Assistant','Junior Research Fellow','Scientist','Senior Scientist','Principal Scientist'] WHERE slug = 'biology';

-- management-business
UPDATE careers SET growth_path = ARRAY['Management Trainee','Assistant Manager','Manager','Senior Manager','General Manager'] WHERE slug = 'business-administration';
UPDATE careers SET growth_path = ARRAY['Financial Analyst','Senior Analyst','Finance Manager','Finance Controller','Chief Financial Officer'] WHERE slug = 'finance';
UPDATE careers SET growth_path = ARRAY['Accounts Executive','Senior Accountant','Accounts Manager','Finance Controller','Chief Financial Officer'] WHERE slug = 'accounting';
UPDATE careers SET growth_path = ARRAY['Marketing Executive','Marketing Manager','Senior Marketing Manager','Marketing Director','Chief Marketing Officer'] WHERE slug = 'marketing';
UPDATE careers SET growth_path = ARRAY['HR Executive','HR Manager','Senior HR Manager','HR Business Partner','Chief Human Resources Officer'] WHERE slug = 'human-resource-management';

-- medical-healthcare
UPDATE careers SET growth_path = ARRAY['Intern','Resident Doctor','Medical Officer','Specialist / Consultant','Senior Consultant'] WHERE slug = 'medicine';
UPDATE careers SET growth_path = ARRAY['Pharmacist Trainee','Pharmacist','Senior Pharmacist','Pharmacy Manager','Regulatory Affairs Manager'] WHERE slug = 'pharmacy';
UPDATE careers SET growth_path = ARRAY['Staff Nurse','Senior Staff Nurse','Nursing Supervisor','Nursing Superintendent','Chief Nursing Officer'] WHERE slug = 'nursing';
UPDATE careers SET growth_path = ARRAY['Physiotherapist Trainee','Physiotherapist','Senior Physiotherapist','Clinical Lead','Department Head'] WHERE slug = 'physiotherapy';

-- law
UPDATE careers SET growth_path = ARRAY['Associate','Senior Associate','Legal Counsel','Senior Legal Counsel','Partner'] WHERE slug = 'law';
UPDATE careers SET growth_path = ARRAY['Administrative Trainee','Section Officer','Deputy Secretary','Joint Secretary','Secretary'] WHERE slug = 'public-administration';

-- arts-humanities
UPDATE careers SET growth_path = ARRAY['Trainee Psychologist','Psychologist','Senior Psychologist','Clinical Lead','Head of Department'] WHERE slug = 'psychology';
UPDATE careers SET growth_path = ARRAY['Research Assistant','Research Associate','Social Researcher','Senior Researcher','Research Director'] WHERE slug = 'sociology';

-- design-creative
UPDATE careers SET growth_path = ARRAY['Junior Architect','Architect','Senior Architect','Principal Architect','Design Director'] WHERE slug = 'architecture';
UPDATE careers SET growth_path = ARRAY['Junior Designer','Designer','Senior Designer','Design Lead','Creative Director'] WHERE slug = 'design';

-- media-communication
UPDATE careers SET growth_path = ARRAY['Trainee Journalist','Reporter / Correspondent','Senior Correspondent','Editor','Managing Editor'] WHERE slug = 'journalism-and-mass-communication';

-- agriculture
UPDATE careers SET growth_path = ARRAY['Agricultural Officer Trainee','Agricultural Officer','Senior Agricultural Officer','Project Manager','Regional Head'] WHERE slug = 'agriculture';
UPDATE careers SET growth_path = ARRAY['Forest Range Officer','Assistant Conservator of Forests','Deputy Conservator of Forests','Conservator of Forests','Chief Conservator of Forests'] WHERE slug = 'forestry';

-- hospitality-tourism
UPDATE careers SET growth_path = ARRAY['Management Trainee','Guest Relations Executive','Duty Manager','Assistant General Manager','General Manager'] WHERE slug = 'hospitality-management';
UPDATE careers SET growth_path = ARRAY['Tour Executive','Senior Tour Executive','Tour Manager','Operations Manager','General Manager'] WHERE slug = 'tourism';

-- sports-fitness
UPDATE careers SET growth_path = ARRAY['Trainee Sports Scientist','Sports Scientist','Senior Sports Scientist','Performance Manager','Head of Sports Science'] WHERE slug = 'sports-science';

-- ---------------------------------------------------------------------
-- 2. Skills (careers.skills, still the column the career page renders)
-- ---------------------------------------------------------------------

UPDATE careers SET skills = ARRAY['Python','Java','Data Structures & Algorithms','DBMS','Operating Systems','Computer Networks','Git'] WHERE slug = 'computer-science-and-engineering';
UPDATE careers SET skills = ARRAY['Java','SQL','Cloud Computing','System Administration','Networking','Cybersecurity Basics','Git'] WHERE slug = 'information-technology';
UPDATE careers SET skills = ARRAY['Circuit Design','Embedded Systems','Signal Processing','VLSI','Communication Systems','C Programming'] WHERE slug = 'electronics-and-communication-engineering';
UPDATE careers SET skills = ARRAY['Circuit Analysis','Power Systems','Control Systems','Electrical Machines','AutoCAD Electrical','MATLAB'] WHERE slug = 'electrical-engineering';
UPDATE careers SET skills = ARRAY['AutoCAD','SolidWorks','Thermodynamics','Manufacturing Processes','Machine Design','GD&T'] WHERE slug = 'mechanical-engineering';
UPDATE careers SET skills = ARRAY['Aerodynamics','Aircraft Structures','Propulsion Systems','CAD/CAM','Flight Mechanics','MATLAB'] WHERE slug = 'aerospace-engineering';
UPDATE careers SET skills = ARRAY['AutoCAD','Structural Analysis','Surveying','Construction Management','STAAD Pro','Building Materials'] WHERE slug = 'civil-engineering';
UPDATE careers SET skills = ARRAY['Process Design','Thermodynamics','Fluid Mechanics','Plant Safety','Chemical Reaction Engineering','MATLAB'] WHERE slug = 'chemical-engineering';
UPDATE careers SET skills = ARRAY['Operations Research','Process Optimization','Lean Six Sigma','Supply Chain Management','ERP Systems','Statistics'] WHERE slug = 'industrial-engineering';
UPDATE careers SET skills = ARRAY['CNC Programming','CAD/CAM','Production Planning','Quality Control','Lean Manufacturing','Industrial Automation'] WHERE slug = 'manufacturing-engineering';
UPDATE careers SET skills = ARRAY['Materials Science','Metallurgical Processes','Corrosion Engineering','Heat Treatment','Quality Testing','Metallography'] WHERE slug = 'metallurgical-and-materials-engineering';
UPDATE careers SET skills = ARRAY['Mine Planning','Rock Mechanics','Mine Surveying','Mining Safety','Blasting Techniques','Mineral Processing'] WHERE slug = 'mining-engineering';
UPDATE careers SET skills = ARRAY['Reservoir Engineering','Drilling Engineering','Petroleum Geology','Well Testing','Production Engineering','Process Simulation'] WHERE slug = 'petroleum-engineering';
UPDATE careers SET skills = ARRAY['Medical Imaging','Biomaterials','Biomechanics','Signal Processing','Medical Device Design','Regulatory Standards'] WHERE slug = 'biomedical-engineering';
UPDATE careers SET skills = ARRAY['Molecular Biology','Genetic Engineering','Bioprocess Engineering','Cell Culture Techniques','Bioinformatics','Lab Research'] WHERE slug = 'biotechnology';
UPDATE careers SET skills = ARRAY['Environmental Impact Assessment','Water Treatment','Waste Management','Pollution Control','GIS','Environmental Regulations'] WHERE slug = 'environmental-engineering';

UPDATE careers SET skills = ARRAY['Classical Mechanics','Quantum Mechanics','Electromagnetism','Data Analysis','MATLAB','Scientific Research'] WHERE slug = 'physics';
UPDATE careers SET skills = ARRAY['Organic Chemistry','Inorganic Chemistry','Analytical Techniques','Spectroscopy','Lab Safety','Research Methodology'] WHERE slug = 'chemistry';
UPDATE careers SET skills = ARRAY['Statistics','Linear Algebra','Calculus','Mathematical Modelling','Python','Problem Solving'] WHERE slug = 'mathematics';
UPDATE careers SET skills = ARRAY['Statistical Modelling','Probability Theory','R Programming','Data Visualization','Survey Design','SQL'] WHERE slug = 'statistics';
UPDATE careers SET skills = ARRAY['Cell Biology','Genetics','Ecology','Microscopy','Research Methodology','Lab Techniques'] WHERE slug = 'biology';

UPDATE careers SET skills = ARRAY['Business Strategy','Financial Analysis','Marketing Management','Leadership','Operations Management','MS Excel'] WHERE slug = 'business-administration';
UPDATE careers SET skills = ARRAY['Financial Modelling','Corporate Finance','Investment Analysis','Risk Management','Accounting Principles','MS Excel'] WHERE slug = 'finance';
UPDATE careers SET skills = ARRAY['Financial Accounting','Taxation','Auditing','Bookkeeping','Tally','GST Compliance'] WHERE slug = 'accounting';
UPDATE careers SET skills = ARRAY['Digital Marketing','Market Research','Brand Management','Content Strategy','Social Media Marketing','Consumer Behaviour Analysis'] WHERE slug = 'marketing';
UPDATE careers SET skills = ARRAY['Recruitment & Talent Acquisition','Employee Relations','Performance Management','HR Analytics','Labour Law','Training & Development'] WHERE slug = 'human-resource-management';

UPDATE careers SET skills = ARRAY['Clinical Diagnosis','Patient Care','Medical Ethics','Pharmacology','Emergency Medicine','Medical Research'] WHERE slug = 'medicine';
UPDATE careers SET skills = ARRAY['Pharmacology','Pharmaceutics','Medicinal Chemistry','Drug Regulatory Affairs','Quality Control','Clinical Research'] WHERE slug = 'pharmacy';
UPDATE careers SET skills = ARRAY['Patient Care','Clinical Procedures','Medical Terminology','Emergency Response','Health Assessment','Nursing Ethics'] WHERE slug = 'nursing';
UPDATE careers SET skills = ARRAY['Musculoskeletal Assessment','Rehabilitation Techniques','Exercise Therapy','Electrotherapy','Patient Care','Anatomy & Physiology'] WHERE slug = 'physiotherapy';

UPDATE careers SET skills = ARRAY['Legal Research','Legal Drafting','Litigation','Contract Law','Constitutional Law','Legal Reasoning'] WHERE slug = 'law';
UPDATE careers SET skills = ARRAY['Public Policy Analysis','Governance','Administrative Law','Public Finance','Leadership','Report Writing'] WHERE slug = 'public-administration';

UPDATE careers SET skills = ARRAY['Clinical Assessment','Counselling Techniques','Research Methodology','Behavioural Analysis','Psychological Testing','Statistics'] WHERE slug = 'psychology';
UPDATE careers SET skills = ARRAY['Social Research Methods','Data Analysis','Community Engagement','Report Writing','Policy Analysis','Statistics'] WHERE slug = 'sociology';

UPDATE careers SET skills = ARRAY['AutoCAD','Building Design','SketchUp','Structural Understanding','Urban Planning','3D Visualization'] WHERE slug = 'architecture';
UPDATE careers SET skills = ARRAY['Design Thinking','Adobe Creative Suite','User Research','Prototyping','Typography','Visual Communication'] WHERE slug = 'design';

UPDATE careers SET skills = ARRAY['News Writing','Content Editing','Video Production','Digital Media','Research & Fact-Checking','Public Speaking'] WHERE slug = 'journalism-and-mass-communication';

UPDATE careers SET skills = ARRAY['Crop Science','Soil Science','Agricultural Economics','Irrigation Management','Farm Management','Plant Pathology'] WHERE slug = 'agriculture';
UPDATE careers SET skills = ARRAY['Forest Management','Wildlife Conservation','GIS & Remote Sensing','Silviculture','Environmental Impact Assessment','Biodiversity Studies'] WHERE slug = 'forestry';

UPDATE careers SET skills = ARRAY['Hotel Operations','Food & Beverage Management','Guest Relations','Event Management','Housekeeping Management','Revenue Management'] WHERE slug = 'hospitality-management';
UPDATE careers SET skills = ARRAY['Tour Planning & Operations','Destination Marketing','Customer Service','Travel Documentation','Event Coordination','Cultural Knowledge'] WHERE slug = 'tourism';

UPDATE careers SET skills = ARRAY['Exercise Physiology','Sports Biomechanics','Sports Nutrition','Strength & Conditioning','Injury Prevention','Performance Analysis'] WHERE slug = 'sports-science';

-- ---------------------------------------------------------------------
-- 3. Skills catalog + career_skills -- same derivation V24 used, scoped
--    naturally to whatever's in careers.skills (only the 42 rows above,
--    since V49 truncated the careers table down to just these).
-- ---------------------------------------------------------------------

INSERT INTO skills (slug, name)
SELECT DISTINCT ON (slug) slug, name
FROM (
    SELECT
        trim(both '-' from regexp_replace(lower(trim(s)), '[^a-z0-9]+', '-', 'g')) AS slug,
        trim(s) AS name
    FROM careers, unnest(skills) AS s
    WHERE trim(s) <> ''
) distinct_skills
ORDER BY slug, name
ON CONFLICT (slug) DO NOTHING;

INSERT INTO career_skills (career_slug, skill_slug)
SELECT DISTINCT
    c.slug,
    trim(both '-' from regexp_replace(lower(trim(s)), '[^a-z0-9]+', '-', 'g'))
FROM careers c, unnest(c.skills) AS s
WHERE trim(s) <> '';

-- ---------------------------------------------------------------------
-- 4. Industries / employers + career_industries. careers.top_recruiters
--    (what V25 originally unnested) was dropped in V41, so the source
--    data lives in a temp table here instead of a careers column.
-- ---------------------------------------------------------------------

-- Not ON COMMIT DROP: Flyway/psql may run each statement in its own
-- auto-committed transaction rather than the whole script in one, which
-- would drop the table before the next statement could see it. Dropped
-- explicitly below once it's no longer needed instead.
CREATE TEMP TABLE tmp_career_industries (career_slug VARCHAR(64), industry_name VARCHAR(160));

INSERT INTO tmp_career_industries (career_slug, industry_name) VALUES
('computer-science-and-engineering', 'TCS'), ('computer-science-and-engineering', 'Infosys'), ('computer-science-and-engineering', 'Wipro'), ('computer-science-and-engineering', 'Google'), ('computer-science-and-engineering', 'Microsoft'), ('computer-science-and-engineering', 'Amazon'),
('information-technology', 'TCS'), ('information-technology', 'Infosys'), ('information-technology', 'Cognizant'), ('information-technology', 'Accenture'), ('information-technology', 'IBM'), ('information-technology', 'Capgemini'),
('electronics-and-communication-engineering', 'Intel'), ('electronics-and-communication-engineering', 'Qualcomm'), ('electronics-and-communication-engineering', 'Texas Instruments'), ('electronics-and-communication-engineering', 'Samsung'), ('electronics-and-communication-engineering', 'Bharat Electronics Limited'), ('electronics-and-communication-engineering', 'Nokia'),
('electrical-engineering', 'Siemens'), ('electrical-engineering', 'ABB'), ('electrical-engineering', 'Larsen & Toubro'), ('electrical-engineering', 'Bharat Heavy Electricals Limited'), ('electrical-engineering', 'Tata Power'), ('electrical-engineering', 'Schneider Electric'),
('mechanical-engineering', 'Tata Motors'), ('mechanical-engineering', 'Mahindra & Mahindra'), ('mechanical-engineering', 'Larsen & Toubro'), ('mechanical-engineering', 'Maruti Suzuki'), ('mechanical-engineering', 'Bosch'), ('mechanical-engineering', 'Ashok Leyland'),
('aerospace-engineering', 'Hindustan Aeronautics Limited'), ('aerospace-engineering', 'Indian Space Research Organisation'), ('aerospace-engineering', 'Boeing'), ('aerospace-engineering', 'Airbus'), ('aerospace-engineering', 'Defence Research and Development Organisation'), ('aerospace-engineering', 'Tata Advanced Systems'),
('civil-engineering', 'L&T Construction'), ('civil-engineering', 'DLF'), ('civil-engineering', 'Shapoorji Pallonji'), ('civil-engineering', 'NBCC'), ('civil-engineering', 'Tata Projects'), ('civil-engineering', 'Godrej Properties'),
('chemical-engineering', 'Reliance Industries'), ('chemical-engineering', 'Indian Oil Corporation'), ('chemical-engineering', 'ONGC'), ('chemical-engineering', 'BASF'), ('chemical-engineering', 'Tata Chemicals'), ('chemical-engineering', 'Dr. Reddy''s Laboratories'),
('industrial-engineering', 'Toyota'), ('industrial-engineering', 'Tata Motors'), ('industrial-engineering', 'Amazon'), ('industrial-engineering', 'Flipkart'), ('industrial-engineering', 'Bosch'), ('industrial-engineering', 'Larsen & Toubro'),
('manufacturing-engineering', 'Tata Motors'), ('manufacturing-engineering', 'Maruti Suzuki'), ('manufacturing-engineering', 'Bajaj Auto'), ('manufacturing-engineering', 'Godrej & Boyce'), ('manufacturing-engineering', 'Larsen & Toubro'), ('manufacturing-engineering', 'Bharat Forge'),
('metallurgical-and-materials-engineering', 'Tata Steel'), ('metallurgical-and-materials-engineering', 'JSW Steel'), ('metallurgical-and-materials-engineering', 'Steel Authority of India'), ('metallurgical-and-materials-engineering', 'Hindalco Industries'), ('metallurgical-and-materials-engineering', 'Vedanta'), ('metallurgical-and-materials-engineering', 'Jindal Steel & Power'),
('mining-engineering', 'Coal India Limited'), ('mining-engineering', 'Hindustan Zinc'), ('mining-engineering', 'NMDC'), ('mining-engineering', 'Vedanta'), ('mining-engineering', 'Steel Authority of India'), ('mining-engineering', 'Adani Enterprises'),
('petroleum-engineering', 'ONGC'), ('petroleum-engineering', 'Indian Oil Corporation'), ('petroleum-engineering', 'Reliance Industries'), ('petroleum-engineering', 'Cairn Oil & Gas'), ('petroleum-engineering', 'Schlumberger'), ('petroleum-engineering', 'Gas Authority of India Limited'),
('biomedical-engineering', 'Philips Healthcare'), ('biomedical-engineering', 'GE Healthcare'), ('biomedical-engineering', 'Siemens Healthineers'), ('biomedical-engineering', 'Wipro GE Healthcare'), ('biomedical-engineering', 'Medtronic'), ('biomedical-engineering', 'Johnson & Johnson'),
('biotechnology', 'Biocon'), ('biotechnology', 'Serum Institute of India'), ('biotechnology', 'Dr. Reddy''s Laboratories'), ('biotechnology', 'Bharat Biotech'), ('biotechnology', 'Cipla'), ('biotechnology', 'Piramal Pharma'),
('environmental-engineering', 'Central Pollution Control Board'), ('environmental-engineering', 'Tata Consulting Engineers'), ('environmental-engineering', 'Ramky Enviro Engineers'), ('environmental-engineering', 'Larsen & Toubro'), ('environmental-engineering', 'ERM India'), ('environmental-engineering', 'Ministry of Environment, Forest and Climate Change'),
('physics', 'Indian Space Research Organisation'), ('physics', 'Bhabha Atomic Research Centre'), ('physics', 'Tata Institute of Fundamental Research'), ('physics', 'Defence Research and Development Organisation'), ('physics', 'Council of Scientific and Industrial Research'), ('physics', 'Indian Institutes of Technology'),
('chemistry', 'Council of Scientific and Industrial Research'), ('chemistry', 'Dr. Reddy''s Laboratories'), ('chemistry', 'Sun Pharmaceutical'), ('chemistry', 'BASF'), ('chemistry', 'Tata Chemicals'), ('chemistry', 'Reliance Industries'),
('mathematics', 'Council of Scientific and Industrial Research'), ('mathematics', 'Indian Statistical Institute'), ('mathematics', 'TCS'), ('mathematics', 'Reserve Bank of India'), ('mathematics', 'Indian Institutes of Technology'), ('mathematics', 'Fractal Analytics'),
('statistics', 'Indian Statistical Institute'), ('statistics', 'National Sample Survey Office'), ('statistics', 'Reserve Bank of India'), ('statistics', 'Nielsen'), ('statistics', 'Fractal Analytics'), ('statistics', 'TCS'),
('biology', 'Council of Scientific and Industrial Research'), ('biology', 'Indian Council of Agricultural Research'), ('biology', 'Biocon'), ('biology', 'Serum Institute of India'), ('biology', 'Wildlife Institute of India'), ('biology', 'Department of Biotechnology'),
('business-administration', 'Tata Group'), ('business-administration', 'Reliance Industries'), ('business-administration', 'McKinsey & Company'), ('business-administration', 'Deloitte'), ('business-administration', 'Hindustan Unilever'), ('business-administration', 'ICICI Bank'),
('finance', 'HDFC Bank'), ('finance', 'ICICI Bank'), ('finance', 'Goldman Sachs'), ('finance', 'JPMorgan Chase'), ('finance', 'Deloitte'), ('finance', 'State Bank of India'),
('accounting', 'Deloitte'), ('accounting', 'KPMG'), ('accounting', 'Ernst & Young'), ('accounting', 'PricewaterhouseCoopers'), ('accounting', 'TCS'), ('accounting', 'ICICI Bank'),
('marketing', 'Hindustan Unilever'), ('marketing', 'Procter & Gamble'), ('marketing', 'ITC Limited'), ('marketing', 'Asian Paints'), ('marketing', 'Ogilvy'), ('marketing', 'Google'),
('human-resource-management', 'TCS'), ('human-resource-management', 'Infosys'), ('human-resource-management', 'Hindustan Unilever'), ('human-resource-management', 'Accenture'), ('human-resource-management', 'Wipro'), ('human-resource-management', 'ICICI Bank'),
('medicine', 'All India Institute of Medical Sciences'), ('medicine', 'Apollo Hospitals'), ('medicine', 'Fortis Healthcare'), ('medicine', 'Max Healthcare'), ('medicine', 'Manipal Hospitals'), ('medicine', 'Government Medical Colleges'),
('pharmacy', 'Sun Pharmaceutical'), ('pharmacy', 'Cipla'), ('pharmacy', 'Dr. Reddy''s Laboratories'), ('pharmacy', 'Apollo Pharmacy'), ('pharmacy', 'Lupin'), ('pharmacy', 'MedPlus'),
('nursing', 'All India Institute of Medical Sciences'), ('nursing', 'Apollo Hospitals'), ('nursing', 'Fortis Healthcare'), ('nursing', 'Max Healthcare'), ('nursing', 'Government Hospitals'), ('nursing', 'Manipal Hospitals'),
('physiotherapy', 'Apollo Hospitals'), ('physiotherapy', 'Fortis Healthcare'), ('physiotherapy', 'Max Healthcare'), ('physiotherapy', 'Manipal Hospitals'), ('physiotherapy', 'Indian Spinal Injuries Centre'), ('physiotherapy', 'Government Hospitals'),
('law', 'Cyril Amarchand Mangaldas'), ('law', 'AZB & Partners'), ('law', 'Khaitan & Co'), ('law', 'Supreme Court of India'), ('law', 'Trilegal'), ('law', 'Luthra & Luthra Law Offices'),
('public-administration', 'Government of India'), ('public-administration', 'State Civil Services'), ('public-administration', 'United Nations Development Programme'), ('public-administration', 'NITI Aayog'), ('public-administration', 'Tata Institute of Social Sciences'), ('public-administration', 'Indian Institute of Public Administration'),
('psychology', 'Fortis Healthcare'), ('psychology', 'Apollo Hospitals'), ('psychology', 'NIMHANS'), ('psychology', 'Tata Institute of Social Sciences'), ('psychology', 'Practo'), ('psychology', 'Government Hospitals'),
('sociology', 'Tata Institute of Social Sciences'), ('sociology', 'United Nations Development Programme'), ('sociology', 'NITI Aayog'), ('sociology', 'UNICEF'), ('sociology', 'Centre for the Study of Developing Societies'), ('sociology', 'Government of India'),
('architecture', 'L&T Construction'), ('architecture', 'DLF'), ('architecture', 'Godrej Properties'), ('architecture', 'HCP Design, Planning and Management'), ('architecture', 'Shapoorji Pallonji'), ('architecture', 'CP Kukreja Architects'),
('design', 'Tata Elxsi'), ('design', 'Infosys'), ('design', 'Wipro'), ('design', 'Godrej Design Lab'), ('design', 'Titan Company'), ('design', 'Flipkart'),
('journalism-and-mass-communication', 'The Times of India'), ('journalism-and-mass-communication', 'NDTV'), ('journalism-and-mass-communication', 'India Today Group'), ('journalism-and-mass-communication', 'Hindustan Times'), ('journalism-and-mass-communication', 'Press Trust of India'), ('journalism-and-mass-communication', 'Network18'),
('agriculture', 'Indian Council of Agricultural Research'), ('agriculture', 'National Bank for Agriculture and Rural Development'), ('agriculture', 'ITC Limited'), ('agriculture', 'Rallis India'), ('agriculture', 'UPL Limited'), ('agriculture', 'Government Agriculture Departments'),
('forestry', 'Indian Forest Service'), ('forestry', 'Wildlife Institute of India'), ('forestry', 'Ministry of Environment, Forest and Climate Change'), ('forestry', 'State Forest Departments'), ('forestry', 'World Wide Fund for Nature India'), ('forestry', 'Forest Survey of India'),
('hospitality-management', 'Taj Hotels'), ('hospitality-management', 'Oberoi Hotels & Resorts'), ('hospitality-management', 'ITC Hotels'), ('hospitality-management', 'Marriott International'), ('hospitality-management', 'Hyatt Hotels'), ('hospitality-management', 'Lemon Tree Hotels'),
('tourism', 'Thomas Cook India'), ('tourism', 'SOTC Travel'), ('tourism', 'MakeMyTrip'), ('tourism', 'Ministry of Tourism'), ('tourism', 'Cox & Kings'), ('tourism', 'Yatra.com'),
('sports-science', 'Sports Authority of India'), ('sports-science', 'Indian Premier League'), ('sports-science', 'National Institute of Sports'), ('sports-science', 'JSW Sports'), ('sports-science', 'Reliance Foundation Young Champs'), ('sports-science', 'Table Tennis Federation of India');

INSERT INTO industries (slug, name)
SELECT DISTINCT ON (slug) slug, name
FROM (
    SELECT
        trim(both '-' from regexp_replace(lower(trim(industry_name)), '[^a-z0-9]+', '-', 'g')) AS slug,
        trim(industry_name) AS name
    FROM tmp_career_industries
) distinct_industries
ORDER BY slug, name
ON CONFLICT (slug) DO NOTHING;

INSERT INTO career_industries (career_slug, industry_slug)
SELECT DISTINCT
    career_slug,
    trim(both '-' from regexp_replace(lower(trim(industry_name)), '[^a-z0-9]+', '-', 'g'))
FROM tmp_career_industries;

DROP TABLE tmp_career_industries;

-- ---------------------------------------------------------------------
-- 5. Exams -- career_exams + its reverse junction exam_careers, both
--    against the existing V6 exam catalog. Both junction tables were
--    fully TRUNCATEd by V49, so every career_slug / exam_slug key starts
--    a fresh, gap-free sort_order sequence at 0 here.
-- ---------------------------------------------------------------------

CREATE TEMP TABLE tmp_career_exams (career_slug VARCHAR(64), exam_slug VARCHAR(64), ord SERIAL);

INSERT INTO tmp_career_exams (career_slug, exam_slug) VALUES
-- Engineering & Technology: JEE Main / JEE Advanced / GATE are a clean,
-- direct match for every engineering discipline (precedent: V12/V13's
-- original data linked exactly these three to every new engineering
-- career it added). ISRO ICRB and RRB JE are added only where the exam's
-- own V6 description names that discipline by name; IBPS SO (IT) only
-- where its description names it.
('computer-science-and-engineering', 'jee-main'), ('computer-science-and-engineering', 'jee-advanced'), ('computer-science-and-engineering', 'gate'), ('computer-science-and-engineering', 'isro-icrb'), ('computer-science-and-engineering', 'ibps-so-it'),
('information-technology', 'jee-main'), ('information-technology', 'jee-advanced'), ('information-technology', 'gate'), ('information-technology', 'ibps-so-it'),
('electronics-and-communication-engineering', 'jee-main'), ('electronics-and-communication-engineering', 'jee-advanced'), ('electronics-and-communication-engineering', 'gate'), ('electronics-and-communication-engineering', 'isro-icrb'), ('electronics-and-communication-engineering', 'rrb-je'),
('electrical-engineering', 'jee-main'), ('electrical-engineering', 'jee-advanced'), ('electrical-engineering', 'gate'), ('electrical-engineering', 'isro-icrb'), ('electrical-engineering', 'rrb-je'),
('mechanical-engineering', 'jee-main'), ('mechanical-engineering', 'jee-advanced'), ('mechanical-engineering', 'gate'), ('mechanical-engineering', 'isro-icrb'), ('mechanical-engineering', 'rrb-je'),
('aerospace-engineering', 'jee-main'), ('aerospace-engineering', 'jee-advanced'), ('aerospace-engineering', 'gate'),
('civil-engineering', 'jee-main'), ('civil-engineering', 'jee-advanced'), ('civil-engineering', 'gate'), ('civil-engineering', 'rrb-je'),
('chemical-engineering', 'jee-main'), ('chemical-engineering', 'jee-advanced'), ('chemical-engineering', 'gate'),
('industrial-engineering', 'jee-main'), ('industrial-engineering', 'jee-advanced'), ('industrial-engineering', 'gate'),
('manufacturing-engineering', 'jee-main'), ('manufacturing-engineering', 'jee-advanced'), ('manufacturing-engineering', 'gate'),
('metallurgical-and-materials-engineering', 'jee-main'), ('metallurgical-and-materials-engineering', 'jee-advanced'), ('metallurgical-and-materials-engineering', 'gate'),
('mining-engineering', 'jee-main'), ('mining-engineering', 'jee-advanced'), ('mining-engineering', 'gate'),
('petroleum-engineering', 'jee-main'), ('petroleum-engineering', 'jee-advanced'), ('petroleum-engineering', 'gate'),
('biomedical-engineering', 'jee-main'), ('biomedical-engineering', 'jee-advanced'), ('biomedical-engineering', 'gate'),
('biotechnology', 'jee-main'), ('biotechnology', 'jee-advanced'), ('biotechnology', 'gate'), ('biotechnology', 'csir-net'),
('environmental-engineering', 'jee-main'), ('environmental-engineering', 'jee-advanced'), ('environmental-engineering', 'gate'),
-- Science & Research: CUET for undergraduate entry, CSIR-NET/UGC-NET for
-- research/lectureship eligibility, GATE where the discipline has its own
-- well-known GATE paper.
('physics', 'cuet'), ('physics', 'csir-net'), ('physics', 'ugc-net'), ('physics', 'gate'),
('chemistry', 'cuet'), ('chemistry', 'csir-net'), ('chemistry', 'ugc-net'), ('chemistry', 'gate'),
('mathematics', 'cuet'), ('mathematics', 'csir-net'), ('mathematics', 'ugc-net'), ('mathematics', 'gate'),
('statistics', 'cuet'), ('statistics', 'ugc-net'),
('biology', 'cuet'), ('biology', 'csir-net'), ('biology', 'ugc-net'),
-- Management & Business
('business-administration', 'cat'), ('business-administration', 'cuet'),
('finance', 'cat'), ('finance', 'ca-foundation'), ('finance', 'cuet'),
('accounting', 'ca-foundation'), ('accounting', 'cs-foundation'), ('accounting', 'cuet'),
('marketing', 'cat'), ('marketing', 'cuet'),
('human-resource-management', 'cat'), ('human-resource-management', 'cuet'),
-- Medical & Healthcare
('medicine', 'neet-ug'), ('medicine', 'neet-pg'),
('nursing', 'neet-ug'),
-- Law
('law', 'clat'), ('law', 'judicial-services-exam'),
('public-administration', 'upsc-cse'), ('public-administration', 'cuet'),
-- Arts & Humanities
('psychology', 'cuet'), ('psychology', 'ugc-net'),
('sociology', 'cuet'), ('sociology', 'ugc-net'),
-- Design & Creative
('architecture', 'jee-main'), ('architecture', 'uceed'), ('architecture', 'cuet'),
('design', 'uceed'), ('design', 'nid-dat'), ('design', 'cuet'),
-- Media & Communication
('journalism-and-mass-communication', 'cuet'),
-- Agriculture
('agriculture', 'icar-aieea'),
('forestry', 'icar-aieea'),
-- Hospitality & Tourism
('hospitality-management', 'nchmct-jee');
-- Left unmapped, no clean match in the V6 catalog: pharmacy, physiotherapy,
-- tourism, sports-science.

INSERT INTO career_exams (career_slug, exam_slug, sort_order)
SELECT career_slug, exam_slug, (ROW_NUMBER() OVER (PARTITION BY career_slug ORDER BY ord))::int - 1
FROM tmp_career_exams;

INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT exam_slug, career_slug, (ROW_NUMBER() OVER (PARTITION BY exam_slug ORDER BY ord))::int - 1
FROM tmp_career_exams;

DROP TABLE tmp_career_exams;
