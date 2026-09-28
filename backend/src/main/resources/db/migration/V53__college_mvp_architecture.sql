-- Implements the uploaded "CareerGuide -- College MVP Architecture" spec
-- (the second, 20-page, authoritative version -- the first 13-page version
-- was superseded before any code was written against it). That doc's own
-- words: "Because CareerGuide already uses Discipline -> Specialization ->
-- Job Role... The college should be able to connect to the same
-- specialization system" -- so this reuses the existing careers/degrees/
-- specializations tables by slug throughout, rather than inventing parallel
-- ones. Per the spec: "There is no Course entity in the MVP" (Section 4,
-- and first in Section 25's explicit not-to-build list) and "Do not
-- directly connect colleges to job roles in the initial MVP" (Section 18)
-- -- neither is added here.
--
-- New master tables: states, cities, universities.
-- New relationship tables: college_degrees, college_specializations.
-- Extended: colleges gets ownership_type, university_slug, state_slug,
-- city_slug, website, status.
--
-- Three judgment calls worth recording:
--
-- 1. college_type: the spec asks for a college_type field, but colleges
--    already has `type` (IIT/NIT/Medical/Law/Management/Polytechnic/
--    University/ITI, added V1, still populated on every row) doing exactly
--    that job. Adding a second, parallel `college_type` column would just
--    create two competing sources of truth for the same fact with no way
--    to keep them in sync. `type` stays as-is and fulfills this part of
--    the spec.
--
-- 2. college_disciplines: the spec wants a college<->discipline (career)
--    relationship, but V13 already created exactly that shape -- the
--    unidirectional `career_colleges` table (career_slug, college_slug),
--    exposed today as Career.relatedCollegeSlugs / the admin career form's
--    "Related Colleges" picker. Rather than fork a second, parallel
--    college_slug/career_slug join table that would need to be kept in
--    sync with the first by hand forever, College gets a proper JPA
--    inverse mapping onto the SAME career_colleges table (mappedBy on the
--    College entity side of Career.relatedColleges) -- one table, one
--    source of truth, editable and readable from either side. This is
--    safe to do now specifically because career_colleges was in V49's
--    TRUNCATE list (it referenced the pre-taxonomy career slugs) and was
--    never repopulated after -- it's genuinely empty, so there's no
--    existing data to reconcile between two divergent shapes. No SQL
--    change is needed for this table at all; the seed data below inserts
--    into the existing career_colleges directly.
--
-- 3. discipline_degrees / specialization_degrees: discipline_degrees is
--    already satisfied by career_degrees (V51) -- same slugs, same
--    semantics, nothing to add. specialization_degrees is explicitly
--    optional/deferred in the spec ("can be added later without breaking
--    existing structure") and is skipped here for the same reason
--    college_specializations gets no seed rows below: accurately mapping
--    265 specializations against specific colleges isn't something to
--    guess at, unlike the broad discipline/degree links below which are
--    all well-known, publicly documented facts about each institution.
--
-- states/cities: seeded with the full, current (post-2020) list of 28
-- states + 8 union territories for states (stable, well-known reference
-- data -- India's last territorial change was Jammu & Kashmir's 2019
-- reorganisation), but cities gets only the 12 cities the existing 20
-- seed colleges actually sit in -- an exhaustive Indian city catalog would
-- be thousands of rows fabricated with no source, the same "don't guess
-- past what's confidently known" rule V47/V51 already established for
-- degree links. Admin can add more cities as more colleges are entered.
--
-- universities: the table is created with NO seed rows. Every one of the
-- 20 existing colleges is, on inspection, either itself an autonomous
-- degree-granting body (every IIT, NIT, IIM, AIIMS, the two National Law
-- Universities, NID, plus Delhi University/BHU/Indian Maritime University,
-- which are themselves universities, not colleges affiliated to one) or
-- affiliated to a technical-education board rather than a university
-- (the polytechnic and ITI). Inventing a "University of X" parent for any
-- of them would misrepresent how Indian higher ed is actually structured.
-- The table exists so admin can record real affiliating universities for
-- future, non-autonomous colleges (the common case for most private
-- engineering/arts/commerce colleges in India).
--
-- ownership_type/website/status/state/city backfill for the 20 existing
-- colleges below is all well-known, stable, publicly documented fact about
-- each named institution (its home city/state, whether it's a government
-- or private body, its official domain) -- not a guess -- with the same
-- caution applied as everywhere else in this file: 3 rows (the polytechnic,
-- the ITI, the Institute of Hotel Management Pusa) get no website because
-- no single official domain for them could be confidently confirmed here,
-- and college_degrees below only links a degree where it's a clean, direct,
-- well-known match (same principle as V51), leaving 1 of the 20
-- (nchm-pusa) and college_disciplines leaving 5 of the 20 (the two general
-- universities plus imu-chennai, govt-polytechnic-mumbai's specific trades,
-- iti-mumbai) without a link rather than force one.

CREATE TABLE states (
    slug VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    code VARCHAR(8) NOT NULL
);

CREATE TABLE cities (
    slug       VARCHAR(64) PRIMARY KEY,
    name       VARCHAR(128) NOT NULL,
    state_slug VARCHAR(64) NOT NULL REFERENCES states (slug)
);

CREATE TABLE universities (
    slug             VARCHAR(64) PRIMARY KEY,
    name             VARCHAR(200) NOT NULL,
    university_type  VARCHAR(32) NOT NULL,
    ownership_type   VARCHAR(32) NOT NULL,
    state_slug       VARCHAR(64) REFERENCES states (slug) ON DELETE SET NULL,
    city_slug        VARCHAR(64) REFERENCES cities (slug) ON DELETE SET NULL,
    website          VARCHAR(255),
    status           VARCHAR(16) NOT NULL DEFAULT 'Active'
);

CREATE TABLE college_degrees (
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    degree_slug  VARCHAR(64) NOT NULL REFERENCES degrees (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (college_slug, degree_slug)
);

CREATE TABLE college_specializations (
    college_slug         VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    specialization_slug  VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    sort_order           INT NOT NULL DEFAULT 0,
    PRIMARY KEY (college_slug, specialization_slug)
);

ALTER TABLE colleges ADD COLUMN ownership_type VARCHAR(32) NOT NULL DEFAULT 'Government';
ALTER TABLE colleges ADD COLUMN university_slug VARCHAR(64) REFERENCES universities (slug) ON DELETE SET NULL;
ALTER TABLE colleges ADD COLUMN state_slug VARCHAR(64) REFERENCES states (slug);
ALTER TABLE colleges ADD COLUMN city_slug VARCHAR(64) REFERENCES cities (slug) ON DELETE SET NULL;
ALTER TABLE colleges ADD COLUMN website VARCHAR(255);
ALTER TABLE colleges ADD COLUMN status VARCHAR(16) NOT NULL DEFAULT 'Active';

-- ---------------------------------------------------------------------
-- Reference data: all 28 states + 8 union territories.
-- ---------------------------------------------------------------------
INSERT INTO states (slug, name, code) VALUES
    ('andhra-pradesh', 'Andhra Pradesh', 'AP'),
    ('arunachal-pradesh', 'Arunachal Pradesh', 'AR'),
    ('assam', 'Assam', 'AS'),
    ('bihar', 'Bihar', 'BR'),
    ('chhattisgarh', 'Chhattisgarh', 'CG'),
    ('goa', 'Goa', 'GA'),
    ('gujarat', 'Gujarat', 'GJ'),
    ('haryana', 'Haryana', 'HR'),
    ('himachal-pradesh', 'Himachal Pradesh', 'HP'),
    ('jharkhand', 'Jharkhand', 'JH'),
    ('karnataka', 'Karnataka', 'KA'),
    ('kerala', 'Kerala', 'KL'),
    ('madhya-pradesh', 'Madhya Pradesh', 'MP'),
    ('maharashtra', 'Maharashtra', 'MH'),
    ('manipur', 'Manipur', 'MN'),
    ('meghalaya', 'Meghalaya', 'ML'),
    ('mizoram', 'Mizoram', 'MZ'),
    ('nagaland', 'Nagaland', 'NL'),
    ('odisha', 'Odisha', 'OD'),
    ('punjab', 'Punjab', 'PB'),
    ('rajasthan', 'Rajasthan', 'RJ'),
    ('sikkim', 'Sikkim', 'SK'),
    ('tamil-nadu', 'Tamil Nadu', 'TN'),
    ('telangana', 'Telangana', 'TG'),
    ('tripura', 'Tripura', 'TR'),
    ('uttar-pradesh', 'Uttar Pradesh', 'UP'),
    ('uttarakhand', 'Uttarakhand', 'UK'),
    ('west-bengal', 'West Bengal', 'WB'),
    ('andaman-and-nicobar-islands', 'Andaman and Nicobar Islands', 'AN'),
    ('chandigarh', 'Chandigarh', 'CH'),
    ('dadra-and-nagar-haveli-and-daman-and-diu', 'Dadra and Nagar Haveli and Daman and Diu', 'DN'),
    ('delhi', 'Delhi', 'DL'),
    ('jammu-and-kashmir', 'Jammu and Kashmir', 'JK'),
    ('ladakh', 'Ladakh', 'LA'),
    ('lakshadweep', 'Lakshadweep', 'LD'),
    ('puducherry', 'Puducherry', 'PY');

-- Only the cities the existing 20 seed colleges are actually in -- see
-- header comment.
INSERT INTO cities (slug, name, state_slug) VALUES
    ('mumbai', 'Mumbai', 'maharashtra'),
    ('new-delhi', 'New Delhi', 'delhi'),
    ('chennai', 'Chennai', 'tamil-nadu'),
    ('tiruchirappalli', 'Tiruchirappalli', 'tamil-nadu'),
    ('warangal', 'Warangal', 'telangana'),
    ('vellore', 'Vellore', 'tamil-nadu'),
    ('bengaluru', 'Bengaluru', 'karnataka'),
    ('hyderabad', 'Hyderabad', 'telangana'),
    ('ahmedabad', 'Ahmedabad', 'gujarat'),
    ('varanasi', 'Varanasi', 'uttar-pradesh'),
    ('patna', 'Patna', 'bihar'),
    ('dhanbad', 'Dhanbad', 'jharkhand');

-- ---------------------------------------------------------------------
-- Backfill for the 20 existing colleges: ownership_type, state_slug,
-- city_slug, website. All Government except cmc-vellore (a private,
-- Christian-minority deemed university). No university_slug for any of
-- them -- see header comment.
-- ---------------------------------------------------------------------
UPDATE colleges SET ownership_type = 'Private' WHERE slug = 'cmc-vellore';
ALTER TABLE colleges ALTER COLUMN ownership_type DROP DEFAULT;

UPDATE colleges SET state_slug = 'maharashtra', city_slug = 'mumbai', website = 'https://www.iitb.ac.in' WHERE slug = 'iit-bombay';
UPDATE colleges SET state_slug = 'delhi', city_slug = 'new-delhi', website = 'https://home.iitd.ac.in' WHERE slug = 'iit-delhi';
UPDATE colleges SET state_slug = 'tamil-nadu', city_slug = 'chennai', website = 'https://www.iitm.ac.in' WHERE slug = 'iit-madras';
UPDATE colleges SET state_slug = 'tamil-nadu', city_slug = 'tiruchirappalli', website = 'https://www.nitt.edu' WHERE slug = 'nit-trichy';
UPDATE colleges SET state_slug = 'telangana', city_slug = 'warangal', website = 'https://www.nitw.ac.in' WHERE slug = 'nit-warangal';
UPDATE colleges SET state_slug = 'delhi', city_slug = 'new-delhi', website = 'https://www.aiims.edu' WHERE slug = 'aiims-delhi';
UPDATE colleges SET state_slug = 'tamil-nadu', city_slug = 'vellore', website = 'https://www.cmch-vellore.edu' WHERE slug = 'cmc-vellore';
UPDATE colleges SET state_slug = 'karnataka', city_slug = 'bengaluru', website = 'https://www.nls.ac.in' WHERE slug = 'nlsiu-bangalore';
UPDATE colleges SET state_slug = 'telangana', city_slug = 'hyderabad', website = 'https://www.nalsar.ac.in' WHERE slug = 'nalsar-hyderabad';
UPDATE colleges SET state_slug = 'gujarat', city_slug = 'ahmedabad', website = 'https://www.iima.ac.in' WHERE slug = 'iim-ahmedabad';
UPDATE colleges SET state_slug = 'karnataka', city_slug = 'bengaluru', website = 'https://www.iimb.ac.in' WHERE slug = 'iim-bangalore';
UPDATE colleges SET state_slug = 'gujarat', city_slug = 'ahmedabad', website = 'https://www.nid.edu' WHERE slug = 'nid-ahmedabad';
UPDATE colleges SET state_slug = 'delhi', city_slug = 'new-delhi', website = 'https://www.du.ac.in' WHERE slug = 'du-delhi';
UPDATE colleges SET state_slug = 'uttar-pradesh', city_slug = 'varanasi', website = 'https://www.bhu.ac.in' WHERE slug = 'bhu-varanasi';
UPDATE colleges SET state_slug = 'maharashtra', city_slug = 'mumbai' WHERE slug = 'govt-polytechnic-mumbai';
UPDATE colleges SET state_slug = 'maharashtra', city_slug = 'mumbai' WHERE slug = 'iti-mumbai';
UPDATE colleges SET state_slug = 'delhi', city_slug = 'new-delhi' WHERE slug = 'nchm-pusa';
UPDATE colleges SET state_slug = 'bihar', city_slug = 'patna', website = 'https://www.nitp.ac.in' WHERE slug = 'nit-patna';
UPDATE colleges SET state_slug = 'tamil-nadu', city_slug = 'chennai', website = 'https://www.imu.edu.in' WHERE slug = 'imu-chennai';
UPDATE colleges SET state_slug = 'jharkhand', city_slug = 'dhanbad', website = 'https://www.iitism.ac.in' WHERE slug = 'iit-ism-dhanbad';

-- Every one of the 20 existing colleges now has a state -- safe to require
-- it going forward. city_slug/website/university_slug stay optional (not
-- every college has a confidently-known city-catalog entry or official
-- site yet, and most are, correctly, affiliated with no separate
-- university -- see header comment).
ALTER TABLE colleges ALTER COLUMN state_slug SET NOT NULL;

-- ---------------------------------------------------------------------
-- college_degrees: only a degree that's a clean, direct, well-known match
-- for the institution (same principle as V51's career_degrees). 1 of 20
-- (nchm-pusa) gets none.
-- ---------------------------------------------------------------------
INSERT INTO college_degrees (college_slug, degree_slug, sort_order) VALUES
    ('iit-bombay', 'b-tech', 0),
    ('iit-delhi', 'b-tech', 0),
    ('iit-madras', 'b-tech', 0),
    ('nit-trichy', 'b-tech', 0),
    ('nit-warangal', 'b-tech', 0),
    ('nit-patna', 'b-tech', 0),
    ('iit-ism-dhanbad', 'b-tech', 0),
    ('imu-chennai', 'b-tech', 0),
    ('aiims-delhi', 'mbbs', 0),
    ('cmc-vellore', 'mbbs', 0),
    ('nlsiu-bangalore', 'llb', 0),
    ('nalsar-hyderabad', 'llb', 0),
    ('iim-ahmedabad', 'mba', 0),
    ('iim-bangalore', 'mba', 0),
    ('nid-ahmedabad', 'b-des', 0),
    ('du-delhi', 'ba', 0),
    ('bhu-varanasi', 'ba', 0),
    ('govt-polytechnic-mumbai', 'diploma', 0),
    ('iti-mumbai', 'certificate', 0);

-- ---------------------------------------------------------------------
-- college_disciplines, via the existing (and currently empty -- see header
-- comment) career_colleges table. Only the well-known core branches each
-- institution is actually known for; the two general universities
-- (du-delhi, bhu-varanasi) and imu-chennai/iti-mumbai are left unmapped
-- rather than force a guess at which of the 42 disciplines to pick for an
-- institution that broad or that specific.
-- ---------------------------------------------------------------------
INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES
    ('computer-science-and-engineering', 'iit-bombay', 0),
    ('computer-science-and-engineering', 'iit-delhi', 1),
    ('computer-science-and-engineering', 'iit-madras', 2),
    ('computer-science-and-engineering', 'nit-trichy', 3),
    ('computer-science-and-engineering', 'nit-warangal', 4),
    ('computer-science-and-engineering', 'nit-patna', 5),
    ('computer-science-and-engineering', 'iit-ism-dhanbad', 6),
    ('mechanical-engineering', 'iit-bombay', 0),
    ('mechanical-engineering', 'iit-delhi', 1),
    ('mechanical-engineering', 'iit-madras', 2),
    ('mechanical-engineering', 'nit-trichy', 3),
    ('mechanical-engineering', 'nit-warangal', 4),
    ('mechanical-engineering', 'nit-patna', 5),
    ('mechanical-engineering', 'govt-polytechnic-mumbai', 6),
    ('civil-engineering', 'iit-bombay', 0),
    ('civil-engineering', 'iit-delhi', 1),
    ('civil-engineering', 'iit-madras', 2),
    ('civil-engineering', 'nit-trichy', 3),
    ('civil-engineering', 'nit-warangal', 4),
    ('civil-engineering', 'nit-patna', 5),
    ('civil-engineering', 'govt-polytechnic-mumbai', 6),
    ('electrical-engineering', 'iit-bombay', 0),
    ('electrical-engineering', 'iit-delhi', 1),
    ('electrical-engineering', 'iit-madras', 2),
    ('electrical-engineering', 'nit-trichy', 3),
    ('electrical-engineering', 'nit-warangal', 4),
    ('electrical-engineering', 'nit-patna', 5),
    ('electrical-engineering', 'govt-polytechnic-mumbai', 6),
    ('mining-engineering', 'iit-ism-dhanbad', 0),
    ('medicine', 'aiims-delhi', 0),
    ('medicine', 'cmc-vellore', 1),
    ('law', 'nlsiu-bangalore', 0),
    ('law', 'nalsar-hyderabad', 1),
    ('business-administration', 'iim-ahmedabad', 0),
    ('business-administration', 'iim-bangalore', 1),
    ('design', 'nid-ahmedabad', 0),
    ('hospitality-management', 'nchm-pusa', 0)
ON CONFLICT DO NOTHING;
