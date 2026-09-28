-- Adds the "Job Role" entity from the uploaded Content & Data Architecture
-- and ER & Data Model specs (see the Data Model Roadmap doc's "Spec v1.0
-- Match" / "ER Data Model Match" tabs for the full reasoning).
--
-- Both uploaded documents give the same worked example -- Career: Software
-- Engineering -> Job Roles: Backend/Frontend/Full Stack Developer, DevOps
-- Engineer, Cloud Engineer, Software Architect, Engineering Manager -- and
-- their own `careers` example lists (Software Engineering, Data Science,
-- Cybersecurity, Medicine, Law, ...) are field names, not job titles. That
-- means the live `careers` table (Software Engineer, Data Scientist,
-- Cybersecurity Analyst, ...) already sits at Career grain content-wise, so
-- this migration does NOT rename or reinterpret it. It only adds a new,
-- independent, deliberately thin Job Role entity underneath it -- matching
-- the spec's own job_roles column list (no education/growth/courses/exams
-- of its own; it inherits those from its Career and only adds skills,
-- salary band and seniority).
--
-- career_job_roles is many-to-many, per the ER doc's own model (a Job Role
-- isn't assumed to belong to exactly one Career) -- unlike branch_slug's
-- one-nullable-FK shape in V23.
--
-- Seeded: only the one worked example both documents actually give
-- (Software Engineer -> its 7 job roles), same "don't fabricate content the
-- source docs didn't provide" rule V23/V24/V25 followed for branches and
-- skills. The other 55 careers get no job roles yet.

CREATE TABLE job_roles (
    slug             VARCHAR(64) PRIMARY KEY,
    name             VARCHAR(160) NOT NULL,
    description      TEXT,
    experience_level VARCHAR(32),
    salary_min       VARCHAR(64),
    salary_max       VARCHAR(64)
);

CREATE TABLE career_job_roles (
    career_slug   VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    job_role_slug VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    PRIMARY KEY (career_slug, job_role_slug)
);
CREATE INDEX idx_career_job_roles_job_role ON career_job_roles (job_role_slug);

CREATE TABLE job_role_skills (
    job_role_slug VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    skill_slug    VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    PRIMARY KEY (job_role_slug, skill_slug)
);
CREATE INDEX idx_job_role_skills_skill ON job_role_skills (skill_slug);

CREATE TABLE job_role_industries (
    job_role_slug VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    industry_slug VARCHAR(64) NOT NULL REFERENCES industries (slug) ON DELETE CASCADE,
    PRIMARY KEY (job_role_slug, industry_slug)
);
CREATE INDEX idx_job_role_industries_industry ON job_role_industries (industry_slug);

INSERT INTO job_roles (slug, name, description, experience_level) VALUES
    ('backend-developer',     'Backend Developer',     'Builds and maintains the server-side logic, APIs and databases behind an application.', 'Entry to Senior'),
    ('frontend-developer',    'Frontend Developer',    'Builds the user-facing part of web applications -- layout, interactivity and client-side logic.', 'Entry to Senior'),
    ('full-stack-developer',  'Full Stack Developer',  'Works across both the frontend and backend of an application.', 'Entry to Senior'),
    ('devops-engineer',       'DevOps Engineer',       'Builds and runs the pipelines, infrastructure and automation that ship and operate software.', 'Mid to Senior'),
    ('cloud-engineer',        'Cloud Engineer',        'Designs and manages applications and infrastructure on cloud platforms.', 'Mid to Senior'),
    ('software-architect',    'Software Architect',    'Designs the high-level structure of software systems and guides technical decisions across teams.', 'Senior'),
    ('engineering-manager',   'Engineering Manager',   'Leads a team of engineers -- balancing people management with technical direction.', 'Senior');

INSERT INTO career_job_roles (career_slug, job_role_slug)
SELECT 'software-engineer', slug FROM job_roles;
