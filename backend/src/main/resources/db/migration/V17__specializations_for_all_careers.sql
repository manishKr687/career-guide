-- Extends the Specializations catalog entity (introduced in V16 for Aerospace
-- Engineer only) to every other career, following the same "linked to real
-- courses/exams, not a plain tag" bar. See V16's migration comment and the
-- backend README for the full rationale.
--
-- Every specialization here reuses an EXISTING course and/or exam already in
-- the catalog (mostly the same ones already linked to that career via
-- career_courses/career_exams, occasionally one more genuinely relevant
-- catalog entry, the same pattern V16 used for Avionics -> ECE). A handful of
-- careers with no standardized entrance exam (School Principal, Entrepreneur,
-- Digital Marketing Manager, Electrician, Plumber, Fitness Trainer,
-- Sustainability Consultant) link their specializations to courses only --
-- that's a real gap in the catalog's own exam coverage, not an omission here.
--
-- career_specializations/specialization_courses/specialization_exams are all
-- brand-new (career_slug, specialization_slug) groups here -- none of these 54
-- careers had any specialization rows before this migration, and every new
-- specialization slug is new too -- so every sort_order sequence below starts
-- fresh at 0 with no pre-existing rows to collide with (see V14's postmortem).

-- ---------------------------------------------------------------------
-- Specializations
-- ---------------------------------------------------------------------

INSERT INTO specializations (slug, name, description, icon) VALUES ('plant-breeding-genetics', 'Plant Breeding & Genetics', 'Develops improved crop varieties through breeding and genetic selection for higher yield, pest resistance and climate resilience.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('soil-science', 'Soil Science', 'Studies soil fertility, composition and health to guide irrigation, fertilization and sustainable land-use decisions.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('agri-biotechnology', 'Agricultural Biotechnology', 'Applies genetic engineering and biotech tools to crops and livestock -- the discipline behind GM seeds, tissue culture and biofertilizers.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('archival-research', 'Archival & Museum Studies', 'Curates, preserves and interprets primary historical documents and artifacts, largely the domain of archives and museums.', 'book');
INSERT INTO specializations (slug, name, description, icon) VALUES ('ancient-medieval-history', 'Ancient & Medieval History', 'Focuses on India''s and the world''s ancient and medieval periods through textual, epigraphic and archaeological evidence.', 'book');
INSERT INTO specializations (slug, name, description, icon) VALUES ('modern-indian-history', 'Modern Indian History', 'Studies colonial and post-independence India -- the freedom movement, partition and nation-building -- often the base for competitive-exam and academic careers.', 'book');
INSERT INTO specializations (slug, name, description, icon) VALUES ('clinical-psychology', 'Clinical Psychology', 'Diagnoses and treats mental health conditions through therapy in hospitals, clinics or private practice.', 'heart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('counselling-psychology', 'Counselling Psychology', 'Helps people navigate personal, relationship, academic or career challenges through structured counselling.', 'heart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('organizational-psychology', 'Organizational Psychology', 'Applies psychological principles to workplace behaviour, hiring, and employee wellbeing for organizations.', 'users');
INSERT INTO specializations (slug, name, description, icon) VALUES ('retail-banking', 'Retail Banking', 'Manages day-to-day customer banking -- accounts, deposits and personal loans -- at the branch level.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('credit-loans', 'Credit & Loans', 'Evaluates and processes loan applications, from personal loans to business credit, assessing risk and repayment capacity.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('treasury-forex', 'Treasury & Forex', 'Manages a bank''s investments, liquidity and foreign-exchange operations.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('core-banking-systems', 'Core Banking Systems', 'Maintains and develops the centralized software that powers a bank''s day-to-day transactions and account management.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('banking-cybersecurity', 'Banking Cybersecurity', 'Protects banking systems and customer data from fraud, breaches and cyberattacks.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('digital-payments', 'Digital Payments', 'Builds and manages UPI, net-banking and card payment infrastructure behind digital transactions.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('business-intelligence', 'Business Intelligence', 'Turns raw business data into dashboards and reports that guide day-to-day decision-making.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('financial-analytics', 'Financial Analytics', 'Analyzes financial data -- revenue, costs, forecasts -- to support budgeting and investment decisions.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('marketing-analytics', 'Marketing Analytics', 'Measures campaign performance and customer behaviour to guide marketing spend and strategy.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('audit-assurance', 'Audit & Assurance', 'Independently verifies a company''s financial statements for accuracy and regulatory compliance.', 'doc');
INSERT INTO specializations (slug, name, description, icon) VALUES ('taxation', 'Taxation', 'Advises individuals and businesses on direct and indirect tax planning, filing and compliance.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('corporate-finance', 'Corporate Finance', 'Advises on capital structure, budgeting and financial strategy for companies.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('corporate-compliance', 'Corporate Compliance', 'Ensures a company follows the Companies Act and other statutory and regulatory requirements.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('corporate-governance', 'Corporate Governance', 'Advises company boards on governance structure, shareholder rights and ethical business practice.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mergers-acquisitions', 'Mergers & Acquisitions', 'Advises companies on buying, selling or merging with other businesses, structuring the deal end-to-end.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('equity-capital-markets', 'Equity Capital Markets', 'Helps companies raise capital by issuing shares through IPOs and follow-on offerings.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('private-equity', 'Private Equity', 'Invests in and helps grow private companies, typically taking an ownership stake and an active management role.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('infantry', 'Infantry', 'Leads ground combat units -- the Army''s largest and most frontline arm.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('artillery', 'Artillery', 'Operates long-range weapon systems that provide fire support to infantry and armoured units.', 'target');
INSERT INTO specializations (slug, name, description, icon) VALUES ('army-aviation', 'Army Aviation', 'Flies and coordinates helicopters for reconnaissance, transport and combat support.', 'plane');
INSERT INTO specializations (slug, name, description, icon) VALUES ('interaction-design', 'Interaction Design', 'Designs how users interact with an app or website -- flows, gestures and micro-interactions.', 'palette');
INSERT INTO specializations (slug, name, description, icon) VALUES ('ux-research', 'UX Research', 'Studies real user behaviour and needs through interviews, testing and analytics to guide design decisions.', 'search');
INSERT INTO specializations (slug, name, description, icon) VALUES ('product-design-systems', 'Design Systems', 'Builds and maintains reusable component libraries and design standards across a product.', 'layers');
INSERT INTO specializations (slug, name, description, icon) VALUES ('branding-identity', 'Branding & Identity', 'Creates logos, color systems and visual identities that define how a brand looks and feels.', 'palette');
INSERT INTO specializations (slug, name, description, icon) VALUES ('motion-graphics', 'Motion Graphics', 'Designs animated visuals and video graphics for ads, social media and product demos.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('print-packaging-design', 'Print & Packaging Design', 'Designs physical print materials and product packaging, balancing print production constraints with visual impact.', 'layers');
INSERT INTO specializations (slug, name, description, icon) VALUES ('primary-education', 'Primary Education', 'Teaches foundational literacy and numeracy to young children in the early years of school.', 'teach');
INSERT INTO specializations (slug, name, description, icon) VALUES ('subject-specialist-teaching', 'Subject-Specialist Teaching', 'Teaches a specific subject -- Science, Math, English or others -- at the middle or senior school level.', 'book');
INSERT INTO specializations (slug, name, description, icon) VALUES ('special-education', 'Special Education', 'Teaches and supports students with learning disabilities or other special needs.', 'heart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('academic-administration', 'Academic Administration', 'Manages a school''s day-to-day operations, staffing, scheduling and compliance.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('curriculum-leadership', 'Curriculum Leadership', 'Shapes a school''s academic curriculum and teaching standards across grades and subjects.', 'book');
INSERT INTO specializations (slug, name, description, icon) VALUES ('academic-research', 'Academic Research', 'Conducts original research and publishes findings, often alongside teaching.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('higher-ed-teaching', 'Higher Education Teaching', 'Focuses primarily on teaching and mentoring students at the undergraduate or postgraduate level.', 'teach');
INSERT INTO specializations (slug, name, description, icon) VALUES ('computer-vision', 'Computer Vision', 'Builds systems that let computers interpret images and video -- the tech behind facial recognition and self-driving perception.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('nlp', 'Natural Language Processing', 'Builds systems that understand and generate human language -- the tech behind chatbots and translation.', 'mega');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mlops', 'MLOps & Deployment', 'Builds and maintains the infrastructure to deploy, monitor and retrain machine learning models in production.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('carbon-esg-reporting', 'Carbon & ESG Reporting', 'Helps companies measure and report their carbon footprint and ESG performance for regulators and investors.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('renewable-energy-consulting', 'Renewable Energy Consulting', 'Advises businesses on adopting solar, wind and other renewable energy sources to cut emissions and costs.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('thermal-engineering', 'Thermal Engineering', 'Designs engines, turbines and heat-exchange systems that convert or manage thermal energy.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('design-manufacturing', 'Design & Manufacturing (CAD/CAM)', 'Uses CAD/CAM tools to design mechanical parts and the manufacturing processes that produce them.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('automotive-engineering', 'Automotive Engineering', 'Designs and develops vehicles and their components -- engines, transmissions, chassis and increasingly EV systems.', 'wrench');
INSERT INTO specializations (slug, name, description, icon) VALUES ('structural-engineering', 'Structural Engineering', 'Designs the load-bearing structure of buildings, bridges and towers to safely withstand loads and stresses.', 'building');
INSERT INTO specializations (slug, name, description, icon) VALUES ('transportation-engineering', 'Transportation Engineering', 'Plans and designs roads, railways, airports and traffic systems.', 'train');
INSERT INTO specializations (slug, name, description, icon) VALUES ('environmental-water-engineering', 'Environmental & Water Resources', 'Designs water supply, drainage and wastewater systems, and manages environmental impact of construction.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('power-systems', 'Power Systems', 'Designs and manages the generation, transmission and distribution of electrical power.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('control-systems', 'Control Systems', 'Designs automated control systems that regulate machinery, processes and electrical equipment.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('renewable-energy-systems', 'Renewable Energy Systems', 'Designs solar, wind and other renewable power generation and grid-integration systems.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('vlsi-design', 'VLSI Design', 'Designs integrated circuits and microchips -- the silicon at the heart of every electronic device.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('embedded-systems', 'Embedded Systems', 'Designs the microcontroller-based hardware and firmware inside everyday electronic products.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('communication-systems', 'Communication Systems', 'Designs the systems behind wireless, satellite and fiber-optic communication networks.', 'mega');
INSERT INTO specializations (slug, name, description, icon) VALUES ('process-engineering', 'Process Engineering', 'Designs and optimizes industrial chemical manufacturing processes for safety, efficiency and scale.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('petrochemicals-refining', 'Petrochemicals & Refining', 'Works on refining crude oil and producing petrochemicals like plastics and fertilizers.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('polymer-engineering', 'Polymer Engineering', 'Develops plastics, rubbers and other polymer materials for industrial and consumer use.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('medical-imaging', 'Medical Imaging', 'Designs and maintains imaging equipment like MRI, CT and ultrasound machines.', 'steth');
INSERT INTO specializations (slug, name, description, icon) VALUES ('biomedical-instrumentation', 'Biomedical Instrumentation', 'Designs medical devices and diagnostic instruments used in hospitals and labs.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('prosthetics-implants', 'Prosthetics & Implants', 'Designs artificial limbs, joints and implants that restore function lost to injury or disease.', 'heart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('water-wastewater-treatment', 'Water & Wastewater Treatment', 'Designs systems that treat drinking water and wastewater to safe, regulated standards.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('air-pollution-control', 'Air Pollution Control', 'Designs systems and policies to monitor and reduce industrial and vehicular air pollution.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('waste-management', 'Waste Management', 'Designs systems for the collection, treatment and safe disposal or recycling of solid waste.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('ship-propulsion-systems', 'Ship Propulsion Systems', 'Designs and maintains the engines and propulsion machinery that power ships.', 'ship');
INSERT INTO specializations (slug, name, description, icon) VALUES ('naval-architecture', 'Naval Architecture', 'Designs the hull, stability and structure of ships and other marine vessels.', 'ship');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mine-planning-design', 'Mine Planning & Design', 'Plans how a mine is laid out and extracted safely and efficiently over its lifetime.', 'pickaxe');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mineral-processing', 'Mineral Processing', 'Processes raw ore into usable, purified minerals and metals after extraction.', 'pickaxe');
INSERT INTO specializations (slug, name, description, icon) VALUES ('industrial-automation', 'Industrial Automation', 'Designs automated manufacturing lines that combine mechanical, electrical and software systems.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('robotics-integration', 'Robotics Integration', 'Integrates robotic arms and automated systems into existing industrial processes.', 'robot');
INSERT INTO specializations (slug, name, description, icon) VALUES ('autonomous-systems', 'Autonomous Systems', 'Designs robots and vehicles that can navigate and make decisions with minimal human input.', 'robot');
INSERT INTO specializations (slug, name, description, icon) VALUES ('robotic-perception-ai', 'Robotic Perception & AI', 'Combines sensors, computer vision and AI to let robots perceive and understand their environment.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('startup-fundraising', 'Startup Fundraising', 'Raises capital from angel investors, venture capital and other sources to grow a startup.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('product-led-growth', 'Product-Led Growth', 'Builds and scales a business where the product itself drives user acquisition and retention.', 'trend');
INSERT INTO specializations (slug, name, description, icon) VALUES ('district-administration', 'District Administration', 'Runs the day-to-day administration of a district -- law and order, welfare schemes and public services.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('policy-public-administration', 'Policy & Public Administration', 'Shapes and implements government policy at the state or central secretariat level.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('law-order-crime-investigation', 'Law & Order / Crime Investigation', 'Leads police units responsible for maintaining law and order and investigating crimes.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('traffic-cyber-policing', 'Traffic & Cyber Policing', 'Manages traffic enforcement and increasingly, cybercrime investigation units.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('satellite-systems', 'Satellite Systems', 'Designs and builds satellites -- their structure, power, communication and payload systems.', 'rocket');
INSERT INTO specializations (slug, name, description, icon) VALUES ('launch-vehicle-systems', 'Launch Vehicle Systems', 'Designs and builds the rockets that carry satellites and payloads into orbit.', 'rocket');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mission-software-systems', 'Mission Software Systems', 'Develops the flight software and ground systems that control satellites and missions.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('signal-telecom', 'Signal & Telecommunication', 'Maintains railway signaling and telecommunication systems that keep trains running safely.', 'mega');
INSERT INTO specializations (slug, name, description, icon) VALUES ('track-civil-works', 'Track & Civil Works', 'Maintains and builds railway tracks, bridges and other civil infrastructure.', 'train');
INSERT INTO specializations (slug, name, description, icon) VALUES ('rolling-stock-maintenance', 'Rolling Stock Maintenance', 'Maintains locomotives, coaches and wagons -- the Railways'' mechanical fleet.', 'wrench');
INSERT INTO specializations (slug, name, description, icon) VALUES ('market-surveillance-systems', 'Market Surveillance Systems', 'Builds and maintains systems that monitor stock market trading for irregularities and fraud.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('fintech-regulation', 'Fintech Regulation', 'Shapes and enforces IT and data-security regulations for India''s fast-growing fintech sector.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('front-office-guest-relations', 'Front Office & Guest Relations', 'Manages guest check-in, reservations and the overall guest experience at a hotel.', 'user');
INSERT INTO specializations (slug, name, description, icon) VALUES ('food-beverage-management', 'Food & Beverage Management', 'Oversees a hotel''s restaurants, bars and catering operations.', 'star');
INSERT INTO specializations (slug, name, description, icon) VALUES ('event-banquet-management', 'Event & Banquet Management', 'Plans and executes weddings, conferences and other large hotel-hosted events.', 'cal');
INSERT INTO specializations (slug, name, description, icon) VALUES ('machine-learning', 'Machine Learning', 'Builds predictive models and algorithms that learn patterns from data.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('big-data-engineering', 'Big Data Engineering', 'Builds the pipelines and infrastructure that collect, store and process massive datasets.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('data-visualization-analytics', 'Data Visualization & Analytics', 'Turns complex datasets into clear visualizations and insights for decision-makers.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('frontend-development', 'Frontend Development', 'Builds the user-facing part of websites and apps -- what people actually see and interact with.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('backend-development', 'Backend Development', 'Builds the servers, databases and APIs that power an application behind the scenes.', 'code');
INSERT INTO specializations (slug, name, description, icon) VALUES ('mobile-app-development', 'Mobile App Development', 'Builds native or cross-platform apps for Android and iOS.', 'phone');
INSERT INTO specializations (slug, name, description, icon) VALUES ('network-security', 'Network Security', 'Protects an organization''s networks from unauthorized access and attacks.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('ethical-hacking-pentesting', 'Ethical Hacking & Pen Testing', 'Simulates real attacks on systems to find and fix security vulnerabilities before criminals do.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('security-operations-incident-response', 'Security Operations & Incident Response', 'Monitors systems for threats around the clock and responds when a breach occurs.', 'shield');
INSERT INTO specializations (slug, name, description, icon) VALUES ('multi-cloud-infrastructure', 'Multi-Cloud Infrastructure', 'Designs scalable infrastructure across AWS, Azure and GCP for reliability and cost efficiency.', 'monitor');
INSERT INTO specializations (slug, name, description, icon) VALUES ('devops-cicd', 'DevOps & CI/CD', 'Builds automated pipelines that let software be built, tested and deployed continuously and reliably.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('corporate-law', 'Corporate Law', 'Advises businesses on contracts, mergers, compliance and corporate structuring.', 'brief');
INSERT INTO specializations (slug, name, description, icon) VALUES ('criminal-law', 'Criminal Law', 'Represents clients in criminal proceedings, from defense to prosecution.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('litigation-dispute-resolution', 'Litigation & Dispute Resolution', 'Represents clients in civil court cases and alternative dispute resolution like arbitration.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('civil-judiciary', 'Civil Judiciary', 'Adjudicates civil disputes -- property, contracts, family matters -- in the lower judiciary.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('criminal-judiciary', 'Criminal Judiciary', 'Adjudicates criminal cases, from trial to sentencing, in the lower judiciary.', 'scale');
INSERT INTO specializations (slug, name, description, icon) VALUES ('product-strategy', 'Product Strategy', 'Defines a product''s vision, roadmap and priorities based on user needs and business goals.', 'target');
INSERT INTO specializations (slug, name, description, icon) VALUES ('growth-product-management', 'Growth Product Management', 'Focuses on user acquisition, activation and retention metrics to grow a product''s user base.', 'trend');
INSERT INTO specializations (slug, name, description, icon) VALUES ('technical-product-management', 'Technical Product Management', 'Works closely with engineering on technically complex products, often requiring a strong technical background.', 'chip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('process-analysis', 'Process Analysis', 'Studies and improves how a business''s internal workflows and processes operate.', 'gear');
INSERT INTO specializations (slug, name, description, icon) VALUES ('business-intelligence-reporting', 'Business Intelligence & Reporting', 'Builds reports and dashboards that translate business data into decisions.', 'chart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('requirements-management', 'Requirements Management', 'Gathers and documents what a business or client actually needs, translating it for technical teams.', 'clip');
INSERT INTO specializations (slug, name, description, icon) VALUES ('talent-acquisition', 'Talent Acquisition', 'Sources, interviews and hires the right people for an organization''s open roles.', 'users');
INSERT INTO specializations (slug, name, description, icon) VALUES ('compensation-benefits', 'Compensation & Benefits', 'Designs pay structures, incentives and benefits packages that attract and retain employees.', 'bank');
INSERT INTO specializations (slug, name, description, icon) VALUES ('learning-development', 'Learning & Development', 'Designs training programs that build employee skills and support career growth.', 'teach');
INSERT INTO specializations (slug, name, description, icon) VALUES ('seo-content-marketing', 'SEO & Content Marketing', 'Improves a website''s search ranking and creates content that attracts organic traffic.', 'search');
INSERT INTO specializations (slug, name, description, icon) VALUES ('paid-media-performance-marketing', 'Paid Media & Performance Marketing', 'Runs and optimizes paid ad campaigns across Google, Meta and other platforms for measurable ROI.', 'target');
INSERT INTO specializations (slug, name, description, icon) VALUES ('social-media-marketing', 'Social Media Marketing', 'Builds and manages a brand''s presence and engagement across social platforms.', 'mega');
INSERT INTO specializations (slug, name, description, icon) VALUES ('print-digital-journalism', 'Print & Digital Journalism', 'Reports and writes news stories for newspapers, magazines and digital publications.', 'doc');
INSERT INTO specializations (slug, name, description, icon) VALUES ('broadcast-journalism', 'Broadcast Journalism', 'Reports and presents news for television and radio.', 'mega');
INSERT INTO specializations (slug, name, description, icon) VALUES ('investigative-journalism', 'Investigative Journalism', 'Conducts in-depth, often long-term investigations into corruption, crime or public interest issues.', 'search');
INSERT INTO specializations (slug, name, description, icon) VALUES ('general-medicine', 'General Medicine', 'Diagnoses and treats a broad range of adult illnesses as a first point of medical contact.', 'steth');
INSERT INTO specializations (slug, name, description, icon) VALUES ('surgery', 'Surgery', 'Performs operative procedures to treat injuries, diseases and deformities.', 'heart');
INSERT INTO specializations (slug, name, description, icon) VALUES ('pediatrics', 'Pediatrics', 'Diagnoses and treats illnesses in infants, children and adolescents.', 'users');
INSERT INTO specializations (slug, name, description, icon) VALUES ('emergency-critical-care', 'Emergency & Critical Care', 'Manages acute, life-threatening conditions in emergency rooms and intensive care units.', 'pulse');
INSERT INTO specializations (slug, name, description, icon) VALUES ('critical-care-nursing', 'Critical Care Nursing', 'Provides intensive, round-the-clock nursing care to critically ill patients in ICUs.', 'pulse');
INSERT INTO specializations (slug, name, description, icon) VALUES ('community-public-health-nursing', 'Community & Public Health Nursing', 'Delivers preventive healthcare and health education in community settings.', 'leaf');
INSERT INTO specializations (slug, name, description, icon) VALUES ('orthodontics', 'Orthodontics', 'Corrects misaligned teeth and jaws using braces and other appliances.', 'steth');
INSERT INTO specializations (slug, name, description, icon) VALUES ('oral-maxillofacial-surgery', 'Oral & Maxillofacial Surgery', 'Performs surgical procedures on the mouth, jaw and face.', 'steth');
INSERT INTO specializations (slug, name, description, icon) VALUES ('clinical-pharmacy', 'Clinical Pharmacy', 'Works directly with doctors and patients in hospitals to optimize medication therapy.', 'steth');
INSERT INTO specializations (slug, name, description, icon) VALUES ('pharmaceutical-manufacturing', 'Pharmaceutical Manufacturing', 'Works in the industrial production and quality control of medicines.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('physical-sciences-research', 'Physical Sciences Research', 'Conducts research in physics, chemistry or related physical sciences, often in national labs or academia.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('life-sciences-biotech-research', 'Life Sciences & Biotech Research', 'Conducts research in biology, genetics or biotechnology, often for drug discovery or agriculture.', 'flask');
INSERT INTO specializations (slug, name, description, icon) VALUES ('residential-wiring', 'Residential Wiring', 'Installs and repairs electrical wiring and fixtures in homes.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('industrial-electrical-maintenance', 'Industrial Electrical Maintenance', 'Maintains and repairs electrical systems and machinery in factories and industrial plants.', 'bolt');
INSERT INTO specializations (slug, name, description, icon) VALUES ('residential-plumbing', 'Residential Plumbing', 'Installs and repairs water supply and drainage systems in homes.', 'wrench');
INSERT INTO specializations (slug, name, description, icon) VALUES ('industrial-pipefitting', 'Industrial Pipefitting', 'Installs and maintains large-scale piping systems in factories and industrial facilities.', 'wrench');
INSERT INTO specializations (slug, name, description, icon) VALUES ('strength-conditioning', 'Strength & Conditioning', 'Designs strength and conditioning programs for individuals or athletes to build fitness and performance.', 'trophy');
INSERT INTO specializations (slug, name, description, icon) VALUES ('group-fitness-instruction', 'Group Fitness Instruction', 'Leads group workout classes like aerobics, spin or yoga at gyms and studios.', 'users');

-- ---------------------------------------------------------------------
-- career_specializations (each career's own list, sort_order 0..N-1)
-- ---------------------------------------------------------------------

-- agricultural-scientist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('agricultural-scientist', 'plant-breeding-genetics', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('agricultural-scientist', 'soil-science', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('agricultural-scientist', 'agri-biotechnology', 2) ON CONFLICT DO NOTHING;

-- historian
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('historian', 'archival-research', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('historian', 'ancient-medieval-history', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('historian', 'modern-indian-history', 2) ON CONFLICT DO NOTHING;

-- psychologist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('psychologist', 'clinical-psychology', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('psychologist', 'counselling-psychology', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('psychologist', 'organizational-psychology', 2) ON CONFLICT DO NOTHING;

-- bank-po
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('bank-po', 'retail-banking', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('bank-po', 'credit-loans', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('bank-po', 'treasury-forex', 2) ON CONFLICT DO NOTHING;

-- ibps-it-officer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ibps-it-officer', 'core-banking-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ibps-it-officer', 'banking-cybersecurity', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ibps-it-officer', 'digital-payments', 2) ON CONFLICT DO NOTHING;

-- data-analyst
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-analyst', 'business-intelligence', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-analyst', 'financial-analytics', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-analyst', 'marketing-analytics', 2) ON CONFLICT DO NOTHING;

-- chartered-accountant
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chartered-accountant', 'audit-assurance', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chartered-accountant', 'taxation', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chartered-accountant', 'corporate-finance', 2) ON CONFLICT DO NOTHING;

-- company-secretary
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('company-secretary', 'corporate-compliance', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('company-secretary', 'corporate-governance', 1) ON CONFLICT DO NOTHING;

-- investment-banker
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('investment-banker', 'mergers-acquisitions', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('investment-banker', 'equity-capital-markets', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('investment-banker', 'private-equity', 2) ON CONFLICT DO NOTHING;

-- army-officer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('army-officer', 'infantry', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('army-officer', 'artillery', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('army-officer', 'army-aviation', 2) ON CONFLICT DO NOTHING;

-- ux-designer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ux-designer', 'interaction-design', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ux-designer', 'ux-research', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ux-designer', 'product-design-systems', 2) ON CONFLICT DO NOTHING;

-- graphic-designer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('graphic-designer', 'branding-identity', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('graphic-designer', 'motion-graphics', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('graphic-designer', 'print-packaging-design', 2) ON CONFLICT DO NOTHING;

-- school-teacher
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('school-teacher', 'primary-education', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('school-teacher', 'subject-specialist-teaching', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('school-teacher', 'special-education', 2) ON CONFLICT DO NOTHING;

-- school-principal
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('school-principal', 'academic-administration', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('school-principal', 'curriculum-leadership', 1) ON CONFLICT DO NOTHING;

-- professor
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('professor', 'academic-research', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('professor', 'higher-ed-teaching', 1) ON CONFLICT DO NOTHING;

-- ai-ml-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ai-ml-engineer', 'computer-vision', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ai-ml-engineer', 'nlp', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ai-ml-engineer', 'mlops', 2) ON CONFLICT DO NOTHING;

-- sustainability-consultant
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('sustainability-consultant', 'carbon-esg-reporting', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('sustainability-consultant', 'renewable-energy-consulting', 1) ON CONFLICT DO NOTHING;

-- mechanical-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mechanical-engineer', 'thermal-engineering', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mechanical-engineer', 'design-manufacturing', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mechanical-engineer', 'automotive-engineering', 2) ON CONFLICT DO NOTHING;

-- civil-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('civil-engineer', 'structural-engineering', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('civil-engineer', 'transportation-engineering', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('civil-engineer', 'environmental-water-engineering', 2) ON CONFLICT DO NOTHING;

-- electrical-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electrical-engineer', 'power-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electrical-engineer', 'control-systems', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electrical-engineer', 'renewable-energy-systems', 2) ON CONFLICT DO NOTHING;

-- electronics-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electronics-engineer', 'vlsi-design', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electronics-engineer', 'embedded-systems', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electronics-engineer', 'communication-systems', 2) ON CONFLICT DO NOTHING;

-- chemical-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chemical-engineer', 'process-engineering', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chemical-engineer', 'petrochemicals-refining', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('chemical-engineer', 'polymer-engineering', 2) ON CONFLICT DO NOTHING;

-- biomedical-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('biomedical-engineer', 'medical-imaging', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('biomedical-engineer', 'biomedical-instrumentation', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('biomedical-engineer', 'prosthetics-implants', 2) ON CONFLICT DO NOTHING;

-- environmental-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('environmental-engineer', 'water-wastewater-treatment', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('environmental-engineer', 'air-pollution-control', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('environmental-engineer', 'waste-management', 2) ON CONFLICT DO NOTHING;

-- marine-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('marine-engineer', 'ship-propulsion-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('marine-engineer', 'naval-architecture', 1) ON CONFLICT DO NOTHING;

-- mining-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mining-engineer', 'mine-planning-design', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mining-engineer', 'mineral-processing', 1) ON CONFLICT DO NOTHING;

-- mechatronics-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mechatronics-engineer', 'industrial-automation', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('mechatronics-engineer', 'robotics-integration', 1) ON CONFLICT DO NOTHING;

-- robotics-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('robotics-engineer', 'autonomous-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('robotics-engineer', 'robotic-perception-ai', 1) ON CONFLICT DO NOTHING;

-- entrepreneur
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('entrepreneur', 'startup-fundraising', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('entrepreneur', 'product-led-growth', 1) ON CONFLICT DO NOTHING;

-- ias-officer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ias-officer', 'district-administration', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ias-officer', 'policy-public-administration', 1) ON CONFLICT DO NOTHING;

-- ips-officer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ips-officer', 'law-order-crime-investigation', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('ips-officer', 'traffic-cyber-policing', 1) ON CONFLICT DO NOTHING;

-- isro-scientist-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('isro-scientist-engineer', 'satellite-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('isro-scientist-engineer', 'launch-vehicle-systems', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('isro-scientist-engineer', 'mission-software-systems', 2) ON CONFLICT DO NOTHING;

-- rrb-junior-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('rrb-junior-engineer', 'signal-telecom', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('rrb-junior-engineer', 'track-civil-works', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('rrb-junior-engineer', 'rolling-stock-maintenance', 2) ON CONFLICT DO NOTHING;

-- sebi-grade-a-officer-it
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('sebi-grade-a-officer-it', 'market-surveillance-systems', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('sebi-grade-a-officer-it', 'fintech-regulation', 1) ON CONFLICT DO NOTHING;

-- hotel-manager
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hotel-manager', 'front-office-guest-relations', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hotel-manager', 'food-beverage-management', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hotel-manager', 'event-banquet-management', 2) ON CONFLICT DO NOTHING;

-- data-scientist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-scientist', 'machine-learning', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-scientist', 'big-data-engineering', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('data-scientist', 'data-visualization-analytics', 2) ON CONFLICT DO NOTHING;

-- software-engineer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('software-engineer', 'frontend-development', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('software-engineer', 'backend-development', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('software-engineer', 'mobile-app-development', 2) ON CONFLICT DO NOTHING;

-- cybersecurity-analyst
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cybersecurity-analyst', 'network-security', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cybersecurity-analyst', 'ethical-hacking-pentesting', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cybersecurity-analyst', 'security-operations-incident-response', 2) ON CONFLICT DO NOTHING;

-- cloud-architect
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cloud-architect', 'multi-cloud-infrastructure', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('cloud-architect', 'devops-cicd', 1) ON CONFLICT DO NOTHING;

-- lawyer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('lawyer', 'corporate-law', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('lawyer', 'criminal-law', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('lawyer', 'litigation-dispute-resolution', 2) ON CONFLICT DO NOTHING;

-- judge
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('judge', 'civil-judiciary', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('judge', 'criminal-judiciary', 1) ON CONFLICT DO NOTHING;

-- product-manager
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('product-manager', 'product-strategy', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('product-manager', 'growth-product-management', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('product-manager', 'technical-product-management', 2) ON CONFLICT DO NOTHING;

-- business-analyst
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('business-analyst', 'process-analysis', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('business-analyst', 'business-intelligence-reporting', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('business-analyst', 'requirements-management', 2) ON CONFLICT DO NOTHING;

-- hr-manager
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hr-manager', 'talent-acquisition', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hr-manager', 'compensation-benefits', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('hr-manager', 'learning-development', 2) ON CONFLICT DO NOTHING;

-- digital-marketing-manager
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('digital-marketing-manager', 'seo-content-marketing', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('digital-marketing-manager', 'paid-media-performance-marketing', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('digital-marketing-manager', 'social-media-marketing', 2) ON CONFLICT DO NOTHING;

-- journalist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('journalist', 'print-digital-journalism', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('journalist', 'broadcast-journalism', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('journalist', 'investigative-journalism', 2) ON CONFLICT DO NOTHING;

-- doctor-mbbs
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('doctor-mbbs', 'general-medicine', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('doctor-mbbs', 'surgery', 1) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('doctor-mbbs', 'pediatrics', 2) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('doctor-mbbs', 'emergency-critical-care', 3) ON CONFLICT DO NOTHING;

-- nurse
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('nurse', 'critical-care-nursing', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('nurse', 'community-public-health-nursing', 1) ON CONFLICT DO NOTHING;

-- dentist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('dentist', 'orthodontics', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('dentist', 'oral-maxillofacial-surgery', 1) ON CONFLICT DO NOTHING;

-- pharmacist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('pharmacist', 'clinical-pharmacy', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('pharmacist', 'pharmaceutical-manufacturing', 1) ON CONFLICT DO NOTHING;

-- research-scientist
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('research-scientist', 'physical-sciences-research', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('research-scientist', 'life-sciences-biotech-research', 1) ON CONFLICT DO NOTHING;

-- electrician
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electrician', 'residential-wiring', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('electrician', 'industrial-electrical-maintenance', 1) ON CONFLICT DO NOTHING;

-- plumber
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('plumber', 'residential-plumbing', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('plumber', 'industrial-pipefitting', 1) ON CONFLICT DO NOTHING;

-- fitness-trainer
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('fitness-trainer', 'strength-conditioning', 0) ON CONFLICT DO NOTHING;
INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES ('fitness-trainer', 'group-fitness-instruction', 1) ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- specialization_courses / specialization_exams (each starting fresh at 0)
-- ---------------------------------------------------------------------

-- plant-breeding-genetics (agricultural-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('plant-breeding-genetics', 'bsc-agriculture', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('plant-breeding-genetics', 'icar-aieea', 0) ON CONFLICT DO NOTHING;
-- soil-science (agricultural-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('soil-science', 'bsc-agriculture', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('soil-science', 'icar-aieea', 0) ON CONFLICT DO NOTHING;
-- agri-biotechnology (agricultural-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('agri-biotechnology', 'bsc-agriculture', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('agri-biotechnology', 'icar-aieea', 0) ON CONFLICT DO NOTHING;
-- archival-research (historian)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('archival-research', 'ma-history', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('archival-research', 'ugc-net', 0) ON CONFLICT DO NOTHING;
-- ancient-medieval-history (historian)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ancient-medieval-history', 'ba-humanities', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ancient-medieval-history', 'ma-history', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('ancient-medieval-history', 'cuet', 0) ON CONFLICT DO NOTHING;
-- modern-indian-history (historian)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('modern-indian-history', 'ba-humanities', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('modern-indian-history', 'ma-history', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('modern-indian-history', 'ugc-net', 0) ON CONFLICT DO NOTHING;
-- clinical-psychology (psychologist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('clinical-psychology', 'msc-psychology', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('clinical-psychology', 'cuet', 0) ON CONFLICT DO NOTHING;
-- counselling-psychology (psychologist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('counselling-psychology', 'msc-psychology', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('counselling-psychology', 'ba-humanities', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('counselling-psychology', 'cuet', 0) ON CONFLICT DO NOTHING;
-- organizational-psychology (psychologist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('organizational-psychology', 'msc-psychology', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('organizational-psychology', 'cuet', 0) ON CONFLICT DO NOTHING;
-- retail-banking (bank-po)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('retail-banking', 'bcom', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('retail-banking', 'bba', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('retail-banking', 'ibps-po', 0) ON CONFLICT DO NOTHING;
-- credit-loans (bank-po)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('credit-loans', 'bcom', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('credit-loans', 'ibps-po', 0) ON CONFLICT DO NOTHING;
-- treasury-forex (bank-po)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('treasury-forex', 'bba', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('treasury-forex', 'ibps-po', 0) ON CONFLICT DO NOTHING;
-- core-banking-systems (ibps-it-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('core-banking-systems', 'btech-cse', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('core-banking-systems', 'mca', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('core-banking-systems', 'ibps-so-it', 0) ON CONFLICT DO NOTHING;
-- banking-cybersecurity (ibps-it-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('banking-cybersecurity', 'cybersecurity-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('banking-cybersecurity', 'ibps-so-it', 0) ON CONFLICT DO NOTHING;
-- digital-payments (ibps-it-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('digital-payments', 'btech-cse', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('digital-payments', 'mca', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('digital-payments', 'ibps-so-it', 0) ON CONFLICT DO NOTHING;
-- business-intelligence (data-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('business-intelligence', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('business-intelligence', 'bba', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('business-intelligence', 'cuet', 0) ON CONFLICT DO NOTHING;
-- financial-analytics (data-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('financial-analytics', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('financial-analytics', 'bcom', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('financial-analytics', 'cuet', 0) ON CONFLICT DO NOTHING;
-- marketing-analytics (data-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('marketing-analytics', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('marketing-analytics', 'bba', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('marketing-analytics', 'cuet', 0) ON CONFLICT DO NOTHING;
-- audit-assurance (chartered-accountant)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('audit-assurance', 'ca-course', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('audit-assurance', 'ca-foundation', 0) ON CONFLICT DO NOTHING;
-- taxation (chartered-accountant)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('taxation', 'ca-course', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('taxation', 'bcom', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('taxation', 'ca-foundation', 0) ON CONFLICT DO NOTHING;
-- corporate-finance (chartered-accountant)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('corporate-finance', 'ca-course', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('corporate-finance', 'ca-foundation', 0) ON CONFLICT DO NOTHING;
-- corporate-compliance (company-secretary)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('corporate-compliance', 'cs-course', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('corporate-compliance', 'cs-foundation', 0) ON CONFLICT DO NOTHING;
-- corporate-governance (company-secretary)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('corporate-governance', 'cs-course', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('corporate-governance', 'cs-foundation', 0) ON CONFLICT DO NOTHING;
-- mergers-acquisitions (investment-banker)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mergers-acquisitions', 'mba-finance', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mergers-acquisitions', 'cat', 0) ON CONFLICT DO NOTHING;
-- equity-capital-markets (investment-banker)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('equity-capital-markets', 'mba-finance', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('equity-capital-markets', 'cat', 0) ON CONFLICT DO NOTHING;
-- private-equity (investment-banker)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('private-equity', 'mba-finance', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('private-equity', 'cat', 0) ON CONFLICT DO NOTHING;
-- infantry (army-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('infantry', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('infantry', 'nda-exam', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('infantry', 'cds-exam', 1) ON CONFLICT DO NOTHING;
-- artillery (army-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('artillery', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('artillery', 'cds-exam', 0) ON CONFLICT DO NOTHING;
-- army-aviation (army-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('army-aviation', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('army-aviation', 'nda-exam', 0) ON CONFLICT DO NOTHING;
-- interaction-design (ux-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('interaction-design', 'ux-design-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('interaction-design', 'uceed', 0) ON CONFLICT DO NOTHING;
-- ux-research (ux-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ux-research', 'ux-design-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ux-research', 'bdes', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('ux-research', 'nid-dat', 0) ON CONFLICT DO NOTHING;
-- product-design-systems (ux-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('product-design-systems', 'bdes', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('product-design-systems', 'ux-design-cert', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('product-design-systems', 'uceed', 0) ON CONFLICT DO NOTHING;
-- branding-identity (graphic-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('branding-identity', 'graphic-design-diploma', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('branding-identity', 'bdes', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('branding-identity', 'nid-dat', 0) ON CONFLICT DO NOTHING;
-- motion-graphics (graphic-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('motion-graphics', 'bdes', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('motion-graphics', 'nid-dat', 0) ON CONFLICT DO NOTHING;
-- print-packaging-design (graphic-designer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('print-packaging-design', 'graphic-design-diploma', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('print-packaging-design', 'nid-dat', 0) ON CONFLICT DO NOTHING;
-- primary-education (school-teacher)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('primary-education', 'bed', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('primary-education', 'ctet', 0) ON CONFLICT DO NOTHING;
-- subject-specialist-teaching (school-teacher)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('subject-specialist-teaching', 'bed', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('subject-specialist-teaching', 'ctet', 0) ON CONFLICT DO NOTHING;
-- special-education (school-teacher)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('special-education', 'bed', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('special-education', 'ctet', 0) ON CONFLICT DO NOTHING;
-- academic-administration (school-principal)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('academic-administration', 'bed', 0) ON CONFLICT DO NOTHING;
-- curriculum-leadership (school-principal)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('curriculum-leadership', 'bed', 0) ON CONFLICT DO NOTHING;
-- academic-research (professor)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('academic-research', 'phd-science', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('academic-research', 'ugc-net', 0) ON CONFLICT DO NOTHING;
-- higher-ed-teaching (professor)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('higher-ed-teaching', 'ma-history', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('higher-ed-teaching', 'phd-science', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('higher-ed-teaching', 'ugc-net', 0) ON CONFLICT DO NOTHING;
-- computer-vision (ai-ml-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('computer-vision', 'ai-ml-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('computer-vision', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('computer-vision', 'gate', 0) ON CONFLICT DO NOTHING;
-- nlp (ai-ml-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('nlp', 'ai-ml-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('nlp', 'gate', 0) ON CONFLICT DO NOTHING;
-- mlops (ai-ml-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mlops', 'ai-ml-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mlops', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mlops', 'gate', 0) ON CONFLICT DO NOTHING;
-- carbon-esg-reporting (sustainability-consultant)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('carbon-esg-reporting', 'sustainability-cert', 0) ON CONFLICT DO NOTHING;
-- renewable-energy-consulting (sustainability-consultant)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('renewable-energy-consulting', 'sustainability-cert', 0) ON CONFLICT DO NOTHING;
-- thermal-engineering (mechanical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('thermal-engineering', 'btech-mech', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('thermal-engineering', 'gate', 0) ON CONFLICT DO NOTHING;
-- design-manufacturing (mechanical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('design-manufacturing', 'btech-mech', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('design-manufacturing', 'diploma-mech', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('design-manufacturing', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('design-manufacturing', 'gate', 1) ON CONFLICT DO NOTHING;
-- automotive-engineering (mechanical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('automotive-engineering', 'btech-mech', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('automotive-engineering', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('automotive-engineering', 'gate', 1) ON CONFLICT DO NOTHING;
-- structural-engineering (civil-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('structural-engineering', 'btech-civil', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('structural-engineering', 'gate', 0) ON CONFLICT DO NOTHING;
-- transportation-engineering (civil-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('transportation-engineering', 'btech-civil', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('transportation-engineering', 'diploma-civil', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('transportation-engineering', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- environmental-water-engineering (civil-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('environmental-water-engineering', 'btech-civil', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('environmental-water-engineering', 'gate', 0) ON CONFLICT DO NOTHING;
-- power-systems (electrical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('power-systems', 'btech-electrical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('power-systems', 'gate', 0) ON CONFLICT DO NOTHING;
-- control-systems (electrical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('control-systems', 'btech-electrical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('control-systems', 'diploma-electrical', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('control-systems', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('control-systems', 'gate', 1) ON CONFLICT DO NOTHING;
-- renewable-energy-systems (electrical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('renewable-energy-systems', 'btech-electrical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('renewable-energy-systems', 'gate', 0) ON CONFLICT DO NOTHING;
-- vlsi-design (electronics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('vlsi-design', 'btech-ece', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('vlsi-design', 'gate', 0) ON CONFLICT DO NOTHING;
-- embedded-systems (electronics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('embedded-systems', 'btech-ece', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('embedded-systems', 'diploma-ece', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('embedded-systems', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('embedded-systems', 'gate', 1) ON CONFLICT DO NOTHING;
-- communication-systems (electronics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('communication-systems', 'btech-ece', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('communication-systems', 'gate', 0) ON CONFLICT DO NOTHING;
-- process-engineering (chemical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('process-engineering', 'btech-chemical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('process-engineering', 'gate', 0) ON CONFLICT DO NOTHING;
-- petrochemicals-refining (chemical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('petrochemicals-refining', 'btech-chemical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('petrochemicals-refining', 'gate', 0) ON CONFLICT DO NOTHING;
-- polymer-engineering (chemical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('polymer-engineering', 'btech-chemical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('polymer-engineering', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- medical-imaging (biomedical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('medical-imaging', 'btech-biomedical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('medical-imaging', 'gate', 0) ON CONFLICT DO NOTHING;
-- biomedical-instrumentation (biomedical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('biomedical-instrumentation', 'btech-biomedical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('biomedical-instrumentation', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('biomedical-instrumentation', 'gate', 1) ON CONFLICT DO NOTHING;
-- prosthetics-implants (biomedical-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('prosthetics-implants', 'btech-biomedical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('prosthetics-implants', 'gate', 0) ON CONFLICT DO NOTHING;
-- water-wastewater-treatment (environmental-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('water-wastewater-treatment', 'btech-environmental', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('water-wastewater-treatment', 'gate', 0) ON CONFLICT DO NOTHING;
-- air-pollution-control (environmental-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('air-pollution-control', 'btech-environmental', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('air-pollution-control', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- waste-management (environmental-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('waste-management', 'btech-environmental', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('waste-management', 'gate', 0) ON CONFLICT DO NOTHING;
-- ship-propulsion-systems (marine-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ship-propulsion-systems', 'btech-marine', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('ship-propulsion-systems', 'imu-cet', 0) ON CONFLICT DO NOTHING;
-- naval-architecture (marine-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('naval-architecture', 'btech-marine', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('naval-architecture', 'imu-cet', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('naval-architecture', 'gate', 1) ON CONFLICT DO NOTHING;
-- mine-planning-design (mining-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mine-planning-design', 'btech-mining', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mine-planning-design', 'gate', 0) ON CONFLICT DO NOTHING;
-- mineral-processing (mining-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mineral-processing', 'btech-mining', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mineral-processing', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mineral-processing', 'gate', 1) ON CONFLICT DO NOTHING;
-- industrial-automation (mechatronics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('industrial-automation', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('industrial-automation', 'gate', 0) ON CONFLICT DO NOTHING;
-- robotics-integration (mechatronics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('robotics-integration', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('robotics-integration', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('robotics-integration', 'gate', 1) ON CONFLICT DO NOTHING;
-- autonomous-systems (robotics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('autonomous-systems', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('autonomous-systems', 'gate', 0) ON CONFLICT DO NOTHING;
-- robotic-perception-ai (robotics-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('robotic-perception-ai', 'btech-mechatronics', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('robotic-perception-ai', 'ai-ml-cert', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('robotic-perception-ai', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('robotic-perception-ai', 'gate', 1) ON CONFLICT DO NOTHING;
-- startup-fundraising (entrepreneur)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('startup-fundraising', 'entrepreneurship-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('startup-fundraising', 'mba-general', 1) ON CONFLICT DO NOTHING;
-- product-led-growth (entrepreneur)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('product-led-growth', 'entrepreneurship-cert', 0) ON CONFLICT DO NOTHING;
-- district-administration (ias-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('district-administration', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('district-administration', 'upsc-cse', 0) ON CONFLICT DO NOTHING;
-- policy-public-administration (ias-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('policy-public-administration', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('policy-public-administration', 'upsc-cse', 0) ON CONFLICT DO NOTHING;
-- law-order-crime-investigation (ips-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('law-order-crime-investigation', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('law-order-crime-investigation', 'upsc-cse', 0) ON CONFLICT DO NOTHING;
-- traffic-cyber-policing (ips-officer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('traffic-cyber-policing', 'any-graduate-degree', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('traffic-cyber-policing', 'upsc-cse', 0) ON CONFLICT DO NOTHING;
-- satellite-systems (isro-scientist-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('satellite-systems', 'btech-ece', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('satellite-systems', 'btech-electrical', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('satellite-systems', 'isro-icrb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('satellite-systems', 'gate', 1) ON CONFLICT DO NOTHING;
-- launch-vehicle-systems (isro-scientist-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('launch-vehicle-systems', 'btech-mech', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('launch-vehicle-systems', 'btech-electrical', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('launch-vehicle-systems', 'isro-icrb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('launch-vehicle-systems', 'gate', 1) ON CONFLICT DO NOTHING;
-- mission-software-systems (isro-scientist-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mission-software-systems', 'btech-cse', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mission-software-systems', 'isro-icrb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mission-software-systems', 'gate', 1) ON CONFLICT DO NOTHING;
-- signal-telecom (rrb-junior-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('signal-telecom', 'diploma-electrical', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('signal-telecom', 'btech-electrical', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('signal-telecom', 'rrb-je', 0) ON CONFLICT DO NOTHING;
-- track-civil-works (rrb-junior-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('track-civil-works', 'diploma-civil', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('track-civil-works', 'rrb-je', 0) ON CONFLICT DO NOTHING;
-- rolling-stock-maintenance (rrb-junior-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('rolling-stock-maintenance', 'diploma-mech', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('rolling-stock-maintenance', 'rrb-je', 0) ON CONFLICT DO NOTHING;
-- market-surveillance-systems (sebi-grade-a-officer-it)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('market-surveillance-systems', 'btech-cse', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('market-surveillance-systems', 'mca', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('market-surveillance-systems', 'sebi-grade-a', 0) ON CONFLICT DO NOTHING;
-- fintech-regulation (sebi-grade-a-officer-it)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('fintech-regulation', 'mca', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('fintech-regulation', 'sebi-grade-a', 0) ON CONFLICT DO NOTHING;
-- front-office-guest-relations (hotel-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('front-office-guest-relations', 'bhm', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('front-office-guest-relations', 'nchmct-jee', 0) ON CONFLICT DO NOTHING;
-- food-beverage-management (hotel-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('food-beverage-management', 'bhm', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('food-beverage-management', 'nchmct-jee', 0) ON CONFLICT DO NOTHING;
-- event-banquet-management (hotel-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('event-banquet-management', 'bhm', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('event-banquet-management', 'nchmct-jee', 0) ON CONFLICT DO NOTHING;
-- machine-learning (data-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('machine-learning', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('machine-learning', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('machine-learning', 'gate', 0) ON CONFLICT DO NOTHING;
-- big-data-engineering (data-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('big-data-engineering', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('big-data-engineering', 'mca', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('big-data-engineering', 'gate', 0) ON CONFLICT DO NOTHING;
-- data-visualization-analytics (data-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('data-visualization-analytics', 'data-science-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('data-visualization-analytics', 'cuet', 0) ON CONFLICT DO NOTHING;
-- frontend-development (software-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('frontend-development', 'web-dev-bootcamp', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('frontend-development', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- backend-development (software-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('backend-development', 'web-dev-bootcamp', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('backend-development', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('backend-development', 'jee-main', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('backend-development', 'bitsat', 1) ON CONFLICT DO NOTHING;
-- mobile-app-development (software-engineer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mobile-app-development', 'diploma-cs', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('mobile-app-development', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('mobile-app-development', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- network-security (cybersecurity-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('network-security', 'cybersecurity-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('network-security', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- ethical-hacking-pentesting (cybersecurity-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ethical-hacking-pentesting', 'cybersecurity-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('ethical-hacking-pentesting', 'btech-cse', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('ethical-hacking-pentesting', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- security-operations-incident-response (cybersecurity-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('security-operations-incident-response', 'cybersecurity-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('security-operations-incident-response', 'jee-main', 0) ON CONFLICT DO NOTHING;
-- multi-cloud-infrastructure (cloud-architect)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('multi-cloud-infrastructure', 'cloud-computing-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('multi-cloud-infrastructure', 'pmp', 0) ON CONFLICT DO NOTHING;
-- devops-cicd (cloud-architect)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('devops-cicd', 'cloud-computing-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('devops-cicd', 'pmp', 0) ON CONFLICT DO NOTHING;
-- corporate-law (lawyer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('corporate-law', 'ballb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('corporate-law', 'llb', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('corporate-law', 'clat', 0) ON CONFLICT DO NOTHING;
-- criminal-law (lawyer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('criminal-law', 'llb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('criminal-law', 'ballb', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('criminal-law', 'clat', 0) ON CONFLICT DO NOTHING;
-- litigation-dispute-resolution (lawyer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('litigation-dispute-resolution', 'ballb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('litigation-dispute-resolution', 'clat', 0) ON CONFLICT DO NOTHING;
-- civil-judiciary (judge)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('civil-judiciary', 'llb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('civil-judiciary', 'judicial-services-exam', 0) ON CONFLICT DO NOTHING;
-- criminal-judiciary (judge)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('criminal-judiciary', 'ballb', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('criminal-judiciary', 'judicial-services-exam', 0) ON CONFLICT DO NOTHING;
-- product-strategy (product-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('product-strategy', 'product-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('product-strategy', 'mba-general', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('product-strategy', 'cat', 0) ON CONFLICT DO NOTHING;
-- growth-product-management (product-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('growth-product-management', 'product-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('growth-product-management', 'pmp', 0) ON CONFLICT DO NOTHING;
-- technical-product-management (product-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('technical-product-management', 'product-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('technical-product-management', 'mba-general', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('technical-product-management', 'cat', 0) ON CONFLICT DO NOTHING;
-- process-analysis (business-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('process-analysis', 'bba', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('process-analysis', 'cuet', 0) ON CONFLICT DO NOTHING;
-- business-intelligence-reporting (business-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('business-intelligence-reporting', 'mba-general', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('business-intelligence-reporting', 'bba', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('business-intelligence-reporting', 'cat', 0) ON CONFLICT DO NOTHING;
-- requirements-management (business-analyst)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('requirements-management', 'bba', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('requirements-management', 'mba-general', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('requirements-management', 'cat', 0) ON CONFLICT DO NOTHING;
-- talent-acquisition (hr-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('talent-acquisition', 'hr-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('talent-acquisition', 'cat', 0) ON CONFLICT DO NOTHING;
-- compensation-benefits (hr-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('compensation-benefits', 'hr-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('compensation-benefits', 'mba-general', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('compensation-benefits', 'cat', 0) ON CONFLICT DO NOTHING;
-- learning-development (hr-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('learning-development', 'hr-management-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('learning-development', 'cat', 0) ON CONFLICT DO NOTHING;
-- seo-content-marketing (digital-marketing-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('seo-content-marketing', 'digital-marketing-cert', 0) ON CONFLICT DO NOTHING;
-- paid-media-performance-marketing (digital-marketing-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('paid-media-performance-marketing', 'digital-marketing-cert', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('paid-media-performance-marketing', 'mba-general', 1) ON CONFLICT DO NOTHING;
-- social-media-marketing (digital-marketing-manager)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('social-media-marketing', 'digital-marketing-cert', 0) ON CONFLICT DO NOTHING;
-- print-digital-journalism (journalist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('print-digital-journalism', 'bjmc', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('print-digital-journalism', 'cuet', 0) ON CONFLICT DO NOTHING;
-- broadcast-journalism (journalist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('broadcast-journalism', 'bjmc', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('broadcast-journalism', 'cuet', 0) ON CONFLICT DO NOTHING;
-- investigative-journalism (journalist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('investigative-journalism', 'bjmc', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('investigative-journalism', 'cuet', 0) ON CONFLICT DO NOTHING;
-- general-medicine (doctor-mbbs)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('general-medicine', 'mbbs', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('general-medicine', 'neet-ug', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('general-medicine', 'neet-pg', 1) ON CONFLICT DO NOTHING;
-- surgery (doctor-mbbs)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('surgery', 'mbbs', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('surgery', 'neet-pg', 0) ON CONFLICT DO NOTHING;
-- pediatrics (doctor-mbbs)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('pediatrics', 'mbbs', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('pediatrics', 'neet-pg', 0) ON CONFLICT DO NOTHING;
-- emergency-critical-care (doctor-mbbs)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('emergency-critical-care', 'mbbs', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('emergency-critical-care', 'neet-pg', 0) ON CONFLICT DO NOTHING;
-- critical-care-nursing (nurse)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('critical-care-nursing', 'bsc-nursing', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('critical-care-nursing', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- community-public-health-nursing (nurse)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('community-public-health-nursing', 'gnm-diploma', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('community-public-health-nursing', 'bsc-nursing', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('community-public-health-nursing', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- orthodontics (dentist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('orthodontics', 'bds', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('orthodontics', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- oral-maxillofacial-surgery (dentist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('oral-maxillofacial-surgery', 'bds', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('oral-maxillofacial-surgery', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- clinical-pharmacy (pharmacist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('clinical-pharmacy', 'bpharm', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('clinical-pharmacy', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- pharmaceutical-manufacturing (pharmacist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('pharmaceutical-manufacturing', 'bpharm', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('pharmaceutical-manufacturing', 'neet-ug', 0) ON CONFLICT DO NOTHING;
-- physical-sciences-research (research-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('physical-sciences-research', 'msc-science', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('physical-sciences-research', 'phd-science', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('physical-sciences-research', 'csir-net', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('physical-sciences-research', 'gate', 1) ON CONFLICT DO NOTHING;
-- life-sciences-biotech-research (research-scientist)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('life-sciences-biotech-research', 'msc-science', 0) ON CONFLICT DO NOTHING;
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('life-sciences-biotech-research', 'phd-science', 1) ON CONFLICT DO NOTHING;
INSERT INTO specialization_exams (specialization_slug, exam_slug, sort_order) VALUES ('life-sciences-biotech-research', 'csir-net', 0) ON CONFLICT DO NOTHING;
-- residential-wiring (electrician)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('residential-wiring', 'iti-electrician', 0) ON CONFLICT DO NOTHING;
-- industrial-electrical-maintenance (electrician)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('industrial-electrical-maintenance', 'iti-electrician', 0) ON CONFLICT DO NOTHING;
-- residential-plumbing (plumber)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('residential-plumbing', 'iti-plumber', 0) ON CONFLICT DO NOTHING;
-- industrial-pipefitting (plumber)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('industrial-pipefitting', 'iti-plumber', 0) ON CONFLICT DO NOTHING;
-- strength-conditioning (fitness-trainer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('strength-conditioning', 'fitness-cert', 0) ON CONFLICT DO NOTHING;
-- group-fitness-instruction (fitness-trainer)
INSERT INTO specialization_courses (specialization_slug, course_slug, sort_order) VALUES ('group-fitness-instruction', 'fitness-cert', 0) ON CONFLICT DO NOTHING;
