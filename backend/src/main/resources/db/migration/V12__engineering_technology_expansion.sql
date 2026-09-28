-- Fills gaps in the "Engineering & Technology" category against a fuller
-- industry taxonomy (Chemical & Materials, Aerospace & Defence,
-- Biotechnology & Biomedical, Energy & Environment, Marine & Ocean, Mining &
-- Earth Sciences, and the Mechatronics/Robotics corner of Emerging Tech).
-- Before this migration, only 4 careers existed under engineering-technology
-- (Mechanical, Civil, Electrical, Electronics) — the Computing & IT branch
-- of that taxonomy is already covered separately under it-software /
-- emerging-careers (Software Engineer, Data Scientist, Cybersecurity
-- Analyst, AI/ML Engineer), so it isn't duplicated here.
--
-- This intentionally adds one career per genuinely-missing branch rather
-- than one row per leaf item in the taxonomy (e.g. "VLSI", "Quantum",
-- "Photonics", "AR/VR" are academic specializations, not distinct job
-- roles) -- consistent with how the existing catalog already represents
-- roles like Software Engineer or Electronics Engineer as a single career
-- that folds in several sub-skills, rather than splitting per specialization.
--
-- As with V11, this is a NEW migration rather than an edit to
-- backend/seed-json/careers.json / courses.json / exams.json: those JSON
-- files are regenerated wholesale into V4/V5/V6 by
-- backend/scripts/generate_seed_sql.py, so new content that must coexist
-- with V12 has to be hand-written SQL here instead.

-- ---------------------------------------------------------------------
-- New careers
-- ---------------------------------------------------------------------

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('chemical-engineer', 'Chemical Engineer', 'engineering-technology', 'Process Design · Petrochemicals · Materials', 'Stable', 'B.Tech / B.E in Chemical Engineering', ARRAY['Process Design','Thermodynamics','Plant Safety','Process Simulation (Aspen)'], 'Designing and operating the processes that turn raw materials into fuels, chemicals, plastics and pharmaceuticals', '₹4.5L – ₹20L / year', ARRAY['Graduate Engineer Trainee','Process Engineer','Senior Process Engineer','Plant Manager','Technical Director'], 'flask', 'Chemical Engineers design and run the large-scale processes behind fuels, plastics, fertilisers and pharmaceuticals — turning raw materials into everyday products safely and efficiently.', 4);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('aerospace-engineer', 'Aerospace Engineer', 'engineering-technology', 'Aircraft · Spacecraft · Propulsion', 'Niche', 'B.Tech / B.E in Aerospace or Aeronautical Engineering', ARRAY['Aerodynamics','CAD (CATIA)','Propulsion Systems','Flight Mechanics'], 'Designing and testing aircraft, spacecraft, satellites and their propulsion systems', '₹5L – ₹22L / year', ARRAY['Graduate Engineer Trainee','Design Engineer','Senior Engineer','Lead Engineer','Chief Engineer'], 'plane', 'Aerospace Engineers design, build and test the aircraft, satellites and launch vehicles that fly through the atmosphere and into space, working across agencies like ISRO and HAL and private aerospace firms.', 5);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('biomedical-engineer', 'Biomedical Engineer', 'engineering-technology', 'Medical Devices · Diagnostics · Healthcare Tech', 'Emerging', 'B.Tech in Biomedical Engineering', ARRAY['Medical Device Design','Biomaterials','Signal Processing','Regulatory Standards'], 'Designing medical devices, diagnostic equipment and healthcare technology used in hospitals and clinics', '₹4L – ₹16L / year', ARRAY['Graduate Engineer Trainee','R&D Engineer','Senior Biomedical Engineer','Product Lead','R&D Manager'], 'pulse', 'Biomedical Engineers apply engineering to healthcare — designing the imaging systems, diagnostic devices, prosthetics and hospital equipment that clinicians rely on every day.', 6);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('environmental-engineer', 'Environmental Engineer', 'engineering-technology', 'Pollution Control · Water Systems · Sustainability', 'Growing', 'B.Tech / B.E in Environmental Engineering', ARRAY['Water Treatment','Environmental Impact Assessment','Waste Management','Regulatory Compliance'], 'Designing systems to treat water and waste, control pollution and reduce industrial environmental impact', '₹4L – ₹15L / year', ARRAY['Graduate Engineer Trainee','Environmental Engineer','Senior Consultant','Project Manager','Sustainability Head'], 'leaf', 'Environmental Engineers design the water treatment plants, waste management systems and pollution-control technology that keep industries compliant and cities liveable.', 7);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('marine-engineer', 'Marine Engineer', 'engineering-technology', 'Ships · Offshore Systems · Naval Architecture', 'Stable', 'B.Tech / B.E in Marine Engineering or Naval Architecture (via IMU-CET)', ARRAY['Ship Systems','Naval Architecture','Marine Propulsion','Offshore Engineering'], 'Designing, building and maintaining the engines, hulls and systems of ships and offshore platforms', '₹5L – ₹25L / year (higher with sailing allowances)', ARRAY['Graduate Marine Engineer','4th/3rd Engineer (Sailing)','2nd Engineer','Chief Engineer','Shore-based Technical Superintendent'], 'ship', 'Marine Engineers design and maintain the propulsion, power and control systems aboard ships and offshore platforms — a path that can include both sailing roles at sea and shore-based technical careers.', 8);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('mining-engineer', 'Mining Engineer', 'engineering-technology', 'Mineral Extraction · Mine Planning · Safety', 'Stable', 'B.Tech / B.E in Mining Engineering', ARRAY['Mine Planning','Geotechnical Analysis','Mine Safety','Surveying'], 'Planning and overseeing the safe, efficient extraction of coal, metals and minerals from mines', '₹5L – ₹18L / year', ARRAY['Graduate Engineer Trainee','Mining Engineer','Senior Mine Planner','Mine Manager','General Manager'], 'pickaxe', 'Mining Engineers plan and supervise how minerals, coal and metals are safely and efficiently extracted from the earth, balancing output, safety and environmental impact.', 9);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('mechatronics-engineer', 'Mechatronics Engineer', 'engineering-technology', 'Automation · Robotics · Smart Systems', 'High Demand', 'B.Tech / B.E in Mechatronics Engineering', ARRAY['Automation & PLC','Sensors & Actuators','Embedded Systems','Robotics Fundamentals'], 'Designing automated systems and smart machines that combine mechanical, electronic and software components', '₹4.5L – ₹20L / year', ARRAY['Graduate Engineer Trainee','Automation Engineer','Senior Mechatronics Engineer','Automation Lead','Engineering Manager'], 'switch', 'Mechatronics Engineers blend mechanical, electronics and software skills to design automated systems — from factory robots and smart appliances to self-driving hardware.', 10);

INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, typical_work, salary_range, growth_path, icon, description, sort_order) VALUES ('robotics-engineer', 'Robotics Engineer', 'engineering-technology', 'Robots · Automation · AI-Driven Machines', 'High Demand', 'B.Tech in Robotics & Automation, or Mechatronics with a robotics focus', ARRAY['Robot Kinematics','ROS','Computer Vision','Control Systems'], 'Designing and programming robots and autonomous machines for manufacturing, logistics and defence', '₹5L – ₹28L / year', ARRAY['Robotics Engineer','Senior Robotics Engineer','Robotics Team Lead','Principal Engineer','Head of Robotics'], 'robot', 'Robotics Engineers design and program the robots and autonomous machines used in manufacturing, warehouses, healthcare and defence, combining mechanical design with AI-driven control software.', 11);

-- ---------------------------------------------------------------------
-- New courses (no existing course covered any of these branches)
-- ---------------------------------------------------------------------

INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-chemical', 'B.Tech Chemical Engineering', 'Undergraduate', '4 years', 'Covers process design, thermodynamics, reaction engineering and plant safety.', '12th with PCM + JEE Main/Advanced', 'flask');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-aerospace', 'B.Tech Aerospace Engineering', 'Undergraduate', '4 years', 'Covers aerodynamics, propulsion, structures and flight mechanics for aircraft and spacecraft.', '12th with PCM + JEE Main/Advanced', 'plane');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-biomedical', 'B.Tech Biomedical Engineering', 'Undergraduate', '4 years', 'Covers medical device design, biomaterials, signal processing and healthcare technology.', '12th with PCM/PCB + JEE Main or institute entrance', 'pulse');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-environmental', 'B.Tech Environmental Engineering', 'Undergraduate', '4 years', 'Covers water and waste treatment, pollution control and environmental impact assessment.', '12th with PCM + JEE Main or state CET', 'leaf');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-marine', 'B.Tech Marine Engineering / Naval Architecture', 'Undergraduate', '4 years', 'Covers ship systems, marine propulsion, naval architecture and offshore engineering.', '12th with PCM + IMU-CET', 'ship');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-mining', 'B.Tech Mining Engineering', 'Undergraduate', '4 years', 'Covers mine planning, geotechnical analysis, mine safety and surveying.', '12th with PCM + JEE Main/Advanced', 'pickaxe');
INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES ('btech-mechatronics', 'B.Tech Mechatronics Engineering', 'Undergraduate', '4 years', 'Covers automation, sensors and actuators, embedded systems and robotics fundamentals.', '12th with PCM + JEE Main or state CET', 'switch');

-- ---------------------------------------------------------------------
-- New exam (Marine Engineering's real-world entrance route -- unlike the
-- other new careers, it isn't reached via JEE)
-- ---------------------------------------------------------------------

INSERT INTO exams (slug, name, full_name, category, conducted_by, frequency, description, icon) VALUES ('imu-cet', 'IMU-CET', 'Indian Maritime University Common Entrance Test', 'After 12th', 'Indian Maritime University', 'Once a year', 'National entrance exam for admission to marine engineering, naval architecture and other maritime programs across Indian Maritime University and its affiliated institutes.', 'ship');

-- ---------------------------------------------------------------------
-- career_courses / career_exams / career_stages
-- ---------------------------------------------------------------------

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('chemical-engineer', 'btech-chemical', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('chemical-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('chemical-engineer', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('chemical-engineer', 'gate', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('chemical-engineer', 'polytechnic-cet', 3) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('chemical-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('chemical-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('aerospace-engineer', 'btech-aerospace', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('aerospace-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('aerospace-engineer', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('aerospace-engineer', 'gate', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('aerospace-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('aerospace-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('biomedical-engineer', 'btech-biomedical', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('biomedical-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('biomedical-engineer', 'gate', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('biomedical-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('biomedical-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('environmental-engineer', 'btech-environmental', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('environmental-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('environmental-engineer', 'gate', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('environmental-engineer', 'polytechnic-cet', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('environmental-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('environmental-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('marine-engineer', 'btech-marine', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('marine-engineer', 'imu-cet', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('marine-engineer', 'gate', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('marine-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('marine-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('mining-engineer', 'btech-mining', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mining-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mining-engineer', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mining-engineer', 'gate', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('mining-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('mining-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('mechatronics-engineer', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mechatronics-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mechatronics-engineer', 'gate', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('mechatronics-engineer', 'polytechnic-cet', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('mechatronics-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('mechatronics-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

INSERT INTO career_courses (career_slug, course_slug, sort_order) VALUES ('robotics-engineer', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('robotics-engineer', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES ('robotics-engineer', 'gate', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('robotics-engineer', 'after-12th', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_stages (career_slug, stage_slug, sort_order) VALUES ('robotics-engineer', 'graduation', 1) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- Reverse relations: course_careers / course_exams, exam_careers / exam_courses
-- ---------------------------------------------------------------------

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-chemical', 'chemical-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-chemical', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-chemical', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-chemical', 'gate', 2) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-aerospace', 'aerospace-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-aerospace', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-aerospace', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-aerospace', 'gate', 2) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-biomedical', 'biomedical-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-biomedical', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-biomedical', 'gate', 1) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-environmental', 'environmental-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-environmental', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-environmental', 'gate', 1) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-marine', 'marine-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-marine', 'imu-cet', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-marine', 'gate', 1) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-mining', 'mining-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-mining', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-mining', 'jee-advanced', 1) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-mining', 'gate', 2) ON CONFLICT DO NOTHING;

INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-mechatronics', 'mechatronics-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_careers (course_slug, career_slug, sort_order) VALUES ('btech-mechatronics', 'robotics-engineer', 1) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-mechatronics', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO course_exams (course_slug, exam_slug, sort_order) VALUES ('btech-mechatronics', 'gate', 1) ON CONFLICT DO NOTHING;

INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('imu-cet', 'marine-engineer', 0) ON CONFLICT DO NOTHING;
INSERT INTO exam_courses (exam_slug, course_slug, sort_order) VALUES ('imu-cet', 'btech-marine', 0) ON CONFLICT DO NOTHING;

INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'chemical-engineer', 100) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'aerospace-engineer', 101) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'biomedical-engineer', 102) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'environmental-engineer', 103) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'mining-engineer', 104) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'mechatronics-engineer', 105) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-main', 'robotics-engineer', 106) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-advanced', 'chemical-engineer', 100) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-advanced', 'aerospace-engineer', 101) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('jee-advanced', 'mining-engineer', 102) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'chemical-engineer', 100) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'aerospace-engineer', 101) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'biomedical-engineer', 102) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'environmental-engineer', 103) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'marine-engineer', 104) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'mining-engineer', 105) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'mechatronics-engineer', 106) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('gate', 'robotics-engineer', 107) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('polytechnic-cet', 'chemical-engineer', 100) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('polytechnic-cet', 'environmental-engineer', 101) ON CONFLICT DO NOTHING;
INSERT INTO exam_careers (exam_slug, career_slug, sort_order) VALUES ('polytechnic-cet', 'mechatronics-engineer', 102) ON CONFLICT DO NOTHING;
