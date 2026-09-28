-- Phase 2 (continued) of the Data Model Roadmap doc: same treatment as
-- V24, but for careers.top_recruiters -- "which careers hire at TCS"
-- becomes a join instead of a text scan. Same deliberate choices as V24:
-- unidirectional, no sort_order/@OrderColumn, minimal slug+name shape,
-- careers.top_recruiters left in place.
--
-- Backfill: 263 total mentions across careers.top_recruiters collapse to
-- 191 distinct industries/recruiters after slugifying and deduping (same
-- clean-split check as V24 -- no two different display names collapse to
-- the same slug).

CREATE TABLE industries (
    slug VARCHAR(64) PRIMARY KEY,
    name VARCHAR(160) NOT NULL
);

CREATE TABLE career_industries (
    career_slug   VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    industry_slug VARCHAR(64) NOT NULL REFERENCES industries (slug) ON DELETE CASCADE,
    PRIMARY KEY (career_slug, industry_slug)
);
CREATE INDEX idx_career_industries_industry ON career_industries (industry_slug);

INSERT INTO industries (slug, name)
SELECT DISTINCT ON (slug) slug, name
FROM (
    SELECT
        trim(both '-' from regexp_replace(lower(trim(r)), '[^a-z0-9]+', '-', 'g')) AS slug,
        trim(r) AS name
    FROM careers, unnest(top_recruiters) AS r
    WHERE trim(r) <> ''
) distinct_industries
ORDER BY slug, name;

INSERT INTO career_industries (career_slug, industry_slug)
SELECT DISTINCT
    c.slug,
    trim(both '-' from regexp_replace(lower(trim(r)), '[^a-z0-9]+', '-', 'g'))
FROM careers c, unnest(c.top_recruiters) AS r
WHERE trim(r) <> '';
