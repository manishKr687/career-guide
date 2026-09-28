-- Adds the 28 NITs missing from the catalog (only nit-trichy, nit-warangal
-- and nit-patna existed before this) -- all 31 statutory National
-- Institutes of Technology, per the NIT Council / Wikipedia's "National
-- Institutes of Technology" list, cross-checked against each institute's
-- own founding year. IIEST Shibpur (sometimes informally called the
-- "32nd NIT") is deliberately excluded -- it's a differently-named,
-- differently-governed institute (converted from a Bengal Engineering
-- college in 2014), not a plain "National Institute of Technology X".
--
-- Scope, same "don't guess past what's confidently known" bar as V53/V56/
-- V57: every NIT (old and new alike) is linked only to the five core
-- engineering disciplines every NIT -- including the newest 2010-batch
-- ones -- is confirmed to run: Computer Science & Engineering, Electrical
-- Engineering, Electronics & Communication Engineering, Mechanical
-- Engineering and Civil Engineering, each via a plain B.Tech (spot-checked
-- against NIT Mizoram's and NIT Manipur's own admissions pages, both of
-- which confirm exactly these five). Specialized/additional branches that
-- vary institute to institute -- Mining, Chemical, Metallurgical,
-- Architecture, Textile, Agricultural and so on at specific NITs -- are
-- left for a follow-up pass, since confirming those needs a per-institute
-- check rather than a fact true of the whole group.
--
-- established uses each institute's founding year (matches the existing
-- nit-trichy/nit-warangal convention: 1964/1959 are founding years, not
-- their 2002 "declared NIT" year); college_exams gets jee-main only,
-- matching nit-trichy/nit-warangal (not nit-patna, which also has gate --
-- pre-existing data, not touched here). sort_order in career_colleges is
-- computed relative to the current max per career_slug (not hardcoded
-- literals) specifically to avoid repeating the duplicate/gap bug fixed in
-- V58.

INSERT INTO cities (slug, name, state_slug) VALUES
    ('surathkal', 'Surathkal', 'karnataka'),
    ('bhopal', 'Bhopal', 'madhya-pradesh'),
    ('nagpur', 'Nagpur', 'maharashtra'),
    ('durgapur', 'Durgapur', 'west-bengal'),
    ('jamshedpur', 'Jamshedpur', 'jharkhand'),
    ('srinagar', 'Srinagar', 'jammu-and-kashmir'),
    ('silchar', 'Silchar', 'assam'),
    ('prayagraj', 'Prayagraj', 'uttar-pradesh'),
    ('surat', 'Surat', 'gujarat'),
    ('kozhikode', 'Kozhikode', 'kerala'),
    ('rourkela', 'Rourkela', 'odisha'),
    ('jaipur', 'Jaipur', 'rajasthan'),
    ('kurukshetra', 'Kurukshetra', 'haryana'),
    ('hamirpur', 'Hamirpur', 'himachal-pradesh'),
    ('jalandhar', 'Jalandhar', 'punjab'),
    ('raipur', 'Raipur', 'chhattisgarh'),
    ('agartala', 'Agartala', 'tripura'),
    ('yupia', 'Yupia', 'arunachal-pradesh'),
    ('cuncolim', 'Cuncolim', 'goa'),
    ('imphal', 'Imphal', 'manipur'),
    ('shillong', 'Shillong', 'meghalaya'),
    ('aizawl', 'Aizawl', 'mizoram'),
    ('dimapur', 'Dimapur', 'nagaland'),
    ('karaikal', 'Karaikal', 'puducherry'),
    ('ravangla', 'Ravangla', 'sikkim'),
    ('srinagar-garhwal', 'Srinagar (Garhwal)', 'uttarakhand'),
    ('tadepalligudem', 'Tadepalligudem', 'andhra-pradesh')
ON CONFLICT DO NOTHING;

INSERT INTO colleges (slug, name, location, type, established, tags, description, ownership_type, state_slug, city_slug, website, status) VALUES
    ('nit-surathkal', 'NIT Karnataka, Surathkal', 'Surathkal, Karnataka', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in Karnataka offering undergraduate and postgraduate engineering programs.', 'Government', 'karnataka', 'surathkal', 'https://www.nitk.ac.in', 'Active'),
    ('nit-bhopal', 'NIT Bhopal', 'Bhopal, Madhya Pradesh', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in Madhya Pradesh offering undergraduate and postgraduate engineering programs.', 'Government', 'madhya-pradesh', 'bhopal', 'https://www.manit.ac.in', 'Active'),
    ('nit-nagpur', 'NIT Nagpur', 'Nagpur, Maharashtra', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in Maharashtra offering undergraduate and postgraduate engineering programs.', 'Government', 'maharashtra', 'nagpur', 'https://www.vnit.ac.in', 'Active'),
    ('nit-durgapur', 'NIT Durgapur', 'Durgapur, West Bengal', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in West Bengal offering undergraduate and postgraduate engineering programs.', 'Government', 'west-bengal', 'durgapur', 'https://www.nitdgp.ac.in', 'Active'),
    ('nit-jamshedpur', 'NIT Jamshedpur', 'Jamshedpur, Jharkhand', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in Jharkhand offering undergraduate and postgraduate engineering programs.', 'Government', 'jharkhand', 'jamshedpur', 'https://www.nitjsr.ac.in', 'Active'),
    ('nit-srinagar', 'NIT Srinagar', 'Srinagar, Jammu and Kashmir', 'NIT', 1960, ARRAY['Engineering'], 'A National Institute of Technology in Jammu and Kashmir offering undergraduate and postgraduate engineering programs.', 'Government', 'jammu-and-kashmir', 'srinagar', 'https://www.nitsri.ac.in', 'Active'),
    ('nit-silchar', 'NIT Silchar', 'Silchar, Assam', 'NIT', 1967, ARRAY['Engineering'], 'A National Institute of Technology in Assam offering undergraduate and postgraduate engineering programs.', 'Government', 'assam', 'silchar', 'https://www.nits.ac.in', 'Active'),
    ('nit-allahabad', 'NIT Allahabad', 'Prayagraj, Uttar Pradesh', 'NIT', 1961, ARRAY['Engineering'], 'A National Institute of Technology in Uttar Pradesh offering undergraduate and postgraduate engineering programs.', 'Government', 'uttar-pradesh', 'prayagraj', 'https://www.mnnit.ac.in', 'Active'),
    ('nit-surat', 'NIT Surat', 'Surat, Gujarat', 'NIT', 1961, ARRAY['Engineering'], 'A National Institute of Technology in Gujarat offering undergraduate and postgraduate engineering programs.', 'Government', 'gujarat', 'surat', 'https://www.svnit.ac.in', 'Active'),
    ('nit-calicut', 'NIT Calicut', 'Kozhikode, Kerala', 'NIT', 1961, ARRAY['Engineering'], 'A National Institute of Technology in Kerala offering undergraduate and postgraduate engineering programs.', 'Government', 'kerala', 'kozhikode', 'https://www.nitc.ac.in', 'Active'),
    ('nit-rourkela', 'NIT Rourkela', 'Rourkela, Odisha', 'NIT', 1961, ARRAY['Engineering'], 'A National Institute of Technology in Odisha offering undergraduate and postgraduate engineering programs.', 'Government', 'odisha', 'rourkela', 'https://www.nitrkl.ac.in', 'Active'),
    ('nit-jaipur', 'NIT Jaipur', 'Jaipur, Rajasthan', 'NIT', 1963, ARRAY['Engineering'], 'A National Institute of Technology in Rajasthan offering undergraduate and postgraduate engineering programs.', 'Government', 'rajasthan', 'jaipur', 'https://www.mnit.ac.in', 'Active'),
    ('nit-kurukshetra', 'NIT Kurukshetra', 'Kurukshetra, Haryana', 'NIT', 1963, ARRAY['Engineering'], 'A National Institute of Technology in Haryana offering undergraduate and postgraduate engineering programs.', 'Government', 'haryana', 'kurukshetra', 'https://www.nitkkr.ac.in', 'Active'),
    ('nit-hamirpur', 'NIT Hamirpur', 'Hamirpur, Himachal Pradesh', 'NIT', 1986, ARRAY['Engineering'], 'A National Institute of Technology in Himachal Pradesh offering undergraduate and postgraduate engineering programs.', 'Government', 'himachal-pradesh', 'hamirpur', 'https://www.nith.ac.in', 'Active'),
    ('nit-jalandhar', 'NIT Jalandhar', 'Jalandhar, Punjab', 'NIT', 1987, ARRAY['Engineering'], 'A National Institute of Technology in Punjab offering undergraduate and postgraduate engineering programs.', 'Government', 'punjab', 'jalandhar', 'https://www.nitj.ac.in', 'Active'),
    ('nit-raipur', 'NIT Raipur', 'Raipur, Chhattisgarh', 'NIT', 1956, ARRAY['Engineering'], 'A National Institute of Technology in Chhattisgarh offering undergraduate and postgraduate engineering programs.', 'Government', 'chhattisgarh', 'raipur', 'https://www.nitrr.ac.in', 'Active'),
    ('nit-agartala', 'NIT Agartala', 'Agartala, Tripura', 'NIT', 1965, ARRAY['Engineering'], 'A National Institute of Technology in Tripura offering undergraduate and postgraduate engineering programs.', 'Government', 'tripura', 'agartala', 'https://www.nita.ac.in', 'Active'),
    ('nit-arunachal-pradesh', 'NIT Arunachal Pradesh', 'Yupia, Arunachal Pradesh', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Arunachal Pradesh offering undergraduate and postgraduate engineering programs.', 'Government', 'arunachal-pradesh', 'yupia', 'https://www.nitap.ac.in', 'Active'),
    ('nit-delhi', 'NIT Delhi', 'New Delhi, Delhi', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Delhi offering undergraduate and postgraduate engineering programs.', 'Government', 'delhi', 'new-delhi', 'https://www.nitdelhi.ac.in', 'Active'),
    ('nit-goa', 'NIT Goa', 'Cuncolim, Goa', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Goa offering undergraduate and postgraduate engineering programs.', 'Government', 'goa', 'cuncolim', 'https://www.nitgoa.ac.in', 'Active'),
    ('nit-manipur', 'NIT Manipur', 'Imphal, Manipur', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Manipur offering undergraduate and postgraduate engineering programs.', 'Government', 'manipur', 'imphal', 'https://www.nitmanipur.ac.in', 'Active'),
    ('nit-meghalaya', 'NIT Meghalaya', 'Shillong, Meghalaya', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Meghalaya offering undergraduate and postgraduate engineering programs.', 'Government', 'meghalaya', 'shillong', 'https://www.nitm.ac.in', 'Active'),
    ('nit-mizoram', 'NIT Mizoram', 'Aizawl, Mizoram', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Mizoram offering undergraduate and postgraduate engineering programs.', 'Government', 'mizoram', 'aizawl', 'https://www.nitmz.ac.in', 'Active'),
    ('nit-nagaland', 'NIT Nagaland', 'Dimapur, Nagaland', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Nagaland offering undergraduate and postgraduate engineering programs.', 'Government', 'nagaland', 'dimapur', 'https://www.nitnagaland.ac.in', 'Active'),
    ('nit-puducherry', 'NIT Puducherry', 'Karaikal, Puducherry', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Puducherry offering undergraduate and postgraduate engineering programs.', 'Government', 'puducherry', 'karaikal', 'https://www.nitpy.ac.in', 'Active'),
    ('nit-sikkim', 'NIT Sikkim', 'Ravangla, Sikkim', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Sikkim offering undergraduate and postgraduate engineering programs.', 'Government', 'sikkim', 'ravangla', 'https://www.nitsikkim.ac.in', 'Active'),
    ('nit-uttarakhand', 'NIT Uttarakhand', 'Srinagar, Uttarakhand', 'NIT', 2010, ARRAY['Engineering'], 'A National Institute of Technology in Uttarakhand offering undergraduate and postgraduate engineering programs.', 'Government', 'uttarakhand', 'srinagar-garhwal', 'https://www.nituk.ac.in', 'Active'),
    ('nit-andhra-pradesh', 'NIT Andhra Pradesh', 'Tadepalligudem, Andhra Pradesh', 'NIT', 2015, ARRAY['Engineering'], 'A National Institute of Technology in Andhra Pradesh offering undergraduate and postgraduate engineering programs.', 'Government', 'andhra-pradesh', 'tadepalligudem', 'https://www.nitandhra.ac.in', 'Active')
ON CONFLICT DO NOTHING;

INSERT INTO college_exams (college_slug, exam_slug, sort_order)
SELECT c.slug, 'jee-main', 0
FROM (VALUES
    ('nit-surathkal'), ('nit-bhopal'), ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'),
    ('nit-srinagar'), ('nit-silchar'), ('nit-allahabad'), ('nit-surat'), ('nit-calicut'),
    ('nit-rourkela'), ('nit-jaipur'), ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'),
    ('nit-raipur'), ('nit-agartala'), ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'),
    ('nit-manipur'), ('nit-meghalaya'), ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'),
    ('nit-sikkim'), ('nit-uttarakhand'), ('nit-andhra-pradesh')
) AS c(slug)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order)
SELECT c.slug, 'b-tech', 0
FROM (VALUES
    ('nit-surathkal'), ('nit-bhopal'), ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'),
    ('nit-srinagar'), ('nit-silchar'), ('nit-allahabad'), ('nit-surat'), ('nit-calicut'),
    ('nit-rourkela'), ('nit-jaipur'), ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'),
    ('nit-raipur'), ('nit-agartala'), ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'),
    ('nit-manipur'), ('nit-meghalaya'), ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'),
    ('nit-sikkim'), ('nit-uttarakhand'), ('nit-andhra-pradesh')
) AS c(slug)
ON CONFLICT DO NOTHING;

-- career_colleges: sort_order computed relative to each career_slug's
-- current max (not a hardcoded literal) so this can never collide with
-- whatever's already there -- see header comment.
INSERT INTO career_colleges (career_slug, college_slug, sort_order)
SELECT v.career_slug, v.college_slug,
       (SELECT COALESCE(MAX(sort_order), -1) FROM career_colleges cc WHERE cc.career_slug = v.career_slug)
       + ROW_NUMBER() OVER (PARTITION BY v.career_slug ORDER BY v.college_slug)
FROM (
    SELECT career_slug, college_slug
    FROM (VALUES
        ('nit-surathkal'), ('nit-bhopal'), ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'),
        ('nit-srinagar'), ('nit-silchar'), ('nit-allahabad'), ('nit-surat'), ('nit-calicut'),
        ('nit-rourkela'), ('nit-jaipur'), ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'),
        ('nit-raipur'), ('nit-agartala'), ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'),
        ('nit-manipur'), ('nit-meghalaya'), ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'),
        ('nit-sikkim'), ('nit-uttarakhand'), ('nit-andhra-pradesh')
    ) AS colleges(college_slug)
    CROSS JOIN (VALUES
        ('computer-science-and-engineering'),
        ('electrical-engineering'),
        ('electronics-and-communication-engineering'),
        ('mechanical-engineering'),
        ('civil-engineering')
    ) AS careers(career_slug)
) v
ON CONFLICT DO NOTHING;

-- college_career_degrees: @OrderBy, not @OrderColumn (see College.java),
-- so a plain per-college 0..4 index is safe -- no density/uniqueness
-- invariant to worry about here.
INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT colleges.college_slug, careers.career_slug, 'b-tech',
       ROW_NUMBER() OVER (PARTITION BY colleges.college_slug ORDER BY careers.career_slug) - 1
FROM (VALUES
    ('nit-surathkal'), ('nit-bhopal'), ('nit-nagpur'), ('nit-durgapur'), ('nit-jamshedpur'),
    ('nit-srinagar'), ('nit-silchar'), ('nit-allahabad'), ('nit-surat'), ('nit-calicut'),
    ('nit-rourkela'), ('nit-jaipur'), ('nit-kurukshetra'), ('nit-hamirpur'), ('nit-jalandhar'),
    ('nit-raipur'), ('nit-agartala'), ('nit-arunachal-pradesh'), ('nit-delhi'), ('nit-goa'),
    ('nit-manipur'), ('nit-meghalaya'), ('nit-mizoram'), ('nit-nagaland'), ('nit-puducherry'),
    ('nit-sikkim'), ('nit-uttarakhand'), ('nit-andhra-pradesh')
) AS colleges(college_slug)
CROSS JOIN (VALUES
    ('computer-science-and-engineering'),
    ('electrical-engineering'),
    ('electronics-and-communication-engineering'),
    ('mechanical-engineering'),
    ('civil-engineering')
) AS careers(career_slug)
ON CONFLICT DO NOTHING;
