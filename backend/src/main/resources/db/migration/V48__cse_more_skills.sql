-- Adds 10 requested skills to Computer Science Engineer's skill list, on
-- top of the 4 it already has (Data Structures & Algorithms, Operating
-- Systems, Computer Networks, Programming Fundamentals -- none of which are
-- removed, since this is additive, not a replacement).
--
-- Checked live against the running skills catalog first: Data Structures &
-- Algorithms / Operating Systems / Computer Networks are already on this
-- career (no-ops below); Database Management / Problem Solving / Git /
-- Communication already exist as skill rows (used elsewhere) but weren't
-- linked to this career yet; Programming / Software Engineering /
-- Object-Oriented Programming don't exist as skill rows at all yet, so
-- those three are created here first. "Programming" is kept distinct from
-- the existing "Programming Fundamentals" -- the request listed both
-- implicitly (Programming is new, Programming Fundamentals was already
-- there), and they're different enough (general vs. the specific
-- fundamentals course topic) to not collapse into one.

INSERT INTO skills (slug, name) VALUES
    ('programming', 'Programming'),
    ('software-engineering', 'Software Engineering'),
    ('object-oriented-programming', 'Object-Oriented Programming')
ON CONFLICT (slug) DO NOTHING;

-- careers.skills is the free-text source array (see V24's migration
-- comment) -- updated to the full union so it stays consistent with
-- career_skills below rather than drifting from it.
UPDATE careers
SET skills = ARRAY[
    'Data Structures & Algorithms', 'Operating Systems', 'Computer Networks', 'Programming Fundamentals',
    'Programming', 'Database Management', 'Software Engineering', 'Object-Oriented Programming',
    'Problem Solving', 'Git', 'Communication'
]
WHERE slug = 'computer-science-engineer';

-- career_skills has no sort_order (unordered relation, see V24) -- plain
-- ON CONFLICT DO NOTHING against its (career_slug, skill_slug) primary key
-- covers the 3 skills already linked (data-structures-algorithms,
-- operating-systems, computer-networks) as no-ops.
INSERT INTO career_skills (career_slug, skill_slug) VALUES
    ('computer-science-engineer', 'programming'),
    ('computer-science-engineer', 'data-structures-algorithms'),
    ('computer-science-engineer', 'database-management'),
    ('computer-science-engineer', 'operating-systems'),
    ('computer-science-engineer', 'computer-networks'),
    ('computer-science-engineer', 'software-engineering'),
    ('computer-science-engineer', 'object-oriented-programming'),
    ('computer-science-engineer', 'problem-solving'),
    ('computer-science-engineer', 'git'),
    ('computer-science-engineer', 'communication')
ON CONFLICT DO NOTHING;
