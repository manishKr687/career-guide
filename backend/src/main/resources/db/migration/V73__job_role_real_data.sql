-- Real per-role content for the 247 job roles that were left with a
-- placeholder description ("X is a job role reached through Y and
-- related disciplines"), a flat "Entry to Senior" level and no salary,
-- skills or industries -- the state a bulk taxonomy rebuild left them in
-- (V49/V50), overwriting even the 5 original hand-written V26 rows.
--
-- Each role gets: a real one-line description of what the role actually
-- does, a seniority-appropriate experienceLevel, a salary band (India,
-- LPA -- deliberately a defensible per-domain/per-seniority band, not
-- fake per-role precision), and skill/industry links -- but ONLY where
-- an existing catalog entry is a clean match. Most core-engineering,
-- science and humanities roles get zero industries: only 10 of the 313
-- Industry rows are broad sectors, and forcing one of those 10 onto a
-- Mining Engineer or Sociologist would overstate the fit -- same
-- "do not force it" call V69 made for defence-services-officer.

UPDATE job_roles SET description = 'Investigates financial records for fraud, embezzlement and financial misconduct, often supporting legal proceedings.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '15 LPA' WHERE slug = 'forensic-accountant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('forensic-accountant', 'auditing'),
    ('forensic-accountant', 'financial-accounting'),
    ('forensic-accountant', 'critical-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises individuals and businesses on tax planning, compliance and filings under Indian tax law.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'tax-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('tax-consultant', 'taxation'),
    ('tax-consultant', 'gst-compliance'),
    ('tax-consultant', 'financial-accounting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Examines financial statements and internal controls to verify accuracy and regulatory compliance.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'auditor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('auditor', 'auditing'),
    ('auditor', 'accounting-principles'),
    ('auditor', 'compliance')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees an organization''s accounting operations, financial reporting and internal controls at a senior level.', experience_level = 'Senior', salary_min = '15 LPA', salary_max = '35 LPA' WHERE slug = 'financial-controller';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('financial-controller', 'financial-reporting'),
    ('financial-controller', 'budgeting'),
    ('financial-controller', 'compliance')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Maintains financial records, prepares statements and manages day-to-day bookkeeping for an organization.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'accountant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('accountant', 'bookkeeping'),
    ('accountant', 'accounting-principles'),
    ('accountant', 'tally')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests avionics and flight-control systems that keep aircraft and spacecraft stable and safe.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'flight-systems-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('flight-systems-engineer', 'flight-mechanics'),
    ('flight-systems-engineer', 'control-systems'),
    ('flight-systems-engineer', 'aircraft-structures')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, analyses and tests aircraft, spacecraft and their propulsion and structural systems.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'aerospace-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('aerospace-engineer', 'aerodynamics'),
    ('aerospace-engineer', 'aircraft-structures'),
    ('aerospace-engineer', 'cfd')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests satellite subsystems -- structures, power, communication and payload -- for space missions.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '20 LPA' WHERE slug = 'satellite-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('satellite-engineer', 'aerospace-electronics-fundamentals'),
    ('satellite-engineer', 'communication-systems'),
    ('satellite-engineer', 'propulsion-systems')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses airflow over aircraft and vehicle surfaces to optimize lift, drag and stability using CFD.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'aerodynamics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('aerodynamics-engineer', 'aerodynamics'),
    ('aerodynamics-engineer', 'cfd'),
    ('aerodynamics-engineer', 'fluid-mechanics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs aircraft structures and systems, balancing aerodynamics, weight, safety and manufacturability.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'aircraft-design-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('aircraft-design-engineer', 'aircraft-structures'),
    ('aircraft-design-engineer', 'cad-catia'),
    ('aircraft-design-engineer', 'structural-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests jet engines, rocket motors and other propulsion systems for aerospace vehicles.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'propulsion-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('propulsion-engineer', 'propulsion-systems'),
    ('propulsion-engineer', 'thermodynamics'),
    ('propulsion-engineer', 'fluid-mechanics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and integrates spacecraft systems -- structural, thermal, power and propulsion -- for satellite and space missions.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '22 LPA' WHERE slug = 'spacecraft-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('spacecraft-engineer', 'propulsion-systems'),
    ('spacecraft-engineer', 'aerospace-electronics-fundamentals'),
    ('spacecraft-engineer', 'systems-engineering')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and maintains an aircraft''s electronic systems -- navigation, communication and flight instrumentation.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'avionics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('avionics-engineer', 'aerospace-electronics-fundamentals'),
    ('avionics-engineer', 'circuit-design'),
    ('avionics-engineer', 'embedded-systems')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches crop and soil science to improve yield, pest resistance and sustainable farming practices.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '12 LPA' WHERE slug = 'agricultural-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('agricultural-scientist', 'crop-science'),
    ('agricultural-scientist', 'soil-science'),
    ('agricultural-scientist', 'plant-pathology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and oversees day-to-day farm operations -- crop cycles, labour, equipment and budgets.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'farm-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('farm-manager', 'farm-management'),
    ('farm-manager', 'budgeting'),
    ('farm-manager', 'crop-science')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises farmers on crop selection, soil management and cultivation practices to improve productivity.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'agronomist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('agronomist', 'crop-science'),
    ('agronomist', 'soil-analysis'),
    ('agronomist', 'agricultural-economics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises farms and agribusinesses on crop planning, soil health and farm profitability.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'agricultural-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('agricultural-consultant', 'agricultural-economics'),
    ('agricultural-consultant', 'farm-management'),
    ('agricultural-consultant', 'crop-science')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'A government or cooperative-sector role extending farming advisories, subsidies and schemes to farmers.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'agricultural-officer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('agricultural-officer', 'public-administration'),
    ('agricultural-officer', 'crop-science'),
    ('agricultural-officer', 'farm-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('agricultural-officer', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs outdoor spaces -- parks, campuses and public areas -- balancing aesthetics, ecology and function.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'landscape-architect';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('landscape-architect', 'building-design'),
    ('landscape-architect', 'sketchup'),
    ('landscape-architect', 'urban-planning')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops building designs and drawings under an architect''s direction, from concept through construction documents.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'architectural-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('architectural-designer', 'building-design'),
    ('architectural-designer', 'autocad'),
    ('architectural-designer', 'sketchup')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans land use, infrastructure and zoning for cities and townships to guide sustainable growth.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'urban-planner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('urban-planner', 'urban-planning'),
    ('urban-planner', 'gis'),
    ('urban-planner', 'policy-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('urban-planner', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs buildings and oversees their construction, balancing aesthetics, function, safety and cost.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '20 LPA' WHERE slug = 'architect';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('architect', 'building-design'),
    ('architect', 'autocad'),
    ('architect', 'structural-understanding')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies living organisms and ecosystems through research, fieldwork and laboratory analysis.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'biologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biologist', 'lab-research'),
    ('biologist', 'scientific-research'),
    ('biologist', 'biodiversity-studies')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and conducts original research studies, analyses data and publishes findings in a scientific field.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'research-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('research-scientist', 'scientific-research'),
    ('research-scientist', 'experimental-design'),
    ('research-scientist', 'research-methodology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies interactions between organisms and their environment to guide conservation and land-use decisions.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'ecologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('ecologist', 'ecology'),
    ('ecologist', 'biodiversity-studies'),
    ('ecologist', 'gis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies bacteria, viruses and other microorganisms in clinical, industrial or research laboratory settings.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '11 LPA' WHERE slug = 'microbiologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('microbiologist', 'lab-techniques'),
    ('microbiologist', 'microscopy'),
    ('microbiologist', 'cell-culture-techniques')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('microbiologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies genes and heredity, applying genetic analysis to research, medicine or agriculture.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'geneticist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('geneticist', 'genetics'),
    ('geneticist', 'genetic-engineering'),
    ('geneticist', 'molecular-biology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs medical devices and equipment, combining engineering principles with biology and medicine.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'biomedical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biomedical-engineer', 'medical-device-design'),
    ('biomedical-engineer', 'biomaterials'),
    ('biomedical-engineer', 'anatomy-physiology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('biomedical-engineer', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, tests and validates medical devices to meet safety and regulatory requirements.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'medical-device-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('medical-device-engineer', 'medical-device-design'),
    ('medical-device-engineer', 'regulatory-standards'),
    ('medical-device-engineer', 'prototyping')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('medical-device-engineer', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages and maintains medical equipment and technology within a hospital or healthcare setting.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'clinical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('clinical-engineer', 'medical-device-design'),
    ('clinical-engineer', 'troubleshooting'),
    ('clinical-engineer', 'regulatory-compliance')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('clinical-engineer', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops and tests new biomedical technologies and devices in a research setting.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'biomedical-research-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biomedical-research-engineer', 'biomaterials'),
    ('biomedical-research-engineer', 'medical-research'),
    ('biomedical-research-engineer', 'experimental-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('biomedical-research-engineer', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses biological data -- genomic, proteomic -- using computational and statistical methods.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'bioinformatics-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('bioinformatics-scientist', 'bioinformatics'),
    ('bioinformatics-scientist', 'molecular-biology'),
    ('bioinformatics-scientist', 'python')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('bioinformatics-scientist', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Tests raw materials and finished products to ensure they meet quality and regulatory standards.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '12 LPA' WHERE slug = 'quality-control-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('quality-control-scientist', 'quality-control'),
    ('quality-control-scientist', 'lab-techniques'),
    ('quality-control-scientist', 'regulatory-standards')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('quality-control-scientist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and scales up biological manufacturing processes -- fermentation, purification -- for biotech products.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'bioprocess-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('bioprocess-engineer', 'bioprocess-engineering'),
    ('bioprocess-engineer', 'process-optimization'),
    ('bioprocess-engineer', 'cell-culture-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Conducts laboratory research to develop new biotechnology products, processes or therapies.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'biotechnology-researcher';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biotechnology-researcher', 'molecular-biology'),
    ('biotechnology-researcher', 'lab-research'),
    ('biotechnology-researcher', 'genetic-engineering')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies biological science to develop products and processes in medicine, agriculture or industry.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'biotechnologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biotechnologist', 'molecular-biology'),
    ('biotechnologist', 'bioprocess-engineering'),
    ('biotechnologist', 'lab-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises organizations on strategy, operations and performance improvement across industries.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '25 LPA' WHERE slug = 'management-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('management-consultant', 'business-strategy'),
    ('management-consultant', 'business-acumen'),
    ('management-consultant', 'stakeholder-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees day-to-day operations, budgets and staff for a business unit or department.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'business-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('business-manager', 'operations-management'),
    ('business-manager', 'budgeting'),
    ('business-manager', 'leadership')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses business processes and data to recommend improvements and support decision-making.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'business-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('business-analyst', 'data-analysis'),
    ('business-analyst', 'requirements-gathering'),
    ('business-analyst', 'business-acumen')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('business-analyst', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages daily operations, processes and resources to keep a business running efficiently.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'operations-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('operations-manager', 'operations-management'),
    ('operations-manager', 'process-optimization'),
    ('operations-manager', 'staff-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises senior leadership on long-term business strategy, market positioning and growth.', experience_level = 'Senior', salary_min = '10 LPA', salary_max = '35 LPA' WHERE slug = 'strategy-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('strategy-consultant', 'business-strategy'),
    ('strategy-consultant', 'strategic-thinking'),
    ('strategy-consultant', 'market-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees manufacturing processes on the shop floor to meet output, quality and cost targets.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'production-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('production-engineer', 'production-engineering'),
    ('production-engineer', 'production-planning'),
    ('production-engineer', 'quality-control')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tunes automated control systems that keep industrial processes running safely and efficiently.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'process-control-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('process-control-engineer', 'control-systems'),
    ('process-control-engineer', 'automation-plc'),
    ('process-control-engineer', 'process-optimization')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and operates processes that convert crude oil and gas into fuels and chemicals.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'petrochemical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('petrochemical-engineer', 'process-design'),
    ('petrochemical-engineer', 'chemical-reaction-engineering'),
    ('petrochemical-engineer', 'process-simulation-aspen')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and operates industrial chemical processes, scaling lab reactions into safe, efficient plant operations.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'chemical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('chemical-engineer', 'chemical-reaction-engineering'),
    ('chemical-engineer', 'process-design'),
    ('chemical-engineer', 'process-simulation')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs chemical process flowsheets and equipment specifications for new or upgraded plants.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'process-design-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('process-design-engineer', 'process-design'),
    ('process-design-engineer', 'process-simulation-aspen'),
    ('process-design-engineer', 'thermodynamics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Monitors and improves manufacturing processes for efficiency, safety and product quality.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'process-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('process-engineer', 'process-optimization'),
    ('process-engineer', 'process-mapping'),
    ('process-engineer', 'quality-control')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Maintains and optimizes plant machinery, utilities and processes for safe, continuous operation.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'plant-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('plant-engineer', 'maintenance-operations'),
    ('plant-engineer', 'plant-safety'),
    ('plant-engineer', 'process-optimization')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Uses lab instrumentation to identify and quantify chemical composition of samples for quality or research.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'analytical-chemist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('analytical-chemist', 'analytical-techniques'),
    ('analytical-chemist', 'spectroscopy'),
    ('analytical-chemist', 'lab-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Tests raw materials and finished chemical products against quality specifications and standards.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'quality-control-chemist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('quality-control-chemist', 'quality-control'),
    ('quality-control-chemist', 'analytical-techniques'),
    ('quality-control-chemist', 'lab-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops and refines chemical formulations for products such as pharmaceuticals, cosmetics or specialty chemicals.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'formulation-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('formulation-scientist', 'organic-chemistry'),
    ('formulation-scientist', 'lab-research'),
    ('formulation-scientist', 'analytical-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies the composition, structure and properties of substances through experimentation and analysis.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'chemist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('chemist', 'organic-chemistry'),
    ('chemist', 'inorganic-chemistry'),
    ('chemist', 'lab-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and supervises construction projects on site -- schedules, materials, labour and safety.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'construction-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('construction-engineer', 'construction-management'),
    ('construction-engineer', 'project-execution'),
    ('construction-engineer', 'blueprint-reading')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and oversees construction of roads and highways, including pavement and drainage design.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'highway-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('highway-engineer', 'structural-analysis'),
    ('highway-engineer', 'surveying'),
    ('highway-engineer', 'construction-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('highway-engineer', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and designs transport infrastructure -- roads, transit systems -- for safe, efficient movement.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'transportation-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('transportation-engineer', 'urban-planning'),
    ('transportation-engineer', 'surveying'),
    ('transportation-engineer', 'structural-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('transportation-engineer', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs systems for water supply, irrigation, drainage and flood control.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'water-resources-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('water-resources-engineer', 'water-treatment'),
    ('water-resources-engineer', 'environmental-regulations'),
    ('water-resources-engineer', 'surveying')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Surveys and maps land and construction sites to guide design and construction accuracy.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'survey-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('survey-engineer', 'surveying'),
    ('survey-engineer', 'gis'),
    ('survey-engineer', 'measurement-tools')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, builds and maintains infrastructure -- buildings, roads, bridges and water systems.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'civil-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('civil-engineer', 'structural-analysis'),
    ('civil-engineer', 'autocad'),
    ('civil-engineer', 'construction-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages day-to-day construction activity on site -- coordinating labour, materials and quality checks.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'site-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('site-engineer', 'construction-management'),
    ('site-engineer', 'blueprint-reading'),
    ('site-engineer', 'project-execution')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs load-bearing structures -- buildings, bridges -- to ensure they are safe and stable.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'structural-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('structural-engineer', 'structural-analysis'),
    ('structural-engineer', 'staad-pro'),
    ('structural-engineer', 'building-materials')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies soil and rock behaviour to design safe foundations for buildings and infrastructure.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'geotechnical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('geotechnical-engineer', 'geotechnical-analysis'),
    ('geotechnical-engineer', 'soil-analysis'),
    ('geotechnical-engineer', 'surveying')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs systems and solutions to control pollution, treat waste and protect the environment.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'environmental-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('environmental-engineer', 'environmental-impact-assessment'),
    ('environmental-engineer', 'waste-management'),
    ('environmental-engineer', 'water-treatment')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds interactive game mechanics, graphics and logic using game engines and programming.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '18 LPA' WHERE slug = 'game-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('game-developer', 'programming'),
    ('game-developer', 'object-oriented-programming'),
    ('game-developer', 'c-programming')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('game-developer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses large datasets and builds predictive models to drive business or research decisions.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '28 LPA' WHERE slug = 'data-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('data-scientist', 'machine-learning'),
    ('data-scientist', 'data-analysis'),
    ('data-scientist', 'python')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('data-scientist', 'information-technology'),
    ('data-scientist', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds and deploys machine learning models into production systems at scale.', experience_level = 'Entry to Senior', salary_min = '7 LPA', salary_max = '30 LPA' WHERE slug = 'machine-learning-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('machine-learning-engineer', 'machine-learning'),
    ('machine-learning-engineer', 'deep-learning'),
    ('machine-learning-engineer', 'mlops')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('machine-learning-engineer', 'information-technology'),
    ('machine-learning-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops rendering, animation and visualization systems for games, film or simulation software.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'computer-graphics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('computer-graphics-engineer', 'programming'),
    ('computer-graphics-engineer', '3d-visualization'),
    ('computer-graphics-engineer', 'object-oriented-programming')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('computer-graphics-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Works across both the frontend and backend of an application.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '22 LPA' WHERE slug = 'full-stack-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('full-stack-developer', 'javascript'),
    ('full-stack-developer', 'react'),
    ('full-stack-developer', 'sql')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('full-stack-developer', 'information-technology'),
    ('full-stack-developer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Monitors systems and networks for security threats and responds to incidents.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'security-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('security-analyst', 'cybersecurity'),
    ('security-analyst', 'incident-response'),
    ('security-analyst', 'threat-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('security-analyst', 'information-technology'),
    ('security-analyst', 'banking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds the user-facing part of web applications -- layout, interactivity and client-side logic.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'frontend-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('frontend-developer', 'javascript'),
    ('frontend-developer', 'react'),
    ('frontend-developer', 'visual-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('frontend-developer', 'information-technology'),
    ('frontend-developer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages, secures and tunes an organization''s databases for performance and reliability.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'database-administrator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('database-administrator', 'dbms'),
    ('database-administrator', 'sql'),
    ('database-administrator', 'database-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('database-administrator', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds and maintains the server-side logic, APIs and databases behind an application.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '22 LPA' WHERE slug = 'backend-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('backend-developer', 'sql'),
    ('backend-developer', 'java'),
    ('backend-developer', 'system-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('backend-developer', 'information-technology'),
    ('backend-developer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and builds AI-powered systems and applications, from model integration to deployment.', experience_level = 'Entry to Senior', salary_min = '7 LPA', salary_max = '32 LPA' WHERE slug = 'ai-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('ai-engineer', 'machine-learning'),
    ('ai-engineer', 'generative-ai'),
    ('ai-engineer', 'python')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('ai-engineer', 'information-technology'),
    ('ai-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and manages applications and infrastructure on cloud platforms.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '25 LPA' WHERE slug = 'cloud-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cloud-engineer', 'aws'),
    ('cloud-engineer', 'azure'),
    ('cloud-engineer', 'cloud-platforms')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('cloud-engineer', 'information-technology'),
    ('cloud-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, implements and maintains computer networks for organizations.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'network-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('network-engineer', 'networking'),
    ('network-engineer', 'computer-networks'),
    ('network-engineer', 'network-security')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('network-engineer', 'information-technology'),
    ('network-engineer', 'telecommunications')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds and maintains the pipelines and infrastructure that move and transform data at scale.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '25 LPA' WHERE slug = 'data-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('data-engineer', 'sql'),
    ('data-engineer', 'python'),
    ('data-engineer', 'database-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('data-engineer', 'information-technology'),
    ('data-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, builds and maintains software applications and systems across the stack.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '25 LPA' WHERE slug = 'software-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('software-engineer', 'programming'),
    ('software-engineer', 'software-engineering'),
    ('software-engineer', 'data-structures-algorithms')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('software-engineer', 'information-technology'),
    ('software-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds mobile applications for Android or iOS, from UI to backend integration.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'mobile-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mobile-developer', 'javascript-java-python'),
    ('mobile-developer', 'object-oriented-programming'),
    ('mobile-developer', 'programming')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('mobile-developer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds and runs the pipelines, infrastructure and automation that ship and operate software.', experience_level = 'Mid to Senior', salary_min = '6 LPA', salary_max = '26 LPA' WHERE slug = 'devops-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('devops-engineer', 'ci-cd'),
    ('devops-engineer', 'docker'),
    ('devops-engineer', 'kubernetes')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('devops-engineer', 'information-technology'),
    ('devops-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Keeps large-scale systems reliable, scalable and performant through automation and monitoring.', experience_level = 'Mid to Senior', salary_min = '8 LPA', salary_max = '32 LPA' WHERE slug = 'site-reliability-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('site-reliability-engineer', 'ci-cd'),
    ('site-reliability-engineer', 'kubernetes'),
    ('site-reliability-engineer', 'incident-response')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('site-reliability-engineer', 'information-technology'),
    ('site-reliability-engineer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and implements security controls to protect systems and networks from attack.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '24 LPA' WHERE slug = 'cybersecurity-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cybersecurity-engineer', 'cybersecurity'),
    ('cybersecurity-engineer', 'network-security'),
    ('cybersecurity-engineer', 'penetration-testing')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('cybersecurity-engineer', 'information-technology'),
    ('cybersecurity-engineer', 'banking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, integrates and maintains complex hardware/software systems end to end.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'systems-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('systems-engineer', 'systems-engineering'),
    ('systems-engineer', 'operating-systems'),
    ('systems-engineer', 'troubleshooting')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('systems-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds decentralized applications and smart contracts on blockchain platforms.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '24 LPA' WHERE slug = 'blockchain-developer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('blockchain-developer', 'programming'),
    ('blockchain-developer', 'cybersecurity'),
    ('blockchain-developer', 'object-oriented-programming')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('blockchain-developer', 'information-technology'),
    ('blockchain-developer', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Creates visual content -- branding, print and digital -- using design software and typography.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'graphic-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('graphic-designer', 'adobe-creative-suite'),
    ('graphic-designer', 'visual-design'),
    ('graphic-designer', 'typography')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches user needs and designs intuitive, usable digital product experiences.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'ux-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('ux-designer', 'user-research'),
    ('ux-designer', 'wireframing'),
    ('ux-designer', 'design-thinking')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('ux-designer', 'information-technology'),
    ('ux-designer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Leads the visual style and creative direction of a brand, campaign or production.', experience_level = 'Senior', salary_min = '10 LPA', salary_max = '25 LPA' WHERE slug = 'art-director';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('art-director', 'visual-communication'),
    ('art-director', 'branding'),
    ('art-director', 'leadership')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs the visual layout and interactive elements of digital interfaces.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'ui-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('ui-designer', 'visual-design'),
    ('ui-designer', 'wireframing'),
    ('ui-designer', 'adobe-creative-suite')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('ui-designer', 'information-technology'),
    ('ui-designer', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Creates 2D/3D animated visuals for film, games or advertising.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '12 LPA' WHERE slug = 'animator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('animator', '3d-visualization'),
    ('animator', 'adobe-creative-suite'),
    ('animator', 'visual-design')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs gameplay mechanics, levels and rules that shape a game''s player experience.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'game-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('game-designer', 'design-thinking'),
    ('game-designer', 'creativity'),
    ('game-designer', 'prototyping')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('game-designer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs clothing and accessories, from concept sketches to finished garments.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '12 LPA' WHERE slug = 'fashion-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('fashion-designer', 'visual-design'),
    ('fashion-designer', 'creativity'),
    ('fashion-designer', 'adobe-creative-suite')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs physical or digital products end-to-end, balancing form, function and user needs.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'product-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('product-designer', 'design-thinking'),
    ('product-designer', 'prototyping'),
    ('product-designer', 'user-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs the form, function and manufacturability of physical products.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'industrial-designer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('industrial-designer', 'design-thinking'),
    ('industrial-designer', 'prototyping'),
    ('industrial-designer', 'cad-cam')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs electrical systems and circuits for buildings, machinery or products.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'electrical-design-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('electrical-design-engineer', 'circuit-design'),
    ('electrical-design-engineer', 'autocad-electrical'),
    ('electrical-design-engineer', 'electrical-machines')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs automated control systems that regulate industrial machinery and processes.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'control-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('control-engineer', 'control-systems'),
    ('control-engineer', 'automation-plc'),
    ('control-engineer', 'programming-cpp-python-plc')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs power-conversion circuits -- inverters, converters -- for motors, renewables and drives.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'power-electronics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('power-electronics-engineer', 'power-systems'),
    ('power-electronics-engineer', 'circuit-design'),
    ('power-electronics-engineer', 'electrical-machines')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Maintains and troubleshoots electrical equipment and systems to minimize downtime.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'electrical-maintenance-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('electrical-maintenance-engineer', 'maintenance-operations'),
    ('electrical-maintenance-engineer', 'circuit-repair'),
    ('electrical-maintenance-engineer', 'troubleshooting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, develops and maintains electrical systems -- power generation, machines and circuits.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'electrical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('electrical-engineer', 'circuit-design'),
    ('electrical-engineer', 'power-systems'),
    ('electrical-engineer', 'electrical-machines')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and operates systems for generating, transmitting and distributing electrical power.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'power-systems-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('power-systems-engineer', 'power-systems'),
    ('power-systems-engineer', 'electrical-machines'),
    ('power-systems-engineer', 'control-systems')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs relay and protection schemes that safeguard power systems from faults.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'protection-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('protection-engineer', 'power-systems'),
    ('protection-engineer', 'circuit-analysis'),
    ('protection-engineer', 'control-systems')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and maintains solar, wind and other renewable power generation systems.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'renewable-energy-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('renewable-energy-engineer', 'power-systems'),
    ('renewable-energy-engineer', 'sustainability'),
    ('renewable-energy-engineer', 'electrical-machines')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs algorithms and systems to analyse and process audio, image or sensor signals.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'signal-processing-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('signal-processing-engineer', 'signal-processing'),
    ('signal-processing-engineer', 'matlab'),
    ('signal-processing-engineer', 'embedded-systems')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and maintains systems for transmitting voice, data and video over networks.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'communication-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('communication-engineer', 'communication-systems'),
    ('communication-engineer', 'signal-processing'),
    ('communication-engineer', 'networking')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('communication-engineer', 'telecommunications')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests radio-frequency circuits and systems for wireless communication devices.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'rf-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('rf-engineer', 'circuit-design'),
    ('rf-engineer', 'signal-processing'),
    ('rf-engineer', 'communication-systems')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('rf-engineer', 'telecommunications')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs firmware and hardware for embedded systems inside devices and machines.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'embedded-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('embedded-engineer', 'embedded-systems'),
    ('embedded-engineer', 'c-programming'),
    ('embedded-engineer', 'circuit-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('embedded-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and verifies integrated circuits and chips used in electronic devices.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '22 LPA' WHERE slug = 'vlsi-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('vlsi-engineer', 'vlsi'),
    ('vlsi-engineer', 'circuit-design'),
    ('vlsi-engineer', 'pcb-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('vlsi-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests electronic circuits and devices across consumer, industrial or communication applications.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'electronics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('electronics-engineer', 'circuit-design'),
    ('electronics-engineer', 'embedded-systems'),
    ('electronics-engineer', 'pcb-design')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and programs FPGA-based digital hardware for high-performance or embedded applications.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '20 LPA' WHERE slug = 'fpga-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('fpga-engineer', 'vlsi'),
    ('fpga-engineer', 'embedded-systems'),
    ('fpga-engineer', 'circuit-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('fpga-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests physical computing hardware -- boards, chips and devices.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'hardware-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hardware-engineer', 'pcb-design'),
    ('hardware-engineer', 'circuit-design'),
    ('hardware-engineer', 'embedded-systems')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('hardware-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and fabricates semiconductor devices and chips used in electronics.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '22 LPA' WHERE slug = 'semiconductor-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('semiconductor-engineer', 'vlsi'),
    ('semiconductor-engineer', 'materials-science'),
    ('semiconductor-engineer', 'circuit-design')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('semiconductor-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies environmental conditions and impacts to inform policy and conservation decisions.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '11 LPA' WHERE slug = 'environmental-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('environmental-scientist', 'environmental-impact-assessment'),
    ('environmental-scientist', 'ecology'),
    ('environmental-scientist', 'environmental-regulations')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('environmental-scientist', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises businesses and governments on environmental compliance, impact assessment and sustainability.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'environmental-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('environmental-consultant', 'environmental-regulations'),
    ('environmental-consultant', 'environmental-impact-assessment'),
    ('environmental-consultant', 'sustainability')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs processes and systems that reduce environmental impact and resource use.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'sustainability-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sustainability-engineer', 'sustainability'),
    ('sustainability-engineer', 'esg-frameworks'),
    ('sustainability-engineer', 'process-optimization')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and operates systems that treat water and wastewater to safe standards.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'water-treatment-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('water-treatment-engineer', 'water-treatment'),
    ('water-treatment-engineer', 'environmental-regulations'),
    ('water-treatment-engineer', 'process-design')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Identifies and models financial and operational risks to guide business decisions.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'risk-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('risk-analyst', 'risk-assessment'),
    ('risk-analyst', 'financial-analysis'),
    ('risk-analyst', 'statistical-modelling')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('risk-analyst', 'banking'),
    ('risk-analyst', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses financial data and market trends to guide investment and business decisions.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'financial-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('financial-analyst', 'financial-analysis'),
    ('financial-analyst', 'financial-modelling'),
    ('financial-analyst', 'excel')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('financial-analyst', 'banking'),
    ('financial-analyst', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Helps individuals plan savings, investments and retirement to meet financial goals.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'financial-planner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('financial-planner', 'financial-planning'),
    ('financial-planner', 'investment-analysis'),
    ('financial-planner', 'financial-literacy')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('financial-planner', 'banking'),
    ('financial-planner', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages an organization''s cash flow, liquidity and banking relationships.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'treasury-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('treasury-analyst', 'financial-analysis'),
    ('treasury-analyst', 'corporate-finance'),
    ('treasury-analyst', 'risk-assessment')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('treasury-analyst', 'banking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises companies on raising capital, mergers and acquisitions and financial strategy.', experience_level = 'Entry to Senior', salary_min = '8 LPA', salary_max = '40 LPA' WHERE slug = 'investment-banker';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('investment-banker', 'financial-modelling'),
    ('investment-banker', 'valuation'),
    ('investment-banker', 'deal-structuring')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('investment-banker', 'banking'),
    ('investment-banker', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Assesses the creditworthiness of borrowers to guide lending decisions.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'credit-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('credit-analyst', 'financial-analysis'),
    ('credit-analyst', 'risk-assessment'),
    ('credit-analyst', 'financial-modelling')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('credit-analyst', 'banking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages investment portfolios to meet clients'' return and risk objectives.', experience_level = 'Senior', salary_min = '12 LPA', salary_max = '40 LPA' WHERE slug = 'portfolio-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('portfolio-manager', 'valuation'),
    ('portfolio-manager', 'risk-management'),
    ('portfolio-manager', 'investment-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('portfolio-manager', 'banking'),
    ('portfolio-manager', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages forest land for timber production, conservation and ecosystem health.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'forester';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('forester', 'forest-management'),
    ('forester', 'silviculture'),
    ('forester', 'biodiversity-studies')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages and researches land and natural resources to support conservation goals.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'conservation-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('conservation-scientist', 'biodiversity-studies'),
    ('conservation-scientist', 'ecology'),
    ('conservation-scientist', 'wildlife-conservation')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages wildlife populations and habitats to balance conservation and human activity.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'wildlife-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('wildlife-manager', 'wildlife-conservation'),
    ('wildlife-manager', 'biodiversity-studies'),
    ('wildlife-manager', 'forest-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'A government forestry role enforcing conservation law and managing forest reserves.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'forest-officer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('forest-officer', 'forest-management'),
    ('forest-officer', 'public-administration'),
    ('forest-officer', 'wildlife-conservation')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('forest-officer', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and executes events end-to-end -- venue, vendors, logistics and budget.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'event-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('event-manager', 'event-management'),
    ('event-manager', 'event-coordination'),
    ('event-manager', 'budgeting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees daily restaurant operations -- staff, service quality, inventory and budgets.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'restaurant-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('restaurant-manager', 'food-beverage-management'),
    ('restaurant-manager', 'staff-management'),
    ('restaurant-manager', 'customer-service')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages food and beverage operations across a hotel or hospitality outlet.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'food-and-beverage-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('food-and-beverage-manager', 'food-beverage-management'),
    ('food-and-beverage-manager', 'staff-management'),
    ('food-and-beverage-manager', 'budgeting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees all hotel operations -- guest experience, staff, revenue and facilities.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'hotel-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hotel-manager', 'hotel-operations'),
    ('hotel-manager', 'revenue-management'),
    ('hotel-manager', 'staff-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages the guest-facing front desk team -- check-in, reservations and guest relations.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'front-office-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('front-office-manager', 'guest-relations'),
    ('front-office-manager', 'hotel-operations'),
    ('front-office-manager', 'staff-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages recruitment, employee relations, performance and policy for an organization''s workforce.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'hr-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hr-manager', 'employee-relations'),
    ('hr-manager', 'performance-management'),
    ('hr-manager', 'recruitment-talent-acquisition')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Sources, screens and hires candidates to fill an organization''s open positions.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'recruiter';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('recruiter', 'recruitment-talent-acquisition'),
    ('recruiter', 'interviewing'),
    ('recruiter', 'talent-acquisition')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and delivers training programs to build employee skills and capability.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'learning-and-development-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('learning-and-development-specialist', 'training-development'),
    ('learning-and-development-specialist', 'curriculum-design'),
    ('learning-and-development-specialist', 'mentorship')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages the end-to-end hiring pipeline -- sourcing, screening and offer negotiation.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'talent-acquisition-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('talent-acquisition-specialist', 'talent-acquisition'),
    ('talent-acquisition-specialist', 'recruitment-talent-acquisition'),
    ('talent-acquisition-specialist', 'interviewing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and benchmarks salary and benefits structures to keep pay competitive and fair.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'compensation-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('compensation-analyst', 'compensation-benefits'),
    ('compensation-analyst', 'hr-analytics'),
    ('compensation-analyst', 'data-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Partners with business leaders to align HR strategy -- talent, culture -- with business goals.', experience_level = 'Senior', salary_min = '10 LPA', salary_max = '25 LPA' WHERE slug = 'hr-business-partner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hr-business-partner', 'employee-relations'),
    ('hr-business-partner', 'organizational-development'),
    ('hr-business-partner', 'stakeholder-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Optimizes processes, layouts and workflows to improve efficiency and reduce waste.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'industrial-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('industrial-engineer', 'process-optimization'),
    ('industrial-engineer', 'lean-six-sigma'),
    ('industrial-engineer', 'operations-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and optimizes supply chain networks -- sourcing, logistics and inventory.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'supply-chain-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('supply-chain-engineer', 'supply-chain-management'),
    ('supply-chain-engineer', 'operations-research'),
    ('supply-chain-engineer', 'process-mapping')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Improves operational processes and systems to boost efficiency and reduce cost.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'operations-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('operations-engineer', 'operations-management'),
    ('operations-engineer', 'process-optimization'),
    ('operations-engineer', 'process-mapping')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops and enforces quality standards and testing processes across manufacturing.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'quality-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('quality-engineer', 'quality-control'),
    ('quality-engineer', 'quality-testing'),
    ('quality-engineer', 'failure-analysis-fmea')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Leads Lean/Six Sigma initiatives to continuously improve manufacturing processes.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'continuous-improvement-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('continuous-improvement-engineer', 'lean-six-sigma'),
    ('continuous-improvement-engineer', 'lean-manufacturing'),
    ('continuous-improvement-engineer', 'process-optimization')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and improves manufacturing processes, tooling and production lines.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'manufacturing-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('manufacturing-engineer', 'manufacturing-processes'),
    ('manufacturing-engineer', 'lean-manufacturing'),
    ('manufacturing-engineer', 'cad-cam')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages and maintains an organization''s day-to-day network operations and connectivity.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'network-administrator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('network-administrator', 'networking'),
    ('network-administrator', 'computer-networks'),
    ('network-administrator', 'system-administration')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('network-administrator', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides technical support to resolve hardware, software and connectivity issues for end users.', experience_level = 'Entry', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'it-support-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('it-support-engineer', 'troubleshooting'),
    ('it-support-engineer', 'it-infrastructure'),
    ('it-support-engineer', 'customer-service')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('it-support-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Monitors and resolves issues in production applications to keep them running smoothly.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'application-support-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('application-support-engineer', 'troubleshooting'),
    ('application-support-engineer', 'sql'),
    ('application-support-engineer', 'it-infrastructure')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('application-support-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages IT infrastructure operations -- servers, networks and systems -- for reliability.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'it-operations-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('it-operations-engineer', 'it-infrastructure'),
    ('it-operations-engineer', 'system-administration'),
    ('it-operations-engineer', 'troubleshooting')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('it-operations-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages IT service delivery -- incidents, requests and vendor relationships -- against SLAs.', experience_level = 'Senior', salary_min = '10 LPA', salary_max = '22 LPA' WHERE slug = 'it-service-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('it-service-manager', 'it-infrastructure'),
    ('it-service-manager', 'stakeholder-management'),
    ('it-service-manager', 'compliance')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('it-service-manager', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Monitors and protects IT systems from security threats and vulnerabilities.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'it-security-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('it-security-analyst', 'cybersecurity'),
    ('it-security-analyst', 'information-security'),
    ('it-security-analyst', 'incident-response')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('it-security-analyst', 'information-technology'),
    ('it-security-analyst', 'banking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages and monitors an organization''s cloud infrastructure and resources.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'cloud-administrator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cloud-administrator', 'cloud-platforms'),
    ('cloud-administrator', 'aws'),
    ('cloud-administrator', 'azure')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('cloud-administrator', 'information-technology'),
    ('cloud-administrator', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs, builds and maintains servers, networks and systems infrastructure.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'infrastructure-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('infrastructure-engineer', 'it-infrastructure'),
    ('infrastructure-engineer', 'cloud-platforms'),
    ('infrastructure-engineer', 'system-administration')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('infrastructure-engineer', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Installs, configures and maintains servers and systems for an organization.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '12 LPA' WHERE slug = 'system-administrator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('system-administrator', 'system-administration'),
    ('system-administrator', 'linux'),
    ('system-administrator', 'troubleshooting')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('system-administrator', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Reviews, refines and finalizes written content for publication across print or digital media.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '12 LPA' WHERE slug = 'editor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('editor', 'content-editing'),
    ('editor', 'writing'),
    ('editor', 'research-fact-checking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and buys advertising placements across media channels to reach target audiences.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'media-planner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('media-planner', 'campaign-management'),
    ('media-planner', 'market-research'),
    ('media-planner', 'digital-marketing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Creates and manages written, video or audio content across digital platforms.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '11 LPA' WHERE slug = 'content-producer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('content-producer', 'content-strategy'),
    ('content-producer', 'video-production'),
    ('content-producer', 'writing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages an organization''s public image, media relations and communication strategy.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'public-relations-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('public-relations-specialist', 'media-ethics'),
    ('public-relations-specialist', 'stakeholder-communication'),
    ('public-relations-specialist', 'crisis-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches, writes and reports news stories across print, broadcast or digital media.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '12 LPA' WHERE slug = 'journalist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('journalist', 'news-writing'),
    ('journalist', 'research-fact-checking'),
    ('journalist', 'investigation')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Writes persuasive marketing and advertising copy for brands across channels.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '11 LPA' WHERE slug = 'copywriter';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('copywriter', 'writing'),
    ('copywriter', 'branding'),
    ('copywriter', 'content-strategy')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Covers and reports breaking news stories for print, broadcast or digital outlets.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'news-reporter';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('news-reporter', 'news-writing'),
    ('news-reporter', 'investigation'),
    ('news-reporter', 'research-fact-checking')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Represents clients in court and provides legal advice across civil or criminal matters.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '20 LPA' WHERE slug = 'advocate';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('advocate', 'litigation'),
    ('advocate', 'legal-research'),
    ('advocate', 'legal-reasoning')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches case law, statutes and legal precedent to support litigation or policy work.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'legal-researcher';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('legal-researcher', 'legal-research'),
    ('legal-researcher', 'legal-reasoning'),
    ('legal-researcher', 'archival-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises an organization on legal risk, compliance and contractual matters.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '20 LPA' WHERE slug = 'legal-advisor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('legal-advisor', 'contract-law'),
    ('legal-advisor', 'compliance'),
    ('legal-advisor', 'legal-drafting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises companies on mergers, contracts, compliance and corporate governance.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '30 LPA' WHERE slug = 'corporate-lawyer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('corporate-lawyer', 'corporate-law'),
    ('corporate-lawyer', 'contract-law'),
    ('corporate-lawyer', 'deal-structuring')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides specialized legal advice to clients on a project or retainer basis.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'legal-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('legal-consultant', 'legal-knowledge'),
    ('legal-consultant', 'legal-research'),
    ('legal-consultant', 'legal-drafting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Represents and advises clients on legal matters across litigation, contracts or compliance.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '25 LPA' WHERE slug = 'lawyer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('lawyer', 'legal-reasoning'),
    ('lawyer', 'litigation'),
    ('lawyer', 'legal-drafting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Represents the state in criminal cases, presenting evidence and arguing for conviction.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'prosecutor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('prosecutor', 'litigation'),
    ('prosecutor', 'legal-reasoning'),
    ('prosecutor', 'constitutional-law')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Creates CAD models and CAM toolpaths that drive automated manufacturing machinery.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'cad-cam-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cad-cam-engineer', 'cad-cam'),
    ('cad-cam-engineer', 'cnc-programming'),
    ('cad-cam-engineer', 'drafting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and integrates automated systems and robotics into manufacturing lines.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '17 LPA' WHERE slug = 'manufacturing-automation-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('manufacturing-automation-engineer', 'industrial-automation'),
    ('manufacturing-automation-engineer', 'robotics-fundamentals'),
    ('manufacturing-automation-engineer', 'automation-plc')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('manufacturing-automation-engineer', 'automotive')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Programs and operates CNC machines to manufacture precision parts.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'cnc-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cnc-engineer', 'cnc-programming'),
    ('cnc-engineer', 'blueprint-reading'),
    ('cnc-engineer', 'precision')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Runs and optimizes paid digital ad campaigns to hit measurable growth targets.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'performance-marketing-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('performance-marketing-specialist', 'digital-marketing'),
    ('performance-marketing-specialist', 'seo-sem'),
    ('performance-marketing-specialist', 'campaign-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('performance-marketing-specialist', 'e-commerce'),
    ('performance-marketing-specialist', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Positions and markets a product, bridging product, sales and marketing teams.', experience_level = 'Senior', salary_min = '10 LPA', salary_max = '25 LPA' WHERE slug = 'product-marketing-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('product-marketing-manager', 'product-strategy'),
    ('product-marketing-manager', 'market-research'),
    ('product-marketing-manager', 'brand-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('product-marketing-manager', 'saas')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies markets, competitors and consumer behaviour to guide business strategy.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'market-research-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('market-research-analyst', 'market-research'),
    ('market-research-analyst', 'data-analysis'),
    ('market-research-analyst', 'consumer-behaviour-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Optimizes websites and content to rank higher in search engine results.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'seo-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('seo-specialist', 'seo-sem'),
    ('seo-specialist', 'content-strategy'),
    ('seo-specialist', 'data-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('seo-specialist', 'e-commerce')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and executes marketing strategy and campaigns to grow a brand or product.', experience_level = 'Senior', salary_min = '8 LPA', salary_max = '22 LPA' WHERE slug = 'marketing-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('marketing-manager', 'marketing-management'),
    ('marketing-manager', 'brand-management'),
    ('marketing-manager', 'campaign-management')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and runs marketing campaigns across digital channels -- search, social and email.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'digital-marketing-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('digital-marketing-specialist', 'digital-marketing'),
    ('digital-marketing-specialist', 'social-media-marketing'),
    ('digital-marketing-specialist', 'seo-sem')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('digital-marketing-specialist', 'e-commerce')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages a brand''s identity, positioning and marketing strategy across channels.', experience_level = 'Senior', salary_min = '8 LPA', salary_max = '20 LPA' WHERE slug = 'brand-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('brand-manager', 'brand-management'),
    ('brand-manager', 'branding'),
    ('brand-manager', 'market-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies mathematical theory and modelling to solve problems in research, finance or technology.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'mathematician';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mathematician', 'mathematics'),
    ('mathematician', 'mathematical-modelling'),
    ('mathematician', 'linear-algebra')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Builds mathematical and statistical models to price and manage financial risk.', experience_level = 'Entry to Senior', salary_min = '8 LPA', salary_max = '30 LPA' WHERE slug = 'quantitative-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('quantitative-analyst', 'mathematical-modelling'),
    ('quantitative-analyst', 'statistical-modelling'),
    ('quantitative-analyst', 'python')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('quantitative-analyst', 'banking'),
    ('quantitative-analyst', 'fintech')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies mathematical modelling and optimization to improve business decision-making.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'operations-research-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('operations-research-analyst', 'operations-research'),
    ('operations-research-analyst', 'mathematical-modelling'),
    ('operations-research-analyst', 'data-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs heating, ventilation and air-conditioning systems for buildings and facilities.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'hvac-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hvac-engineer', 'energy-modeling-software'),
    ('hvac-engineer', 'thermodynamics'),
    ('hvac-engineer', 'autocad')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and implements automated systems and robotics for industrial processes.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'automation-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('automation-engineer', 'automation-plc'),
    ('automation-engineer', 'industrial-automation'),
    ('automation-engineer', 'control-systems')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('automation-engineer', 'automotive')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Keeps industrial and plant machinery running through preventive maintenance and breakdown repair.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'maintenance-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('maintenance-engineer', 'maintenance-operations'),
    ('maintenance-engineer', 'troubleshooting'),
    ('maintenance-engineer', 'plant-safety')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and develops vehicle systems and components -- engines, chassis and electronics.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'automotive-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('automotive-engineer', 'machine-design'),
    ('automotive-engineer', 'cad-catia'),
    ('automotive-engineer', 'thermodynamics')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('automotive-engineer', 'automotive')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs mechanical parts and assemblies using CAD tools and engineering analysis.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'mechanical-design-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mechanical-design-engineer', 'machine-design'),
    ('mechanical-design-engineer', 'solidworks'),
    ('mechanical-design-engineer', 'gd-t')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and analyses heat transfer and thermal systems -- engines, HVAC and power plants.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'thermal-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('thermal-engineer', 'heat-transfer'),
    ('thermal-engineer', 'thermodynamics'),
    ('thermal-engineer', 'cfd')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Creates detailed 3D CAD models and drawings for mechanical parts and assemblies.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'cad-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cad-engineer', 'solidworks'),
    ('cad-engineer', 'cad-catia'),
    ('cad-engineer', 'drafting')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and programs robotic systems for industrial, medical or research applications.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '20 LPA' WHERE slug = 'robotics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('robotics-engineer', 'robotics-fundamentals'),
    ('robotics-engineer', 'ros'),
    ('robotics-engineer', 'sensors-actuators')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('robotics-engineer', 'automotive')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Combines mechanical, electronic and software engineering to design automated systems.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'mechatronics-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mechatronics-engineer', 'robotics-fundamentals'),
    ('mechatronics-engineer', 'automation-plc'),
    ('mechatronics-engineer', 'sensors-actuators')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses and treats disorders of the brain, spine and nervous system.', experience_level = 'Senior', salary_min = '15 LPA', salary_max = '40 LPA' WHERE slug = 'neurologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('neurologist', 'clinical-diagnosis'),
    ('neurologist', 'medical-terminology'),
    ('neurologist', 'patient-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('neurologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses and treats general medical conditions and manages ongoing patient care.', experience_level = 'Entry to Senior', salary_min = '8 LPA', salary_max = '25 LPA' WHERE slug = 'physician';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('physician', 'clinical-diagnosis'),
    ('physician', 'patient-care'),
    ('physician', 'medical-terminology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('physician', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses, treats and manages patients'' health across general or specialized medicine.', experience_level = 'Entry to Senior', salary_min = '8 LPA', salary_max = '25 LPA' WHERE slug = 'medical-doctor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('medical-doctor', 'clinical-diagnosis'),
    ('medical-doctor', 'patient-care'),
    ('medical-doctor', 'medical-ethics')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('medical-doctor', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses and treats medical conditions in infants, children and adolescents.', experience_level = 'Senior', salary_min = '12 LPA', salary_max = '30 LPA' WHERE slug = 'pediatrician';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('pediatrician', 'clinical-diagnosis'),
    ('pediatrician', 'patient-communication'),
    ('pediatrician', 'medical-terminology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('pediatrician', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses and treats diseases of the heart and cardiovascular system.', experience_level = 'Senior', salary_min = '18 LPA', salary_max = '50 LPA' WHERE slug = 'cardiologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('cardiologist', 'clinical-diagnosis'),
    ('cardiologist', 'medical-terminology'),
    ('cardiologist', 'patient-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('cardiologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Performs operations to treat injuries, diseases and deformities.', experience_level = 'Senior', salary_min = '20 LPA', salary_max = '50 LPA' WHERE slug = 'surgeon';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('surgeon', 'clinical-procedures'),
    ('surgeon', 'precision-dexterity'),
    ('surgeon', 'patient-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('surgeon', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Diagnoses and treats conditions of the skin, hair and nails.', experience_level = 'Senior', salary_min = '12 LPA', salary_max = '35 LPA' WHERE slug = 'dermatologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('dermatologist', 'clinical-diagnosis'),
    ('dermatologist', 'patient-care'),
    ('dermatologist', 'medical-terminology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('dermatologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches and develops new materials with improved properties for industrial use.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'materials-research-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('materials-research-engineer', 'material-science'),
    ('materials-research-engineer', 'materials-science'),
    ('materials-research-engineer', 'lab-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Selects and tests materials to meet strength, durability and cost requirements in products.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'materials-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('materials-engineer', 'materials-science'),
    ('materials-engineer', 'metallography'),
    ('materials-engineer', 'quality-testing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses and prevents material degradation from corrosion in industrial equipment.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'corrosion-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('corrosion-engineer', 'corrosion-engineering'),
    ('corrosion-engineer', 'materials-science'),
    ('corrosion-engineer', 'quality-testing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies the structure and properties of materials to develop new applications.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'materials-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('materials-scientist', 'materials-science'),
    ('materials-scientist', 'microscopy'),
    ('materials-scientist', 'lab-research')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Extracts and processes metals, and studies their structure and properties.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'metallurgical-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('metallurgical-engineer', 'metallurgical-processes'),
    ('metallurgical-engineer', 'metallography'),
    ('metallurgical-engineer', 'materials-science')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Develops and enforces safety procedures to prevent accidents in mining operations.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'mine-safety-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mine-safety-engineer', 'mine-safety'),
    ('mine-safety-engineer', 'mining-safety'),
    ('mine-safety-engineer', 'safety-standards')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs processes to extract and refine valuable minerals from ore.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'mineral-processing-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mineral-processing-engineer', 'mineral-processing'),
    ('mineral-processing-engineer', 'process-design'),
    ('mineral-processing-engineer', 'quality-testing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and designs mines and mining operations for safe, efficient mineral extraction.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '16 LPA' WHERE slug = 'mining-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mining-engineer', 'mine-planning'),
    ('mining-engineer', 'rock-mechanics'),
    ('mining-engineer', 'blasting-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Oversees day-to-day mining operations -- production, equipment and safety.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'mining-operations-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mining-operations-engineer', 'mining-safety'),
    ('mining-operations-engineer', 'mine-planning'),
    ('mining-operations-engineer', 'maintenance-operations')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans mine layouts, schedules and resource extraction sequences.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'mine-planning-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('mine-planning-engineer', 'mine-planning'),
    ('mine-planning-engineer', 'mine-surveying'),
    ('mine-planning-engineer', 'rock-mechanics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides urgent nursing care to patients in emergency and trauma settings.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'emergency-nurse';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('emergency-nurse', 'emergency-care'),
    ('emergency-nurse', 'patient-care'),
    ('emergency-nurse', 'clinical-assessment')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('emergency-nurse', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides critical care nursing to severely ill patients in intensive care units.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'icu-nurse';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('icu-nurse', 'clinical-procedures'),
    ('icu-nurse', 'patient-care'),
    ('icu-nurse', 'emergency-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('icu-nurse', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Delivers preventive healthcare and health education within community settings.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'community-health-nurse';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('community-health-nurse', 'patient-communication'),
    ('community-health-nurse', 'health-assessment'),
    ('community-health-nurse', 'community-engagement')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('community-health-nurse', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'An advanced-practice nurse who diagnoses and manages patient care independently.', experience_level = 'Senior', salary_min = '6 LPA', salary_max = '14 LPA' WHERE slug = 'nurse-practitioner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('nurse-practitioner', 'clinical-diagnosis'),
    ('nurse-practitioner', 'patient-care'),
    ('nurse-practitioner', 'medication-management')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('nurse-practitioner', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides direct patient care -- monitoring, medication and treatment -- in clinical settings.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'registered-nurse';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('registered-nurse', 'patient-care'),
    ('registered-nurse', 'nursing-ethics'),
    ('registered-nurse', 'clinical-procedures')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('registered-nurse', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Models underground oil and gas reservoirs to optimize extraction and recovery.', experience_level = 'Entry to Senior', salary_min = '8 LPA', salary_max = '30 LPA' WHERE slug = 'reservoir-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('reservoir-engineer', 'reservoir-engineering'),
    ('reservoir-engineer', 'petroleum-geology'),
    ('reservoir-engineer', 'well-testing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and oversees the drilling and completion of oil and gas wells.', experience_level = 'Entry to Senior', salary_min = '7 LPA', salary_max = '28 LPA' WHERE slug = 'well-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('well-engineer', 'drilling-engineering'),
    ('well-engineer', 'well-testing'),
    ('well-engineer', 'reservoir-engineering')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs methods to extract oil and gas efficiently and safely from reservoirs.', experience_level = 'Entry to Senior', salary_min = '7 LPA', salary_max = '28 LPA' WHERE slug = 'petroleum-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('petroleum-engineer', 'reservoir-engineering'),
    ('petroleum-engineer', 'drilling-engineering'),
    ('petroleum-engineer', 'petroleum-geology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and supervises the drilling of oil and gas wells.', experience_level = 'Entry to Senior', salary_min = '7 LPA', salary_max = '28 LPA' WHERE slug = 'drilling-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('drilling-engineer', 'drilling-engineering'),
    ('drilling-engineer', 'well-testing'),
    ('drilling-engineer', 'offshore-engineering')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises on medication therapy and safety in hospital or clinical settings.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '12 LPA' WHERE slug = 'clinical-pharmacist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('clinical-pharmacist', 'pharmacology'),
    ('clinical-pharmacist', 'medication-management'),
    ('clinical-pharmacist', 'patient-counselling')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('clinical-pharmacist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Dispenses medication and advises patients on safe and effective drug use.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'pharmacist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('pharmacist', 'pharmaceutics'),
    ('pharmacist', 'medication-management'),
    ('pharmacist', 'patient-counselling')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('pharmacist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Monitors and reports adverse drug reactions to ensure medicine safety.', experience_level = 'Entry to Mid', salary_min = '4 LPA', salary_max = '9 LPA' WHERE slug = 'drug-safety-associate';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('drug-safety-associate', 'drug-safety'),
    ('drug-safety-associate', 'drug-regulatory-affairs'),
    ('drug-safety-associate', 'pharmacology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('drug-safety-associate', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches and develops new drug formulations and delivery methods.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'pharmaceutical-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('pharmaceutical-scientist', 'pharmaceutics'),
    ('pharmaceutical-scientist', 'medicinal-chemistry'),
    ('pharmaceutical-scientist', 'lab-research')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('pharmaceutical-scientist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies how drugs interact with biological systems to inform safe, effective use.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'pharmacologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('pharmacologist', 'pharmacology'),
    ('pharmacologist', 'medicinal-chemistry'),
    ('pharmacologist', 'lab-research')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('pharmacologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches the fundamental laws of matter and energy through theory and experimentation.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'physicist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('physicist', 'quantum-mechanics'),
    ('physicist', 'classical-mechanics'),
    ('physicist', 'mathematical-modelling')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies physics to medical imaging and radiation therapy for patient diagnosis and treatment.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'medical-physicist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('medical-physicist', 'medical-imaging'),
    ('medical-physicist', 'quantum-mechanics'),
    ('medical-physicist', 'regulatory-standards')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('medical-physicist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and tests new technologies and prototypes in an applied research setting.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '18 LPA' WHERE slug = 'research-engineer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('research-engineer', 'experimental-design'),
    ('research-engineer', 'prototyping'),
    ('research-engineer', 'research-methodology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Treats and rehabilitates sports-related injuries to restore athletes'' movement and performance.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'sports-physiotherapist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sports-physiotherapist', 'sports-biomechanics'),
    ('sports-physiotherapist', 'rehabilitation-techniques'),
    ('sports-physiotherapist', 'injury-prevention')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('sports-physiotherapist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Assesses and treats movement disorders through exercise, manual therapy and rehabilitation.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'physiotherapist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('physiotherapist', 'rehabilitation-techniques'),
    ('physiotherapist', 'musculoskeletal-assessment'),
    ('physiotherapist', 'patient-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('physiotherapist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Helps patients recover physical function after injury, illness or surgery.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '8 LPA' WHERE slug = 'rehabilitation-therapist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('rehabilitation-therapist', 'rehabilitation-techniques'),
    ('rehabilitation-therapist', 'exercise-therapy'),
    ('rehabilitation-therapist', 'patient-care')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('rehabilitation-therapist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Provides guidance and emotional support to individuals facing personal or mental health challenges.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '9 LPA' WHERE slug = 'counselor';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('counselor', 'counselling-techniques'),
    ('counselor', 'empathy'),
    ('counselor', 'behavioural-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('counselor', 'healthcare'),
    ('counselor', 'education')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies psychology to improve workplace behaviour, culture and performance.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'organizational-psychologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('organizational-psychologist', 'behavioural-analysis'),
    ('organizational-psychologist', 'organizational-development'),
    ('organizational-psychologist', 'psychological-testing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Assesses and treats mental health conditions through therapy and psychological assessment.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'clinical-psychologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('clinical-psychologist', 'clinical-assessment'),
    ('clinical-psychologist', 'counselling-techniques'),
    ('clinical-psychologist', 'psychological-testing')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('clinical-psychologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Supports HR functions -- recruitment, employee relations and policy administration.', experience_level = 'Entry to Mid', salary_min = '3 LPA', salary_max = '7 LPA' WHERE slug = 'hr-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('hr-specialist', 'employee-relations'),
    ('hr-specialist', 'recruitment-talent-acquisition'),
    ('hr-specialist', 'hr-analytics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies human behaviour and mental processes to assess and support individuals.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '13 LPA' WHERE slug = 'psychologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('psychologist', 'psychological-testing'),
    ('psychologist', 'behavioural-analysis'),
    ('psychologist', 'counselling-techniques')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('psychologist', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages public-sector programs, budgets and operations within a government department.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '15 LPA' WHERE slug = 'government-administrator';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('government-administrator', 'public-administration'),
    ('government-administrator', 'policy-analysis'),
    ('government-administrator', 'governance')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('government-administrator', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Implements government policy and public services within an administrative department.', experience_level = 'Entry to Senior', salary_min = '6 LPA', salary_max = '18 LPA' WHERE slug = 'civil-servant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('civil-servant', 'public-administration'),
    ('civil-servant', 'governance'),
    ('civil-servant', 'policy-knowledge')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('civil-servant', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages an organization''s relationships with government and regulatory bodies.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '15 LPA' WHERE slug = 'public-affairs-specialist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('public-affairs-specialist', 'policy-analysis'),
    ('public-affairs-specialist', 'stakeholder-communication'),
    ('public-affairs-specialist', 'public-policy-analysis')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('public-affairs-specialist', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Researches and evaluates public policy options to advise government or organizations.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '14 LPA' WHERE slug = 'policy-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('policy-analyst', 'policy-analysis'),
    ('policy-analyst', 'public-policy-analysis'),
    ('policy-analyst', 'research-methodology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('policy-analyst', 'government')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and conducts studies on social behaviour, trends and structures.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'social-researcher';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('social-researcher', 'social-research-methods'),
    ('social-researcher', 'survey-design'),
    ('social-researcher', 'critical-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Studies human society, social behaviour and institutions through research.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '11 LPA' WHERE slug = 'sociologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sociologist', 'social-research-methods'),
    ('sociologist', 'critical-analysis'),
    ('sociologist', 'research-methods')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Supports individuals and communities facing hardship through counselling and social services.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'social-worker';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('social-worker', 'case-management'),
    ('social-worker', 'community-engagement'),
    ('social-worker', 'empathy')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies exercise science to improve athletic performance and prevent injury.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'sports-scientist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sports-scientist', 'exercise-physiology'),
    ('sports-scientist', 'sports-biomechanics'),
    ('sports-scientist', 'performance-analysis')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses athlete and team performance data to guide training and strategy.', experience_level = 'Entry to Senior', salary_min = '3 LPA', salary_max = '10 LPA' WHERE slug = 'sports-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sports-analyst', 'performance-analysis'),
    ('sports-analyst', 'data-analysis'),
    ('sports-analyst', 'sports-biomechanics')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs nutrition plans to optimize athletes'' performance and recovery.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'sports-nutritionist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sports-nutritionist', 'sports-nutrition'),
    ('sports-nutritionist', 'nutrition-basics'),
    ('sports-nutritionist', 'patient-communication')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs training programs to build athletes'' strength, speed and endurance.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '7 LPA' WHERE slug = 'strength-and-conditioning-coach';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('strength-and-conditioning-coach', 'strength-conditioning'),
    ('strength-and-conditioning-coach', 'exercise-science'),
    ('strength-and-conditioning-coach', 'motivation-coaching')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs and leads fitness programs to help clients reach health and fitness goals.', experience_level = 'Entry', salary_min = '2 LPA', salary_max = '5 LPA' WHERE slug = 'fitness-trainer';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('fitness-trainer', 'physical-fitness'),
    ('fitness-trainer', 'motivation-coaching'),
    ('fitness-trainer', 'exercise-science')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Helps athletes build mental resilience, focus and performance under pressure.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '12 LPA' WHERE slug = 'sports-psychologist';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('sports-psychologist', 'behavioural-analysis'),
    ('sports-psychologist', 'motivation-coaching'),
    ('sports-psychologist', 'counselling-techniques')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Analyses data to uncover trends and insights that support business decisions.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'data-analyst';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('data-analyst', 'data-analysis'),
    ('data-analyst', 'statistics'),
    ('data-analyst', 'sql')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('data-analyst', 'information-technology')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs studies and applies statistical methods to analyse and interpret data.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '15 LPA' WHERE slug = 'statistician';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('statistician', 'statistics'),
    ('statistician', 'statistical-modelling'),
    ('statistician', 'probability-theory')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Applies statistical methods to design and analyse biological and medical research studies.', experience_level = 'Entry to Senior', salary_min = '5 LPA', salary_max = '16 LPA' WHERE slug = 'biostatistician';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('biostatistician', 'statistical-modelling'),
    ('biostatistician', 'statistics'),
    ('biostatistician', 'research-methodology')
ON CONFLICT DO NOTHING;
INSERT INTO job_role_industries (job_role_slug, industry_slug) VALUES
    ('biostatistician', 'healthcare')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Plans and leads guided tours, managing logistics, itineraries and guest experience.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '7 LPA' WHERE slug = 'tour-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('tour-manager', 'tour-planning-operations'),
    ('tour-manager', 'travel-documentation'),
    ('tour-manager', 'guest-relations')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Designs custom travel itineraries and bookings for individual or group clients.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'travel-planner';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('travel-planner', 'tour-planning-operations'),
    ('travel-planner', 'travel-documentation'),
    ('travel-planner', 'destination-marketing')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Advises clients on travel options and books flights, hotels and packages.', experience_level = 'Entry to Mid', salary_min = '2.5 LPA', salary_max = '6 LPA' WHERE slug = 'travel-consultant';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('travel-consultant', 'travel-documentation'),
    ('travel-consultant', 'customer-service'),
    ('travel-consultant', 'tour-planning-operations')
ON CONFLICT DO NOTHING;

UPDATE job_roles SET description = 'Manages tourism operations and marketing for a specific travel destination.', experience_level = 'Entry to Senior', salary_min = '4 LPA', salary_max = '12 LPA' WHERE slug = 'destination-manager';
INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('destination-manager', 'destination-marketing'),
    ('destination-manager', 'tour-planning-operations'),
    ('destination-manager', 'stakeholder-management')
ON CONFLICT DO NOTHING;
