-- Adds India's top-ranked medical colleges per NIRF's Medical category
-- (top 30, cross-checked against multiple sources), the same "closed,
-- authoritative list" approach V59/V62 used for NITs/IITs, since there is
-- no single fixed "all medical colleges" list the way there is for NITs
-- (31) or IITs (23) -- hundreds of government/private/state medical
-- colleges exist with no equivalent closed set, so NIRF's top-30 ranking
-- is used as the bounded starting scope here instead, per direct request.
--
-- Only aiims-delhi (NIRF #1) and cmc-vellore (NIRF #3) already existed.
-- bhu-varanasi (NIRF #6) already existed too, but as a plain University
-- record with no medicine link -- enriched here instead of duplicated,
-- since IMS-BHU is a faculty of the same Banaras Hindu University already
-- in the catalog, not a separate autonomous institute (unlike IIT (BHU)
-- Varanasi, which genuinely is separately governed and already has its
-- own distinct college row).
--
-- Four ranked entries are deliberately EXCLUDED from this migration after
-- direct verification that they do not grant MBBS (the only medical
-- degree this catalog models so far) -- listed as "Medical" by NIRF but
-- functionally postgraduate/super-specialty-only institutes:
--   - PGIMER Chandigarh (NIRF #2) -- UG offerings are nursing/allied
--     health only (B.Sc Nursing, MLT, etc.), no MBBS.
--   - SGPGI Lucknow (NIRF #5) -- postgraduate/doctoral only, plus BPT.
--   - Sree Chitra Tirunal Institute (NIRF #17) -- PG/doctoral only
--     (MD/DM/MCh/PhD); sources conflict on whether it has ever run MBBS,
--     so it's left out rather than guessed.
--   - Institute of Liver and Biliary Sciences, Delhi (NIRF #28) --
--     confirmed PG/super-specialty only (DM/MCh/PhD), no MBBS.
-- These aren't a good fit for a career+degree pairing built around MBBS;
-- revisiting them would need a PG-only modeling approach this pass
-- doesn't attempt.
--
-- Amrita's location is recorded as Kochi, Kerala (where Amrita Institute
-- of Medical Sciences and its School of Medicine actually are), not
-- Coimbatore as some NIRF-derived listings show -- Coimbatore is Amrita
-- Vishwa Vidyapeetham's main/registered campus, not where its medical
-- faculty operates.
--
-- Scope for this pass: career=medicine, degree=mbbs only (matching how
-- aiims-delhi/cmc-vellore were already modeled) -- MD/MS postgraduate
-- specializations by subject are a much larger, separate follow-up, same
-- boundary the NIT/IIT M.Tech generalization drew at "one higher degree",
-- not per-subject PG specialization breakdown.
--
-- type follows existing precedent: a distinctly-named medical college
-- (even one under a larger government structure) is 'Medical' (matching
-- cmc-vellore); a genuinely broad multi-faculty deemed/central university
-- that happens to also run a medical school is 'University' (matching
-- bhu-varanasi/du-delhi).

INSERT INTO cities (slug, name, state_slug) VALUES
    ('puducherry', 'Puducherry', 'puducherry'),
    ('lucknow', 'Lucknow', 'uttar-pradesh'),
    ('kochi', 'Kochi', 'kerala'),
    ('manipal', 'Manipal', 'karnataka'),
    ('pune', 'Pune', 'maharashtra'),
    ('rishikesh', 'Rishikesh', 'uttarakhand'),
    ('wardha', 'Wardha', 'maharashtra'),
    ('kolkata', 'Kolkata', 'west-bengal'),
    ('aligarh', 'Aligarh', 'uttar-pradesh')
ON CONFLICT DO NOTHING;

INSERT INTO colleges (slug, name, location, type, established, tags, description, ownership_type, state_slug, city_slug, website, status) VALUES
    ('jipmer-puducherry', 'JIPMER', 'Puducherry, Puducherry', 'Medical', 1823, ARRAY['Medical'], 'A premier government medical institute in Puducherry offering undergraduate, postgraduate and doctoral medical education.', 'Government', 'puducherry', 'puducherry', 'https://www.jipmer.edu.in', 'Active'),
    ('nimhans-bangalore', 'NIMHANS', 'Bengaluru, Karnataka', 'Medical', 1974, ARRAY['Medical'], 'A national institute in Karnataka specializing in mental health and neurosciences, offering undergraduate, postgraduate and doctoral medical education.', 'Government', 'karnataka', 'bengaluru', 'https://www.nimhans.ac.in', 'Active'),
    ('kgmu-lucknow', 'KGMU Lucknow', 'Lucknow, Uttar Pradesh', 'Medical', 1905, ARRAY['Medical'], 'A state medical university in Uttar Pradesh offering undergraduate, postgraduate and doctoral medical education.', 'Government', 'uttar-pradesh', 'lucknow', 'https://www.kgmu.org', 'Active'),
    ('amrita-kochi', 'Amrita Institute of Medical Sciences', 'Kochi, Kerala', 'University', 1998, ARRAY['Medical'], 'The medical sciences campus of Amrita Vishwa Vidyapeetham in Kerala, offering undergraduate, postgraduate and doctoral medical education.', 'Private', 'kerala', 'kochi', 'https://www.amrita.edu', 'Active'),
    ('kmc-manipal', 'Kasturba Medical College, Manipal', 'Manipal, Karnataka', 'Medical', 1953, ARRAY['Medical'], 'India''s first self-financing private medical college, a constituent college of Manipal Academy of Higher Education in Karnataka.', 'Private', 'karnataka', 'manipal', 'https://www.manipal.edu', 'Active'),
    ('saveetha-chennai', 'Saveetha Medical College', 'Chennai, Tamil Nadu', 'University', 2008, ARRAY['Medical'], 'A constituent medical college of Saveetha Institute of Medical and Technical Sciences (a deemed university) in Tamil Nadu.', 'Private', 'tamil-nadu', 'chennai', 'https://www.smc.saveetha.com', 'Active'),
    ('dy-patil-pune', 'Dr. D. Y. Patil Medical College', 'Pune, Maharashtra', 'University', 1996, ARRAY['Medical'], 'A constituent medical college of Dr. D. Y. Patil Vidyapeeth (a deemed university) in Maharashtra.', 'Private', 'maharashtra', 'pune', 'https://dpu.edu.in', 'Active'),
    ('aiims-rishikesh', 'AIIMS Rishikesh', 'Rishikesh, Uttarakhand', 'Medical', 2012, ARRAY['Medical'], 'One of the AIIMS institutes established under the Pradhan Mantri Swasthya Suraksha Yojana, in Uttarakhand.', 'Government', 'uttarakhand', 'rishikesh', 'https://www.aiimsrishikesh.edu.in', 'Active'),
    ('aiims-bhubaneswar', 'AIIMS Bhubaneswar', 'Bhubaneswar, Odisha', 'Medical', 2012, ARRAY['Medical'], 'One of the AIIMS institutes established under the Pradhan Mantri Swasthya Suraksha Yojana, in Odisha.', 'Government', 'odisha', 'bhubaneswar', 'https://www.aiimsbhubaneswar.nic.in', 'Active'),
    ('soa-bhubaneswar', 'Siksha ''O'' Anusandhan', 'Bhubaneswar, Odisha', 'University', 2007, ARRAY['Medical'], 'The medical school (Institute of Medical Sciences and SUM Hospital) of Siksha ''O'' Anusandhan, a deemed university in Odisha.', 'Private', 'odisha', 'bhubaneswar', 'https://www.soa.ac.in', 'Active'),
    ('madras-medical-college', 'Madras Medical College', 'Chennai, Tamil Nadu', 'Medical', 1835, ARRAY['Medical'], 'One of the oldest medical colleges in Asia, a government medical college in Tamil Nadu attached to Rajiv Gandhi Government General Hospital.', 'Government', 'tamil-nadu', 'chennai', 'https://www.mmc.tn.gov.in', 'Active'),
    ('srm-medical-college', 'SRM Medical College', 'Chennai, Tamil Nadu', 'University', 2005, ARRAY['Medical'], 'The medical college and hospital of SRM Institute of Science and Technology in Tamil Nadu.', 'Private', 'tamil-nadu', 'chennai', 'https://medical.srmist.edu.in', 'Active'),
    ('aiims-jodhpur', 'AIIMS Jodhpur', 'Jodhpur, Rajasthan', 'Medical', 2012, ARRAY['Medical'], 'One of the AIIMS institutes established under the Pradhan Mantri Swasthya Suraksha Yojana, in Rajasthan.', 'Government', 'rajasthan', 'jodhpur', 'https://www.aiimsjodhpur.edu.in', 'Active'),
    ('datta-meghe-wardha', 'Jawaharlal Nehru Medical College, Wardha', 'Wardha, Maharashtra', 'University', 1990, ARRAY['Medical'], 'A constituent medical college of Datta Meghe Institute of Higher Education and Research (a deemed university) in Maharashtra.', 'Private', 'maharashtra', 'wardha', 'https://dmiher.edu.in', 'Active'),
    ('sri-ramachandra-chennai', 'Sri Ramachandra Institute of Higher Education and Research', 'Chennai, Tamil Nadu', 'University', 1985, ARRAY['Medical'], 'A deemed university in Tamil Nadu built around Sri Ramachandra Medical College and Research Institute.', 'Private', 'tamil-nadu', 'chennai', 'https://sriramachandra.edu.in', 'Active'),
    ('vmmc-safdarjung-delhi', 'VMMC & Safdarjung Hospital', 'New Delhi, Delhi', 'Medical', 2001, ARRAY['Medical'], 'A government medical college in Delhi attached to Safdarjung Hospital.', 'Government', 'delhi', 'new-delhi', 'https://vmmc-sjh.nic.in', 'Active'),
    ('ipgmer-kolkata', 'IPGMER Kolkata', 'Kolkata, West Bengal', 'Medical', 1957, ARRAY['Medical'], 'A West Bengal government postgraduate medical institute attached to SSKM Hospital, which also runs an MBBS program.', 'Government', 'west-bengal', 'kolkata', 'https://ipgmer.gov.in', 'Active'),
    ('kims-bhubaneswar', 'Kalinga Institute of Medical Sciences', 'Bhubaneswar, Odisha', 'University', 2007, ARRAY['Medical'], 'The medical school of KIIT, a deemed university in Odisha.', 'Private', 'odisha', 'bhubaneswar', 'https://kims.kiit.ac.in', 'Active'),
    ('aiims-bhopal', 'AIIMS Bhopal', 'Bhopal, Madhya Pradesh', 'Medical', 2012, ARRAY['Medical'], 'One of the AIIMS institutes established under the Pradhan Mantri Swasthya Suraksha Yojana, in Madhya Pradesh.', 'Government', 'madhya-pradesh', 'bhopal', 'https://www.aiimsbhopal.edu.in', 'Active'),
    ('maulana-azad-medical-college', 'Maulana Azad Medical College', 'New Delhi, Delhi', 'Medical', 1958, ARRAY['Medical'], 'A Delhi government medical college, part of the University of Delhi''s Faculty of Medical Sciences.', 'Government', 'delhi', 'new-delhi', 'https://www.mamc.ac.in', 'Active'),
    ('aiims-patna', 'AIIMS Patna', 'Patna, Bihar', 'Medical', 2012, ARRAY['Medical'], 'One of the AIIMS institutes established under the Pradhan Mantri Swasthya Suraksha Yojana, in Bihar.', 'Government', 'bihar', 'patna', 'https://www.aiimspatna.edu.in', 'Active'),
    ('amu-aligarh', 'Aligarh Muslim University', 'Aligarh, Uttar Pradesh', 'University', 1920, ARRAY['Medical'], 'A central university in Uttar Pradesh whose Jawaharlal Nehru Medical College offers undergraduate, postgraduate and doctoral medical education.', 'Government', 'uttar-pradesh', 'aligarh', 'https://www.amu.ac.in', 'Active'),
    ('st-johns-bengaluru', 'St. John''s Medical College', 'Bengaluru, Karnataka', 'Medical', 1963, ARRAY['Medical'], 'A private Christian minority medical college in Karnataka run by the Catholic Bishops'' Conference of India.', 'Private', 'karnataka', 'bengaluru', 'https://www.stjohns.in', 'Active')
ON CONFLICT DO NOTHING;

INSERT INTO college_exams (college_slug, exam_slug, sort_order)
SELECT c.slug, 'neet-ug', 0
FROM (VALUES
    ('jipmer-puducherry'), ('nimhans-bangalore'), ('kgmu-lucknow'), ('amrita-kochi'), ('kmc-manipal'),
    ('saveetha-chennai'), ('dy-patil-pune'), ('aiims-rishikesh'), ('aiims-bhubaneswar'), ('soa-bhubaneswar'),
    ('madras-medical-college'), ('srm-medical-college'), ('aiims-jodhpur'), ('datta-meghe-wardha'),
    ('sri-ramachandra-chennai'), ('vmmc-safdarjung-delhi'), ('ipgmer-kolkata'), ('kims-bhubaneswar'),
    ('aiims-bhopal'), ('maulana-azad-medical-college'), ('aiims-patna'), ('amu-aligarh'), ('st-johns-bengaluru')
) AS c(slug)
ON CONFLICT DO NOTHING;

-- college_degrees: mbbs for all 23 new colleges plus the bhu-varanasi
-- enrichment (which already has 'ba' at sort_order 0).
INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT v.college_slug, 'mbbs',
       (SELECT COALESCE(MAX(sort_order), -1) + 1 FROM college_degrees cd WHERE cd.college_slug = v.college_slug)
FROM (VALUES
    ('jipmer-puducherry'), ('nimhans-bangalore'), ('kgmu-lucknow'), ('amrita-kochi'), ('kmc-manipal'),
    ('saveetha-chennai'), ('dy-patil-pune'), ('aiims-rishikesh'), ('aiims-bhubaneswar'), ('soa-bhubaneswar'),
    ('madras-medical-college'), ('srm-medical-college'), ('aiims-jodhpur'), ('datta-meghe-wardha'),
    ('sri-ramachandra-chennai'), ('vmmc-safdarjung-delhi'), ('ipgmer-kolkata'), ('kims-bhubaneswar'),
    ('aiims-bhopal'), ('maulana-azad-medical-college'), ('aiims-patna'), ('amu-aligarh'), ('st-johns-bengaluru'),
    ('bhu-varanasi')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- career_colleges: medicine, appended relative to its current max.
INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT 'medicine', v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = 'medicine')
       + ROW_NUMBER() OVER (ORDER BY v.college_slug)
FROM (VALUES
    ('jipmer-puducherry'), ('nimhans-bangalore'), ('kgmu-lucknow'), ('amrita-kochi'), ('kmc-manipal'),
    ('saveetha-chennai'), ('dy-patil-pune'), ('aiims-rishikesh'), ('aiims-bhubaneswar'), ('soa-bhubaneswar'),
    ('madras-medical-college'), ('srm-medical-college'), ('aiims-jodhpur'), ('datta-meghe-wardha'),
    ('sri-ramachandra-chennai'), ('vmmc-safdarjung-delhi'), ('ipgmer-kolkata'), ('kims-bhubaneswar'),
    ('aiims-bhopal'), ('maulana-azad-medical-college'), ('aiims-patna'), ('amu-aligarh'), ('st-johns-bengaluru'),
    ('bhu-varanasi')
) AS v(college_slug)
ON CONFLICT DO NOTHING;

-- college_career_degrees: derived from the career_colleges rows just
-- inserted, paired with mbbs.
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT cc.college_slug, cc.career_slug, 'mbbs',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = cc.college_slug)
       + ROW_NUMBER() OVER (PARTITION BY cc.college_slug ORDER BY cc.career_slug)
FROM career_colleges cc
WHERE cc.career_slug = 'medicine'
ON CONFLICT DO NOTHING;
