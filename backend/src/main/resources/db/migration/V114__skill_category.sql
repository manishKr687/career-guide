-- Gives every skill a category, and a place for a description.
--
-- `skill_type` has existed since V34 and is NULL for 384 of 413 rows -- 93%.
-- The 29 that are set use six values at three different granularities
-- ("Technical", "Programming Language", "Cloud", "Tool", "Soft Skill",
-- "Domain Skill"), so it cannot drive a facet: nearly every skill would land
-- in an "Unclassified" bucket, and the ones that did not would be split
-- between "Technical" and "Cloud" for no reason a reader could follow.
--
-- `category` replaces it as the filterable axis. `skill_type` is left alone
-- rather than dropped -- it is what an editor typed, and this is derived.
--
-- CLASSIFIED BY RULE, NOT BY HAND, and the rules are below so they can be
-- argued with. 413 names is too many to assign individually with any care,
-- and unlike a salary figure a misfiled skill is visible and harmless: it
-- appears under the wrong browse heading, not in front of someone making a
-- decision about money.
--
-- The rules were tested against the real names before being committed here,
-- and the first draft was wrong in ways worth recording: an unanchored `cad`
-- matched "ACADemic Writing" and filed it under Tools, and a bare `design`
-- swept Circuit Design and Curriculum Design into Creative. Both are fixed by
-- \m...\M word boundaries and by dropping the categories whose membership
-- could not be decided from a name.
--
-- FIVE BUCKETS, NOT THE SEVEN THE MOCK SHOWS. "Creative" and "Language" were
-- tried and abandoned: deciding from the name alone whether "Experimental
-- Design" is creative or scientific, or whether "Communication Systems" is a
-- communication skill or a telecoms subject, is guesswork. Skills that cannot
-- be placed confidently stay in Domain, which is where two thirds of this
-- catalog honestly belongs -- it is largely field knowledge (Aerodynamics,
-- Clinical Dentistry, Crop Science), not generic competencies.
--
-- NOT SEEDED: `description`, and no demand or difficulty columns at all.
-- 413 descriptions is a content task, and the page reads fine without them.
-- Demand level and learning difficulty would be pure invention -- nothing in
-- this database implies either -- so they are absent rather than empty. What
-- the listing shows instead is REACH: how many job roles and careers use a
-- skill, which the catalog can prove.

ALTER TABLE skills
    ADD COLUMN category varchar(24),
    ADD COLUMN description text;

UPDATE skills SET category = CASE
    -- 1. Soft skills: an explicit list. These are the generic competencies,
    --    and no name pattern separates them from field knowledge reliably.
    WHEN name IN (
        'Adaptability','Empathy','Teamwork','Leadership','Discipline','Attention to Detail',
        'Decision Making','Critical Thinking','Creativity','Customer Service','Crisis Management',
        'Business Acumen','Detail-Oriented','Patience','Integrity','Time Management','Collaboration',
        'Problem Solving','Interpersonal Skills','Work Ethic','Resilience','Observation',
        'Cultural Knowledge','Community Engagement','Mentoring','Conflict Resolution','Networking',
        'Ethics','Professionalism','Curiosity','Perseverance','Stress Management',
        'Emotional Intelligence','Communication','Business Communication','Negotiation',
        'Public Speaking','Presentation Skills','Empathy & Patience','Teaching',
        'Cross-team Leadership','Academic Leadership','Classroom Management'
    ) THEN 'Soft'

    -- 2. Programming. \m..\M anchors "programming" so it does not match inside
    --    a longer word, and the exact-match arm catches bare language names
    --    that carry no other clue.
    WHEN name ~* '\mprogramming\M'
      OR name ~* '^(java|javascript|python|c\+\+|sql|matlab|r)$'
      OR name ~* '(matlab|shell script|^html|^css|object-oriented)'
        THEN 'Programming'

    -- 3. Named tools and platforms. Every token is word-anchored: the
    --    unanchored version of this rule is what filed "Academic Writing"
    --    under Tools.
    WHEN name ~* '\m(autocad|cad|cam|catia|docker|kubernetes|aws|azure|gcp|adobe|tally|sap|erp|git|jenkins|figma|excel|tableau|tensorflow|pytorch|simulink|ansys|revit|solidworks|plc|software|tools|suite)\M'
        THEN 'Tools'

    -- 4. Analytical method.
    WHEN name ~* '\m(analysis|analytics|analytical|statistics|statistical|research|forecasting|calculus|probability|econometrics|modeling|modelling)\M'
        THEN 'Analytical'

    -- 5. Everything else is field knowledge. Not a dumping ground -- it is
    --    what most of this catalog is.
    ELSE 'Domain'
END;

-- Corrections where the rule is defensible in general but wrong for a
-- specific name. Kept short on purpose: a long override list means the rules
-- are wrong and should be rewritten instead of patched.
UPDATE skills SET category = 'Domain'
WHERE name IN ('Circuit Analysis', 'Communication Systems', 'Failure Analysis (FMEA)');

ALTER TABLE skills ALTER COLUMN category SET NOT NULL;

ALTER TABLE skills ADD CONSTRAINT skills_category_known CHECK (
    category IN ('Soft', 'Programming', 'Tools', 'Analytical', 'Domain')
);

CREATE INDEX idx_skills_category ON skills (category);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM skills WHERE category IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% skill(s) went unclassified', bad;
    END IF;

    -- Every bucket must hold something; an empty facet is a dead control.
    SELECT count(*) INTO bad FROM (VALUES
        ('Soft'), ('Programming'), ('Tools'), ('Analytical'), ('Domain')
    ) AS v(cat)
    WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.category = v.cat);
    IF bad > 0 THEN
        RAISE EXCEPTION '% skill categor(y/ies) match no skill', bad;
    END IF;

    -- Domain is the fallback, so it will be the biggest -- but if it swallows
    -- almost everything the rules above have stopped working and the facet is
    -- worthless. 85% is the point at which that is true.
    SELECT count(*) INTO bad FROM skills WHERE category = 'Domain';
    IF bad > (SELECT count(*) * 85 / 100 FROM skills) THEN
        RAISE EXCEPTION 'Domain holds % of % skills -- the classification rules are not matching', bad, (SELECT count(*) FROM skills);
    END IF;

    -- The specific misfile that caught the first draft out. If an unanchored
    -- pattern ever creeps back in, this fails rather than shipping.
    SELECT count(*) INTO bad FROM skills
    WHERE name ILIKE 'academic%' AND category = 'Tools';
    IF bad > 0 THEN
        RAISE EXCEPTION 'an unanchored pattern has filed % "Academic ..." skill(s) under Tools again', bad;
    END IF;
END $$;
