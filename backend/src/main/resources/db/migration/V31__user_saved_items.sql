-- Server-backed replacement for the frontend's browser-localStorage saved
-- items (src/lib/savedItems.ts, courses + colleges only). Per the ER doc's
-- user_saved_careers/courses/colleges/exams (sec.32) -- adds careers and
-- exams too, which localStorage never covered.
--
-- Migrating the frontend off localStorage onto these tables (and wiring
-- /api/me/saved-* endpoints) is a separate follow-up -- this migration only
-- adds the tables so that work isn't blocked on a schema change later.

CREATE TABLE user_saved_careers (
    user_id     BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    career_slug VARCHAR(64) NOT NULL REFERENCES careers (slug) ON DELETE CASCADE,
    saved_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, career_slug)
);

CREATE TABLE user_saved_courses (
    user_id     BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    course_slug VARCHAR(64) NOT NULL REFERENCES courses (slug) ON DELETE CASCADE,
    saved_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, course_slug)
);

CREATE TABLE user_saved_colleges (
    user_id      BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    college_slug VARCHAR(64) NOT NULL REFERENCES colleges (slug) ON DELETE CASCADE,
    saved_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, college_slug)
);

CREATE TABLE user_saved_exams (
    user_id   BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    exam_slug VARCHAR(64) NOT NULL REFERENCES exams (slug) ON DELETE CASCADE,
    saved_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, exam_slug)
);
