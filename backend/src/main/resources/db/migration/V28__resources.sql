-- Adds the "Resource" entity from the uploaded specs (educational content --
-- articles, guides, videos, prep material) with its relationship tables,
-- per both documents' sec.13/16 and sec.28 ("Resources should not be
-- tightly coupled to one entity -- use relationship tables").
--
-- No content is seeded, same reasoning as certifications: no real resource
-- content was provided to backfill.

CREATE TABLE resources (
    slug          VARCHAR(64) PRIMARY KEY,
    title         VARCHAR(300) NOT NULL,
    resource_type VARCHAR(32) NOT NULL,
    description   TEXT,
    content_url   VARCHAR(500),
    author        VARCHAR(160),
    published_at  DATE
);

CREATE TABLE resource_careers (
    resource_slug VARCHAR(64) NOT NULL REFERENCES resources (slug) ON DELETE CASCADE,
    career_slug   VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    PRIMARY KEY (resource_slug, career_slug)
);
CREATE INDEX idx_resource_careers_career ON resource_careers (career_slug);

CREATE TABLE resource_courses (
    resource_slug VARCHAR(64) NOT NULL REFERENCES resources (slug) ON DELETE CASCADE,
    course_slug   VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    PRIMARY KEY (resource_slug, course_slug)
);
CREATE INDEX idx_resource_courses_course ON resource_courses (course_slug);

CREATE TABLE resource_exams (
    resource_slug VARCHAR(64) NOT NULL REFERENCES resources (slug) ON DELETE CASCADE,
    exam_slug     VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    PRIMARY KEY (resource_slug, exam_slug)
);
CREATE INDEX idx_resource_exams_exam ON resource_exams (exam_slug);

CREATE TABLE resource_skills (
    resource_slug VARCHAR(64) NOT NULL REFERENCES resources (slug) ON DELETE CASCADE,
    skill_slug    VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    PRIMARY KEY (resource_slug, skill_slug)
);
CREATE INDEX idx_resource_skills_skill ON resource_skills (skill_slug);
