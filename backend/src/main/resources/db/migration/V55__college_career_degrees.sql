-- Adds a proper three-way (college, career, degree) relation: which degree
-- a college's specific discipline offering is actually awarded through.
--
-- Neither existing table can answer this alone: career_colleges (V13) says
-- a college offers a discipline at all, with no degree attached;
-- college_degrees (V53) says a college awards a degree at all, with no
-- discipline attached. Cross-joining them naively breaks the moment a
-- college has more than one degree (e.g. a future B.Tech + M.Tech + PhD
-- institute) -- there'd be no way to say which of its several degrees a
-- given discipline is actually awarded through. This table records that
-- fact explicitly per (college, career, degree) triple, so the same
-- college can offer the same career through more than one degree, and the
-- same career can be tied to a different degree at a different college.
--
-- Seeded by joining today's career_colleges against today's
-- college_degrees on college_slug: every college in this catalog that has
-- any discipline link also has exactly one degree in college_degrees (see
-- V53's own seed list), so this join is a lossless, unambiguous
-- reconstruction of already-vetted facts, not a guess. sort_order is
-- carried over from career_colleges' own per-college ordering.
--
-- Not yet admin-editable (no CollegeUpsertRequest field, no resourceConfig
-- entry) -- the generic admin form framework has no "list of pairs" field
-- type yet, and building one is out of scope here. Until that lands, new
-- (college, career, degree) triples need a follow-up migration, same as
-- college_specializations' seeding gap noted in V53.

CREATE TABLE college_career_degrees (
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    career_slug  VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    degree_slug  VARCHAR(64) NOT NULL REFERENCES degrees (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (college_slug, career_slug, degree_slug)
);

INSERT INTO college_career_degrees (college_slug, career_slug, degree_slug, sort_order)
SELECT cc.college_slug, cc.career_slug, cd.degree_slug, cc.sort_order
FROM career_colleges cc
JOIN college_degrees cd ON cd.college_slug = cc.college_slug;
