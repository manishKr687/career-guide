-- Adds the integrated 5-year B.Tech + M.Tech dual degree to the Degree
-- catalog -- a real, distinct qualification from a standalone B.Tech or
-- M.Tech (one continuous program, entered after 12th like B.Tech, but
-- graduating with both degrees), which several NITs/IITs offer as an
-- alternative track alongside the standard 4-year B.Tech. Same naming/
-- content convention V52 used for its other integrated dual degrees
-- (ba-llb, bba-llb, b-el-ed, ...): a plain concatenated title, and
-- degree_exams/degree_skills/degree_resources deliberately left
-- unpopulated, same as every other degree V52 added.
--
-- Also links it at NIT Patna, in the disciplines its own admissions
-- pages/JoSAA-sourced aggregators (cross-checked across two independent
-- sources) confirm it runs the 5-year dual-degree track in: Computer
-- Science & Engineering, Electrical Engineering, Civil Engineering,
-- Mechanical Engineering and Electronics & Communication Engineering.
-- The two sources disagree on the exact specialization name within each
-- (e.g. "Data Science" vs. unspecified for CSE), so only the
-- career+degree pairing is recorded here, not a specialization -- same
-- "don't guess past what's confidently known" bar as V56.

INSERT INTO degrees (slug, title, description, icon, preparation_strategy) VALUES
    ('b-tech-m-tech', 'B.Tech M.Tech', 'A 5-year integrated dual degree combining a B.Tech with an M.Tech in the same discipline, entered directly after 12th -- offered by several IITs/NITs as an alternative to the standard 4-year B.Tech, graduating with both a Bachelor''s and Master''s in one continuous program.', 'cap', 'Admission is through the same JEE Main/JEE Advanced route as a standalone B.Tech -- opting for the 5-year dual-degree track happens during JoSAA seat allocation/counselling rather than via a separate entrance exam.')
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order) VALUES
    ('nit-patna', 'b-tech-m-tech', 3)
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order) VALUES
    ('nit-patna', 'computer-science-and-engineering', 'b-tech-m-tech', 7),
    ('nit-patna', 'electrical-engineering', 'b-tech-m-tech', 6),
    ('nit-patna', 'civil-engineering', 'b-tech-m-tech', 6),
    ('nit-patna', 'mechanical-engineering', 'b-tech-m-tech', 6),
    ('nit-patna', 'electronics-and-communication-engineering', 'b-tech-m-tech', 6)
ON CONFLICT DO NOTHING;
