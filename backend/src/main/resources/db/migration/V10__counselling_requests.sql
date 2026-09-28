-- User-submitted requests to book a counselling call. Unlike the content
-- tables (careers, courses, ...), these aren't slugged/admin-authored --
-- they're transient submissions from site visitors, so a plain surrogate id
-- fits better than a slug primary key.
--
-- stage_slug/career_slug are deliberately NOT foreign keys: they're just
-- optional context captured at submission time (e.g. "they were looking at
-- the Data Scientist career page"), and a request shouldn't become
-- unreadable or block a delete just because the career/stage it referenced
-- was later renamed or removed from the catalog.
CREATE TABLE counselling_requests (
    id             BIGSERIAL PRIMARY KEY,
    name           VARCHAR(200) NOT NULL,
    email          VARCHAR(255) NOT NULL,
    phone          VARCHAR(32) NOT NULL,
    preferred_date DATE,
    preferred_time VARCHAR(64),
    stage_slug     VARCHAR(64),
    career_slug    VARCHAR(64),
    message        TEXT,
    status         VARCHAR(16) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONTACTED', 'COMPLETED')),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_counselling_requests_status ON counselling_requests (status);
CREATE INDEX idx_counselling_requests_created_at ON counselling_requests (created_at DESC);
