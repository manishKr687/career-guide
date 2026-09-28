-- CareerGuide core schema.
-- Naming follows the frontend's data model 1:1 so the seed data (V2..V9)
-- can be generated straight from the Next.js app's TypeScript data files.

CREATE TABLE categories (
    slug  VARCHAR(64) PRIMARY KEY,
    name  VARCHAR(128) NOT NULL,
    icon  VARCHAR(32) NOT NULL,
    color VARCHAR(128) NOT NULL
);

CREATE TABLE stages (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(128) NOT NULL,
    tagline     VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    badge_soft  VARCHAR(128) NOT NULL,
    badge_solid VARCHAR(128) NOT NULL,
    icon        VARCHAR(32) NOT NULL,
    highlights  TEXT[] NOT NULL DEFAULT '{}',
    sort_order  INT NOT NULL DEFAULT 0
);

CREATE TABLE careers (
    slug          VARCHAR(64) PRIMARY KEY,
    title         VARCHAR(160) NOT NULL,
    category_slug VARCHAR(64) NOT NULL REFERENCES categories (slug),
    tagline       VARCHAR(255) NOT NULL,
    demand        VARCHAR(32) NOT NULL,
    education     TEXT NOT NULL,
    skills        TEXT[] NOT NULL DEFAULT '{}',
    typical_work  TEXT NOT NULL,
    salary_range  VARCHAR(64) NOT NULL,
    growth_path   TEXT[] NOT NULL DEFAULT '{}',
    icon          VARCHAR(32) NOT NULL,
    description   TEXT NOT NULL,
    sort_order    INT NOT NULL DEFAULT 0
);
CREATE INDEX idx_careers_category ON careers (category_slug);

CREATE TABLE courses (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    level       VARCHAR(32) NOT NULL,
    duration    VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    eligibility TEXT NOT NULL,
    icon        VARCHAR(32) NOT NULL
);
CREATE INDEX idx_courses_level ON courses (level);

CREATE TABLE exams (
    slug         VARCHAR(64) PRIMARY KEY,
    name         VARCHAR(160) NOT NULL,
    full_name    VARCHAR(255) NOT NULL,
    category     VARCHAR(64) NOT NULL,
    conducted_by VARCHAR(255) NOT NULL,
    frequency    VARCHAR(128) NOT NULL,
    description  TEXT NOT NULL,
    icon         VARCHAR(32) NOT NULL
);
CREATE INDEX idx_exams_category ON exams (category);

CREATE TABLE colleges (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    location    VARCHAR(200) NOT NULL,
    type        VARCHAR(32) NOT NULL,
    established INT NOT NULL,
    tags        TEXT[] NOT NULL DEFAULT '{}',
    description TEXT NOT NULL
);
CREATE INDEX idx_colleges_type ON colleges (type);

-- Junction tables. Each mirrors one *Slugs[] array from the frontend's data
-- model exactly (they are kept directional/independent, not derived, because
-- the source data itself maintains each side by hand and the two sides are
-- not always symmetric).

CREATE TABLE career_courses (
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, course_slug)
);

CREATE TABLE career_exams (
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, exam_slug)
);

CREATE TABLE career_stages (
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    stage_slug  VARCHAR(64) NOT NULL REFERENCES stages (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, stage_slug)
);

CREATE TABLE course_careers (
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (course_slug, career_slug)
);

CREATE TABLE course_exams (
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (course_slug, exam_slug)
);

CREATE TABLE exam_careers (
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (exam_slug, career_slug)
);

CREATE TABLE exam_courses (
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (exam_slug, course_slug)
);

CREATE TABLE college_courses (
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    course_slug  VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (college_slug, course_slug)
);

CREATE TABLE college_exams (
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    exam_slug    VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (college_slug, exam_slug)
);

CREATE TABLE stage_careers (
    stage_slug  VARCHAR(64) NOT NULL REFERENCES stages (slug) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (stage_slug, career_slug)
);

CREATE TABLE stage_courses (
    stage_slug  VARCHAR(64) NOT NULL REFERENCES stages (slug) ON DELETE CASCADE,
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (stage_slug, course_slug)
);

CREATE TABLE stage_exams (
    stage_slug VARCHAR(64) NOT NULL REFERENCES stages (slug) ON DELETE CASCADE,
    exam_slug  VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    sort_order INT NOT NULL DEFAULT 0,
    PRIMARY KEY (stage_slug, exam_slug)
);

-- Career assessment: questions -> options -> per-category weights.
CREATE TABLE assessment_questions (
    id         VARCHAR(64) PRIMARY KEY,
    question   TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE assessment_options (
    id          BIGSERIAL PRIMARY KEY,
    question_id VARCHAR(64) NOT NULL REFERENCES assessment_questions (id) ON DELETE CASCADE,
    option_key  VARCHAR(8) NOT NULL,
    label       TEXT NOT NULL,
    sort_order  INT NOT NULL DEFAULT 0,
    UNIQUE (question_id, option_key)
);

CREATE TABLE assessment_option_weights (
    option_id     BIGINT NOT NULL REFERENCES assessment_options (id) ON DELETE CASCADE,
    category_slug VARCHAR(64) NOT NULL REFERENCES categories (slug),
    weight        INT NOT NULL,
    PRIMARY KEY (option_id, category_slug)
);
