-- Adds exam_type (a second, orthogonal classification alongside the
-- existing `category`): category answers "who is this for / what stage"
-- (After 12th, Banking, Defence, ...); exam_type answers "what do you
-- actually get for passing" -- Admission (a seat in a degree program),
-- Recruitment (hired/commissioned into a post), or Eligibility (qualifies
-- you for something you still separately apply for -- a teaching post, a
-- research fellowship, a professional qualification track, or a
-- scholarship). Plain VARCHAR, no DB-level CHECK constraint, matching how
-- `category` itself is validated (admin-form-only, see resourceConfig.ts)
-- -- deliberately no auto-derivation from category either: at 34 rows,
-- changing rarely, with each addition already individually researched,
-- an always-explicit column is lower-risk than a derive-with-override
-- pattern that could silently drift for a future edge case.
--
-- Every exam is classified below (backfilled in the same migration, not
-- left nullable) using the taxonomy worked out directly with the user:
--   Admission (17): jee-main, jee-advanced, bitsat, clat, cuet,
--     icar-aieea, imu-cet, nchmct-jee, nid-dat, uceed, neet-ug, nata,
--     polytechnic-cet, cat, gate, neet-pg, nimcet
--   Recruitment (9): upsc-cse, ibps-po, ibps-so-it, rrb-je, isro-icrb,
--     sebi-grade-a, judicial-services-exam, cds-exam, nda-exam
--   Eligibility (8): ctet, csir-net, ugc-net, jrf, ca-foundation,
--     cs-foundation, pmp, ntse -- folds in what would otherwise be two
--     near-empty categories (a 3-exam "Professional Certification" and a
--     1-exam "Scholarship") rather than fragmenting the taxonomy for
--     that few rows; all eight share the same real trait ("qualifies you
--     for X, doesn't directly hand you X").
--
-- exam_job_roles is the Recruitment-side counterpart to
-- college_career_degrees / exam_career_degrees (Admission-side) -- "this
-- exam gets you this job", reusing JobRole (added in V26 specifically to
-- be narrower than Career) rather than inventing a new entity. Plain
-- @ManyToMany, no sort_order -- matching JobRole's own existing relations
-- (career_job_roles, job_role_skills, job_role_industries), all
-- unordered Sets, not @OrderColumn lists; a exam realistically has 1-2
-- job-role outcomes, so ordering isn't a meaningful concern here the way
-- it is for Exam.relatedCareers.
--
-- Seeded with exactly 2 real rows (a canary, not the full Recruitment
-- backlog): IAS Officer for upsc-cse, Probationary Officer for ibps-po --
-- the other 7 Recruitment exams (ibps-so-it, rrb-je, isro-icrb,
-- sebi-grade-a, judicial-services-exam, cds-exam, nda-exam) stay
-- unlinked until their JobRole rows get the same real research pass,
-- same partial-population precedent as college_career_degrees/
-- exam_career_degrees before their own backfills.

ALTER TABLE exams ADD COLUMN exam_type VARCHAR(32);

UPDATE exams SET exam_type = 'Admission' WHERE slug IN (
    'jee-main', 'jee-advanced', 'bitsat', 'clat', 'cuet', 'icar-aieea', 'imu-cet',
    'nchmct-jee', 'nid-dat', 'uceed', 'neet-ug', 'nata', 'polytechnic-cet',
    'cat', 'gate', 'neet-pg', 'nimcet'
);

UPDATE exams SET exam_type = 'Recruitment' WHERE slug IN (
    'upsc-cse', 'ibps-po', 'ibps-so-it', 'rrb-je', 'isro-icrb', 'sebi-grade-a',
    'judicial-services-exam', 'cds-exam', 'nda-exam'
);

UPDATE exams SET exam_type = 'Eligibility' WHERE slug IN (
    'ctet', 'csir-net', 'ugc-net', 'jrf', 'ca-foundation', 'cs-foundation', 'pmp', 'ntse'
);

ALTER TABLE exams ALTER COLUMN exam_type SET NOT NULL;

CREATE TABLE exam_job_roles (
    exam_slug     VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    job_role_slug VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    PRIMARY KEY (exam_slug, job_role_slug)
);

INSERT INTO job_roles (slug, name, description, experience_level) VALUES
    ('ias-officer', 'IAS Officer', 'A senior administrative officer of the Indian Administrative Service, responsible for policy implementation, district administration and governance at the state and central government level.', 'Entry to Senior'),
    ('probationary-officer', 'Probationary Officer', 'An entry-level managerial role in public sector banks, responsible for branch operations, credit appraisal and customer service, with a defined promotion path into bank management.', 'Entry')
ON CONFLICT DO NOTHING;

INSERT INTO career_job_roles (job_role_slug, career_slug) VALUES
    ('ias-officer', 'public-administration'),
    ('probationary-officer', 'finance')
ON CONFLICT DO NOTHING;

INSERT INTO exam_job_roles (exam_slug, job_role_slug) VALUES
    ('upsc-cse', 'ias-officer'),
    ('ibps-po', 'probationary-officer')
ON CONFLICT DO NOTHING;
