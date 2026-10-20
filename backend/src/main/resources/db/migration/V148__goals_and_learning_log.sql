-- My Career: a goal, the line of stations towards it, the focus items being
-- worked on, and a learning log.
--
-- Schema only. Every row here is a user's own data, written by the app; no
-- catalogue content is touched (MigrationPolicyTest checks that).
--
-- One goal per user, in two parts: what kind of thing it is and which one.
-- Studying: a career, exam, college or degree. Working: a job role, a company
-- (an employer in `industries`), a sector (an `industries` row with
-- is_sector) or a certification. target_slug is not a foreign key because it
-- points at a different table per goal_type; GoalCatalog validates it when the
-- goal is set. target_name is a snapshot so the page still reads if that
-- catalogue row is later renamed or removed.

CREATE TABLE user_goals (
    user_id      bigint       PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    goal_type    varchar(16)  NOT NULL CHECK (goal_type IN
                     ('career', 'exam', 'college', 'degree', 'job_role', 'company', 'sector', 'certification')),
    target_slug  varchar(64)  NOT NULL,
    target_name  varchar(160) NOT NULL,
    -- The first of the month; a goal is "by March 2027", not a day.
    target_month date         CHECK (target_month IS NULL OR extract(day FROM target_month) = 1),
    created_at   timestamptz  NOT NULL DEFAULT now(),
    updated_at   timestamptz  NOT NULL DEFAULT now()
);

CREATE TRIGGER user_goals_touch_updated_at BEFORE UPDATE ON user_goals
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- The line. Built from the catalogue when the goal is set, then the user's to
-- edit: stations can be ticked off, removed, or added (custom = true). Ordered
-- by position with id as the tie-break; position is not unique, so inserting
-- a station never has to renumber the rest inside a constraint.
CREATE TABLE user_goal_stations (
    id        bigserial    PRIMARY KEY,
    user_id   bigint       NOT NULL REFERENCES user_goals (user_id) ON DELETE CASCADE,
    position  smallint     NOT NULL CHECK (position >= 0),
    name      varchar(80)  NOT NULL CHECK (length(btrim(name)) > 0),
    kind      varchar(32)  NOT NULL,
    detail    varchar(200) NOT NULL DEFAULT '',
    next_step varchar(200),
    done      boolean      NOT NULL DEFAULT false,
    custom    boolean      NOT NULL DEFAULT false
);
CREATE INDEX user_goal_stations_user ON user_goal_stations (user_id, position, id);

-- Focus items: skills from the catalogue (skill_slug set) or the user's own
-- subjects and topics (skill_slug null), since the catalogue does not record
-- which subjects an exam tests. level: 0 not started, 1 learning,
-- 2 comfortable, 3 confident. At most six per user, enforced in GoalService.
CREATE TABLE user_goal_focus (
    id         bigserial   PRIMARY KEY,
    user_id    bigint      NOT NULL REFERENCES user_goals (user_id) ON DELETE CASCADE,
    name       varchar(60) NOT NULL CHECK (length(btrim(name)) > 0),
    skill_slug varchar(64) REFERENCES skills (slug) ON DELETE SET NULL,
    level      smallint    NOT NULL DEFAULT 0 CHECK (level BETWEEN 0 AND 3),
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX user_goal_focus_name ON user_goal_focus (user_id, lower(name));

-- The learning log belongs to the user, not to the goal, so changing goal
-- keeps the history. target is a label -- a focus item's name, an exam, "Mock
-- test" -- kept as text so an entry still reads after its focus item is gone.
-- A score is stored with its own maximum (300 for a JEE Main mock, 100 for a
-- percentage), so scores logged against different scales are never compared.
CREATE TABLE user_learning_log (
    id         bigserial    PRIMARY KEY,
    user_id    bigint       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    logged_on  date         NOT NULL,
    note       varchar(280) NOT NULL CHECK (length(btrim(note)) > 0),
    target     varchar(80)  NOT NULL CHECK (length(btrim(target)) > 0),
    minutes    smallint     NOT NULL CHECK (minutes BETWEEN 1 AND 600),
    score      smallint,
    score_max  smallint,
    created_at timestamptz  NOT NULL DEFAULT now(),
    CHECK ((score IS NULL) = (score_max IS NULL)),
    CHECK (score_max IS NULL OR (score_max BETWEEN 1 AND 1000 AND score BETWEEN 0 AND score_max))
);
CREATE INDEX user_learning_log_user_day ON user_learning_log (user_id, logged_on DESC, id DESC);
