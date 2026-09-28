-- Clears all existing Career, Specialization and Job Role data ahead of a
-- full re-import from the uploaded CareerGuide Career Taxonomy PDF (see
-- V50, which follows this one). Per direct request: wipe careers,
-- specializations and job_roles, but leave every other catalog entity
-- (categories, skills, exams, degrees, colleges, industries,
-- certifications, resources, streams) untouched -- they just lose their
-- links to the deleted rows rather than being deleted themselves.
--
-- Postgres requires every table with an FK into a truncated table to be
-- truncated in the SAME statement (see V45's postmortem -- truncating them
-- one at a time fails because an earlier statement's target can still be
-- referenced by a not-yet-truncated table), and this applies TRANSITIVELY:
-- if table B is being truncated because it references careers/
-- specializations/job_roles, and table C references B (even though C has
-- no direct FK to careers/specializations/job_roles itself), C must be
-- truncated in the same statement too, or Postgres fails with "cannot
-- truncate a table referenced in a foreign key constraint". This bit us
-- once already: user_roadmaps was correctly included (nullable FK to
-- careers), but user_roadmap_steps (which has a NOT NULL FK to
-- user_roadmaps.id, ON DELETE CASCADE, from V32) was missed on the first
-- pass because it has no direct reference to careers/specializations/
-- job_roles at all -- only a grep for the full transitive closure catches
-- it. The list below started as every table with a `career_slug`,
-- `specialization_slug` or `job_role_slug` FK per a grep of every
-- migration for "REFERENCES careers", "REFERENCES specializations" and
-- "REFERENCES job_roles" -- but that grep alone isn't enough:
--
--   1. V43 later dropped the entire Courses feature (career_courses,
--      course_careers, specialization_courses among others), so those
--      tables no longer exist even though V1/V16 still "create" them
--      earlier in migration history. Confirmed via V43's own DROP TABLE
--      list (and confirmed no other migration anywhere drops or renames
--      a table) that all three are correctly excluded here.
--   2. Tables that reference an already-included table (not careers/
--      specializations/job_roles directly) also need including --
--      confirmed via a second grep for "REFERENCES user_roadmaps" and
--      "REFERENCES user_roadmap_steps" that user_roadmap_steps is the
--      only such transitive table, and that nothing references
--      user_assessments, user_recommendations or user_progress (so none
--      of those three need to be added).
--
--   -> careers:         career_exams, career_stages, exam_careers,
--                        stage_careers, career_colleges,
--                        career_specializations, career_skills,
--                        career_industries, career_job_roles,
--                        certification_careers, resource_careers,
--                        stream_careers, user_saved_careers, user_roadmaps
--                        (target_career_slug, nullable, schema-only/unused
--                        per V32's own comment)
--   -> user_roadmaps:   user_roadmap_steps (transitive: NOT NULL FK to
--                        user_roadmaps.id, ON DELETE CASCADE)
--   -> specializations: career_specializations, specialization_exams,
--                        specialization_job_roles, specialization_hard_skills,
--                        specialization_soft_skills, specialization_certifications,
--                        specialization_industries
--   -> job_roles:        career_job_roles, specialization_job_roles,
--                        job_role_skills, job_role_industries
--
-- (career_courses, course_careers and specialization_courses were dropped
-- by V43 and are NOT included -- truncating a dropped table fails with
-- "relation does not exist", which is exactly what happened when this
-- migration first shipped without this fix.)
--
-- Deliberately NOT touched: categories, skills, exams, degrees, colleges,
-- industries, certifications, resources, streams -- and
-- counselling_requests.career_slug, which V10 explicitly made a plain
-- (non-FK) text column for exactly this kind of reason, so it's unaffected
-- either way and real leads are never touched.

TRUNCATE TABLE
    career_exams,
    career_stages,
    exam_careers,
    stage_careers,
    career_colleges,
    career_skills,
    career_industries,
    certification_careers,
    resource_careers,
    stream_careers,
    user_saved_careers,
    user_roadmaps,
    user_roadmap_steps,
    specialization_exams,
    specialization_hard_skills,
    specialization_soft_skills,
    specialization_certifications,
    specialization_industries,
    job_role_skills,
    job_role_industries,
    career_specializations,
    career_job_roles,
    specialization_job_roles,
    careers,
    specializations,
    job_roles;
