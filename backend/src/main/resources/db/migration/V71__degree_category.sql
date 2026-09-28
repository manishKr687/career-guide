-- Adds an explicit `category_slug` FK to degrees, so the Degrees page can
-- filter by category the same way Careers/Exams already do.
--
-- Why explicit rather than derived: the only real relation from Degree to
-- Category is indirect, through Career.relatedDegreeSlugs (career_degrees,
-- V51) -- and that relation is deliberately sparse (see V51's migration
-- comment: only disciplines with a clean, direct degree match are linked).
-- Checking it live shows only 9 of these 135 degrees are reachable that
-- way, across just 5 of the 20 categories -- nowhere near enough coverage
-- to build a usable filter. So this follows the same explicit-column call
-- already made for Exam.examType (V68) and Degree.level (V70): a plain,
-- always-set-where-classifiable column, not a weak derivation.
--
-- Nullable (unlike level): 3 rows -- certificate, diploma, phd -- are
-- generic (no subject named in the title itself, e.g. "PhD" vs "PhD in
-- Computer Science"), so there is no confident category to assign; every
-- other row gets one. A NULL here simply means "doesn't surface under any
-- category filter, only under All" -- exactly the outcome the frontend
-- filter's option list is built to produce (only categories that actually
-- have >=1 degree get shown as a choice).
--
-- Classification is standard subject-matter grouping (B.Tech -> Engineering
-- & Technology, MBBS -> Medical & Healthcare, ...), cross-checked against
-- this catalog's own Career->Category assignments (e.g. Architecture is
-- design-creative here, matching that career's own category) rather than
-- invented ad hoc.

ALTER TABLE degrees ADD COLUMN category_slug VARCHAR(64) REFERENCES categories(slug);

UPDATE degrees SET category_slug = 'medical-healthcare' WHERE slug IN (
    'anm', 'bams', 'baslp', 'bds', 'bhms', 'bnys', 'boptom', 'bot', 'bpharm', 'bpt', 'bsc-nursing', 'bsms', 'bums', 'dm', 'dpharm', 'gnm', 'maslp', 'mbbs', 'mch', 'md', 'mds', 'moptom', 'mot', 'mpharm', 'mpt', 'ms-surgery', 'msc-nursing', 'pharmd', 'phd-nursing', 'phd-pharmaceutical-sciences', 'post-basic-bsc-nursing'
);

UPDATE degrees SET category_slug = 'engineering-technology' WHERE slug IN (
    'b-eng', 'b-tech', 'b-tech-m-tech', 'm-eng', 'm-tech', 'phd-engineering'
);

UPDATE degrees SET category_slug = 'design-creative' WHERE slug IN (
    'b-arch', 'b-des', 'b-plan', 'bfa', 'm-arch', 'm-des', 'm-plan', 'mfa', 'phd-architecture', 'phd-design', 'phd-fine-arts', 'phd-urban-planning'
);

UPDATE degrees SET category_slug = 'commerce-finance' WHERE slug IN (
    'b-com', 'ba-economics', 'bsc-economics', 'm-com', 'ma-economics', 'msc-economics', 'phd-economics'
);

UPDATE degrees SET category_slug = 'management-business' WHERE slug IN (
    'bba', 'bbm', 'bms', 'mba', 'mms', 'pgdm', 'phd-management'
);

UPDATE degrees SET category_slug = 'it-software' WHERE slug IN (
    'bca', 'bsc-artificial-intelligence', 'bsc-computer-science', 'bsc-cybersecurity', 'bsc-data-science', 'bsc-information-technology', 'mca', 'msc-artificial-intelligence', 'msc-computer-science', 'msc-cybersecurity', 'msc-data-science', 'msc-information-technology', 'phd-computer-science', 'phd-information-technology'
);

UPDATE degrees SET category_slug = 'law' WHERE slug IN (
    'ba-llb', 'bba-llb', 'bcom-llb', 'bsc-llb', 'llb', 'llm', 'phd-law'
);

UPDATE degrees SET category_slug = 'arts-humanities' WHERE slug IN (
    'ba', 'ma', 'phd-arts-humanities'
);

UPDATE degrees SET category_slug = 'education-teaching' WHERE slug IN (
    'b-ed', 'b-el-ed', 'ba-bed', 'bsc-bed', 'd-el-ed', 'm-ed', 'phd-education'
);

UPDATE degrees SET category_slug = 'media-communication' WHERE slug IN (
    'ba-journalism', 'ba-mass-communication', 'bjmc', 'bmm', 'm-journalism', 'm-mass-communication', 'ma-journalism', 'ma-mass-communication', 'phd-mass-communication'
);

UPDATE degrees SET category_slug = 'hospitality-tourism' WHERE slug IN (
    'ba-tourism', 'bhm', 'bhmct', 'bsc-hospitality-management', 'bsc-hotel-management', 'bttm', 'm-hotel-management', 'msc-hospitality-management', 'mttm'
);

UPDATE degrees SET category_slug = 'agriculture' WHERE slug IN (
    'bfsc', 'bsc-agriculture', 'bsc-forestry', 'bsc-horticulture', 'bvsc-ah', 'msc-agriculture', 'msc-forestry', 'msc-horticulture', 'mvsc', 'phd-agricultural-sciences'
);

UPDATE degrees SET category_slug = 'sports-fitness' WHERE slug IN (
    'bped', 'bpes', 'bsc-sports-management', 'bsc-sports-science', 'mped', 'msc-sports-management', 'msc-sports-science', 'phd-sports-science'
);

UPDATE degrees SET category_slug = 'science-research' WHERE slug IN (
    'b-sc', 'msc'
);
