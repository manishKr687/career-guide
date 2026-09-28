-- Adds "Stream" (Content & Data Architecture doc sec.4, ER & Data Model doc
-- sec.5): the After-12th-level split (Science / Commerce / Arts & Humanities
-- / Vocational) that neither existed as a table nor even a hardcoded enum
-- anywhere in this codebase before.
--
-- Scope note: the ER doc's own `streams` example list mixes two different
-- ideas under one entity -- the 4 board-exam streams every "After 12th"
-- student picks from, and broader field names (Engineering, Medical,
-- Computer Science, Management, Law, Design) that already exist in this
-- database as Categories/Careers. Seeding the latter as Streams too would
-- create a second, overlapping way to say "Engineering", so only the 4
-- canonical After-12th streams are seeded here -- the one example both
-- documents actually agree on (Content & Data Architecture doc sec.4).
--
-- stage_streams links Stream to the existing Stage entity (V1), matching
-- Content & Data Architecture sec.4's "Each stage can be associated with
-- multiple streams". stream_careers/stream_courses match the ER doc's own
-- relationship list; only after-12th is linked today since that's the only
-- stage the source docs actually associate with streams.

CREATE TABLE streams (
    slug        VARCHAR(64) PRIMARY KEY,
    name        VARCHAR(160) NOT NULL,
    description TEXT
);

CREATE TABLE stage_streams (
    stage_slug  VARCHAR(64) NOT NULL REFERENCES stages (slug) ON DELETE CASCADE,
    stream_slug VARCHAR(64) NOT NULL REFERENCES streams (slug) ON DELETE CASCADE,
    PRIMARY KEY (stage_slug, stream_slug)
);
CREATE INDEX idx_stage_streams_stream ON stage_streams (stream_slug);

CREATE TABLE stream_careers (
    stream_slug VARCHAR(64) NOT NULL REFERENCES streams (slug) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    PRIMARY KEY (stream_slug, career_slug)
);
CREATE INDEX idx_stream_careers_career ON stream_careers (career_slug);

CREATE TABLE stream_courses (
    stream_slug VARCHAR(64) NOT NULL REFERENCES streams (slug) ON DELETE CASCADE,
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    PRIMARY KEY (stream_slug, course_slug)
);
CREATE INDEX idx_stream_courses_course ON stream_courses (course_slug);

INSERT INTO streams (slug, name, description) VALUES
    ('science',          'Science',           'Physics, Chemistry, Biology/Maths -- the stream behind most engineering, medical and pure science careers.'),
    ('commerce',         'Commerce',          'Accounting, Business Studies and Economics -- the stream behind most finance, commerce and management careers.'),
    ('arts-humanities',  'Arts & Humanities', 'Literature, History, Political Science and the social sciences -- the stream behind law, media, design and civil services careers.'),
    ('vocational',       'Vocational',        'Skill-focused, job-oriented programs -- the stream behind skilled trades and diploma-led careers.');

INSERT INTO stage_streams (stage_slug, stream_slug)
SELECT 'after-12th', slug FROM streams;
