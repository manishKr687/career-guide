-- Turns salary from display text into queryable numbers.
--
-- Salary was stored six different ways across three tables, all VARCHAR(64):
--
--   careers.salary_range                     "₹4L – ₹30L / year"   42/42 set
--   job_roles.salary_min / salary_max        "4 LPA" / "15 LPA"   247/255 set
--   specializations.salary_{entry,mid,senior}_level               0/263 set
--
-- Three spellings of one concept. "₹4L" and "4 LPA" are the same number and
-- do not compare; careers pack a whole range into a single column; and
-- ordering by any of them sorts lexically, so ₹10L lands before ₹4L.
--
-- Nothing could be filtered, sorted, aggregated or validated. The validation
-- gap is not hypothetical: a bad round-trip wrote mojibake
-- ("â‚¹3L â€“ â‚¹15L / year") into one career's salary and the column accepted
-- it silently. A numeric column cannot hold that.
--
-- UNIT: lakhs per annum, NUMERIC(6,2).
--
-- Lakhs because that is the unit the domain speaks in, and storing rupees
-- would mean six trailing zeros on every row for no gain. NUMERIC rather than
-- INTEGER because 9 job roles are already "2.5 LPA" -- a first pass with an
-- integer-only regex silently classed those as unparseable, which is exactly
-- the kind of quiet loss this migration exists to end.
--
-- DISPLAY STRINGS ARE KEPT FOR NOW, NOT DROPPED.
--
-- "₹4L – ₹30L / year" is fully reconstructible from (4, 30), so it should
-- become derived rather than stored -- the same treatment education titles
-- got in V103. But dropping the columns in the same migration that adds the
-- numbers would break every reader in the gap between this and the code
-- change. They are dropped once the API composes the string instead.
--
-- specializations' three columns are dropped here, though: zero of 263 rows
-- has ever held a value, so there is nothing to migrate and no reader to
-- break. Three empty columns are not a tiered-salary model; if that is wanted
-- later it deserves to be designed rather than inherited.

ALTER TABLE careers
    ADD COLUMN salary_min_lpa NUMERIC(6,2),
    ADD COLUMN salary_max_lpa NUMERIC(6,2);

ALTER TABLE job_roles
    ADD COLUMN salary_min_lpa NUMERIC(6,2),
    ADD COLUMN salary_max_lpa NUMERIC(6,2);

UPDATE careers
SET salary_min_lpa = (regexp_match(salary_range, '^₹([0-9]+(?:\.[0-9]+)?)L'))[1]::numeric,
    salary_max_lpa = (regexp_match(salary_range, '– ₹([0-9]+(?:\.[0-9]+)?)L'))[1]::numeric
WHERE salary_range ~ '^₹[0-9]+(\.[0-9]+)?L – ₹[0-9]+(\.[0-9]+)?L / year$';

UPDATE job_roles
SET salary_min_lpa = replace(salary_min, ' LPA', '')::numeric,
    salary_max_lpa = replace(salary_max, ' LPA', '')::numeric
WHERE salary_min ~ '^[0-9]+(\.[0-9]+)? LPA$'
  AND salary_max ~ '^[0-9]+(\.[0-9]+)? LPA$';

ALTER TABLE specializations
    DROP COLUMN salary_entry_level,
    DROP COLUMN salary_mid_level,
    DROP COLUMN salary_senior_level;

DO $$
DECLARE bad int;
BEGIN
    -- Every row that HAD a salary must now have numbers. A row that failed to
    -- parse would otherwise land as a silent NULL and look like "no data".
    SELECT count(*) INTO bad FROM careers
    WHERE salary_range IS NOT NULL AND salary_range <> ''
      AND (salary_min_lpa IS NULL OR salary_max_lpa IS NULL);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have a salary string that did not parse', bad;
    END IF;

    SELECT count(*) INTO bad FROM job_roles
    WHERE salary_min IS NOT NULL AND salary_min <> ''
      AND (salary_min_lpa IS NULL OR salary_max_lpa IS NULL);
    IF bad > 0 THEN
        RAISE EXCEPTION '% job role(s) have a salary string that did not parse', bad;
    END IF;

    SELECT count(*) INTO bad FROM careers WHERE salary_min_lpa IS NOT NULL;
    IF bad <> 42 THEN
        RAISE EXCEPTION 'expected 42 careers with numeric salary, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM job_roles WHERE salary_min_lpa IS NOT NULL;
    IF bad <> 247 THEN
        RAISE EXCEPTION 'expected 247 job roles with numeric salary, found %', bad;
    END IF;

    -- The parse must agree with the string it came from, not merely produce
    -- some number: a regex that grabbed the wrong capture group would pass
    -- every count above.
    SELECT count(*) INTO bad FROM careers
    WHERE salary_min_lpa IS NOT NULL
      AND salary_range <> ('₹' || trim_scale(salary_min_lpa)::text || 'L – ₹'
                           || trim_scale(salary_max_lpa)::text || 'L / year');
    IF bad > 0 THEN
        RAISE EXCEPTION '% career salary string(s) do not round-trip from the parsed numbers', bad;
    END IF;

    -- A range must not be inverted.
    SELECT count(*) INTO bad FROM careers WHERE salary_min_lpa > salary_max_lpa;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) have min salary above max', bad;
    END IF;

    SELECT count(*) INTO bad FROM job_roles WHERE salary_min_lpa > salary_max_lpa;
    IF bad > 0 THEN
        RAISE EXCEPTION '% job role(s) have min salary above max', bad;
    END IF;

    -- Nothing absurd: a lakh figure outside 0.1-1000 is a parse error, not a
    -- salary.
    SELECT count(*) INTO bad FROM careers
    WHERE salary_min_lpa <= 0 OR salary_max_lpa > 1000;
    IF bad > 0 THEN
        RAISE EXCEPTION '% career salary value(s) are out of plausible range', bad;
    END IF;
END $$;

-- Now that the values are numbers, keep them numbers.
ALTER TABLE careers ADD CONSTRAINT careers_salary_range_sane
    CHECK (salary_min_lpa IS NULL OR salary_max_lpa IS NULL
           OR (salary_min_lpa > 0 AND salary_min_lpa <= salary_max_lpa));

ALTER TABLE job_roles ADD CONSTRAINT job_roles_salary_range_sane
    CHECK (salary_min_lpa IS NULL OR salary_max_lpa IS NULL
           OR (salary_min_lpa > 0 AND salary_min_lpa <= salary_max_lpa));

CREATE INDEX idx_careers_salary_min ON careers (salary_min_lpa);
CREATE INDEX idx_job_roles_salary_min ON job_roles (salary_min_lpa);
