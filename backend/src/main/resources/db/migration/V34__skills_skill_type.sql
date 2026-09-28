-- Adds skill_type, a genuinely missing classification identified by matching
-- the uploaded "CareerGuide -- PostgreSQL Database Schema" doc (section on
-- skills.skill_type) and "CareerGuide -- Sample Master Data & Seed SQL"
-- (section 4, Skills), against the live 197-row skills table.
--
-- Confirmed via psql that 8 of the seed doc's skills (java, javascript,
-- react, spring-boot, aws, docker, kafka, cybersecurity) do not exist in the
-- 197 existing rows -- these are inserted as genuinely new skills. The other
-- 8 skills named in the seed doc (python, sql, git, data-analysis,
-- machine-learning, communication, leadership, problem-solving) already
-- exist, so for those we only backfill skill_type on the existing row --
-- their slug/name are untouched. All other 189 pre-existing skills are left
-- with skill_type = NULL rather than guessing a classification the source
-- documents never gave us for them.

ALTER TABLE skills ADD COLUMN skill_type VARCHAR(50);

INSERT INTO skills (slug, name, skill_type) VALUES
    ('java',          'Java',           'Programming Language'),
    ('javascript',    'JavaScript',     'Programming Language'),
    ('react',         'React',          'Technical'),
    ('spring-boot',   'Spring Boot',    'Technical'),
    ('aws',           'AWS',            'Cloud'),
    ('docker',        'Docker',         'Tool'),
    ('kafka',         'Kafka',          'Technical'),
    ('cybersecurity', 'Cybersecurity',  'Domain Skill');

UPDATE skills SET skill_type = 'Programming Language' WHERE slug = 'python';
UPDATE skills SET skill_type = 'Technical'             WHERE slug = 'sql';
UPDATE skills SET skill_type = 'Tool'                  WHERE slug = 'git';
UPDATE skills SET skill_type = 'Technical'             WHERE slug = 'data-analysis';
UPDATE skills SET skill_type = 'Technical'             WHERE slug = 'machine-learning';
UPDATE skills SET skill_type = 'Soft Skill'            WHERE slug = 'communication';
UPDATE skills SET skill_type = 'Soft Skill'            WHERE slug = 'leadership';
UPDATE skills SET skill_type = 'Soft Skill'            WHERE slug = 'problem-solving';
