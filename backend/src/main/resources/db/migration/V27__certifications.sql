-- Adds the "Certification" entity from the uploaded specs: "Certification
-- should be separate from general courses" (Content & Data Architecture
-- doc, sec.12) and "Professional certifications can be associated with
-- careers and skills" (ER & Data Model doc, sec.15).
--
-- No content is seeded -- unlike Job Role, neither uploaded document gives
-- a single worked example with real certification names tied to real
-- careers/skills in this database, so seeding any would be fabricated data
-- (same rule V24/V25 applied to Skill/Industry descriptions). The table
-- exists and is ready for real content.
--
-- courses.level already has a "Certification" enum value (from V1); that's
-- left untouched here rather than migrated, since nothing currently in
-- `courses` is flagged with that level, so there's nothing to move.

CREATE TABLE certifications (
    slug         VARCHAR(64) PRIMARY KEY,
    name         VARCHAR(200) NOT NULL,
    description  TEXT,
    provider     VARCHAR(160),
    level        VARCHAR(32),
    duration     VARCHAR(64),
    official_url VARCHAR(500)
);

CREATE TABLE certification_careers (
    certification_slug VARCHAR(64) NOT NULL REFERENCES certifications (slug) ON DELETE CASCADE,
    career_slug         VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    PRIMARY KEY (certification_slug, career_slug)
);
CREATE INDEX idx_certification_careers_career ON certification_careers (career_slug);

CREATE TABLE certification_skills (
    certification_slug VARCHAR(64) NOT NULL REFERENCES certifications (slug) ON DELETE CASCADE,
    skill_slug          VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    PRIMARY KEY (certification_slug, skill_slug)
);
CREATE INDEX idx_certification_skills_skill ON certification_skills (skill_slug);
