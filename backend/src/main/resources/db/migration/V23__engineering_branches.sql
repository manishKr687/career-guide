-- Phase 1 of the Data Model Roadmap doc: inserts a "branch" grouping layer
-- between category and career, exactly as scoped in the earlier Taxonomy
-- Blueprint. Purely additive -- careers.category_slug is untouched, so
-- nothing that already reads it (assessment scoring, category counts) has
-- to change.
--
-- Scope: only Engineering & Technology's 12 branches are seeded here, since
-- that's the only category the Taxonomy Blueprint actually designed. Other
-- categories can get their own branches later the same way.
--
-- The Computing & IT branch deliberately does NOT include Software
-- Engineer, Data Scientist, Cybersecurity Analyst or Cloud Architect, even
-- though the original taxonomy sketch listed them there: those 4 careers
-- are in the it-software category (V21), not engineering-technology, and a
-- career's branch should stay inside its own category -- pulling them in
-- here would leave branches.category_slug and careers.category_slug
-- disagreeing for those rows. That cross-category question is still open;
-- this migration only backfills the 13 careers that are actually in
-- engineering-technology today. ai-ml-engineer is also left out for the
-- same reason -- it's in emerging-careers, not engineering-technology.

CREATE TABLE branches (
    slug          VARCHAR(64) PRIMARY KEY,
    name          VARCHAR(160) NOT NULL,
    icon          VARCHAR(32) NOT NULL,
    category_slug VARCHAR(64) NOT NULL REFERENCES categories (slug),
    sort_order    INT NOT NULL DEFAULT 0
);
CREATE INDEX idx_branches_category ON branches (category_slug);

ALTER TABLE careers ADD COLUMN branch_slug VARCHAR(64) REFERENCES branches (slug);
CREATE INDEX idx_careers_branch ON careers (branch_slug);

INSERT INTO branches (slug, name, icon, category_slug, sort_order) VALUES
    ('computing-it', 'Computing & IT', 'chip', 'engineering-technology', 0),
    ('electrical-electronics', 'Electrical & Electronics', 'bolt', 'engineering-technology', 1),
    ('mechanical-manufacturing', 'Mechanical & Manufacturing', 'gear', 'engineering-technology', 2),
    ('civil-infrastructure', 'Civil & Infrastructure', 'building', 'engineering-technology', 3),
    ('chemical-materials', 'Chemical & Materials', 'flask', 'engineering-technology', 4),
    ('aerospace-defence', 'Aerospace & Defence', 'plane', 'engineering-technology', 5),
    ('biotechnology-biomedical', 'Biotechnology & Biomedical', 'heart', 'engineering-technology', 6),
    ('energy-environment', 'Energy & Environment', 'leaf', 'engineering-technology', 7),
    ('agriculture-food', 'Agriculture & Food', 'leaf', 'engineering-technology', 8),
    ('marine-ocean', 'Marine & Ocean', 'ship', 'engineering-technology', 9),
    ('mining-earth-sciences', 'Mining & Earth Sciences', 'pickaxe', 'engineering-technology', 10),
    ('emerging-technologies', 'Emerging Technologies', 'rocket', 'engineering-technology', 11);

-- Backfill: the 13 careers currently in engineering-technology, mapped to
-- the branch each obviously belongs to.
UPDATE careers SET branch_slug = 'mechanical-manufacturing' WHERE slug = 'mechanical-engineer';
UPDATE careers SET branch_slug = 'civil-infrastructure'     WHERE slug = 'civil-engineer';
UPDATE careers SET branch_slug = 'electrical-electronics'   WHERE slug = 'electrical-engineer';
UPDATE careers SET branch_slug = 'electrical-electronics'   WHERE slug = 'electronics-engineer';
UPDATE careers SET branch_slug = 'chemical-materials'       WHERE slug = 'chemical-engineer';
UPDATE careers SET branch_slug = 'aerospace-defence'        WHERE slug = 'aerospace-engineer';
UPDATE careers SET branch_slug = 'biotechnology-biomedical' WHERE slug = 'biomedical-engineer';
UPDATE careers SET branch_slug = 'energy-environment'       WHERE slug = 'environmental-engineer';
UPDATE careers SET branch_slug = 'marine-ocean'             WHERE slug = 'marine-engineer';
UPDATE careers SET branch_slug = 'mining-earth-sciences'    WHERE slug = 'mining-engineer';
UPDATE careers SET branch_slug = 'mechanical-manufacturing' WHERE slug = 'mechatronics-engineer';
UPDATE careers SET branch_slug = 'emerging-technologies'    WHERE slug = 'robotics-engineer';
UPDATE careers SET branch_slug = 'computing-it'             WHERE slug = 'computer-science-engineer';
