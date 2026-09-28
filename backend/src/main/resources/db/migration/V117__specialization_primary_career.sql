-- Gives every specialization one canonical parent career.
--
-- THE PROBLEM. career_specializations is a many-to-many with a composite PK,
-- so a specialization could structurally have zero parents, one, or twelve.
-- Nothing recorded which one was "the" parent, and the specialization page
-- needs exactly one: for its breadcrumb, and for the borrowed data it falls
-- back to when it has no overview of its own (262 of 263 do not). With no
-- canonical parent the page used `careers[0]` -- whichever career the API
-- happened to return first. For the five specializations with two parents,
-- the breadcrumb was therefore arbitrary.
--
-- WHY NOT COLLAPSE TO A 1:N FOREIGN KEY INSTEAD. Because the many-to-many is
-- carrying real information, not accidental duplication:
--
--     Agricultural Biotechnology  = Agriculture + Biotechnology
--     Operations Research         = Industrial Engineering + Mathematics
--     CAD/CAM                     = Manufacturing + Mechanical Engineering
--     Cloud Computing             = Computer Science & Engineering + IT
--     Production Engineering      = Mechanical + Petroleum Engineering
--
-- Agricultural Biotechnology *is* the intersection of two careers. A single FK
-- would force deleting one of those edges, so the schema change would destroy
-- a true fact to satisfy a rule. The deletion test says the same thing: if the
-- career Mathematics were removed, Operations Research would still exist under
-- Industrial Engineering -- a child cannot outlive its parent, so this is an
-- association between peers, not composition.
--
-- So the hierarchy is expressed the way a tree over a graph always is: one
-- edge is designated canonical, the others remain.
--
-- WHY A COLUMN HERE RATHER THAN is_primary ON THE JOIN TABLE. A boolean on
-- career_specializations plus a partial unique index would guarantee "at most
-- one primary per specialization" but not "at least one" -- that needs a
-- trigger. NOT NULL on this column gives both, and the composite FK at the
-- bottom makes "the primary parent is genuinely one of the parents" a schema
-- invariant rather than something application code has to remember.
--
-- HOW THE FIVE WERE CHOSEN. The primary parent decides what a specialization
-- with no content of its own displays, so the richer parent is the better
-- default: for each pair, the career with more total related rows (degrees,
-- exams, colleges, skills, specializations, job roles) wins. The ranking is
-- the same whether or not colleges are counted, and it agrees with the
-- conventional reading in every case (Cloud Computing under CSE, CAD/CAM and
-- Production Engineering under Mechanical). These are judgments, so they are
-- written out literally below rather than recomputed by a rule that would
-- silently choose differently as the catalog grows.

ALTER TABLE specializations ADD COLUMN primary_career_slug VARCHAR(64);

-- The 258 with exactly one parent: that parent, no judgment involved.
UPDATE specializations s
SET primary_career_slug = cs.career_slug
FROM career_specializations cs
WHERE cs.specialization_slug = s.slug
  AND (SELECT count(*) FROM career_specializations x WHERE x.specialization_slug = s.slug) = 1;

-- The five with two parents.
UPDATE specializations SET primary_career_slug = 'biotechnology'
    WHERE slug = 'agricultural-biotechnology';
UPDATE specializations SET primary_career_slug = 'industrial-engineering'
    WHERE slug = 'operations-research';
UPDATE specializations SET primary_career_slug = 'mechanical-engineering'
    WHERE slug = 'cad-cam';
UPDATE specializations SET primary_career_slug = 'computer-science-and-engineering'
    WHERE slug = 'cloud-computing';
UPDATE specializations SET primary_career_slug = 'mechanical-engineering'
    WHERE slug = 'production-engineering';

-- No specialization may be left without a parent. If this fires, a
-- specialization exists with zero career links -- fix the link, do not relax
-- the column, because the page has nothing to render a breadcrumb from.
DO $$
DECLARE unparented int;
BEGIN
    SELECT count(*) INTO unparented FROM specializations WHERE primary_career_slug IS NULL;
    IF unparented > 0 THEN
        RAISE EXCEPTION
            '% specialization(s) have no career link, so no primary parent could be set', unparented;
    END IF;
END $$;

ALTER TABLE specializations ALTER COLUMN primary_career_slug SET NOT NULL;

-- career_specializations' PK is (career_slug, specialization_slug); the
-- composite FK below references the columns the other way round, so it needs
-- its own unique index in that order.
CREATE UNIQUE INDEX career_specializations_spec_career_uk
    ON career_specializations (specialization_slug, career_slug);

-- The invariant. Not "primary_career_slug points at some career" -- that would
-- allow a primary parent that is not actually a parent -- but "this exact
-- (specialization, career) pair exists in the join table".
--
-- No ON DELETE clause on purpose. career_specializations.career_slug is
-- ON DELETE CASCADE, so deleting a career removes its links; if one of them is
-- a specialization's primary, this constraint blocks the cascade and the
-- delete fails. That is the correct outcome rather than an inconvenience --
-- silently cascading would either orphan the specialization or delete it. The
-- service layer repoints first, the same repoint-verify-delete sequence the
-- degree relations already use.
--
-- DEFERRABLE INITIALLY DEFERRED, because the two rows this constraint spans are
-- necessarily written in the same transaction and one order has to come second.
-- Creating a specialization inserts into `specializations` and into
-- `career_specializations`, and Hibernate writes the entity before the join
-- table it does not own -- so an immediately-checked constraint would fail on
-- every create, for a row that is correct by the time the transaction ends.
-- Deferring moves the check to COMMIT, which is where a cross-row invariant
-- belongs. Note this means a violation surfaces at commit rather than at the
-- offending statement, so the services below pre-check and raise their own
-- message instead of letting a commit-time error reach the caller.
ALTER TABLE specializations
    ADD CONSTRAINT specializations_primary_is_a_parent
    FOREIGN KEY (slug, primary_career_slug)
    REFERENCES career_specializations (specialization_slug, career_slug)
    DEFERRABLE INITIALLY DEFERRED;

DO $$
DECLARE n int;
BEGIN
    -- Redundant while the FK above exists, which is the point: if a later
    -- migration drops the constraint, this records what it was protecting.
    SELECT count(*) INTO n FROM specializations s
    WHERE NOT EXISTS (
        SELECT 1 FROM career_specializations cs
        WHERE cs.specialization_slug = s.slug AND cs.career_slug = s.primary_career_slug);
    IF n > 0 THEN
        RAISE EXCEPTION '% specialization(s) have a primary career that is not one of their parents', n;
    END IF;

    SELECT count(*) INTO n FROM pg_constraint
    WHERE conname = 'specializations_primary_is_a_parent';
    IF n <> 1 THEN
        RAISE EXCEPTION 'specializations_primary_is_a_parent constraint missing';
    END IF;

    -- The five judgments above must have landed; a typo in a career slug would
    -- otherwise have been caught by the FK but attributed to the wrong cause.
    SELECT count(*) INTO n FROM specializations
    WHERE slug IN ('agricultural-biotechnology', 'operations-research', 'cad-cam',
                   'cloud-computing', 'production-engineering')
      AND primary_career_slug IN ('biotechnology', 'industrial-engineering',
                                  'mechanical-engineering', 'computer-science-and-engineering');
    IF n <> 5 THEN
        RAISE EXCEPTION 'expected 5 multi-parent specializations to be assigned a primary, found %', n;
    END IF;
END $$;
