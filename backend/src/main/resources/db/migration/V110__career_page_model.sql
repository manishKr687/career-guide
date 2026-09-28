-- Gives Career the structure its detail page needs, and gives Specialization
-- the one number it was missing.
--
-- Five gaps, in order of how much modelling each needed:
--
--   1. growth_path is text[] -- "Software Engineer", "Tech Lead" -- with no
--      experience attached, so a ladder cannot say when each rung happens.
--   2. No salary breakdown by level. The career's overall range exists as
--      numbers (V107); "entry vs mid vs senior" does not exist at all.
--   3. career_industries is 100% employers: 252 rows, every one is_sector =
--      false. The sector half of the question -- which INDUSTRIES a career is
--      practised in, as opposed to which COMPANIES hire -- had no data, even
--      though `industries.is_sector` has distinguished the two all along.
--   4. No work environments, no highlights, no experience or openings.
--   5. Specialization has no salary since V107 dropped its three empty
--      per-level text columns. It now has a consumer, so it comes back -- as
--      numbers this time, nullable, with the same CHECK careers carry.
--
-- WHAT IS SEEDED AND WHAT IS NOT.
--
-- Seeded: growth stages (from the existing ladder), sector links, and work
-- environments. Sectors are listed PER CAREER rather than per category. The
-- first draft of this migration mapped them by category and it was wrong in a
-- way worth recording: `engineering-technology` holds all 16 engineering
-- careers, so Computer Science and Mining Engineering would have received the
-- same sector list. One line per career is more text and the only version
-- that is true.
--
-- Which sectors a field is practised in is still a statement about the field,
-- not a researched per-row fact -- a low-risk claim, unlike "IIT Bombay
-- teaches Blockchain", which is the kind of row V109 refused to generate.
--
-- NOT seeded: career_salary_bands, experience years, job openings.
--
-- These are figures a student plans around and none of them can be derived
-- from anything already in the database. Two derivations were tried and
-- rejected: growth-stage titles match a real job role only 32 times out of
-- 210, and tiering job roles by name puts 250 of 290 in "Mid Level" because
-- the catalog does not encode seniority. Generating plausible-looking rupee
-- figures from the overall range would produce numbers that read as
-- researched and are not. The columns, the table, the admin fields and the UI
-- all ship; the figures are a content task.
--
-- growth_path is NOT dropped here, the same discipline V107 used for
-- salary_range: add the structured form, move the readers, drop the column in
-- a later migration once nothing reads it.

-- --------------------------------------------------------------------------
-- 1. Career columns.
-- --------------------------------------------------------------------------

ALTER TABLE careers
    -- Short claims about the career. Left empty: the page derives them from
    -- facts it can prove (demand, how many specializations, salary ceiling,
    -- how many sectors) and a stored value overrides that. A derived claim
    -- cannot go stale against the data it is derived from.
    ADD COLUMN highlights text[] NOT NULL DEFAULT '{}',

    -- Work settings, e.g. Product Companies / Research Labs / Remote. Plain
    -- text, same as growth_path: there is nothing in the catalog for a work
    -- environment to link to.
    ADD COLUMN work_environments text[] NOT NULL DEFAULT '{}',

    -- Typical years of experience in the field, and open roles. Both
    -- nullable and unseeded -- see the header.
    ADD COLUMN experience_min_years smallint,
    ADD COLUMN experience_max_years smallint,
    ADD COLUMN job_openings integer;

ALTER TABLE careers ADD CONSTRAINT careers_experience_sane
    CHECK (experience_min_years IS NULL OR experience_max_years IS NULL
           OR (experience_min_years >= 0 AND experience_min_years <= experience_max_years));

ALTER TABLE careers ADD CONSTRAINT careers_job_openings_sane
    CHECK (job_openings IS NULL OR job_openings > 0);

-- --------------------------------------------------------------------------
-- 2. The growth ladder, with experience attached.
-- --------------------------------------------------------------------------

-- max_years is nullable and means open-ended: the last rung of a ladder has
-- no upper bound, and 12-NULL is the honest way to say "12+" without picking
-- an arbitrary ceiling.
CREATE TABLE career_growth_stages (
    career_slug varchar(64)  NOT NULL REFERENCES careers(slug) ON DELETE CASCADE,
    title       varchar(160) NOT NULL,
    min_years   smallint     NOT NULL,
    max_years   smallint,
    sort_order  integer      NOT NULL DEFAULT 0,
    id          bigserial    PRIMARY KEY,
    CONSTRAINT career_growth_stages_years_sane
        CHECK (min_years >= 0 AND (max_years IS NULL OR min_years < max_years))
);

CREATE UNIQUE INDEX uq_career_growth_stages_natural
    ON career_growth_stages (career_slug, sort_order);

-- Titles come from growth_path, which is real content. The year bands come
-- from the rung's POSITION, not from per-career research, and every career
-- has exactly 5 rungs so the mapping is total. Stated plainly because the
-- distinction matters: rung 3 of any ladder being roughly 5-8 years in is a
-- convention, and an admin correcting it for a specific career is expected,
-- not exceptional.
INSERT INTO career_growth_stages (career_slug, title, min_years, max_years, sort_order)
SELECT c.slug,
       g.title,
       (ARRAY[0, 2, 5, 8, 12])[g.ord],
       (ARRAY[2, 5, 8, 12, NULL])[g.ord],
       g.ord - 1
FROM careers c, unnest(c.growth_path) WITH ORDINALITY AS g(title, ord);

-- --------------------------------------------------------------------------
-- 3. Salary by level. Structure only -- see the header for why it is empty.
-- --------------------------------------------------------------------------

CREATE TABLE career_salary_bands (
    career_slug varchar(64) NOT NULL REFERENCES careers(slug) ON DELETE CASCADE,
    band        varchar(48) NOT NULL,
    min_lpa     numeric(6,2) NOT NULL,
    max_lpa     numeric(6,2),
    sort_order  integer     NOT NULL DEFAULT 0,
    id          bigserial   PRIMARY KEY,
    -- max_lpa NULL is open-ended, the same convention as max_years above:
    -- "Leadership 40+ LPA" has no ceiling to invent.
    CONSTRAINT career_salary_bands_sane
        CHECK (min_lpa > 0 AND (max_lpa IS NULL OR min_lpa <= max_lpa))
);

CREATE UNIQUE INDEX uq_career_salary_bands_natural
    ON career_salary_bands (career_slug, sort_order);

-- --------------------------------------------------------------------------
-- 4. Specialization salary.
-- --------------------------------------------------------------------------

ALTER TABLE specializations
    ADD COLUMN salary_min_lpa numeric(6,2),
    ADD COLUMN salary_max_lpa numeric(6,2);

ALTER TABLE specializations ADD CONSTRAINT specializations_salary_range_sane
    CHECK (salary_min_lpa IS NULL OR salary_max_lpa IS NULL
           OR (salary_min_lpa > 0 AND salary_min_lpa <= salary_max_lpa));

-- --------------------------------------------------------------------------
-- 5. Sectors. The other half of `industries`.
-- --------------------------------------------------------------------------

-- 14 sectors, so that every category has somewhere truthful to point. The
-- table held 12 (10 original + robotics and research-and-development from
-- V109), all of them tech- or finance-leaning, which is why non-tech careers
-- had no sector to link to.
INSERT INTO industries (slug, name, is_sector) VALUES
    ('manufacturing',             'Manufacturing',              true),
    ('construction-infrastructure', 'Construction & Infrastructure', true),
    ('agriculture-agribusiness',  'Agriculture & Agribusiness', true),
    ('media-entertainment',       'Media & Entertainment',      true),
    ('retail',                    'Retail',                     true),
    ('hospitality-travel',        'Hospitality & Travel',       true),
    ('energy-utilities',          'Energy & Utilities',         true),
    ('aerospace-defence',         'Aerospace & Defence',        true),
    ('pharmaceuticals',           'Pharmaceuticals',            true),
    ('legal-services',            'Legal Services',             true),
    ('consulting',                'Consulting',                 true),
    ('logistics-supply-chain',    'Logistics & Supply Chain',   true),
    ('sports-fitness',            'Sports & Fitness',           true),
    ('social-development',        'Social & Development Sector', true)
ON CONFLICT (slug) DO NOTHING;

-- Career -> sectors, one list per career. career_industries has no
-- sort_order column (it is an unordered Set on the entity), so these append
-- alongside the existing employer rows; the page separates the two on
-- is_sector.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('accounting', 'banking'),
    ('accounting', 'consulting'),
    ('accounting', 'manufacturing'),
    ('accounting', 'retail'),
    ('accounting', 'government'),
    ('aerospace-engineering', 'aerospace-defence'),
    ('aerospace-engineering', 'manufacturing'),
    ('aerospace-engineering', 'research-and-development'),
    ('aerospace-engineering', 'government'),
    ('aerospace-engineering', 'information-technology'),
    ('agriculture', 'agriculture-agribusiness'),
    ('agriculture', 'research-and-development'),
    ('agriculture', 'government'),
    ('agriculture', 'retail'),
    ('agriculture', 'logistics-supply-chain'),
    ('architecture', 'construction-infrastructure'),
    ('architecture', 'consulting'),
    ('architecture', 'government'),
    ('architecture', 'retail'),
    ('architecture', 'media-entertainment'),
    ('biology', 'research-and-development'),
    ('biology', 'healthcare'),
    ('biology', 'pharmaceuticals'),
    ('biology', 'education'),
    ('biology', 'agriculture-agribusiness'),
    ('biomedical-engineering', 'healthcare'),
    ('biomedical-engineering', 'pharmaceuticals'),
    ('biomedical-engineering', 'manufacturing'),
    ('biomedical-engineering', 'research-and-development'),
    ('biomedical-engineering', 'information-technology'),
    ('biotechnology', 'pharmaceuticals'),
    ('biotechnology', 'healthcare'),
    ('biotechnology', 'agriculture-agribusiness'),
    ('biotechnology', 'research-and-development'),
    ('biotechnology', 'manufacturing'),
    ('business-administration', 'consulting'),
    ('business-administration', 'e-commerce'),
    ('business-administration', 'retail'),
    ('business-administration', 'information-technology'),
    ('business-administration', 'manufacturing'),
    ('business-administration', 'logistics-supply-chain'),
    ('chemical-engineering', 'manufacturing'),
    ('chemical-engineering', 'energy-utilities'),
    ('chemical-engineering', 'pharmaceuticals'),
    ('chemical-engineering', 'research-and-development'),
    ('chemical-engineering', 'consulting'),
    ('chemistry', 'pharmaceuticals'),
    ('chemistry', 'manufacturing'),
    ('chemistry', 'research-and-development'),
    ('chemistry', 'energy-utilities'),
    ('chemistry', 'education'),
    ('civil-engineering', 'construction-infrastructure'),
    ('civil-engineering', 'government'),
    ('civil-engineering', 'consulting'),
    ('civil-engineering', 'energy-utilities'),
    ('civil-engineering', 'logistics-supply-chain'),
    ('computer-science-and-engineering', 'information-technology'),
    ('computer-science-and-engineering', 'saas'),
    ('computer-science-and-engineering', 'e-commerce'),
    ('computer-science-and-engineering', 'fintech'),
    ('computer-science-and-engineering', 'healthcare'),
    ('computer-science-and-engineering', 'telecommunications'),
    ('computer-science-and-engineering', 'education'),
    ('computer-science-and-engineering', 'government'),
    ('design', 'media-entertainment'),
    ('design', 'information-technology'),
    ('design', 'e-commerce'),
    ('design', 'retail'),
    ('design', 'consulting'),
    ('electrical-engineering', 'energy-utilities'),
    ('electrical-engineering', 'manufacturing'),
    ('electrical-engineering', 'automotive'),
    ('electrical-engineering', 'construction-infrastructure'),
    ('electrical-engineering', 'telecommunications'),
    ('electronics-and-communication-engineering', 'telecommunications'),
    ('electronics-and-communication-engineering', 'manufacturing'),
    ('electronics-and-communication-engineering', 'automotive'),
    ('electronics-and-communication-engineering', 'aerospace-defence'),
    ('electronics-and-communication-engineering', 'information-technology'),
    ('environmental-engineering', 'energy-utilities'),
    ('environmental-engineering', 'government'),
    ('environmental-engineering', 'construction-infrastructure'),
    ('environmental-engineering', 'consulting'),
    ('environmental-engineering', 'research-and-development'),
    ('finance', 'banking'),
    ('finance', 'fintech'),
    ('finance', 'consulting'),
    ('finance', 'e-commerce'),
    ('finance', 'government'),
    ('forestry', 'agriculture-agribusiness'),
    ('forestry', 'government'),
    ('forestry', 'research-and-development'),
    ('forestry', 'social-development'),
    ('forestry', 'energy-utilities'),
    ('hospitality-management', 'hospitality-travel'),
    ('hospitality-management', 'e-commerce'),
    ('hospitality-management', 'retail'),
    ('hospitality-management', 'logistics-supply-chain'),
    ('human-resource-management', 'consulting'),
    ('human-resource-management', 'information-technology'),
    ('human-resource-management', 'manufacturing'),
    ('human-resource-management', 'retail'),
    ('human-resource-management', 'healthcare'),
    ('industrial-engineering', 'manufacturing'),
    ('industrial-engineering', 'logistics-supply-chain'),
    ('industrial-engineering', 'consulting'),
    ('industrial-engineering', 'automotive'),
    ('industrial-engineering', 'retail'),
    ('information-technology', 'information-technology'),
    ('information-technology', 'saas'),
    ('information-technology', 'e-commerce'),
    ('information-technology', 'fintech'),
    ('information-technology', 'banking'),
    ('information-technology', 'telecommunications'),
    ('information-technology', 'government'),
    ('information-technology', 'consulting'),
    ('journalism-and-mass-communication', 'media-entertainment'),
    ('journalism-and-mass-communication', 'information-technology'),
    ('journalism-and-mass-communication', 'government'),
    ('journalism-and-mass-communication', 'education'),
    ('journalism-and-mass-communication', 'social-development'),
    ('law', 'legal-services'),
    ('law', 'government'),
    ('law', 'consulting'),
    ('law', 'banking'),
    ('law', 'information-technology'),
    ('manufacturing-engineering', 'manufacturing'),
    ('manufacturing-engineering', 'automotive'),
    ('manufacturing-engineering', 'aerospace-defence'),
    ('manufacturing-engineering', 'logistics-supply-chain'),
    ('manufacturing-engineering', 'energy-utilities'),
    ('marketing', 'e-commerce'),
    ('marketing', 'retail'),
    ('marketing', 'media-entertainment'),
    ('marketing', 'information-technology'),
    ('marketing', 'consulting'),
    ('mathematics', 'education'),
    ('mathematics', 'research-and-development'),
    ('mathematics', 'fintech'),
    ('mathematics', 'information-technology'),
    ('mathematics', 'consulting'),
    ('mechanical-engineering', 'manufacturing'),
    ('mechanical-engineering', 'automotive'),
    ('mechanical-engineering', 'energy-utilities'),
    ('mechanical-engineering', 'aerospace-defence'),
    ('mechanical-engineering', 'construction-infrastructure'),
    ('medicine', 'healthcare'),
    ('medicine', 'government'),
    ('medicine', 'research-and-development'),
    ('medicine', 'education'),
    ('metallurgical-and-materials-engineering', 'manufacturing'),
    ('metallurgical-and-materials-engineering', 'construction-infrastructure'),
    ('metallurgical-and-materials-engineering', 'automotive'),
    ('metallurgical-and-materials-engineering', 'aerospace-defence'),
    ('metallurgical-and-materials-engineering', 'research-and-development'),
    ('mining-engineering', 'energy-utilities'),
    ('mining-engineering', 'manufacturing'),
    ('mining-engineering', 'government'),
    ('mining-engineering', 'construction-infrastructure'),
    ('mining-engineering', 'logistics-supply-chain'),
    ('nursing', 'healthcare'),
    ('nursing', 'government'),
    ('nursing', 'education'),
    ('nursing', 'social-development'),
    ('petroleum-engineering', 'energy-utilities'),
    ('petroleum-engineering', 'manufacturing'),
    ('petroleum-engineering', 'government'),
    ('petroleum-engineering', 'consulting'),
    ('petroleum-engineering', 'logistics-supply-chain'),
    ('pharmacy', 'pharmaceuticals'),
    ('pharmacy', 'healthcare'),
    ('pharmacy', 'retail'),
    ('pharmacy', 'research-and-development'),
    ('pharmacy', 'manufacturing'),
    ('physics', 'research-and-development'),
    ('physics', 'education'),
    ('physics', 'energy-utilities'),
    ('physics', 'aerospace-defence'),
    ('physics', 'information-technology'),
    ('physiotherapy', 'healthcare'),
    ('physiotherapy', 'sports-fitness'),
    ('physiotherapy', 'education'),
    ('physiotherapy', 'social-development'),
    ('psychology', 'healthcare'),
    ('psychology', 'education'),
    ('psychology', 'social-development'),
    ('psychology', 'consulting'),
    ('psychology', 'government'),
    ('public-administration', 'government'),
    ('public-administration', 'social-development'),
    ('public-administration', 'consulting'),
    ('public-administration', 'education'),
    ('sociology', 'social-development'),
    ('sociology', 'government'),
    ('sociology', 'education'),
    ('sociology', 'research-and-development'),
    ('sociology', 'media-entertainment'),
    ('sports-science', 'sports-fitness'),
    ('sports-science', 'healthcare'),
    ('sports-science', 'education'),
    ('sports-science', 'media-entertainment'),
    ('statistics', 'fintech'),
    ('statistics', 'information-technology'),
    ('statistics', 'research-and-development'),
    ('statistics', 'healthcare'),
    ('statistics', 'consulting'),
    ('statistics', 'government'),
    ('tourism', 'hospitality-travel'),
    ('tourism', 'government'),
    ('tourism', 'e-commerce'),
    ('tourism', 'media-entertainment')
ON CONFLICT DO NOTHING;

-- --------------------------------------------------------------------------
-- 6. Work environments: per category, then overridden where the category is
--    too broad to be true.
-- --------------------------------------------------------------------------
--
-- Unlike sectors, a category default works here for most careers -- everyone
-- in medical-healthcare does work in hospitals and clinics. The exception is
-- the same one as above: engineering-technology's default describes plants
-- and project sites, which is right for 14 of its 16 careers and wrong for
-- the two computing ones, so those are set again afterwards.

UPDATE careers c SET work_environments = m.envs
FROM (VALUES
    ('it-software',               ARRAY['Product Companies','Tech Startups','IT Services','Remote','Hybrid','Collaborative Teams']),
    ('engineering-technology',    ARRAY['Manufacturing Plants','Design Offices','Project Sites','R&D Labs','Onsite Teams']),
    ('science-research',          ARRAY['Research Labs','Universities','Government Institutes','Field Work']),
    ('medical-healthcare',        ARRAY['Hospitals','Clinics','Diagnostic Labs','Research Institutes','Shift Work']),
    ('commerce-finance',          ARRAY['Corporate Offices','Banks','Consulting Firms','Hybrid']),
    ('banking-insurance',         ARRAY['Banks','Corporate Offices','Branch Networks','Hybrid']),
    ('management-business',       ARRAY['Corporate Offices','Consulting Firms','Startups','Hybrid']),
    ('arts-humanities',           ARRAY['Universities','NGOs','Media Houses','Government Bodies']),
    ('design-creative',           ARRAY['Design Studios','Agencies','Product Companies','Freelance','Remote']),
    ('media-communication',       ARRAY['Newsrooms','Production Houses','Digital Media Teams','Field Reporting']),
    ('law',                       ARRAY['Law Firms','Corporate Legal Teams','Courts','Chambers']),
    ('education-teaching',        ARRAY['Schools','Colleges','EdTech Companies','Coaching Institutes']),
    ('agriculture',               ARRAY['Farms','Agri-Research Stations','Government Extension Services','Field Work']),
    ('hospitality-tourism',       ARRAY['Hotels','Resorts','Travel Companies','Event Venues','Shift Work']),
    ('sports-fitness',            ARRAY['Training Academies','Fitness Centres','Sports Teams','Rehabilitation Clinics']),
    ('skilled-trades',            ARRAY['Workshops','Manufacturing Plants','Service Centres','Project Sites']),
    ('government-civil-services', ARRAY['Government Offices','Field Postings','Public Sector Units']),
    ('defence',                   ARRAY['Military Establishments','Training Academies','Field Deployments']),
    ('emerging-careers',          ARRAY['Product Companies','Tech Startups','Research Labs','Remote','Hybrid']),
    ('entrepreneurship',          ARRAY['Startups','Co-working Spaces','Remote','Investor Networks'])
) AS m(category_slug, envs)
WHERE c.category_slug = m.category_slug;

UPDATE careers SET work_environments =
    ARRAY['Product Companies','Tech Startups','IT Services','Remote','Hybrid','Collaborative Teams']
WHERE slug IN ('computer-science-and-engineering', 'information-technology');

-- --------------------------------------------------------------------------

DO $$
DECLARE bad int;
BEGIN
    -- Every career keeps its ladder, and every rung is accounted for.
    SELECT count(*) INTO bad FROM career_growth_stages;
    IF bad <> 210 THEN
        RAISE EXCEPTION 'expected 210 growth stages (42 careers x 5), found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM careers c
    WHERE (SELECT count(*) FROM career_growth_stages g WHERE g.career_slug = c.slug)
          <> cardinality(c.growth_path);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) lost a growth-path rung in the conversion', bad;
    END IF;

    -- Titles must survive in the same order, or the ladder is reordered
    -- silently -- a count check alone would not catch that.
    -- title is varchar(160) and growth_path is text[], so array_agg produces
    -- varchar[] and the comparison has no operator without the cast.
    SELECT count(*) INTO bad FROM careers c
    WHERE c.growth_path <> (
        SELECT array_agg(g.title::text ORDER BY g.sort_order)
        FROM career_growth_stages g WHERE g.career_slug = c.slug
    );
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have growth stages out of order or renamed', bad;
    END IF;

    -- Dense 0..n-1, since check_relationship_integrity() picks this table up
    -- automatically and would otherwise fail the NEXT boot, not this one.
    SELECT count(*) INTO bad FROM (
        SELECT career_slug FROM career_growth_stages GROUP BY career_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career growth ladder(s) are not dense 0..n-1', bad;
    END IF;

    -- Every career must now have at least one sector, or the Key Industries
    -- section is empty for it and the category mapping missed a category.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (
        SELECT 1 FROM career_industries ci JOIN industries i ON i.slug = ci.industry_slug
        WHERE ci.career_slug = c.slug AND i.is_sector
    );
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) still have no sector linked', bad;
    END IF;

    -- Exactly the 211 pairs listed above, so a typo'd slug (which ON CONFLICT
    -- would not catch, but the FK would) or a silently skipped row shows up.
    SELECT count(*) INTO bad FROM career_industries ci
    JOIN industries i ON i.slug = ci.industry_slug WHERE i.is_sector;
    IF bad <> 211 THEN
        RAISE EXCEPTION 'expected 211 career/sector links, found %', bad;
    END IF;

    -- The two computing careers must not be left with the plant-and-site
    -- default that their category carries.
    SELECT count(*) INTO bad FROM careers
    WHERE slug IN ('computer-science-and-engineering', 'information-technology')
      AND NOT ('Remote' = ANY(work_environments));
    IF bad > 0 THEN
        RAISE EXCEPTION '% computing career(s) kept the engineering work-environment default', bad;
    END IF;

    -- The employer rows must not have been disturbed: 252 before, 252 after.
    SELECT count(*) INTO bad FROM career_industries ci
    JOIN industries i ON i.slug = ci.industry_slug WHERE NOT i.is_sector;
    IF bad <> 252 THEN
        RAISE EXCEPTION 'employer links changed from 252 to % -- sectors were meant to be additive', bad;
    END IF;

    SELECT count(*) INTO bad FROM careers WHERE cardinality(work_environments) = 0;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have no work environments', bad;
    END IF;

    -- The new nullable columns must genuinely be empty, so nobody mistakes a
    -- default for a researched figure.
    SELECT count(*) INTO bad FROM careers
    WHERE experience_min_years IS NOT NULL OR job_openings IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) unexpectedly carry experience or openings figures', bad;
    END IF;

    SELECT count(*) INTO bad FROM career_salary_bands;
    IF bad > 0 THEN
        RAISE EXCEPTION 'career_salary_bands should ship empty, found % row(s)', bad;
    END IF;
END $$;
