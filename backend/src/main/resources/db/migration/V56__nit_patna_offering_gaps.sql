-- Fills in NIT Patna gaps found while auditing its seeded offerings against
-- its real, current program list (NIT Patna's own admissions pages plus
-- JoSAA/CCMT-sourced aggregators, cross-checked across multiple sources).
--
-- Four disciplines NIT Patna clearly runs a B.Tech program in were entirely
-- missing from career_colleges (added in V53, but only for 4 of its actual
-- ~9 engineering branches): Electronics & Communication Engineering,
-- Chemical Engineering, Materials Engineering (matches its "Applied Physics
-- and Materials Engineering" department) and, separately, Architecture
-- (B.Arch, under its "Architecture and Planning" department) -- the career,
-- college and degree rows for all four already existed independently, they
-- were just never linked to each other.
--
-- NIT Patna also runs an M.Tech in Computer Science & Engineering alongside
-- its B.Tech -- the same discipline, a second degree -- which V55 could
-- only derive one-degree-per-college for, since college_degrees had never
-- recorded more than b-tech for this college. This is also the first real
-- (non-synthetic) case of the "same career, multiple degrees at the same
-- institution" scenario the college_career_degrees table exists for.
--
-- Left out, same "don't guess past what's confidently known" bar as V53/
-- V54/V51: Artificial Intelligence & Data Science and Mechatronics &
-- Automation Engineering (both real NIT Patna B.Tech branches per the
-- sources above) have no matching row in the 42-discipline career
-- taxonomy at all -- adding them would mean inventing new careers, not
-- linking existing ones, which is a separate, larger editorial decision.
-- Likewise the integrated 5-year M.Sc (Physics/Chemistry/Math) and MCA
-- programs: the careers and a plain "msc"/"mca" degree both exist, but
-- there's no "integrated" degree variant in the catalog, and forcing the
-- plain postgraduate msc/mca slug onto what's actually a 5-year integrated
-- program would misrepresent it.

INSERT INTO career_colleges (career_slug, college_slug, sort_order) VALUES
    ('electronics-and-communication-engineering', 'nit-patna', 0),
    ('chemical-engineering', 'nit-patna', 0),
    ('metallurgical-and-materials-engineering', 'nit-patna', 0),
    ('architecture', 'nit-patna', 0)
ON CONFLICT DO NOTHING;

INSERT INTO college_degrees (college_slug, degree_slug, sort_order) VALUES
    ('nit-patna', 'b-arch', 1),
    ('nit-patna', 'm-tech', 2)
ON CONFLICT DO NOTHING;

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order) VALUES
    ('nit-patna', 'electronics-and-communication-engineering', 'b-tech', 5),
    ('nit-patna', 'chemical-engineering', 'b-tech', 5),
    ('nit-patna', 'metallurgical-and-materials-engineering', 'b-tech', 5),
    ('nit-patna', 'architecture', 'b-arch', 5),
    ('nit-patna', 'computer-science-and-engineering', 'm-tech', 6)
ON CONFLICT DO NOTHING;
