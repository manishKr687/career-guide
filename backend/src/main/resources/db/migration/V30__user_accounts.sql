-- Adds the "User Data Model" pillar from the uploaded ER & Data Model doc
-- (sec.29-31): a real consumer account system. This is the one pillar the
-- "ER Data Model Match" tab flagged as 0% built -- the only auth in this
-- codebase before this migration was AdminAuthService's single shared admin
-- password, unrelated to end users. The frontend's /profile page and saved
-- items have been browser-localStorage-only until now (see V31).
--
-- Deliberately no new Maven dependency: this project already hand-rolls its
-- own HMAC-signed tokens for admin sessions (AdminTokenService) rather than
-- pulling in Spring Security, and the sandbox this was built in can't
-- resolve new Maven dependencies at all (no network access to Maven
-- Central), so a real dependency add couldn't even be verified here.
-- Passwords are hashed with PBKDF2WithHmacSHA256 (a standard javax.crypto
-- algorithm, same package AdminTokenService already uses for HMAC) rather
-- than bcrypt, purely because that needs no new library. See
-- UserPasswordService.
--
-- users.id is BIGSERIAL, not a slug, matching this database's existing
-- convention for user-generated (not catalog) rows -- see
-- counselling_requests (V10) and assessment_options (V1).
--
-- user_interests: the ER doc's user_interests table references an
-- "interest_id" as if a dedicated interests lookup table exists, but no
-- such table is defined anywhere in either uploaded document (only an
-- example list: Technology, Finance, Healthcare, Design, Government Jobs,
-- Business). Rather than invent an entire reference table the spec never
-- actually specifies, interest is stored as plain text here -- additive
-- and easy to normalize into a real table later if a curated list emerges.

CREATE TABLE users (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name          VARCHAR(200) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_profiles (
    user_id             BIGINT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    education_stage_slug VARCHAR(64) REFERENCES stages (slug),
    stream_slug         VARCHAR(64) REFERENCES streams (slug),
    education_level     VARCHAR(64),
    graduation_year     INT,
    experience_years    INT,
    location            VARCHAR(160)
);

CREATE TABLE user_interests (
    user_id       BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    interest      VARCHAR(64) NOT NULL,
    PRIMARY KEY (user_id, interest)
);

CREATE TABLE user_skills (
    user_id             BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    skill_slug          VARCHAR(64) NOT NULL REFERENCES skills (slug) ON DELETE CASCADE,
    proficiency_level   VARCHAR(32),
    years_of_experience INT,
    PRIMARY KEY (user_id, skill_slug)
);
