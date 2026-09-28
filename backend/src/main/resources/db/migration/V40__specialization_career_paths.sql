-- Adds the "career path" fields the uploaded "Mechanical Engineering Career
-- Paths: Roles, Skills, & Salary Overview" reference image shows for each of
-- its 6 groups (Product Design & Development, Manufacturing & Operations,
-- Systems & Thermal, Robotics & Mechatronics, Project & Leadership,
-- Specialist & Support): Key Roles, Responsibilities, Hard Skills, Soft
-- Skills, and a Salary Estimate broken down by Entry/Mid/Senior.
--
-- This is a general Specialization schema change (every specialization gets
-- these fields, admin CRUD included -- see SpecializationService/
-- AdminSpecializationController), not something Mechanical-Engineer-
-- specific. Only Mechanical Engineer gets real data seeded here: the 6
-- groups become 6 new specializations, added alongside the existing 3
-- (Thermal Engineering, Design & Manufacturing (CAD/CAM), Automotive
-- Engineering) rather than replacing them, since those already model real
-- sub-disciplines the picture doesn't cover.
--
-- Key Roles reuse the existing JobRole entity (specialization_job_roles,
-- owned entirely by Specialization -- same shape as specialization_courses/
-- specialization_exams, see Specialization.java). Hard/Soft Skills reuse the
-- existing Skill entity, split into two separate join tables rather than
-- one filtered by Skill.skill_type, since skill_type is only sparsely
-- backfilled (NULL for most existing skills) -- an explicit Hard/Soft table
-- per specialization is simpler and doesn't depend on every skill involved
-- already being classified correctly. Responsibilities has nothing in the
-- catalog to link to, so it's a plain text[] column, same pattern as
-- Career.skills/growth_path/top_recruiters. Salary Entry/Mid/Senior mirrors
-- Career's own salary_entry_level/salary_mid_level/salary_senior_level
-- column shape exactly.
--
-- The picture's dollar figures are US salary data and don't fit this app's
-- India-focused RupeeL/year convention (Mechanical Engineer's own
-- salary_range is Rupee4L-Rupee18L, nowhere near the picture's $55k-$250k)
-- -- the salary bands below are Indian-market estimates in the same format
-- as every other career's salary_entry_level/mid/senior, not a literal
-- dollar-to-rupee conversion of the picture's numbers.

ALTER TABLE specializations
    ADD COLUMN responsibilities   TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN salary_entry_level  VARCHAR(64),
    ADD COLUMN salary_mid_level    VARCHAR(64),
    ADD COLUMN salary_senior_level VARCHAR(64);

CREATE TABLE specialization_job_roles (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    job_role_slug        VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, job_role_slug)
);

CREATE TABLE specialization_hard_skills (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    skill_slug            VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, skill_slug)
);

CREATE TABLE specialization_soft_skills (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    skill_slug            VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, skill_slug)
);

-- ---------------------------------------------------------------------
-- New skills used by the 6 groups below that don't already exist in the
-- catalog. Hard skills are left with a NULL skill_type, same as most
-- existing hard/technical skills (see Skill.java -- only backfilled where
-- the source data actually named a type); soft skills get skill_type =
-- 'Soft Skill' to match the existing classification (communication,
-- leadership, problem-solving, etc. already use this value).
-- ---------------------------------------------------------------------

INSERT INTO skills (slug, name) VALUES
    ('gdt', 'GD&T'),
    ('fea', 'FEA'),
    ('material-science', 'Material Science'),
    ('lean-six-sigma', 'Lean Six Sigma'),
    ('cnc-programming', 'CNC Programming'),
    ('process-simulation', 'Process Simulation'),
    ('heat-transfer', 'Heat Transfer'),
    ('cfd', 'CFD'),
    ('energy-modeling-software', 'Energy Modeling Software'),
    ('programming-cpp-python-plc', 'Programming (C++, Python, PLC)'),
    ('fea-cfd-robotics', 'FEA/CFD for Robotics'),
    ('budgeting-estimation', 'Budgeting & Estimation'),
    ('risk-assessment', 'Risk Assessment'),
    ('business-communication', 'Business Communication'),
    ('experimental-design', 'Experimental Design'),
    ('failure-analysis-fmea', 'Failure Analysis (FMEA)'),
    ('measurement-tools', 'Measurement Tools')
ON CONFLICT DO NOTHING;

INSERT INTO skills (slug, name, skill_type) VALUES
    ('creativity', 'Creativity', 'Soft Skill'),
    ('teamwork', 'Teamwork', 'Soft Skill'),
    ('adaptability', 'Adaptability', 'Soft Skill'),
    ('detail-oriented', 'Detail-Oriented', 'Soft Skill'),
    ('analytical-thinking', 'Analytical Thinking', 'Soft Skill'),
    ('attention-to-detail', 'Attention to Detail', 'Soft Skill'),
    ('innovation', 'Innovation', 'Soft Skill'),
    ('interdisciplinary-teamwork', 'Interdisciplinary Teamwork', 'Soft Skill'),
    ('strategic-planning', 'Strategic Planning', 'Soft Skill'),
    ('precision', 'Precision', 'Soft Skill'),
    ('report-writing', 'Report Writing', 'Soft Skill'),
    ('critical-thinking', 'Critical Thinking', 'Soft Skill')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- New job roles for the "Key Roles" of each group. None of these slugs
-- collide with the existing 8 job roles (all Software Engineer roles) --
-- 'engineering-manager' is already taken by that career's Engineering
-- Manager, so this one is 'mechanical-engineering-manager'.
-- ---------------------------------------------------------------------

INSERT INTO job_roles (slug, name, description) VALUES
    ('mechanical-design-engineer', 'Mechanical Design Engineer', 'Designs mechanical parts and assemblies in CAD, from first concept to a design that''s actually ready to manufacture.'),
    ('product-development-engineer', 'Product Development Engineer', 'Takes a product from concept through prototyping to a design validated for manufacturing.'),
    ('manufacturing-engineer', 'Manufacturing Engineer', 'Designs and optimizes the processes and equipment that turn a design into a finished product on the shop floor.'),
    ('process-engineer', 'Process Engineer', 'Improves manufacturing processes for quality, cost and throughput using lean and Six Sigma methods.'),
    ('production-supervisor', 'Production Supervisor', 'Runs day-to-day production floor operations -- scheduling, quality control and the team on the line.'),
    ('hvac-engineer', 'HVAC Engineer', 'Designs heating, ventilation and air-conditioning systems for buildings and industrial facilities.'),
    ('power-plant-engineer', 'Power Plant Engineer', 'Operates and maintains the thermal and mechanical systems that generate power at a plant.'),
    ('energy-analyst', 'Energy Analyst', 'Analyzes energy consumption and efficiency, and models improvements to thermal and power systems.'),
    ('robotics-engineer', 'Robotics Engineer', 'Designs and builds robotic systems -- the mechanical structure, sensors, actuators and control software that make them move.'),
    ('mechatronics-engineer', 'Mechatronics Engineer', 'Works across mechanical, electronic and software systems to build integrated automated machines.'),
    ('automation-engineer', 'Automation Engineer', 'Designs and programs automated production lines and industrial control systems.'),
    ('project-engineer', 'Project Engineer', 'Coordinates the technical and schedule details of an engineering project from design through delivery.'),
    ('mechanical-engineering-manager', 'Engineering Manager', 'Leads a team of mechanical engineers -- balancing people management with technical and project direction.'),
    ('mechanical-project-manager', 'Project Manager', 'Owns an engineering project''s scope, budget, schedule and stakeholder relationships end to end.'),
    ('test-validation-engineer', 'Test/Validation Engineer', 'Designs and runs test protocols that validate a product meets its engineering and safety requirements.'),
    ('quality-engineer', 'Quality Engineer', 'Ensures manufactured products meet quality standards through inspection, compliance and failure analysis.'),
    ('rd-engineer', 'R&D Engineer', 'Researches new materials, processes and designs to develop the next generation of a product.')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- The 6 new specializations, one per group in the reference image.
-- Salary bands are Indian-market estimates in the existing RupeeXL-RupeeYL
-- / year format, not a literal conversion of the picture's dollar figures
-- (see the header comment above).
-- ---------------------------------------------------------------------

INSERT INTO specializations (slug, name, description, icon, responsibilities, salary_entry_level, salary_mid_level, salary_senior_level) VALUES
    ('product-design-development', 'Product Design & Development', 'Designs and develops new mechanical products end-to-end -- from concept sketches through 2D/3D CAD models to a prototype that''s actually ready to manufacture.', 'palette',
        ARRAY['Create 2D/3D CAD models', 'Prototype development', 'Design for Manufacturability (DFM)'],
        '₹4L – ₹6L / year', '₹7L – ₹12L / year', '₹13L – ₹20L+ / year'),
    ('manufacturing-operations', 'Manufacturing & Operations', 'Runs and optimizes the shop floor -- production processes, lean manufacturing, quality control and the supply chain that turns a design into a finished product.', 'building',
        ARRAY['Optimize production processes', 'Lean manufacturing', 'Quality Control', 'Supply Chain'],
        '₹3.5L – ₹5.5L / year', '₹6.5L – ₹10L / year', '₹11L – ₹16L+ / year'),
    ('systems-thermal', 'Systems & Thermal', 'Designs and manages the thermal and energy systems -- HVAC, power generation, heat exchange -- that keep buildings, plants and machinery running efficiently.', 'bolt',
        ARRAY['Design HVAC systems', 'Analyze energy consumption', 'Manage thermal systems'],
        '₹4L – ₹6.5L / year', '₹7.5L – ₹12L / year', '₹13L – ₹19L+ / year'),
    ('robotics-mechatronics', 'Robotics & Mechatronics', 'Builds automated and robotic systems that combine mechanical design with sensors, actuators and control software.', 'code',
        ARRAY['Design robotic systems', 'Integrate sensors/actuators', 'PLC Programming'],
        '₹4.5L – ₹7L / year', '₹8L – ₹14L / year', '₹15L – ₹22L+ / year'),
    ('project-leadership', 'Project & Leadership', 'Moves from hands-on engineering into managing engineering projects and teams -- resourcing, vendor relations and strategic delivery.', 'users',
        ARRAY['Manage project lifecycle', 'Resource allocation', 'Team leadership', 'Vendor relations'],
        '₹8L – ₹13L / year', '₹14L – ₹22L / year', '₹23L – ₹35L+ / year'),
    ('specialist-support', 'Specialist & Support', 'Validates and improves what other mechanical engineers build -- testing, failure analysis, quality assurance and applied R&D.', 'shield',
        ARRAY['Develop test protocols', 'Failure analysis', 'Ensure compliance', 'Material research'],
        '₹3.5L – ₹5.5L / year', '₹6.5L – ₹10L / year', '₹11L – ₹16L+ / year')
ON CONFLICT DO NOTHING;

-- career_specializations already has rows 0-2 for mechanical-engineer
-- (thermal-engineering, design-manufacturing, automotive-engineering from
-- V17), so this continues at 3 rather than colliding with them (V14
-- postmortem).
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES
    ('mechanical-engineer', 'product-design-development', 3),
    ('mechanical-engineer', 'manufacturing-operations', 4),
    ('mechanical-engineer', 'systems-thermal', 5),
    ('mechanical-engineer', 'robotics-mechatronics', 6),
    ('mechanical-engineer', 'project-leadership', 7),
    ('mechanical-engineer', 'specialist-support', 8)
ON CONFLICT DO NOTHING;

-- Each new specialization connects to the same course/exam route as the
-- existing Mechanical Engineer specializations (B.Tech Mechanical, JEE
-- Main, GATE) -- Manufacturing & Operations additionally links the diploma
-- route, same as design-manufacturing already does, since production-floor
-- roles are diploma-accessible too.
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES
    ('product-design-development', 'btech-mech', 0),
    ('manufacturing-operations', 'btech-mech', 0),
    ('manufacturing-operations', 'diploma-mech', 1),
    ('systems-thermal', 'btech-mech', 0),
    ('robotics-mechatronics', 'btech-mech', 0),
    ('project-leadership', 'btech-mech', 0),
    ('specialist-support', 'btech-mech', 0)
ON CONFLICT DO NOTHING;

INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES
    ('product-design-development', 'jee-main', 0),
    ('product-design-development', 'gate', 1),
    ('manufacturing-operations', 'jee-main', 0),
    ('manufacturing-operations', 'gate', 1),
    ('systems-thermal', 'jee-main', 0),
    ('systems-thermal', 'gate', 1),
    ('robotics-mechatronics', 'jee-main', 0),
    ('robotics-mechatronics', 'gate', 1),
    ('project-leadership', 'jee-main', 0),
    ('project-leadership', 'gate', 1),
    ('specialist-support', 'jee-main', 0),
    ('specialist-support', 'gate', 1)
ON CONFLICT DO NOTHING;

-- Key Roles.
INSERT INTO specialization_job_roles (specialization_slug, job_role_slug, sort_order) VALUES
    ('product-design-development', 'mechanical-design-engineer', 0),
    ('product-design-development', 'product-development-engineer', 1),
    ('manufacturing-operations', 'manufacturing-engineer', 0),
    ('manufacturing-operations', 'process-engineer', 1),
    ('manufacturing-operations', 'production-supervisor', 2),
    ('systems-thermal', 'hvac-engineer', 0),
    ('systems-thermal', 'power-plant-engineer', 1),
    ('systems-thermal', 'energy-analyst', 2),
    ('robotics-mechatronics', 'robotics-engineer', 0),
    ('robotics-mechatronics', 'mechatronics-engineer', 1),
    ('robotics-mechatronics', 'automation-engineer', 2),
    ('project-leadership', 'project-engineer', 0),
    ('project-leadership', 'mechanical-engineering-manager', 1),
    ('project-leadership', 'mechanical-project-manager', 2),
    ('specialist-support', 'test-validation-engineer', 0),
    ('specialist-support', 'quality-engineer', 1),
    ('specialist-support', 'rd-engineer', 2)
ON CONFLICT DO NOTHING;

-- Hard Skills.
INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('product-design-development', 'cad-catia', 0),
    ('product-design-development', 'gdt', 1),
    ('product-design-development', 'fea', 2),
    ('product-design-development', 'material-science', 3),
    ('manufacturing-operations', 'lean-six-sigma', 0),
    ('manufacturing-operations', 'cnc-programming', 1),
    ('manufacturing-operations', 'process-simulation', 2),
    ('manufacturing-operations', 'robotics-fundamentals', 3),
    ('systems-thermal', 'thermodynamics', 0),
    ('systems-thermal', 'heat-transfer', 1),
    ('systems-thermal', 'cfd', 2),
    ('systems-thermal', 'energy-modeling-software', 3),
    ('robotics-mechatronics', 'programming-cpp-python-plc', 0),
    ('robotics-mechatronics', 'control-systems', 1),
    ('robotics-mechatronics', 'fea-cfd-robotics', 2),
    ('project-leadership', 'project-management', 0),
    ('project-leadership', 'budgeting-estimation', 1),
    ('project-leadership', 'risk-assessment', 2),
    ('project-leadership', 'business-communication', 3),
    ('specialist-support', 'data-analysis', 0),
    ('specialist-support', 'experimental-design', 1),
    ('specialist-support', 'failure-analysis-fmea', 2),
    ('specialist-support', 'measurement-tools', 3)
ON CONFLICT DO NOTHING;

-- Soft Skills.
INSERT INTO specialization_soft_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('product-design-development', 'problem-solving', 0),
    ('product-design-development', 'creativity', 1),
    ('product-design-development', 'teamwork', 2),
    ('manufacturing-operations', 'adaptability', 0),
    ('manufacturing-operations', 'leadership', 1),
    ('manufacturing-operations', 'detail-oriented', 2),
    ('systems-thermal', 'analytical-thinking', 0),
    ('systems-thermal', 'communication', 1),
    ('systems-thermal', 'attention-to-detail', 2),
    ('robotics-mechatronics', 'problem-solving', 0),
    ('robotics-mechatronics', 'innovation', 1),
    ('robotics-mechatronics', 'interdisciplinary-teamwork', 2),
    ('project-leadership', 'leadership', 0),
    ('project-leadership', 'decision-making', 1),
    ('project-leadership', 'negotiation', 2),
    ('project-leadership', 'strategic-planning', 3),
    ('specialist-support', 'problem-solving', 0),
    ('specialist-support', 'precision', 1),
    ('specialist-support', 'report-writing', 2),
    ('specialist-support', 'critical-thinking', 3)
ON CONFLICT DO NOTHING;

-- Also surface these 17 new roles on the Mechanical Engineer career page's
-- own "Job Roles" section (career_job_roles has no sort_order column --
-- see V26). mechanical-engineer had zero job roles before this.
INSERT INTO career_job_roles (career_slug, job_role_slug) VALUES
    ('mechanical-engineer', 'mechanical-design-engineer'),
    ('mechanical-engineer', 'product-development-engineer'),
    ('mechanical-engineer', 'manufacturing-engineer'),
    ('mechanical-engineer', 'process-engineer'),
    ('mechanical-engineer', 'production-supervisor'),
    ('mechanical-engineer', 'hvac-engineer'),
    ('mechanical-engineer', 'power-plant-engineer'),
    ('mechanical-engineer', 'energy-analyst'),
    ('mechanical-engineer', 'robotics-engineer'),
    ('mechanical-engineer', 'mechatronics-engineer'),
    ('mechanical-engineer', 'automation-engineer'),
    ('mechanical-engineer', 'project-engineer'),
    ('mechanical-engineer', 'mechanical-engineering-manager'),
    ('mechanical-engineer', 'mechanical-project-manager'),
    ('mechanical-engineer', 'test-validation-engineer'),
    ('mechanical-engineer', 'quality-engineer'),
    ('mechanical-engineer', 'rd-engineer')
ON CONFLICT DO NOTHING;
