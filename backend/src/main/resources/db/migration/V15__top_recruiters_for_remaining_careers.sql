-- Extends `top_recruiters` (added in V13, previously only populated for the
-- 8 engineering careers from V12) to the other careers in the catalog: a
-- short list of real organizations that commonly hire for that role in
-- India. This is additive only -- no schema change, no other field touched.
--
-- One career is deliberately skipped: 'entrepreneur'. Every other career in
-- the catalog is something you get HIRED for, so "top recruiters" fits; an
-- entrepreneur isn't hired by anyone, they found and run their own venture,
-- so the concept doesn't apply. Its top_recruiters stays '{}' (the column
-- default) rather than forcing in something that doesn't fit, like listing
-- venture capital firms as if they were employers.
--
-- For government/PSU/judicial roles that have effectively one employer
-- (IAS Officer, Judge, etc.), the "recruiters" are the actual organs/bodies
-- a person in that role serves in or is posted to, not literal alternate
-- employers competing to hire them -- that's the closest honest equivalent
-- for a single-track government service.

UPDATE careers SET top_recruiters = ARRAY['ICAR (Indian Council of Agricultural Research)','State Agricultural Universities','Rallis India','UPL Limited','National Seeds Corporation'] WHERE slug = 'agricultural-scientist';

UPDATE careers SET top_recruiters = ARRAY['Archaeological Survey of India (ASI)','Indian Council of Historical Research (ICHR)','National Museum','Universities & Colleges','Publishing Houses (e.g. Oxford University Press India)'] WHERE slug = 'historian';
UPDATE careers SET top_recruiters = ARRAY['NIMHANS','Fortis Healthcare','Apollo Hospitals','Schools & Colleges (Counselling Roles)','Private Practice'] WHERE slug = 'psychologist';

UPDATE careers SET top_recruiters = ARRAY['State Bank of India (SBI)','Punjab National Bank','Bank of Baroda','HDFC Bank','ICICI Bank'] WHERE slug = 'bank-po';
UPDATE careers SET top_recruiters = ARRAY['State Bank of India (SBI)','Bank of Baroda','Canara Bank','Reserve Bank of India (RBI)','Punjab National Bank'] WHERE slug = 'ibps-it-officer';

UPDATE careers SET top_recruiters = ARRAY['Deloitte','EY','Flipkart','Amazon','Accenture'] WHERE slug = 'data-analyst';
UPDATE careers SET top_recruiters = ARRAY['Deloitte','EY','KPMG','PwC','Grant Thornton Bharat'] WHERE slug = 'chartered-accountant';
UPDATE careers SET top_recruiters = ARRAY['Reliance Industries','Tata Group','Infosys','Wipro','HDFC Ltd'] WHERE slug = 'company-secretary';
UPDATE careers SET top_recruiters = ARRAY['Goldman Sachs','JP Morgan','Kotak Mahindra Capital','ICICI Securities','Axis Capital'] WHERE slug = 'investment-banker';

UPDATE careers SET top_recruiters = ARRAY['Indian Army','Assam Rifles','Territorial Army'] WHERE slug = 'army-officer';

UPDATE careers SET top_recruiters = ARRAY['Flipkart','Swiggy','Zomato','Myntra','Ola'] WHERE slug = 'ux-designer';
UPDATE careers SET top_recruiters = ARRAY['Ogilvy','Dentsu','Flipkart','Amazon India','Freelance / Agency Work'] WHERE slug = 'graphic-designer';

UPDATE careers SET top_recruiters = ARRAY['Delhi Public School (DPS) Society','Kendriya Vidyalaya Sangathan (KVS)','DAV Public Schools','Ryan International Group','Government Schools (State Education Departments)'] WHERE slug = 'school-teacher';
UPDATE careers SET top_recruiters = ARRAY['Delhi Public School (DPS) Society','Kendriya Vidyalaya Sangathan (KVS)','DAV Public Schools','Ryan International Group','Government Schools (State Education Departments)'] WHERE slug = 'school-principal';
UPDATE careers SET top_recruiters = ARRAY['Delhi University','Jawaharlal Nehru University (JNU)','IITs & NITs','State Universities','Private Universities (e.g. Ashoka University)'] WHERE slug = 'professor';

UPDATE careers SET top_recruiters = ARRAY['Google India','Microsoft India','NVIDIA','Flipkart','Fractal Analytics'] WHERE slug = 'ai-ml-engineer';
UPDATE careers SET top_recruiters = ARRAY['Deloitte','EY','ERM India','KPMG','Tata Sustainability Group'] WHERE slug = 'sustainability-consultant';

UPDATE careers SET top_recruiters = ARRAY['Tata Motors','Mahindra & Mahindra','Larsen & Toubro (L&T)','Bajaj Auto','Godrej & Boyce'] WHERE slug = 'mechanical-engineer';
UPDATE careers SET top_recruiters = ARRAY['Larsen & Toubro (L&T)','Shapoorji Pallonji','DLF','NBCC (India) Limited','Tata Projects'] WHERE slug = 'civil-engineer';
UPDATE careers SET top_recruiters = ARRAY['Siemens','ABB','Larsen & Toubro (L&T)','Tata Power','NTPC'] WHERE slug = 'electrical-engineer';
UPDATE careers SET top_recruiters = ARRAY['Samsung R&D India','Bosch','Continental','Texas Instruments India','HCL Technologies'] WHERE slug = 'electronics-engineer';

UPDATE careers SET top_recruiters = ARRAY['Government of India (Central Secretariat)','State Governments (IAS Cadre)','District Administration','Public Sector Undertakings (on deputation)'] WHERE slug = 'ias-officer';
UPDATE careers SET top_recruiters = ARRAY['Indian Police Service','State Police Departments','Central Bureau of Investigation (CBI)','Intelligence Bureau (IB)'] WHERE slug = 'ips-officer';
UPDATE careers SET top_recruiters = ARRAY['ISRO (Indian Space Research Organisation)','Vikram Sarabhai Space Centre (VSSC)','U R Rao Satellite Centre (URSC)','NewSpace India Limited (NSIL)'] WHERE slug = 'isro-scientist-engineer';
UPDATE careers SET top_recruiters = ARRAY['Indian Railways (Zonal Railways)','Railway Recruitment Boards','Delhi Metro Rail Corporation (DMRC)','RITES Ltd'] WHERE slug = 'rrb-junior-engineer';
UPDATE careers SET top_recruiters = ARRAY['SEBI (Securities and Exchange Board of India)','Reserve Bank of India (RBI)','IRDAI (Insurance Regulatory and Development Authority)','PFRDA (Pension Fund Regulatory and Development Authority)'] WHERE slug = 'sebi-grade-a-officer-it';

UPDATE careers SET top_recruiters = ARRAY['Taj Hotels (IHCL)','Oberoi Group','Marriott International','ITC Hotels','Lemon Tree Hotels'] WHERE slug = 'hotel-manager';

UPDATE careers SET top_recruiters = ARRAY['Flipkart','Amazon','Google India','Fractal Analytics','Mu Sigma'] WHERE slug = 'data-scientist';
UPDATE careers SET top_recruiters = ARRAY['Tata Consultancy Services (TCS)','Infosys','Google India','Microsoft India','Flipkart'] WHERE slug = 'software-engineer';
UPDATE careers SET top_recruiters = ARRAY['Tata Consultancy Services (TCS)','Wipro','Deloitte','Palo Alto Networks','IBM India'] WHERE slug = 'cybersecurity-analyst';
UPDATE careers SET top_recruiters = ARRAY['Amazon Web Services (AWS)','Microsoft Azure','Google Cloud','Tata Consultancy Services (TCS)','Infosys'] WHERE slug = 'cloud-architect';

UPDATE careers SET top_recruiters = ARRAY['AZB & Partners','Cyril Amarchand Mangaldas','Khaitan & Co','Shardul Amarchand Mangaldas','Independent Litigation Practice'] WHERE slug = 'lawyer';
UPDATE careers SET top_recruiters = ARRAY['State Judicial Services','District Courts','High Courts'] WHERE slug = 'judge';

UPDATE careers SET top_recruiters = ARRAY['Flipkart','Amazon','Google India','Swiggy','Zomato'] WHERE slug = 'product-manager';
UPDATE careers SET top_recruiters = ARRAY['Deloitte','Accenture','Tata Consultancy Services (TCS)','EY','Capgemini'] WHERE slug = 'business-analyst';
UPDATE careers SET top_recruiters = ARRAY['Tata Group','Infosys','Hindustan Unilever (HUL)','Wipro','Aditya Birla Group'] WHERE slug = 'hr-manager';
UPDATE careers SET top_recruiters = ARRAY['Ogilvy','WPP','Dentsu','Nykaa','Myntra'] WHERE slug = 'digital-marketing-manager';

UPDATE careers SET top_recruiters = ARRAY['The Times of India','NDTV','The Hindu','India Today Group','Hindustan Times'] WHERE slug = 'journalist';

UPDATE careers SET top_recruiters = ARRAY['AIIMS','Apollo Hospitals','Fortis Healthcare','Max Healthcare','Government Hospitals (State Health Departments)'] WHERE slug = 'doctor-mbbs';
UPDATE careers SET top_recruiters = ARRAY['Apollo Hospitals','Fortis Healthcare','AIIMS','Max Healthcare','Government Hospitals'] WHERE slug = 'nurse';
UPDATE careers SET top_recruiters = ARRAY['Clove Dental','Apollo White Dental','Private Dental Clinics','Government Dental Colleges & Hospitals'] WHERE slug = 'dentist';
UPDATE careers SET top_recruiters = ARRAY['Apollo Pharmacy','MedPlus','Sun Pharma','Cipla','Dr. Reddy''s Laboratories'] WHERE slug = 'pharmacist';

UPDATE careers SET top_recruiters = ARRAY['Council of Scientific & Industrial Research (CSIR)','Tata Institute of Fundamental Research (TIFR)','Indian Institute of Science (IISc)','Bharat Biotech','Serum Institute of India'] WHERE slug = 'research-scientist';

UPDATE careers SET top_recruiters = ARRAY['Urban Company','Havells India','Individual Contracting','Real Estate & Construction Firms'] WHERE slug = 'electrician';
UPDATE careers SET top_recruiters = ARRAY['Urban Company','Individual Contracting','Real Estate & Construction Firms','Jaguar / Kohler Dealer Service Networks'] WHERE slug = 'plumber';

UPDATE careers SET top_recruiters = ARRAY['Cult.fit','Gold''s Gym','Anytime Fitness','Talwalkars','Freelance / Independent Training'] WHERE slug = 'fitness-trainer';
