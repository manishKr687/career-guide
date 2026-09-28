-- Adds JobRole <-> Certification, the certification-side counterpart to
-- the exam-side career_degree_offerings/exam_job_roles work: some job
-- roles are entered via a certification (not an exam), some via an exam,
-- some via both, some via neither -- so this is its own optional relation,
-- not a replacement for exam_job_roles (V68), which stays untouched (it
-- already has real seeded links, e.g. defence-services-officer -> cds-exam/
-- nda-exam).
--
-- Owned entirely by JobRole, no inverse column on Certification -- same
-- unidirectional shape JobRole.relatedSkills/relatedIndustries already use
-- (V26), not the bidirectional Exam.relatedJobRoles/JobRole.relatedExams
-- shape (V68), since only JobRole's own admin form needs to edit this side.
--
-- No rows seeded here: the certifications table itself has no real content
-- yet (V27's own comment -- neither uploaded spec gave real certification
-- data), so there is nothing genuine to link to.

CREATE TABLE job_role_certifications (
    job_role_slug     VARCHAR(64) NOT NULL REFERENCES job_roles (slug) ON DELETE CASCADE,
    certification_slug VARCHAR(64) NOT NULL REFERENCES certifications (slug) ON DELETE CASCADE,
    PRIMARY KEY (job_role_slug, certification_slug)
);
CREATE INDEX idx_job_role_certifications_certification ON job_role_certifications (certification_slug);
