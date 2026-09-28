-- Exam MVP enrichment, per direct request: a handful of static reference
-- fields on exams, plus a reusable Career+Degree relation mirroring
-- college_career_degrees (V55) -- "this exam is the entry gate into
-- Career X via Degree Y" (e.g. jee-main -> computer-science-and-
-- engineering -> b-tech, neet-ug -> medicine -> mbbs, cat -> business-
-- administration -> mba). Reuses the existing Career/Degree tables as-is.
--
-- Deliberately NOT in this pass: category-specific exam details (e.g.
-- UPSC-style multi-stage exams, management sectional cutoffs). That needs
-- either a JSONB column (no admin write path today, and the one pocket of
-- this schema without DB-level type/FK checking) or its own small typed
-- table once a specific category's real content is being entered -- not
-- worth building speculatively against no real data yet.
--
-- All four new exams columns are nullable -- static, well-known facts
-- worth adding per-exam over time, not required to backfill the existing
-- 30-exam catalog in this migration (same "don't guess past what's
-- confidently known" bar as every other content migration here).
--
-- exam_career_degrees is admin-editable from day one (unlike
-- college_career_degrees, which started read-only in V55 and only got an
-- admin path later) -- the SlugTripleId/sync-service/pairs-field-type
-- pattern already exists now, so there's no reason to ship this one
-- read-only first.

ALTER TABLE exams ADD COLUMN mode VARCHAR(32);
ALTER TABLE exams ADD COLUMN eligibility_min_qualification TEXT;
ALTER TABLE exams ADD COLUMN official_website VARCHAR(255);
ALTER TABLE exams ADD COLUMN syllabus_overview TEXT;

CREATE TABLE exam_career_degrees (
    exam_slug   VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    degree_slug VARCHAR(64) NOT NULL REFERENCES degrees (slug) ON DELETE CASCADE,
    sort_order  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (exam_slug, career_slug, degree_slug)
);

-- Seed the well-known, uncontroversial ones directly (same bar as every
-- career_colleges/college_career_degrees seed): JEE Main/Advanced into
-- the engineering disciplines they're already linked to via career_exams,
-- paired with b-tech -- EXCEPT architecture, which JEE Main's own Paper 2
-- (career_exams still lists it under the same exam_slug) admits into via
-- B.Arch, not B.Tech, handled as its own row below instead of being swept
-- into the blanket b-tech pairing. NEET-UG into medicine via mbbs; CAT
-- into business-administration via mba.
INSERT INTO exam_career_degrees (exam_slug, career_slug, degree_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug, 'b-tech',
       ROW_NUMBER() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
FROM career_exams ce
WHERE ce.exam_slug IN ('jee-main', 'jee-advanced')
  AND ce.career_slug <> 'architecture'
ON CONFLICT DO NOTHING;

INSERT INTO exam_career_degrees (exam_slug, career_slug, degree_slug, sort_order) VALUES
    ('jee-main', 'architecture', 'b-arch', 17),
    ('neet-ug', 'medicine', 'mbbs', 0),
    ('cat', 'business-administration', 'mba', 0)
ON CONFLICT DO NOTHING;
