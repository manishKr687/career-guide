-- Completes the JobRole backlog V68 deliberately left as a 2-row canary --
-- the remaining 7 Recruitment-type exams (ibps-so-it, rrb-je, isro-icrb,
-- sebi-grade-a, judicial-services-exam, cds-exam, nda-exam) get real
-- JobRole rows now, same research bar as every other content pass this
-- catalog uses.
--
-- cds-exam and nda-exam share ONE JobRole ("Defence Services Officer")
-- rather than two near-identical rows -- both lead to the same outcome
-- (a commissioned officer role in the Army/Navy/Air Force), just via
-- different entry routes (after 12th vs. after graduation) and academies.
--
-- defence-services-officer gets NO linked Career -- there is no
-- military/defence career in the 42-discipline taxonomy to attach it to,
-- and inventing one is a separate, larger editorial decision (same
-- boundary V56 drew for NIT Patna's AI & Data Science/Mechatronics
-- branches). A JobRole's `careers` Set is optional, not required, so
-- leaving it empty here is a deliberate "don't force it", not an
-- oversight.
--
-- sebi-officer-grade-a links only to `finance` -- SEBI Grade A actually
-- recruits across General, Legal, IT and Research streams, but `finance`
-- is the one clean, uncontroversial match already in the taxonomy;
-- linking `law`/CSE too would overstate how directly this JobRole maps to
-- those disciplines for what's fundamentally a finance-sector regulator.
--
-- Each JobRole's `careers` otherwise mirrors its exam's own already-seeded
-- `relatedCareerSlugs` (rrb-je, isro-icrb) so the two stay consistent.

INSERT INTO job_roles (slug, name, description, experience_level) VALUES
    ('it-officer-banking', 'IT Officer (Bank)', 'A specialist officer role in public sector banks responsible for managing core banking IT infrastructure, cybersecurity, and digital banking systems.', 'Entry to Mid'),
    ('railway-junior-engineer', 'Junior Engineer (Railways)', 'An entry-level engineering role in Indian Railways responsible for maintenance, construction and operations across civil, mechanical, electrical or signalling departments.', 'Entry'),
    ('isro-scientist-engineer', 'Scientist/Engineer (ISRO)', 'An entry-level research and engineering role at ISRO, working on spacecraft, launch vehicle and ground systems design across electronics, computer science, mechanical and electrical disciplines.', 'Entry'),
    ('sebi-officer-grade-a', 'SEBI Officer Grade A', 'An entry-level Assistant Manager role at India''s securities markets regulator, working on market regulation, surveillance and enforcement, with dedicated General, Legal, IT and Research streams.', 'Entry'),
    ('civil-judge', 'Civil Judge', 'An entry-level judicial officer role, presiding over civil and criminal cases at the district court level, recruited directly from law graduates via the state judicial services exam.', 'Entry'),
    ('defence-services-officer', 'Defence Services Officer', 'A commissioned officer role in the Indian Army, Navy or Air Force, entered via the National Defence Academy (after 12th) or Combined Defence Services exam (after graduation), followed by training at the respective service academy.', 'Entry')
ON CONFLICT DO NOTHING;

INSERT INTO career_job_roles (job_role_slug, career_slug) VALUES
    ('it-officer-banking', 'computer-science-and-engineering'),
    ('it-officer-banking', 'information-technology'),
    ('railway-junior-engineer', 'electronics-and-communication-engineering'),
    ('railway-junior-engineer', 'electrical-engineering'),
    ('railway-junior-engineer', 'mechanical-engineering'),
    ('railway-junior-engineer', 'civil-engineering'),
    ('isro-scientist-engineer', 'computer-science-and-engineering'),
    ('isro-scientist-engineer', 'electronics-and-communication-engineering'),
    ('isro-scientist-engineer', 'electrical-engineering'),
    ('isro-scientist-engineer', 'mechanical-engineering'),
    ('sebi-officer-grade-a', 'finance'),
    ('civil-judge', 'law')
ON CONFLICT DO NOTHING;

INSERT INTO exam_job_roles (exam_slug, job_role_slug) VALUES
    ('ibps-so-it', 'it-officer-banking'),
    ('rrb-je', 'railway-junior-engineer'),
    ('isro-icrb', 'isro-scientist-engineer'),
    ('sebi-grade-a', 'sebi-officer-grade-a'),
    ('judicial-services-exam', 'civil-judge'),
    ('cds-exam', 'defence-services-officer'),
    ('nda-exam', 'defence-services-officer')
ON CONFLICT DO NOTHING;
