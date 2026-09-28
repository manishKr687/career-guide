-- Clears all existing Specialization data per direct request. This is a
-- data-only wipe: the specializations table, its schema, the Specialization
-- entity, its API (SpecializationController/AdminSpecializationController)
-- and the admin CRUD UI all stay exactly as they are -- the catalog is just
-- emptied out so it can be repopulated fresh.
--
-- Every join table below has a (plain, non-CASCADE) FK into specializations
-- (specialization_slug). Postgres's TRUNCATE refuses to truncate a table
-- that's still referenced by an FK from another table unless that other
-- table is truncated in the SAME statement (or CASCADE is used) -- it
-- doesn't matter that the referencing table is already empty by the time
-- a later, separate TRUNCATE runs. So all six tables are listed together
-- in one TRUNCATE here, rather than as six separate statements.
TRUNCATE TABLE
  specialization_exams,
  specialization_job_roles,
  specialization_hard_skills,
  specialization_soft_skills,
  career_specializations,
  specializations;
