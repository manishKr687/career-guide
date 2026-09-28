-- Records when catalog content was created and last changed.
--
-- Nothing in this schema has ever known when a row appeared or was last
-- edited. That is fine for a read-only public site and useless for an admin
-- tool: "what changed recently" is the first question an editor asks, and
-- there was no way to answer it.
--
-- EXISTING ROWS GET NULL, NOT now().
--
-- `ALTER TABLE ... ADD COLUMN ... DEFAULT now()` would backfill all 1,200-odd
-- rows with today's date, and every one of them would then claim to have been
-- created the day this migration ran. The dashboard's "recently added" panel
-- would show the entire catalog as new. So the column is added bare, and the
-- default is attached afterwards -- which applies to INSERTs from here on and
-- leaves the seeded rows honestly unknown.
--
-- A null created_at therefore means "seeded before this migration", and the
-- dashboard says so rather than inventing a date.
--
-- updated_at is maintained by a trigger rather than by each service, because
-- there are ten services and a forgotten setter is invisible -- the column
-- would just silently stop tracking for one entity.

CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END $$;

DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'careers', 'degrees', 'exams', 'colleges', 'specializations',
        'job_roles', 'resources', 'skills', 'certifications', 'industries'
    ];
BEGIN
    FOREACH t IN ARRAY tables
    LOOP
        -- Bare ADD COLUMN: no DEFAULT here, so existing rows stay NULL.
        EXECUTE format('ALTER TABLE %I ADD COLUMN created_at timestamptz', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN updated_at timestamptz', t);

        -- Attached after the fact, so it only applies to future INSERTs.
        EXECUTE format('ALTER TABLE %I ALTER COLUMN created_at SET DEFAULT now()', t);

        EXECUTE format(
            'CREATE TRIGGER %I BEFORE UPDATE ON %I
             FOR EACH ROW EXECUTE FUNCTION touch_updated_at()',
            t || '_touch_updated_at', t
        );
    END LOOP;
END $$;

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name IN ('created_at', 'updated_at')
      AND table_name IN ('careers', 'degrees', 'exams', 'colleges', 'specializations',
                         'job_roles', 'resources', 'skills', 'certifications', 'industries');
    IF bad <> 20 THEN
        RAISE EXCEPTION 'expected 20 new timestamp columns across 10 tables, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM pg_trigger
    WHERE tgname LIKE '%_touch_updated_at' AND NOT tgisinternal;
    IF bad <> 10 THEN
        RAISE EXCEPTION 'expected 10 updated_at triggers, found %', bad;
    END IF;

    -- The whole point of adding the column bare: no existing row may claim a
    -- creation date it does not have.
    SELECT count(*) INTO bad FROM careers WHERE created_at IS NOT NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION '% seeded career(s) were backfilled with a fake created_at', bad;
    END IF;
END $$;
