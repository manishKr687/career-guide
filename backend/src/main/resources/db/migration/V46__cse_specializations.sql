-- Adds 4 CSE specializations under the existing "Computer Science Engineer"
-- career (added in V20), per the uploaded "CareerGuide -- Simple CSE
-- Specialization Model" spec: Software Developer, Cloud Engineer, DevOps
-- Engineer, ML/AI Engineer. Runs after V45, which cleared out every
-- existing specialization (including the 3 old CSE ones from V22), so
-- career_specializations/specialization_* start completely fresh here --
-- no sort_order gap risk against anything V45 wiped.
--
-- Three of these four (Software Developer, Cloud Engineer, ML/AI Engineer)
-- overlap in name/content with existing standalone careers (Software
-- Engineer, Cloud Architect, AI/ML Engineer respectively) -- added anyway
-- per direct request, matching the spec exactly rather than the V19/V20/V22
-- precedent of keeping specializations non-overlapping with sibling
-- careers.
--
-- Schema: adds a `demand` column (plain HIGH/MEDIUM/LOW string, matching
-- the spec's "keep demand extremely simple" instruction) plus two new
-- relations Specialization didn't have before -- certifications (reusing
-- the existing, previously-empty `certifications` table) and "recruiters"
-- (reusing the existing `industries` table, the same entity Career already
-- uses for its own "Top Recruiters"). Both are owned entirely by
-- Specialization, same shape as specialization_job_roles/specialization_
-- hard_skills.
--
-- Skills go entirely under Hard Skills (the spec has one flat skill list,
-- no hard/soft split) and salary goes entirely under salary_entry_level
-- (the spec has one flat range, not an entry/mid/senior breakdown) --
-- salary_mid_level/salary_senior_level stay NULL for all 4.
--
-- The backend was mid-restart while this was written, so unlike V40 (which
-- verified live which skills/job roles were genuinely new before inserting
-- plain, non-defensive statements), the skill/job-role/industry inserts
-- below use ON CONFLICT DO NOTHING throughout as a defensive substitute for
-- that live check -- safe whether or not a given slug already exists.
-- specializations/specialization_* rows are this migration's own new
-- slugs and certifications is confirmed still empty (V27 seeded no rows),
-- so those use plain INSERT.

ALTER TABLE specializations ADD COLUMN demand VARCHAR(16);

CREATE TABLE specialization_certifications (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    certification_slug   VARCHAR(64) NOT NULL REFERENCES certifications (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, certification_slug)
);

CREATE TABLE specialization_industries (
    specialization_slug VARCHAR(64) NOT NULL REFERENCES specializations (slug) ON DELETE CASCADE,
    industry_slug         VARCHAR(64) NOT NULL REFERENCES industries (slug) ON DELETE CASCADE,
    sort_order            INT NOT NULL DEFAULT 0,
    PRIMARY KEY (specialization_slug, industry_slug)
);

-- ---------------------------------------------------------------------
-- Skills (all under Hard Skills). Slugs follow the same slugify convention
-- V24/V25 use (lowercase, non-alnum runs -> '-', trimmed).
-- ---------------------------------------------------------------------

INSERT INTO skills (slug, name) VALUES
    ('java', 'Java'),
    ('python', 'Python'),
    ('javascript', 'JavaScript'),
    ('sql', 'SQL'),
    ('data-structures', 'Data Structures'),
    ('spring-boot', 'Spring Boot'),
    ('react', 'React'),
    ('git', 'Git'),
    ('docker', 'Docker'),
    ('aws', 'AWS'),
    ('azure', 'Azure'),
    ('linux', 'Linux'),
    ('networking', 'Networking'),
    ('kubernetes', 'Kubernetes'),
    ('terraform', 'Terraform'),
    ('jenkins', 'Jenkins'),
    ('ci-cd', 'CI/CD'),
    ('machine-learning', 'Machine Learning'),
    ('deep-learning', 'Deep Learning'),
    ('statistics', 'Statistics'),
    ('tensorflow', 'TensorFlow'),
    ('pytorch', 'PyTorch'),
    ('generative-ai', 'Generative AI')
ON CONFLICT (slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- Job roles. backend-developer/frontend-developer/full-stack-developer/
-- cloud-engineer/devops-engineer already exist (V26) -- only the remaining
-- 11 are inserted here.
-- ---------------------------------------------------------------------

INSERT INTO job_roles (slug, name, description) VALUES
    ('software-engineer', 'Software Engineer', 'Writes, tests and ships the code that builds an application''s core functionality.'),
    ('mobile-developer', 'Mobile Developer', 'Builds native or cross-platform apps for iOS and Android.'),
    ('cloud-architect', 'Cloud Architect', 'Designs the overall cloud infrastructure strategy an organization''s systems run on.'),
    ('cloud-infrastructure-engineer', 'Cloud Infrastructure Engineer', 'Provisions and maintains the cloud infrastructure that applications run on.'),
    ('platform-engineer', 'Platform Engineer', 'Builds and maintains the internal platforms and tooling that let other engineering teams ship faster.'),
    ('site-reliability-engineer', 'Site Reliability Engineer', 'Keeps production systems reliable, observable and able to scale under load.'),
    ('machine-learning-engineer', 'Machine Learning Engineer', 'Builds and deploys machine learning models into production systems.'),
    ('ai-engineer', 'AI Engineer', 'Builds AI-powered applications and systems, often on top of existing models and platforms.'),
    ('ml-engineer', 'ML Engineer', 'Designs, trains and tunes machine learning models to solve a specific problem.'),
    ('nlp-engineer', 'NLP Engineer', 'Builds systems that understand and generate human language, from search to chatbots.'),
    ('computer-vision-engineer', 'Computer Vision Engineer', 'Builds systems that interpret and act on visual data from images and video.')
ON CONFLICT (slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- Certifications (table was completely empty before this -- see V27).
-- ---------------------------------------------------------------------

INSERT INTO certifications (slug, name, provider) VALUES
    ('aws-certified-developer', 'AWS Certified Developer', 'Amazon Web Services (AWS)'),
    ('oracle-java-certification', 'Oracle Java Certification', 'Oracle'),
    ('aws-solutions-architect', 'AWS Solutions Architect', 'Amazon Web Services (AWS)'),
    ('azure-administrator', 'Azure Administrator', 'Microsoft'),
    ('google-cloud-certifications', 'Google Cloud Certifications', 'Google Cloud'),
    ('cka', 'CKA', 'Cloud Native Computing Foundation (CNCF)'),
    ('ckad', 'CKAD', 'Cloud Native Computing Foundation (CNCF)'),
    ('aws-certifications', 'AWS Certifications', 'Amazon Web Services (AWS)'),
    ('terraform-certification', 'Terraform Certification', 'HashiCorp'),
    ('aws-machine-learning', 'AWS Machine Learning', 'Amazon Web Services (AWS)'),
    ('google-cloud-ml', 'Google Cloud ML', 'Google Cloud'),
    ('azure-ai-certifications', 'Azure AI Certifications', 'Microsoft')
ON CONFLICT (slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- Industries / recruiters -- reusing the existing entity, same slugify
-- convention as V25.
-- ---------------------------------------------------------------------

INSERT INTO industries (slug, name) VALUES
    ('google', 'Google'),
    ('microsoft', 'Microsoft'),
    ('amazon', 'Amazon'),
    ('tcs', 'TCS'),
    ('infosys', 'Infosys'),
    ('accenture', 'Accenture'),
    ('ibm', 'IBM'),
    ('deloitte', 'Deloitte'),
    ('nvidia', 'NVIDIA')
ON CONFLICT (slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- The 4 specializations themselves.
-- ---------------------------------------------------------------------

INSERT INTO specializations (slug, name, description, icon, salary_entry_level, demand) VALUES
    ('software-developer', 'Software Developer', 'Builds, maintains and improves software applications using programming languages, frameworks and development tools.', 'code', '₹4 LPA – ₹30+ LPA', 'HIGH'),
    ('cloud-engineer', 'Cloud Engineer', 'Designs, deploys and manages applications and infrastructure on cloud platforms.', 'layers', '₹5 LPA – ₹35+ LPA', 'HIGH'),
    ('devops-engineer', 'DevOps Engineer', 'Automates software delivery, infrastructure and operational processes to improve deployment speed and reliability.', 'gear', '₹5 LPA – ₹35+ LPA', 'HIGH'),
    ('ml-ai-engineer', 'ML/AI Engineer', 'Builds machine learning and artificial intelligence systems using data, algorithms and computational models.', 'bulb', '₹6 LPA – ₹40+ LPA', 'HIGH');

INSERT INTO career_specializations (career_slug, specialization_slug, sort_order) VALUES
    ('computer-science-engineer', 'software-developer', 0),
    ('computer-science-engineer', 'cloud-engineer', 1),
    ('computer-science-engineer', 'devops-engineer', 2),
    ('computer-science-engineer', 'ml-ai-engineer', 3);

-- Job roles per specialization.

INSERT INTO specialization_job_roles (specialization_slug, job_role_slug, sort_order) VALUES
    ('software-developer', 'software-engineer', 0),
    ('software-developer', 'backend-developer', 1),
    ('software-developer', 'frontend-developer', 2),
    ('software-developer', 'full-stack-developer', 3),
    ('software-developer', 'mobile-developer', 4);

INSERT INTO specialization_job_roles (specialization_slug, job_role_slug, sort_order) VALUES
    ('cloud-engineer', 'cloud-engineer', 0),
    ('cloud-engineer', 'cloud-architect', 1),
    ('cloud-engineer', 'cloud-infrastructure-engineer', 2);

INSERT INTO specialization_job_roles (specialization_slug, job_role_slug, sort_order) VALUES
    ('devops-engineer', 'devops-engineer', 0),
    ('devops-engineer', 'platform-engineer', 1),
    ('devops-engineer', 'site-reliability-engineer', 2);

INSERT INTO specialization_job_roles (specialization_slug, job_role_slug, sort_order) VALUES
    ('ml-ai-engineer', 'machine-learning-engineer', 0),
    ('ml-ai-engineer', 'ai-engineer', 1),
    ('ml-ai-engineer', 'ml-engineer', 2),
    ('ml-ai-engineer', 'nlp-engineer', 3),
    ('ml-ai-engineer', 'computer-vision-engineer', 4);

-- Hard skills per specialization.

INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('software-developer', 'java', 0),
    ('software-developer', 'python', 1),
    ('software-developer', 'javascript', 2),
    ('software-developer', 'sql', 3),
    ('software-developer', 'data-structures', 4),
    ('software-developer', 'spring-boot', 5),
    ('software-developer', 'react', 6),
    ('software-developer', 'git', 7),
    ('software-developer', 'docker', 8);

INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('cloud-engineer', 'aws', 0),
    ('cloud-engineer', 'azure', 1),
    ('cloud-engineer', 'linux', 2),
    ('cloud-engineer', 'networking', 3),
    ('cloud-engineer', 'docker', 4),
    ('cloud-engineer', 'kubernetes', 5),
    ('cloud-engineer', 'terraform', 6);

INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('devops-engineer', 'linux', 0),
    ('devops-engineer', 'git', 1),
    ('devops-engineer', 'docker', 2),
    ('devops-engineer', 'kubernetes', 3),
    ('devops-engineer', 'jenkins', 4),
    ('devops-engineer', 'ci-cd', 5),
    ('devops-engineer', 'terraform', 6),
    ('devops-engineer', 'aws', 7);

INSERT INTO specialization_hard_skills (specialization_slug, skill_slug, sort_order) VALUES
    ('ml-ai-engineer', 'python', 0),
    ('ml-ai-engineer', 'machine-learning', 1),
    ('ml-ai-engineer', 'deep-learning', 2),
    ('ml-ai-engineer', 'sql', 3),
    ('ml-ai-engineer', 'statistics', 4),
    ('ml-ai-engineer', 'tensorflow', 5),
    ('ml-ai-engineer', 'pytorch', 6),
    ('ml-ai-engineer', 'generative-ai', 7);

-- Certifications per specialization.

INSERT INTO specialization_certifications (specialization_slug, certification_slug, sort_order) VALUES
    ('software-developer', 'aws-certified-developer', 0),
    ('software-developer', 'oracle-java-certification', 1);

INSERT INTO specialization_certifications (specialization_slug, certification_slug, sort_order) VALUES
    ('cloud-engineer', 'aws-solutions-architect', 0),
    ('cloud-engineer', 'azure-administrator', 1),
    ('cloud-engineer', 'google-cloud-certifications', 2);

INSERT INTO specialization_certifications (specialization_slug, certification_slug, sort_order) VALUES
    ('devops-engineer', 'cka', 0),
    ('devops-engineer', 'ckad', 1),
    ('devops-engineer', 'aws-certifications', 2),
    ('devops-engineer', 'terraform-certification', 3);

INSERT INTO specialization_certifications (specialization_slug, certification_slug, sort_order) VALUES
    ('ml-ai-engineer', 'aws-machine-learning', 0),
    ('ml-ai-engineer', 'google-cloud-ml', 1),
    ('ml-ai-engineer', 'azure-ai-certifications', 2);

-- Recruiters (industries) per specialization.

INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order) VALUES
    ('software-developer', 'google', 0),
    ('software-developer', 'microsoft', 1),
    ('software-developer', 'amazon', 2),
    ('software-developer', 'tcs', 3),
    ('software-developer', 'infosys', 4),
    ('software-developer', 'accenture', 5);

INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order) VALUES
    ('cloud-engineer', 'amazon', 0),
    ('cloud-engineer', 'microsoft', 1),
    ('cloud-engineer', 'google', 2),
    ('cloud-engineer', 'ibm', 3),
    ('cloud-engineer', 'accenture', 4),
    ('cloud-engineer', 'deloitte', 5);

INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order) VALUES
    ('devops-engineer', 'amazon', 0),
    ('devops-engineer', 'microsoft', 1),
    ('devops-engineer', 'google', 2),
    ('devops-engineer', 'ibm', 3),
    ('devops-engineer', 'accenture', 4);

INSERT INTO specialization_industries (specialization_slug, industry_slug, sort_order) VALUES
    ('ml-ai-engineer', 'google', 0),
    ('ml-ai-engineer', 'microsoft', 1),
    ('ml-ai-engineer', 'amazon', 2),
    ('ml-ai-engineer', 'nvidia', 3),
    ('ml-ai-engineer', 'tcs', 4),
    ('ml-ai-engineer', 'infosys', 5);
