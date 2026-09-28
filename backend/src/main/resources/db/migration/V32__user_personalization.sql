-- The remaining "Personalization" tables from the ER & Data Model doc
-- (sec.33-34, sec.36): user_assessments, user_recommendations,
-- user_roadmaps, user_roadmap_steps, user_progress.
--
-- Schema only -- these tables have no reads or writes wired up yet. The
-- existing /api/assessment endpoint (AssessmentService) computes a result
-- per request and returns it without saving anything, because until V30
-- there was no user to attach a saved result to. Persisting a result to
-- user_assessments, generating user_recommendations from it, and building a
-- real per-user /roadmap all need their own design pass (how a
-- recommendation is scored, how a roadmap's steps are generated) -- that's
-- a separate, larger piece of work than adding these tables, flagged as
-- such in the "ER Data Model Match" doc tab before this migration was
-- written.
--
-- user_progress: the ER doc lists this table by name (sec.29, sec.36)
-- alongside the others but never shows its column definition in either
-- uploaded document. The shape below (one row per user+entity being
-- tracked, with a status) is inferred to fit the same pattern as
-- user_recommendations, not copied from an explicit spec.

CREATE TABLE user_assessments (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    assessment_type VARCHAR(32) NOT NULL DEFAULT 'career',
    score           JSONB,
    completed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_user_assessments_user ON user_assessments (user_id);

CREATE TABLE user_recommendations (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    entity_type VARCHAR(32) NOT NULL,
    entity_slug VARCHAR(64) NOT NULL,
    score       DOUBLE PRECISION,
    reason      TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_user_recommendations_user ON user_recommendations (user_id);

CREATE TABLE user_roadmaps (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title              VARCHAR(200) NOT NULL,
    target_career_slug VARCHAR(64) REFERENCES careers (slug),
    start_date         DATE,
    target_date        DATE,
    status             VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_user_roadmaps_user ON user_roadmaps (user_id);

CREATE TABLE user_roadmap_steps (
    id           BIGSERIAL PRIMARY KEY,
    roadmap_id   BIGINT NOT NULL REFERENCES user_roadmaps (id) ON DELETE CASCADE,
    step_type    VARCHAR(32) NOT NULL,
    entity_slug  VARCHAR(64),
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    sequence     INT NOT NULL DEFAULT 0,
    status       VARCHAR(32) NOT NULL DEFAULT 'pending',
    target_date  DATE,
    completed_at TIMESTAMPTZ
);
CREATE INDEX idx_user_roadmap_steps_roadmap ON user_roadmap_steps (roadmap_id);

CREATE TABLE user_progress (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    entity_type VARCHAR(32) NOT NULL,
    entity_slug VARCHAR(64) NOT NULL,
    status      VARCHAR(32) NOT NULL DEFAULT 'in_progress',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, entity_type, entity_slug)
);
CREATE INDEX idx_user_progress_user ON user_progress (user_id);
