-- Adds an explicit, always-set `level` column to degrees -- the same
-- "explicit-and-simple over derive-with-override" call already made for
-- Exam.examType (V68): with only 135 rows and low change frequency, a
-- plain always-set column is lower-risk than deriving the level from the
-- title string at read time (this catalog deliberately avoids plain-text
-- title/name guessing elsewhere too -- see V16's migration comment).
--
-- Five buckets, chosen because they're how this catalog's degrees are
-- actually described/searched for in India, not an invented taxonomy:
--   Undergraduate -- includes integrated dual/professional degrees entered
--     after 12th (B.Tech M.Tech dual, BA LLB, BSc BEd, ...) since that's
--     the entry point a visitor filtering by level is asking about; also
--     includes LLB, MBBS and Post Basic B.Sc Nursing, which carry
--     "Bachelor"/UG-equivalent standing despite non-UG-sounding entry
--     routes.
--   Postgraduate -- includes MD/MS/PGDM, which are PG-level despite names
--     that don't start with "M".
--   Diploma, Certificate -- as named.
--   Doctoral -- PhD plus the medical super-specialty degrees (DM, M.Ch)
--     and Pharm.D, which all sit above a first professional/PG degree.
--
-- Backfilling every row now (rather than seeding it only going forward)
-- matches how examType was backfilled for the pre-existing exam catalog in
-- the same V68 migration.

ALTER TABLE degrees ADD COLUMN level VARCHAR(32);

UPDATE degrees SET level = 'Undergraduate';

UPDATE degrees SET level = 'Postgraduate' WHERE slug IN (
    'llm', 'm-arch', 'm-com', 'm-des', 'm-ed', 'm-eng', 'm-hotel-management',
    'm-journalism', 'm-mass-communication', 'm-plan', 'm-tech', 'ma',
    'ma-economics', 'ma-journalism', 'ma-mass-communication', 'maslp', 'mba',
    'mca', 'md', 'mds', 'mfa', 'mms', 'moptom', 'mot', 'mped', 'mpharm', 'mpt',
    'ms-surgery', 'msc', 'msc-agriculture', 'msc-artificial-intelligence',
    'msc-computer-science', 'msc-cybersecurity', 'msc-data-science',
    'msc-economics', 'msc-forestry', 'msc-horticulture',
    'msc-hospitality-management', 'msc-information-technology',
    'msc-nursing', 'msc-sports-management', 'msc-sports-science', 'mttm',
    'mvsc', 'pgdm'
);

UPDATE degrees SET level = 'Doctoral' WHERE slug IN (
    'dm', 'mch', 'pharmd', 'phd', 'phd-agricultural-sciences',
    'phd-architecture', 'phd-arts-humanities', 'phd-computer-science',
    'phd-design', 'phd-economics', 'phd-education', 'phd-engineering',
    'phd-fine-arts', 'phd-information-technology', 'phd-law',
    'phd-management', 'phd-mass-communication', 'phd-nursing',
    'phd-pharmaceutical-sciences', 'phd-sports-science', 'phd-urban-planning'
);

UPDATE degrees SET level = 'Diploma' WHERE slug IN (
    'anm', 'd-el-ed', 'diploma', 'dpharm', 'gnm'
);

UPDATE degrees SET level = 'Certificate' WHERE slug IN ('certificate');

ALTER TABLE degrees ALTER COLUMN level SET NOT NULL;
