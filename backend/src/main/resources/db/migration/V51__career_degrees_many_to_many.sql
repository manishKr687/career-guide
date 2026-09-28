-- Replaces careers.degree_slug (a single nullable *-to-one FK, added in
-- V47) with a real many-to-many relation, same shape as
-- career_specializations/career_job_roles: career_degrees(career_slug,
-- degree_slug, sort_order).
--
-- Why: V47 deliberately used a *-to-one column because "each Career
-- realistically has at most one primary degree path" -- but its own
-- migration comment already listed a long list of careers left NULL
-- specifically *because* they had multiple equally-valid degree paths
-- (data-scientist: B.Tech/B.Sc/MCA; data-analyst: B.Com/BBA/B.Tech; etc.).
-- That was already a sign the *-to-one model was the wrong shape. It
-- matters even more now: V49/V50 replaced the old ~58 narrow careers with
-- 42 broader taxonomy disciplines (Computer Science & Engineering,
-- Finance, Biotechnology, ...), and a discipline this broad routinely has
-- several genuinely valid entry degrees, not one. (Practically, this also
-- makes V47's old backfill moot -- it targeted career slugs V49's TRUNCATE
-- has since deleted, so every current career.degree_slug is NULL anyway;
-- nothing of value is lost by dropping the column.)
--
-- Backfill below maps each of the 42 disciplines to zero or more of the
-- catalog's 10 degree types (b-tech, diploma, b-ed, mba, mca, b-sc, b-com,
-- bba, phd, certificate -- see V44), using the same conservative principle
-- V47 established: only link a degree that's a clean, direct, well-known
-- entry path for that discipline as commonly understood in India -- never
-- a guess. sort_order reflects how commonly each path is taken, most
-- common first; it is NOT a claim about which is "correct".
--
--   Engineering & Technology (16 disciplines): b-tech is the universal
--   primary path. diploma (polytechnic) is added wherever that branch is a
--   standard, widely-offered polytechnic diploma (civil/mechanical/
--   electrical/electronics/chemical/manufacturing/metallurgical/mining);
--   left off for branches where a diploma isn't a standard, widely-offered
--   program (aerospace, industrial, petroleum, biomedical, environmental)
--   -- including it there would be the kind of guess V47 avoided. Computer
--   Science & Engineering and Information Technology additionally get b-sc
--   (a B.Sc CS/IT undergrad path is extremely common) and mca (the
--   standard postgraduate computing route); Biotechnology additionally
--   gets b-sc (B.Sc Biotechnology is as common an entry as B.Tech
--   Biotechnology).
--
--   Science & Research (5: physics, chemistry, mathematics, statistics,
--   biology): b-sc as the universal undergraduate base, phd as the
--   research-doctorate path this whole category leads toward.
--
--   Management & Business (5: business-administration, finance,
--   accounting, marketing, human-resource-management): bba/mba across the
--   board (undergraduate and postgraduate management routes both apply to
--   every one of these); finance and accounting additionally get b-com,
--   the traditional undergraduate base for both.
--
--   Agriculture (2: agriculture, forestry): b-sc only -- B.Sc
--   Agriculture/Forestry are standard, directly-named undergraduate
--   degrees.
--
--   Sports & Fitness (1: sports-science): b-sc (B.Sc Sports Science is a
--   real, directly-named degree at many universities) plus certificate,
--   mirroring V47's own fitness-trainer -> certificate mapping for the
--   many sports/fitness roles entered via a coaching or training
--   certification rather than a full degree.
--
-- Deliberately left with NO degree link (13 disciplines) -- every case
-- below is the same shape of ambiguity V47 already refused to guess at:
--   - medicine, pharmacy, nursing, physiotherapy: each has a real,
--     specific professional degree (MBBS, B.Pharm, B.Sc Nursing, BPT) that
--     is NOT one of this catalog's 10 degree types -- linking b-sc instead
--     would misrepresent a generic science degree as equivalent to a
--     specific professional one.
--   - law, public-administration: LLB and the closest public-policy
--     degrees aren't in this catalog either.
--   - psychology, sociology: the standard path is B.A. (not in this
--     catalog) with B.Sc only a partial alternative for some universities
--     -- V47 flagged exactly this ambiguity for psychologist and left it
--     unmapped; same call here.
--   - architecture, design: B.Arch/B.Des aren't in this catalog -- V47
--     made the identical call for ux-designer.
--   - journalism-and-mass-communication: BJMC/BMM aren't in this catalog.
--   - hospitality-management, tourism: BHM isn't in this catalog -- V47
--     made the identical call for hotel-manager.
-- The frontend's exam-overlap heuristic (data/degrees.ts,
-- filterDegreesRelevantToCareer) remains as a fallback for these, same as
-- before.
--
-- This mapping is inherently editorial judgment, not derived data --
-- unlike the taxonomy import itself, there's no source document backing
-- it. Worth a human sanity-check before treating it as final.

CREATE TABLE career_degrees (
    career_slug  VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    degree_slug  VARCHAR(64) NOT NULL REFERENCES degrees (slug) ON DELETE CASCADE,
    sort_order   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (career_slug, degree_slug)
);

INSERT INTO career_degrees (career_slug, degree_slug, sort_order) VALUES
    ('computer-science-and-engineering', 'b-tech', 0),
    ('computer-science-and-engineering', 'b-sc', 1),
    ('computer-science-and-engineering', 'mca', 2),
    ('computer-science-and-engineering', 'diploma', 3),
    ('information-technology', 'b-tech', 0),
    ('information-technology', 'b-sc', 1),
    ('information-technology', 'mca', 2),
    ('information-technology', 'diploma', 3),
    ('electronics-and-communication-engineering', 'b-tech', 0),
    ('electronics-and-communication-engineering', 'diploma', 1),
    ('electrical-engineering', 'b-tech', 0),
    ('electrical-engineering', 'diploma', 1),
    ('mechanical-engineering', 'b-tech', 0),
    ('mechanical-engineering', 'diploma', 1),
    ('aerospace-engineering', 'b-tech', 0),
    ('civil-engineering', 'b-tech', 0),
    ('civil-engineering', 'diploma', 1),
    ('chemical-engineering', 'b-tech', 0),
    ('chemical-engineering', 'diploma', 1),
    ('industrial-engineering', 'b-tech', 0),
    ('manufacturing-engineering', 'b-tech', 0),
    ('manufacturing-engineering', 'diploma', 1),
    ('metallurgical-and-materials-engineering', 'b-tech', 0),
    ('metallurgical-and-materials-engineering', 'diploma', 1),
    ('mining-engineering', 'b-tech', 0),
    ('mining-engineering', 'diploma', 1),
    ('petroleum-engineering', 'b-tech', 0),
    ('biomedical-engineering', 'b-tech', 0),
    ('biotechnology', 'b-tech', 0),
    ('biotechnology', 'b-sc', 1),
    ('environmental-engineering', 'b-tech', 0),
    ('physics', 'b-sc', 0),
    ('physics', 'phd', 1),
    ('chemistry', 'b-sc', 0),
    ('chemistry', 'phd', 1),
    ('mathematics', 'b-sc', 0),
    ('mathematics', 'phd', 1),
    ('statistics', 'b-sc', 0),
    ('statistics', 'phd', 1),
    ('biology', 'b-sc', 0),
    ('biology', 'phd', 1),
    ('business-administration', 'bba', 0),
    ('business-administration', 'mba', 1),
    ('finance', 'b-com', 0),
    ('finance', 'bba', 1),
    ('finance', 'mba', 2),
    ('accounting', 'b-com', 0),
    ('accounting', 'mba', 1),
    ('marketing', 'bba', 0),
    ('marketing', 'mba', 1),
    ('human-resource-management', 'bba', 0),
    ('human-resource-management', 'mba', 1),
    ('agriculture', 'b-sc', 0),
    ('forestry', 'b-sc', 0),
    ('sports-science', 'b-sc', 0),
    ('sports-science', 'certificate', 1);

ALTER TABLE careers DROP COLUMN degree_slug;
