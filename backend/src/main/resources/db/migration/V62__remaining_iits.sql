-- Adds the 19 IITs missing from the catalog (only iit-bombay, iit-delhi,
-- iit-madras and iit-ism-dhanbad existed before this) -- all 23 statutory
-- Indian Institutes of Technology -- and fixes real discipline gaps on
-- the 4 that already existed.
--
-- Unlike NITs (V59), IITs do NOT share one standardized branch list --
-- verified per-institute (not assumed) before writing this migration,
-- because two direct contradictions turned up early: IIT Goa has no Civil
-- Engineering at all, and IIT Bombay/Delhi have no separate Electronics &
-- Communication Engineering department (their "Electrical Engineering"
-- covers both power and communication) -- unlike IIT Madras, which does
-- have a separate ECE department, a real gap in the pre-existing seed
-- data, fixed below. Every discipline linked in this migration is one a
-- direct, institute-specific source names explicitly for that institute --
-- nothing here is copied across institutes on a "surely they all have
-- this" assumption the way NITs' core five could be.
--
-- Consequently, disciplines are listed per-institute below rather than as
-- one cross join. Some clearly-real branches at specific institutes have
-- no matching career in this catalog's 42-discipline taxonomy at all
-- (Mathematics and Computing, Engineering Physics, Data Science and AI,
-- Mechatronics, Textile Technology, Ocean Engineering and Naval
-- Architecture, Instrumentation Engineering, Geological/Geophysical
-- Engineering, Pharmaceutical Engineering, Ceramic Engineering, Space
-- Science and Engineering, Digital Agriculture, Integrated Circuit Design
-- and Technology) -- adding those would mean inventing new careers, same
-- boundary V56 drew for NIT Patna's AI & Data Science / Mechatronics
-- branches, so none are added here.
--
-- established uses each institute's true founding year where it predates
-- IIT status (iit-roorkee: 1847 as Roorkee College/Thomason College of
-- Civil Engineering; iit-bhu-varanasi: 1919 as Banaras Engineering
-- College), matching the existing iit-ism-dhanbad convention (1926, not
-- its 2016 IIT-conversion year) rather than the newer institutes' plain
-- founding-as-IIT year. college_exams gets jee-advanced only, matching
-- the 4 pre-existing IITs (not gate/jee-main -- that's the NIT/B.Tech-via-
-- JEE-Main pattern, IITs admit UG only via JEE Advanced). sort_order in
-- career_colleges/college_career_degrees is computed relative to each
-- row's current max (never a hardcoded literal), same discipline as
-- V59-V61, to avoid the duplicate/gap bug fixed in V58.

INSERT INTO cities (slug, name, state_slug) VALUES
    ('kharagpur', 'Kharagpur', 'west-bengal'),
    ('kanpur', 'Kanpur', 'uttar-pradesh'),
    ('guwahati', 'Guwahati', 'assam'),
    ('roorkee', 'Roorkee', 'uttarakhand'),
    ('jodhpur', 'Jodhpur', 'rajasthan'),
    ('gandhinagar', 'Gandhinagar', 'gujarat'),
    ('ropar', 'Ropar', 'punjab'),
    ('bhubaneswar', 'Bhubaneswar', 'odisha'),
    ('indore', 'Indore', 'madhya-pradesh'),
    ('mandi', 'Mandi', 'himachal-pradesh'),
    ('palakkad', 'Palakkad', 'kerala'),
    ('tirupati', 'Tirupati', 'andhra-pradesh'),
    ('bhilai', 'Bhilai', 'chhattisgarh'),
    ('dharwad', 'Dharwad', 'karnataka'),
    ('jammu', 'Jammu', 'jammu-and-kashmir'),
    ('ponda', 'Ponda', 'goa')
ON CONFLICT DO NOTHING;

INSERT INTO colleges (slug, name, location, type, established, tags, description, ownership_type, state_slug, city_slug, website, status) VALUES
    ('iit-kharagpur', 'IIT Kharagpur', 'Kharagpur, West Bengal', 'IIT', 1951, ARRAY['Engineering'], 'An Indian Institute of Technology in West Bengal offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'west-bengal', 'kharagpur', 'https://www.iitkgp.ac.in', 'Active'),
    ('iit-kanpur', 'IIT Kanpur', 'Kanpur, Uttar Pradesh', 'IIT', 1959, ARRAY['Engineering'], 'An Indian Institute of Technology in Uttar Pradesh offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'uttar-pradesh', 'kanpur', 'https://www.iitk.ac.in', 'Active'),
    ('iit-guwahati', 'IIT Guwahati', 'Guwahati, Assam', 'IIT', 1994, ARRAY['Engineering'], 'An Indian Institute of Technology in Assam offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'assam', 'guwahati', 'https://www.iitg.ac.in', 'Active'),
    ('iit-roorkee', 'IIT Roorkee', 'Roorkee, Uttarakhand', 'IIT', 1847, ARRAY['Engineering'], 'An Indian Institute of Technology in Uttarakhand offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'uttarakhand', 'roorkee', 'https://www.iitr.ac.in', 'Active'),
    ('iit-jodhpur', 'IIT Jodhpur', 'Jodhpur, Rajasthan', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Rajasthan offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'rajasthan', 'jodhpur', 'https://www.iitj.ac.in', 'Active'),
    ('iit-hyderabad', 'IIT Hyderabad', 'Hyderabad, Telangana', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Telangana offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'telangana', 'hyderabad', 'https://www.iith.ac.in', 'Active'),
    ('iit-gandhinagar', 'IIT Gandhinagar', 'Gandhinagar, Gujarat', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Gujarat offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'gujarat', 'gandhinagar', 'https://www.iitgn.ac.in', 'Active'),
    ('iit-ropar', 'IIT Ropar', 'Ropar, Punjab', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Punjab offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'punjab', 'ropar', 'https://www.iitrpr.ac.in', 'Active'),
    ('iit-patna', 'IIT Patna', 'Patna, Bihar', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Bihar offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'bihar', 'patna', 'https://www.iitp.ac.in', 'Active'),
    ('iit-bhubaneswar', 'IIT Bhubaneswar', 'Bhubaneswar, Odisha', 'IIT', 2008, ARRAY['Engineering'], 'An Indian Institute of Technology in Odisha offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'odisha', 'bhubaneswar', 'https://www.iitbbs.ac.in', 'Active'),
    ('iit-indore', 'IIT Indore', 'Indore, Madhya Pradesh', 'IIT', 2009, ARRAY['Engineering'], 'An Indian Institute of Technology in Madhya Pradesh offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'madhya-pradesh', 'indore', 'https://www.iiti.ac.in', 'Active'),
    ('iit-mandi', 'IIT Mandi', 'Mandi, Himachal Pradesh', 'IIT', 2009, ARRAY['Engineering'], 'An Indian Institute of Technology in Himachal Pradesh offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'himachal-pradesh', 'mandi', 'https://www.iitmandi.ac.in', 'Active'),
    ('iit-bhu-varanasi', 'IIT (BHU) Varanasi', 'Varanasi, Uttar Pradesh', 'IIT', 1919, ARRAY['Engineering'], 'An Indian Institute of Technology in Uttar Pradesh offering undergraduate, postgraduate and doctoral engineering programs. A distinct, autonomous IIT operating on the Banaras Hindu University campus -- not the same institution as the university itself.', 'Government', 'uttar-pradesh', 'varanasi', 'https://www.iitbhu.ac.in', 'Active'),
    ('iit-palakkad', 'IIT Palakkad', 'Palakkad, Kerala', 'IIT', 2015, ARRAY['Engineering'], 'An Indian Institute of Technology in Kerala offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'kerala', 'palakkad', 'https://www.iitpkd.ac.in', 'Active'),
    ('iit-tirupati', 'IIT Tirupati', 'Tirupati, Andhra Pradesh', 'IIT', 2015, ARRAY['Engineering'], 'An Indian Institute of Technology in Andhra Pradesh offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'andhra-pradesh', 'tirupati', 'https://www.iittp.ac.in', 'Active'),
    ('iit-bhilai', 'IIT Bhilai', 'Bhilai, Chhattisgarh', 'IIT', 2016, ARRAY['Engineering'], 'An Indian Institute of Technology in Chhattisgarh offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'chhattisgarh', 'bhilai', 'https://www.iitbhilai.ac.in', 'Active'),
    ('iit-dharwad', 'IIT Dharwad', 'Dharwad, Karnataka', 'IIT', 2016, ARRAY['Engineering'], 'An Indian Institute of Technology in Karnataka offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'karnataka', 'dharwad', 'https://www.iitdh.ac.in', 'Active'),
    ('iit-jammu', 'IIT Jammu', 'Jammu, Jammu and Kashmir', 'IIT', 2016, ARRAY['Engineering'], 'An Indian Institute of Technology in Jammu and Kashmir offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'jammu-and-kashmir', 'jammu', 'https://www.iitjammu.ac.in', 'Active'),
    ('iit-goa', 'IIT Goa', 'Ponda, Goa', 'IIT', 2016, ARRAY['Engineering'], 'An Indian Institute of Technology in Goa offering undergraduate, postgraduate and doctoral engineering programs.', 'Government', 'goa', 'ponda', 'https://www.iitgoa.ac.in', 'Active')
ON CONFLICT DO NOTHING;

INSERT INTO college_exams (college_slug, exam_slug, sort_order)
SELECT c.slug, 'jee-advanced', 0
FROM (VALUES
    ('iit-kharagpur'), ('iit-kanpur'), ('iit-guwahati'), ('iit-roorkee'), ('iit-jodhpur'),
    ('iit-hyderabad'), ('iit-gandhinagar'), ('iit-ropar'), ('iit-patna'), ('iit-bhubaneswar'),
    ('iit-indore'), ('iit-mandi'), ('iit-bhu-varanasi'), ('iit-palakkad'), ('iit-tirupati'),
    ('iit-bhilai'), ('iit-dharwad'), ('iit-jammu'), ('iit-goa')
) AS c(slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT c.slug, 'b-tech', 0
FROM (VALUES
    ('iit-kharagpur'), ('iit-kanpur'), ('iit-guwahati'), ('iit-roorkee'), ('iit-jodhpur'),
    ('iit-hyderabad'), ('iit-gandhinagar'), ('iit-ropar'), ('iit-patna'), ('iit-bhubaneswar'),
    ('iit-indore'), ('iit-mandi'), ('iit-bhu-varanasi'), ('iit-palakkad'), ('iit-tirupati'),
    ('iit-bhilai'), ('iit-dharwad'), ('iit-jammu'), ('iit-goa')
) AS c(slug)
ON CONFLICT DO NOTHING;

-- career_colleges: per-institute discipline pairs (see header comment --
-- these are NOT a uniform cross join). sort_order computed relative to
-- each career_slug's current max.
INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT v.career_slug, v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = v.career_slug)
       + ROW_NUMBER() OVER (PARTITION BY v.career_slug ORDER BY v.college_slug)
FROM (VALUES
    -- Gap-fills on the 4 pre-existing IITs.
    ('electronics-and-communication-engineering', 'iit-madras'),
    ('civil-engineering', 'iit-ism-dhanbad'),
    ('electrical-engineering', 'iit-ism-dhanbad'),
    ('electronics-and-communication-engineering', 'iit-ism-dhanbad'),
    ('mechanical-engineering', 'iit-ism-dhanbad'),
    ('environmental-engineering', 'iit-ism-dhanbad'),
    ('metallurgical-and-materials-engineering', 'iit-ism-dhanbad'),
    ('petroleum-engineering', 'iit-ism-dhanbad'),
    -- IIT Kharagpur
    ('civil-engineering', 'iit-kharagpur'),
    ('computer-science-and-engineering', 'iit-kharagpur'),
    ('electrical-engineering', 'iit-kharagpur'),
    ('electronics-and-communication-engineering', 'iit-kharagpur'),
    ('mechanical-engineering', 'iit-kharagpur'),
    ('mining-engineering', 'iit-kharagpur'),
    ('metallurgical-and-materials-engineering', 'iit-kharagpur'),
    -- IIT Kanpur (no separate ECE)
    ('civil-engineering', 'iit-kanpur'),
    ('computer-science-and-engineering', 'iit-kanpur'),
    ('electrical-engineering', 'iit-kanpur'),
    ('mechanical-engineering', 'iit-kanpur'),
    ('metallurgical-and-materials-engineering', 'iit-kanpur'),
    ('aerospace-engineering', 'iit-kanpur'),
    ('chemical-engineering', 'iit-kanpur'),
    -- IIT Guwahati (unified "Electronics and Electrical Engineering" dept -- EE only, not split)
    ('civil-engineering', 'iit-guwahati'),
    ('computer-science-and-engineering', 'iit-guwahati'),
    ('electrical-engineering', 'iit-guwahati'),
    ('mechanical-engineering', 'iit-guwahati'),
    ('chemical-engineering', 'iit-guwahati'),
    -- IIT Roorkee
    ('computer-science-and-engineering', 'iit-roorkee'),
    ('electrical-engineering', 'iit-roorkee'),
    ('electronics-and-communication-engineering', 'iit-roorkee'),
    ('civil-engineering', 'iit-roorkee'),
    ('chemical-engineering', 'iit-roorkee'),
    ('mechanical-engineering', 'iit-roorkee'),
    ('metallurgical-and-materials-engineering', 'iit-roorkee'),
    -- IIT Jodhpur
    ('computer-science-and-engineering', 'iit-jodhpur'),
    ('electrical-engineering', 'iit-jodhpur'),
    ('mechanical-engineering', 'iit-jodhpur'),
    ('civil-engineering', 'iit-jodhpur'),
    ('chemical-engineering', 'iit-jodhpur'),
    ('metallurgical-and-materials-engineering', 'iit-jodhpur'),
    -- IIT Hyderabad ("Mechanical & Aerospace Engineering" is one combined department)
    ('computer-science-and-engineering', 'iit-hyderabad'),
    ('electrical-engineering', 'iit-hyderabad'),
    ('civil-engineering', 'iit-hyderabad'),
    ('chemical-engineering', 'iit-hyderabad'),
    ('biotechnology', 'iit-hyderabad'),
    ('biomedical-engineering', 'iit-hyderabad'),
    ('metallurgical-and-materials-engineering', 'iit-hyderabad'),
    ('mechanical-engineering', 'iit-hyderabad'),
    ('aerospace-engineering', 'iit-hyderabad'),
    -- IIT Gandhinagar
    ('computer-science-and-engineering', 'iit-gandhinagar'),
    ('electrical-engineering', 'iit-gandhinagar'),
    ('civil-engineering', 'iit-gandhinagar'),
    ('chemical-engineering', 'iit-gandhinagar'),
    ('mechanical-engineering', 'iit-gandhinagar'),
    ('metallurgical-and-materials-engineering', 'iit-gandhinagar'),
    -- IIT Ropar
    ('computer-science-and-engineering', 'iit-ropar'),
    ('electrical-engineering', 'iit-ropar'),
    ('mechanical-engineering', 'iit-ropar'),
    ('civil-engineering', 'iit-ropar'),
    ('chemical-engineering', 'iit-ropar'),
    ('metallurgical-and-materials-engineering', 'iit-ropar'),
    -- IIT Patna
    ('computer-science-and-engineering', 'iit-patna'),
    ('electrical-engineering', 'iit-patna'),
    ('mechanical-engineering', 'iit-patna'),
    ('civil-engineering', 'iit-patna'),
    ('chemical-engineering', 'iit-patna'),
    -- IIT Bhubaneswar
    ('computer-science-and-engineering', 'iit-bhubaneswar'),
    ('electrical-engineering', 'iit-bhubaneswar'),
    ('electronics-and-communication-engineering', 'iit-bhubaneswar'),
    ('mechanical-engineering', 'iit-bhubaneswar'),
    ('civil-engineering', 'iit-bhubaneswar'),
    ('metallurgical-and-materials-engineering', 'iit-bhubaneswar'),
    -- IIT Indore
    ('computer-science-and-engineering', 'iit-indore'),
    ('electrical-engineering', 'iit-indore'),
    ('mechanical-engineering', 'iit-indore'),
    ('chemical-engineering', 'iit-indore'),
    ('civil-engineering', 'iit-indore'),
    ('metallurgical-and-materials-engineering', 'iit-indore'),
    -- IIT Mandi
    ('computer-science-and-engineering', 'iit-mandi'),
    ('electrical-engineering', 'iit-mandi'),
    ('mechanical-engineering', 'iit-mandi'),
    ('civil-engineering', 'iit-mandi'),
    -- IIT (BHU) Varanasi
    ('civil-engineering', 'iit-bhu-varanasi'),
    ('computer-science-and-engineering', 'iit-bhu-varanasi'),
    ('electrical-engineering', 'iit-bhu-varanasi'),
    ('electronics-and-communication-engineering', 'iit-bhu-varanasi'),
    ('mechanical-engineering', 'iit-bhu-varanasi'),
    ('chemical-engineering', 'iit-bhu-varanasi'),
    ('metallurgical-and-materials-engineering', 'iit-bhu-varanasi'),
    ('mining-engineering', 'iit-bhu-varanasi'),
    -- IIT Palakkad
    ('civil-engineering', 'iit-palakkad'),
    ('computer-science-and-engineering', 'iit-palakkad'),
    ('electrical-engineering', 'iit-palakkad'),
    ('mechanical-engineering', 'iit-palakkad'),
    ('metallurgical-and-materials-engineering', 'iit-palakkad'),
    -- IIT Tirupati
    ('computer-science-and-engineering', 'iit-tirupati'),
    ('electrical-engineering', 'iit-tirupati'),
    ('electronics-and-communication-engineering', 'iit-tirupati'),
    ('mechanical-engineering', 'iit-tirupati'),
    ('civil-engineering', 'iit-tirupati'),
    ('chemical-engineering', 'iit-tirupati'),
    ('aerospace-engineering', 'iit-tirupati'),
    ('metallurgical-and-materials-engineering', 'iit-tirupati'),
    -- IIT Bhilai (no confirmed Civil)
    ('computer-science-and-engineering', 'iit-bhilai'),
    ('electrical-engineering', 'iit-bhilai'),
    ('mechanical-engineering', 'iit-bhilai'),
    ('electronics-and-communication-engineering', 'iit-bhilai'),
    ('metallurgical-and-materials-engineering', 'iit-bhilai'),
    -- IIT Dharwad
    ('computer-science-and-engineering', 'iit-dharwad'),
    ('electrical-engineering', 'iit-dharwad'),
    ('mechanical-engineering', 'iit-dharwad'),
    ('civil-engineering', 'iit-dharwad'),
    ('chemical-engineering', 'iit-dharwad'),
    -- IIT Jammu
    ('computer-science-and-engineering', 'iit-jammu'),
    ('civil-engineering', 'iit-jammu'),
    ('mechanical-engineering', 'iit-jammu'),
    ('electrical-engineering', 'iit-jammu'),
    ('chemical-engineering', 'iit-jammu'),
    ('metallurgical-and-materials-engineering', 'iit-jammu'),
    -- IIT Goa (confirmed NO Civil Engineering)
    ('computer-science-and-engineering', 'iit-goa'),
    ('electrical-engineering', 'iit-goa'),
    ('mechanical-engineering', 'iit-goa')
) AS v(career_slug, college_slug)
ON CONFLICT DO NOTHING;

-- college_career_degrees: derived from the career_colleges rows just
-- inserted (paired with b-tech), not hand-listed, so it can't drift.
-- ON CONFLICT protects the 4 pre-existing IITs' already-seeded rows. Uses
-- ROW_NUMBER (not a plain MAX+1 scalar subquery) since several new rows
-- share the same college_slug within this one statement -- a bare
-- MAX+1 subquery would give all of them the same value (harmless here,
-- since College.careerOfferings is @OrderBy not @OrderColumn, but worth
-- keeping sequential regardless).
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT cc.college_slug, cc.career_slug, 'b-tech',
       (SELECT COALESCE(MAX(sort_order), -1) FROM college_career_degrees ccd WHERE ccd.college_slug = cc.college_slug)
       + ROW_NUMBER() OVER (PARTITION BY cc.college_slug ORDER BY cc.career_slug)
FROM career_colleges cc
WHERE cc.college_slug LIKE 'iit-%'
ON CONFLICT DO NOTHING;
