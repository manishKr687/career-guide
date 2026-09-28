-- Phase 2 of the Data Model Roadmap doc: Skill becomes a real entity
-- instead of a plain text[] on careers, so "which careers need Python" is
-- a join instead of a text scan.
--
-- Deliberately unidirectional and with no sort_order/@OrderColumn, unlike
-- career_courses/career_exams/etc: a skill's position in a career's list
-- was never curated data (it's just array order from the original seed),
-- so there's nothing worth preserving an order for, and skipping
-- @OrderColumn avoids the dense-index bookkeeping that's been the real
-- maintenance cost on every other junction table in this project (see the
-- Scaling Read & Write Paths review). careers.skills itself is left in
-- place rather than dropped -- nothing reads career_skills yet, and this
-- keeps the migration purely additive.
--
-- Also deliberately minimal: Skill only has slug + name, not the
-- description/icon shape specializations use. The source data (a plain
-- skill name per array entry, e.g. "CAD/CAM") has no description to
-- backfill, and inventing one per skill would be fabricated content, not
-- real data.
--
-- Backfill: 56 careers' skills arrays contain 221 total mentions collapsing
-- to 197 distinct skills after slugifying and deduping (checked first --
-- no two different display names collapse to the same slug, so this is a
-- clean split, not a lossy merge).

CREATE TABLE skills (
    slug VARCHAR(64) PRIMARY KEY,
    name VARCHAR(160) NOT NULL
);

CREATE TABLE career_skills (
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    skill_slug  VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    PRIMARY KEY (career_slug, skill_slug)
);
CREATE INDEX idx_career_skills_skill ON career_skills (skill_slug);

INSERT INTO skills (slug, name)
SELECT DISTINCT ON (slug) slug, name
FROM (
    SELECT
        trim(both '-' from regexp_replace(lower(trim(s)), '[^a-z0-9]+', '-', 'g')) AS slug,
        trim(s) AS name
    FROM careers, unnest(skills) AS s
    WHERE trim(s) <> ''
) distinct_skills
ORDER BY slug, name;

INSERT INTO career_skills (career_slug, skill_slug)
SELECT DISTINCT
    c.slug,
    trim(both '-' from regexp_replace(lower(trim(s)), '[^a-z0-9]+', '-', 'g'))
FROM careers c, unnest(c.skills) AS s
WHERE trim(s) <> '';
