-- Admin-set lines for My Career: the stations a user starts with when they
-- pick one particular goal (JEE Main, IIT Madras, Data Analyst...).
--
-- Schema only. An item with no row here keeps the line GoalCatalog builds
-- from the catalogue, exactly as before; a row replaces it for that item.
-- Users always get a copy (user_goal_stations), so changing a line here
-- never rewrites anyone's own line -- they are offered the new one instead.

CREATE TABLE goal_lines (
    id          bigserial    PRIMARY KEY,
    goal_type   varchar(16)  NOT NULL CHECK (goal_type IN
                    ('career', 'exam', 'college', 'degree', 'job_role', 'company', 'sector', 'certification')),
    target_slug varchar(64)  NOT NULL,
    -- Goes up by one on every save, so a user's goal can tell it started
    -- from an older version.
    version     integer      NOT NULL DEFAULT 1 CHECK (version >= 1),
    created_at  timestamptz  NOT NULL DEFAULT now(),
    updated_at  timestamptz  NOT NULL DEFAULT now(),
    UNIQUE (goal_type, target_slug)
);

CREATE TRIGGER goal_lines_touch_updated_at BEFORE UPDATE ON goal_lines
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- Same columns and limits as user_goal_stations, which they are copied into.
-- The last station is the goal itself.
CREATE TABLE goal_line_stations (
    id        bigserial    PRIMARY KEY,
    line_id   bigint       NOT NULL REFERENCES goal_lines (id) ON DELETE CASCADE,
    position  smallint     NOT NULL CHECK (position >= 0),
    name      varchar(80)  NOT NULL CHECK (length(btrim(name)) > 0),
    kind      varchar(32)  NOT NULL CHECK (length(btrim(kind)) > 0),
    detail    varchar(200) NOT NULL DEFAULT '',
    next_step varchar(200),
    UNIQUE (line_id, position)
);

-- Which line a user's stations were copied from: 'auto' for the catalogue's
-- own, 'admin:<version>' for an admin line. When it no longer matches what
-- the item would give today, the page offers the new line. Null for goals set
-- before this column existed: those are never offered one.
ALTER TABLE user_goals ADD COLUMN line_source varchar(32);
