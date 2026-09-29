-- Records consent for the counselling form.
--
-- The form collects a name, an email address, a phone number and free text from
-- students -- many of them minors -- and until now it asked for none of that with
-- permission and recorded no evidence that permission was given.
--
-- Under the Digital Personal Data Protection Act 2023 the burden is on the data
-- fiduciary to DEMONSTRATE that consent was obtained. A checkbox in the browser
-- does not demonstrate anything: it can be bypassed by posting to the endpoint
-- directly, and it leaves no record afterwards. So consent is required by the API
-- and stamped here, on the row, at the moment of submission.
--
-- NULLABLE, because the column has to be addable to rows that predate it. There
-- are none today -- counselling_requests is empty -- but writing it NOT NULL would
-- make this migration fail on any database where somebody had already submitted
-- the form, which is precisely the database it most needs to run on. The API
-- rejects a submission without consent, so every row created from here on has a
-- timestamp; a null means "submitted before consent was asked for", which is a
-- fact worth being able to see rather than one to paper over.
--
-- The timestamp is set server-side from the database clock rather than taken from
-- the client. A consent time a browser could choose is not evidence of anything.

ALTER TABLE counselling_requests ADD COLUMN consented_at timestamptz;

COMMENT ON COLUMN counselling_requests.consented_at IS
    'When the submitter ticked the consent box. Set server-side at submission. '
    'Null means the row predates V133, when consent was not collected.';

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'counselling_requests'
      AND column_name = 'consented_at';
    IF n <> 1 THEN RAISE EXCEPTION 'consented_at was not added'; END IF;

    -- Existing rows must NOT have been given a consent timestamp they never gave.
    -- If a DEFAULT ever creeps in here, every historical row silently starts
    -- claiming consent, which is the opposite of what this column is for.
    SELECT count(*) INTO n FROM counselling_requests WHERE consented_at IS NOT NULL;
    IF n > 0 THEN
        RAISE EXCEPTION '% pre-existing request(s) were backfilled with a consent timestamp they never gave', n;
    END IF;
END $$;
