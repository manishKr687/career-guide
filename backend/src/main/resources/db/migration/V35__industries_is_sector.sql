-- Adds is_sector, distinguishing broad industry-sector taxonomy rows from
-- the 191 existing "known employer/company name" rows already in
-- industries. The existing Industry.java entity already self-documents this
-- exact gap ("'industry' here doubles as 'known employer' -- there was no
-- independent industry taxonomy in the source data").
--
-- Confirmed via psql that none of these 10 sector slugs exist among the 191
-- existing industries rows (which are all company names such as accenture,
-- amazon, bosch, canara-bank, etc). These 10 rows come from the uploaded
-- "CareerGuide -- Sample Master Data & Seed SQL" doc's Industry Sectors
-- section.

ALTER TABLE industries ADD COLUMN is_sector BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO industries (slug, name, is_sector) VALUES
    ('information-technology', 'Information Technology', TRUE),
    ('saas',                   'SaaS',                   TRUE),
    ('fintech',                'Fintech',                TRUE),
    ('e-commerce',             'E-Commerce',              TRUE),
    ('banking',                'Banking',                TRUE),
    ('healthcare',             'Healthcare',              TRUE),
    ('automotive',             'Automotive',              TRUE),
    ('telecommunications',     'Telecommunications',      TRUE),
    ('education',              'Education',               TRUE),
    ('government',             'Government',              TRUE);
