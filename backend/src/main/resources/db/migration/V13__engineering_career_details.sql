-- Adds richer per-career detail for the 8 Engineering & Technology careers
-- added in V12 (Chemical, Aerospace, Biomedical, Environmental, Marine,
-- Mining, Mechatronics and Robotics Engineer): a longer, more concrete
-- description, a short list of companies that commonly hire for the role,
-- a salary breakdown by experience level, and links to real colleges known
-- for that specialization.
--
-- The first three are new columns on `careers` (nullable / defaulted so the
-- other 47 existing careers are unaffected and keep rendering exactly as
-- before -- the frontend only shows these sections when populated). The
-- college links are a new `career_colleges` junction table, since careers
-- previously had no direct link to colleges at all (only courses and exams
-- did). This intentionally does NOT backfill top recruiters / salary
-- breakdown / colleges for the other 47 careers -- that's a separate,
-- larger effort the user didn't ask for here.

ALTER TABLE careers ADD COLUMN top_recruiters TEXT[] NOT NULL DEFAULT '{}';
ALTER TABLE careers ADD COLUMN salary_entry_level VARCHAR(64);
ALTER TABLE careers ADD COLUMN salary_mid_level VARCHAR(64);
ALTER TABLE careers ADD COLUMN salary_senior_level VARCHAR(64);

CREATE TABLE career_colleges (
    career_slug  VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, college_slug)
);

-- ---------------------------------------------------------------------
-- Two new colleges: neither Marine Engineering nor Mining Engineering is
-- well represented by the existing 17 curated colleges (all generic IITs /
-- NITs), so these are the real, specific institutes for those branches
-- rather than a forced fit.
-- ---------------------------------------------------------------------

INSERT INTO colleges (slug, name, location, type, established, tags, description) VALUES ('imu-chennai', 'Indian Maritime University, Chennai', 'Chennai, Tamil Nadu', 'University', 2008, ARRAY['Marine Engineering','Naval Architecture','Maritime'], 'India''s central maritime university, offering marine engineering and naval architecture programs and the primary route into merchant navy careers via IMU-CET.');
INSERT INTO colleges (slug, name, location, type, established, tags, description) VALUES ('iit-ism-dhanbad', 'IIT (ISM) Dhanbad', 'Dhanbad, Jharkhand', 'IIT', 1926, ARRAY['Mining Engineering','Earth Sciences','Engineering'], 'India''s oldest and most prominent institute for mining engineering and earth sciences, now part of the IIT system.');

INSERT INTO college_courses (college_slug, course_slug, sort_order) VALUES ('imu-chennai', 'btech-marine', 0) ON CONFLICT DO NOTHING;
INSERT INTO college_exams (college_slug, exam_slug, sort_order) VALUES ('imu-chennai', 'imu-cet', 0) ON CONFLICT DO NOTHING;
INSERT INTO college_courses (college_slug, course_slug, sort_order) VALUES ('iit-ism-dhanbad', 'btech-mining', 0) ON CONFLICT DO NOTHING;
INSERT INTO college_exams (college_slug, exam_slug, sort_order) VALUES ('iit-ism-dhanbad', 'jee-advanced', 0) ON CONFLICT DO NOTHING;
INSERT INTO college_exams (college_slug, exam_slug, sort_order) VALUES ('iit-ism-dhanbad', 'gate', 1) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- career_colleges links (existing IITs/NITs for the branches they already
-- cover well, the 2 new colleges above for the branches they don't)
-- ---------------------------------------------------------------------

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('chemical-engineer', 'iit-bombay', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('chemical-engineer', 'iit-delhi', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('aerospace-engineer', 'iit-bombay', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('aerospace-engineer', 'iit-madras', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('biomedical-engineer', 'iit-madras', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('biomedical-engineer', 'iit-bombay', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('environmental-engineer', 'iit-delhi', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('environmental-engineer', 'iit-bombay', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('marine-engineer', 'imu-chennai', 0) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('mining-engineer', 'iit-ism-dhanbad', 0) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('mechatronics-engineer', 'iit-bombay', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('mechatronics-engineer', 'nit-trichy', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('robotics-engineer', 'iit-bombay', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES ('robotics-engineer', 'iit-madras', 1) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- Richer descriptions, top recruiters and salary-by-experience breakdown
-- for the 8 careers. The original one-paragraph description is expanded
-- with what the day-to-day work is like and who the role suits; the salary
-- breakdown splits the existing overall salary_range into three stages.
-- ---------------------------------------------------------------------

UPDATE careers SET
  description = 'Chemical Engineers design and run the large-scale processes behind fuels, plastics, fertilisers and pharmaceuticals — turning raw materials into everyday products safely and efficiently. Day to day, the work splits between plant floors and control rooms: monitoring reactors, troubleshooting process upsets, and using process simulation software to improve yield or cut waste. It suits people who enjoy applied chemistry and don''t mind shift work at a refinery or plant early on, in exchange for a well-paid, resilient path once experienced — process and plant-safety expertise stays in demand across oil & gas, FMCG and pharma manufacturing alike.',
  top_recruiters = ARRAY['Reliance Industries','Indian Oil Corporation (IOCL)','Tata Chemicals','BASF India','Dr. Reddy''s Laboratories'],
  salary_entry_level = '₹4.5L – ₹7L / year',
  salary_mid_level = '₹8L – ₹14L / year',
  salary_senior_level = '₹15L – ₹20L+ / year'
WHERE slug = 'chemical-engineer';

UPDATE careers SET
  description = 'Aerospace Engineers design, build and test the aircraft, satellites and launch vehicles that fly through the atmosphere and into space, working across agencies like ISRO and HAL and private aerospace firms. The work is highly specialised — structures, propulsion, avionics and aerodynamics are each their own sub-discipline — and most serious roles sit with government/PSU giants or a handful of private manufacturers, so opportunities are concentrated in a few cities (Bengaluru, Hyderabad, Thiruvananthapuram) rather than spread everywhere. It rewards patience and precision, since development cycles are long and safety margins unforgiving, but the field is entering a genuine growth phase as India''s private space sector expands.',
  top_recruiters = ARRAY['Hindustan Aeronautics Limited (HAL)','ISRO','DRDO','Boeing India','Airbus India'],
  salary_entry_level = '₹5L – ₹8L / year',
  salary_mid_level = '₹9L – ₹16L / year',
  salary_senior_level = '₹17L – ₹22L+ / year'
WHERE slug = 'aerospace-engineer';

UPDATE careers SET
  description = 'Biomedical Engineers apply engineering to healthcare — designing the imaging systems, diagnostic devices, prosthetics and hospital equipment that clinicians rely on every day. Much of the role sits at the intersection of hardware design, signal processing and regulatory compliance, since every device has to clear certification before it reaches a hospital, so attention to documentation and standards matters as much as the engineering itself. It suits people who want engineering work with a visible human impact without going through medical school themselves, in a field that''s still small in India but growing quickly as domestic med-tech manufacturing expands.',
  top_recruiters = ARRAY['Philips Healthcare','GE Healthcare','Siemens Healthineers','Medtronic','Trivitron Healthcare'],
  salary_entry_level = '₹4L – ₹6L / year',
  salary_mid_level = '₹7L – ₹11L / year',
  salary_senior_level = '₹12L – ₹16L+ / year'
WHERE slug = 'biomedical-engineer';

UPDATE careers SET
  description = 'Environmental Engineers design the water treatment plants, waste management systems and pollution-control technology that keep industries compliant and cities liveable. The work ranges from hands-on site assessments and treatment-plant design to environmental impact reports and regulatory liaison, often for infrastructure, power or manufacturing clients who need to meet pollution-control norms. It suits people motivated by sustainability who still want a core engineering role rather than a purely policy one, and demand is rising steadily as environmental regulation tightens and ESG reporting becomes standard for large companies.',
  top_recruiters = ARRAY['NTPC','Larsen & Toubro (L&T)','Ramboll','ERM India','State Pollution Control Boards'],
  salary_entry_level = '₹4L – ₹6L / year',
  salary_mid_level = '₹7L – ₹10L / year',
  salary_senior_level = '₹11L – ₹15L+ / year'
WHERE slug = 'environmental-engineer';

UPDATE careers SET
  description = 'Marine Engineers design and maintain the propulsion, power and control systems aboard ships and offshore platforms — a path that can include both sailing roles at sea and shore-based technical careers. Sailing years mean long stints away from home, typically four to eight months at a stretch, in exchange for tax-free income and fast pay growth, and many engineers move into shore-based technical superintendent or surveyor roles once they''ve built enough sea time. It suits people comfortable with an unconventional lifestyle and physically demanding shifts early on, trading time on land for a genuinely global, high-paying trade.',
  top_recruiters = ARRAY['Shipping Corporation of India (SCI)','Maersk','Anglo-Eastern Ship Management','Great Eastern Shipping','MSC'],
  salary_entry_level = '₹5L – ₹9L / year (+ sailing allowances)',
  salary_mid_level = '₹10L – ₹18L / year',
  salary_senior_level = '₹19L – ₹25L+ / year'
WHERE slug = 'marine-engineer';

UPDATE careers SET
  description = 'Mining Engineers plan and supervise how minerals, coal and metals are safely and efficiently extracted from the earth, balancing output, safety and environmental impact. Most roles are based on-site at mines, often in remote locations, and combine underground or open-pit planning with strict safety compliance — mine accidents are heavily regulated, so safety record matters as much as production targets. It suits people who don''t mind a site-based, sometimes remote posting in exchange for strong PSU and private-sector pay, with steady demand tied to India''s ongoing coal, metal and mineral output.',
  top_recruiters = ARRAY['Coal India Limited (CIL)','Vedanta','Hindustan Zinc','NMDC','Tata Steel'],
  salary_entry_level = '₹5L – ₹7L / year',
  salary_mid_level = '₹8L – ₹13L / year',
  salary_senior_level = '₹14L – ₹18L+ / year'
WHERE slug = 'mining-engineer';

UPDATE careers SET
  description = 'Mechatronics Engineers blend mechanical, electronics and software skills to design automated systems — from factory robots and smart appliances to self-driving hardware. The role sits squarely at the intersection of three disciplines, so the day-to-day mixes CAD and hardware design with PLC programming and sensor integration, typically inside a manufacturing or automation team. It suits people who''d rather not specialise narrowly into just mechanical or just electronics, and demand is climbing fast as Indian manufacturing automates — this is one of the more future-proof core-engineering paths right now.',
  top_recruiters = ARRAY['Bosch','Siemens','ABB','Tata Motors','Larsen & Toubro (L&T)'],
  salary_entry_level = '₹4.5L – ₹7L / year',
  salary_mid_level = '₹8L – ₹14L / year',
  salary_senior_level = '₹15L – ₹20L+ / year'
WHERE slug = 'mechatronics-engineer';

UPDATE careers SET
  description = 'Robotics Engineers design and program the robots and autonomous machines used in manufacturing, warehouses, healthcare and defence, combining mechanical design with AI-driven control software. Expect heavy use of tools like ROS, computer vision and simulation environments, plus real hardware debugging when a robot doesn''t behave the way its code says it should. It''s one of the highest-paying and fastest-growing corners of core engineering right now, driven by warehouse automation and manufacturing robotics — but it also rewards a genuine software/AI skillset on top of mechanical fundamentals, more so than a traditional mechanical or electronics role.',
  top_recruiters = ARRAY['Bosch','Addverb Technologies','Grey Orange','Yaskawa India','Tata Elxsi'],
  salary_entry_level = '₹5L – ₹9L / year',
  salary_mid_level = '₹10L – ₹18L / year',
  salary_senior_level = '₹19L – ₹28L+ / year'
WHERE slug = 'robotics-engineer';
