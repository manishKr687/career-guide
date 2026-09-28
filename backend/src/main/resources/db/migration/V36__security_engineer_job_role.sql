-- Adds Security Engineer, the one job role from the uploaded seed doc's Job
-- Roles section confirmed via psql to be genuinely missing from the 7
-- existing job_roles rows (backend-developer, cloud-engineer,
-- devops-engineer, engineering-manager, frontend-developer,
-- full-stack-developer, software-architect).
--
-- Linked to the existing cybersecurity-analyst career (there is no separate
-- "Security" career in the 56-row careers table -- cybersecurity-analyst is
-- the existing, more specific slug for this domain) and to the new
-- cybersecurity skill added in V34.

INSERT INTO job_roles (slug, name, description, experience_level) VALUES
    ('security-engineer', 'Security Engineer',
     'Builds and maintains the systems, tools, and practices that protect an organization''s infrastructure and data from security threats.',
     'Mid to Senior');

INSERT INTO career_job_roles (career_slug, job_role_slug) VALUES
    ('cybersecurity-analyst', 'security-engineer');

INSERT INTO job_role_skills (job_role_slug, skill_slug) VALUES
    ('security-engineer', 'cybersecurity');
