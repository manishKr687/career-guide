-- Drops two Career columns that turned out to be redundant, per the
-- Career-vs-Specialization schema discussion in the Data Model Roadmap doc.
--
-- top_recruiters: had no admin write path at all -- CareerUpsertRequest,
-- CareerService and the admin form never touched it, only the V13 seed and
-- the V12 careers it covered ever populated it. career_industries (V25)
-- already has a full backfill of every mention this column ever had, so
-- nothing is lost; the career detail page's "Top Recruiters" section now
-- reads relatedIndustrySlugs instead.
--
-- salary_entry_level/salary_mid_level/salary_senior_level: only ever
-- populated for the 8 engineering careers added in V12, and now made
-- redundant by Specialization's own, more precise, per-specialization
-- salary breakdown (V40) -- a Mechanical Engineer's "Project & Leadership"
-- specialization pays very differently than its "Manufacturing &
-- Operations" one, which a single career-wide band could never capture.
-- salary_range (the single-string summary) is untouched -- it's the one
-- salary fact populated for every career and shown on every card
-- site-wide, so there's nothing to derive it from for the ~55 careers with
-- no specializations yet.

ALTER TABLE careers
    DROP COLUMN top_recruiters,
    DROP COLUMN salary_entry_level,
    DROP COLUMN salary_mid_level,
    DROP COLUMN salary_senior_level;
