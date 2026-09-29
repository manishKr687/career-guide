# CareerGuide API

A Java / Spring Boot content API for CareerGuide, backed by PostgreSQL. It
serves the same careers / courses / exams / colleges / stages / categories /
assessment data that today lives as static TypeScript files in the Next.js
frontend (`src/data/*.ts`), migrated into a normalized relational schema.

Scope of this pass, agreed up front: **content API only** — read endpoints
mirroring the current static data, plus a server-side version of the career
assessment scoring, and nothing more. No authentication, no user accounts.
The Next.js frontend now fetches from this API (see `src/lib/api.ts` and
`src/data/*.ts` in the project root) instead of its old static data files.

## Stack

- Java 21, Spring Boot 3.5.5, Maven
- Spring Data JPA (Hibernate) + Flyway-versioned migrations
- PostgreSQL 16
- springdoc-openapi (Swagger UI)
- No Elasticsearch — the whole catalog is ~150 rows, so Postgres `ILIKE`
  search (see `search` queries in `src/main/java/.../repository/`) is more
  than enough. This can be revisited if the catalog grows by an order of
  magnitude or two.

## Running it

You need Docker Desktop. Nothing else.

```bash
cd backend
docker compose up --build
```

This starts two containers:

- `postgres` — Postgres 16, with the schema and seed data applied
  automatically by Flyway on the API's first startup.
- `api` — the Spring Boot app, built from source inside the container (the
  `Dockerfile`'s build stage runs `mvn package`, which needs to reach Maven
  Central — that happens on your machine, with your normal internet access).

Once it's up:

- API: http://localhost:8081/api/...
- Swagger UI: http://localhost:8081/swagger-ui.html
- Health check: http://localhost:8081/actuator/health

(Port 8081 on the host, not 8080 — mapped that way in `docker-compose.yml`
because 8080 was already taken by something else on this machine. The
container itself still listens on 8080 internally.)

To stop: `Ctrl+C`, then `docker compose down` (add `-v` to also wipe the
Postgres volume and start from a clean database next time).

### Running without Docker (optional)

If you'd rather run Postgres yourself and the API via your IDE/Maven:

1. Start a local Postgres 16, create a `careerguide` database and a
   `careerguide`/`careerguide` user (or override via the `SPRING_DATASOURCE_*`
   environment variables — see `application.yml`).
2. `mvn spring-boot:run` — Flyway applies all migrations on startup.

## What owns the content

Two things can write the catalog -- Flyway migrations and the admin UI -- and
until this was written down, nothing said which wins. That ambiguity has already
cost data twice: a migration (V80) asserted on rows that only existed because
someone had created them through the admin, and three exams added through the
admin were lost when a database volume was dropped, because they existed in no
migration.

The rule, from go-live onward:

| | Source of truth | Changed by |
|---|---|---|
| **Schema** | Flyway migrations | A new `V___` migration, as always |
| **Catalog content** | The database | The admin UI |
| **User data** | Production only | Real visitors |

Migrations V1-V146 seeded the catalog and remain the record of how it got here,
including why particular things were left empty. They are history, not the live
truth. **Do not add content migrations** -- edit the content in the admin
instead, or the two sources diverge again.

Nothing was removed from V1-V146 to make this true, and nothing should be.
Applied migrations are checksummed; editing one makes Flyway refuse to start
against every database that already ran it. The rule governs what gets written
from here on.

### Where the line falls

Taxonomy counts as schema, not content: `categories`, `stages`, `streams` and
their join tables. Around 165 rows that foreign keys across the whole database
depend on, that change roughly never, and that have no admin screens. A new
migration may add or change those. Everything else -- careers, colleges, exams,
degrees, specializations, skills, job roles, certifications, resources,
industries -- is content, lives in the database, and is edited in the admin.

Content with no admin screen, which this rule leaves editable only by SQL:

| | Rows |
|---|---|
| `assessment_questions` + `assessment_options` + `assessment_option_weights` | 155 |
| `subjects` (an admin API exists, no UI) + `degree_subjects` | 100 |

Those are the screens to build before anyone needs to change the assessment.

A consequence worth stating plainly: CI's replay-from-empty proves the schema and
the original seed are coherent. It does not produce a copy of production. A new
environment is *run the migrations, then import the content*, not *run the
migrations and you are done*.

### Moving content between environments

```bash
./scripts/export-content.sh              # from your local database
./scripts/import-content.sh backups/content-YYYYMMDD-HHMM.sql
```

The export takes every table except `users`, the eleven `user_*` tables,
`counselling_requests` and `flyway_schema_history`. The table list is derived
rather than hard-coded, so a table added later is picked up automatically.

**The import refuses to run against a database that has users or counselling
requests, and that refusal is the point.** Replacing the catalog means truncating
it, and `user_saved_careers`, `user_saved_colleges`, `user_saved_exams` and
`user_roadmaps` all cascade from the content they reference -- so on a live
database this would delete people's saved items and roadmaps without reporting
it. The script is for the first load into a new environment. Updating the catalog
on a site that already has users needs an upsert-based sync, which is a different
tool and does not exist yet.

## Backups

The `postgres` service already uses a named Docker volume
(`careerguide-postgres-data`), so your data survives normal restarts and
`docker compose up`/`down` cycles on its own — you don't need to do anything
for that. A named volume is *not* the same as a backup, though: it won't
survive `docker compose down -v`, an accidental `docker volume rm`, disk
failure, or wanting to go back to an earlier point in time. That's what
these scripts are for.

Run from the `backend/` folder, with `docker compose up` already running:

```powershell
# Windows / PowerShell
.\scripts\backup-db.ps1                      # -> backups\careerguide_<timestamp>.sql
.\scripts\backup-db.ps1 -Label before-risky-change
.\scripts\restore-db.ps1 -File careerguide_20260917_120000.sql
```

```bash
# macOS / Linux / WSL
./scripts/backup-db.sh
./scripts/backup-db.sh before-risky-change
./scripts/restore-db.sh careerguide_20260917_120000.sql
```

How it works: `backup-db` runs `pg_dump --clean --if-exists` *inside* the
postgres container, writing straight to `/backups` (bind-mounted to
`backend/backups/` on your machine via `docker-compose.yml`) — the file never
passes through your host shell, so there's no risk of PowerShell mangling
its encoding. `restore-db` does the same in reverse with `psql -f`, and asks
for confirmation first since it overwrites whatever's currently in the
database. Both were verified end-to-end against a real Postgres 16 instance
(dump → restore into a fresh database → restore over an already-populated
one) with row counts checked before and after.

This is a logical (SQL) backup, not a raw copy of the volume — it's
portable (restorable into any Postgres 16.x instance, not just this exact
container) and the resulting `.sql` file is plain text you can open and
read. `backend/backups/` is gitignored (see `.gitignore`) since dumps
contain real data and can grow over time; copy files out of there if you
want them somewhere more durable than your laptop (a cloud drive, an
external disk, etc.) — these scripts don't do that part for you.

### Backups are the only way back

This matters more than it used to. Since the catalog's source of truth is the
database rather than the migrations, anything added or edited through the admin
exists in exactly one place. Replaying migrations rebuilds the catalog as it
stood at V146 and nothing after it. A backup is the only route back from a lost
volume, a bad restore, or a mistaken bulk delete — and this project has already
lost three admin-created exams and a user account to exactly that, because they
existed in no migration.

### Scheduling

```powershell
.\scripts\schedule-backup.ps1                     # daily 02:00, keep 30 days
.\scripts\schedule-backup.ps1 -Status             # registered? last result?
.\scripts\schedule-backup.ps1 -Remove
```

Registers a Windows Scheduled Task running as the current user, so it needs no
elevation and no stored password. `-Status` reports the last exit code: 0 is
success, and anything else is a backup that failed silently. On macOS/Linux a
cron entry calling `backup-db.sh` does the same job; set `KEEP_DAYS=30` in the
environment to enable the same pruning.

Two limits worth stating: the task does not run while logged out or powered off,
so on a real deployment the backup belongs on the server hosting Postgres; and
it writes to the same disk as the database, which survives a mistake but not a
dead disk. Copying dumps somewhere else is still a manual step.

### Verification

`backup-db` now checks its own output. `pg_dump`'s redirection happens inside
the container, so a dump interrupted by a full disk or a stopped container
leaves a truncated file that looks exactly like a good one until the day it is
needed. The scripts grep for the `-- PostgreSQL database dump complete` marker
that `pg_dump` writes last, and **delete the file and fail** if it is absent —
no backup is better than one you would wrongly trust.

Pruning (`-KeepDays` / `KEEP_DAYS`) only removes unlabelled automatic backups.
A labelled one — `before-schema-change` — was taken deliberately at a moment
someone thought mattered, and is never auto-deleted.

To check a backup is restorable without touching the real database, restore it
into a scratch one and compare:

```bash
docker compose exec -T postgres psql -U careerguide -d postgres \
  -c "CREATE DATABASE restore_test OWNER careerguide;"
docker compose exec -T postgres psql -U careerguide -d restore_test -f /backups/<file>.sql
# compare row counts across every table, then:
docker compose exec -T postgres psql -U careerguide -d postgres -c "DROP DATABASE restore_test;"
```

This was run against the current database on 2026-09-29: 76 tables, identical
row counts in every one, `flyway_schema_history` restored with all 146
migrations recorded. A `pg_dump` backup is a full disaster-recovery artifact —
schema, data and migration history — not just a content copy, so the app boots
straight against a restored database.

## API overview

Public endpoints are read-only except the assessment submission. There's also
an admin API for writes -- see "Admin panel" below.

| Endpoint | Notes |
|---|---|
| `GET /api/categories`, `/api/categories/{slug}` | |
| `GET /api/stages`, `/api/stages/{slug}` | Ordered by the stages' natural sequence (After 10th → Career Switch). |
| `GET /api/careers?category=&q=`, `/api/careers/{slug}` | `category` filters by category slug, `q` searches title/tagline/description. |
| `GET /api/courses?level=&q=`, `/api/courses/{slug}` | `level` e.g. `Undergraduate`, `Diploma`, `Certification`. |
| `GET /api/exams?category=&q=`, `/api/exams/{slug}` | `category` e.g. `Government`, `Banking`, `Defence`. |
| `GET /api/colleges?type=&q=`, `/api/colleges/{slug}` | `type` e.g. `IIT`, `NIT`, `Polytechnic`. |
| `GET /api/specializations`, `/api/specializations/{slug}` | No filters -- the catalog is small (147 rows across every career, see V16/V17). Read-only, no admin CRUD yet. |
| `GET /api/assessment/questions` | All assessment questions with their options and category weights. |
| `POST /api/assessment/submit` | Body: `{"answers": {"<questionId>": "<optionId>", ...}}`. Returns category scores, top categories, and recommended careers. |
| `POST /api/admin/login` | Body: `{"password": "..."}`. Returns `{"token": "..."}` on success, 401 otherwise. |
| `POST/PUT/DELETE /api/admin/{careers,courses,exams,colleges}[/{slug}]` | Create/update/delete. Requires `Authorization: Bearer <token>`. See "Admin panel". |
| `POST /api/counselling-requests` | Public -- the "Book a counselling call" form. Body: `{name, email, phone, preferredDate?, preferredTime?, stageSlug?, careerSlug?, message?}`. |
| `GET /api/admin/counselling-requests`, `PUT .../{id}/status`, `DELETE .../{id}` | Admin inbox for the above. `status` body: `{"status": "PENDING"\|"CONTACTED"\|"COMPLETED"}`. |

## Admin panel

The frontend has an admin UI at `/admin` (e.g. http://localhost:3000/admin)
for adding, editing and deleting careers, courses, exams and colleges without
hand-writing SQL or Flyway migrations. It does *not* manage categories,
stages, or the assessment questions -- those are small, rarely-changed
reference tables still meant to be edited via a migration if needed.

**Auth**: there's no user-accounts system, by design (see "Scope of this
pass" above) -- just a single shared admin password, checked by
`AdminAuthService` and turned into a signed, 24-hour session token by
`AdminTokenService` (no database table or session store involved; see that
class's javadoc for the mechanics). The frontend stores the token in
`localStorage` and sends it as `Authorization: Bearer <token>` on every
admin write.

**Before using it for anything other than poking around locally**, set a
real password and secret: copy `backend/.env.example` to `backend/.env` and
fill in `CAREERGUIDE_ADMIN_PASSWORD` and `CAREERGUIDE_ADMIN_TOKEN_SECRET`
(`backend/.env` is gitignored; `docker compose` loads it automatically). The
defaults baked into `application.yml`/`docker-compose.yml`
(`admin123` / a fixed placeholder secret) are fine for local development
only -- anyone who can reach the API can read/write your catalog with them.

### Deploying: use the prod profile

This repository is public, so those defaults are not merely weak, they are
*known*. Set `SPRING_PROFILES_ACTIVE=prod` on any instance reachable from
outside your own machine, along with:

| Variable | Notes |
|---|---|
| `CAREERGUIDE_ADMIN_PASSWORD` | Compared by `AdminAuthService`; rate-limited. |
| `CAREERGUIDE_ADMIN_TOKEN_SECRET` | Signs admin sessions. At least 32 chars. |
| `CAREERGUIDE_USER_TOKEN_SECRET` | Signs user sessions. At least 32 chars. |
| `SPRING_DATASOURCE_PASSWORD` | Also picked up by Postgres in `docker-compose.yml`. |
| `CAREERGUIDE_CORS_ALLOWED_ORIGINS` | The real frontend origin; must not be localhost. |

Generate the two signing keys, don't invent them:

```bash
openssl rand -base64 48
```

`application-prod.yml` declares each of these with **no default**, so an unset
variable fails at startup instead of falling back. Two things make that alone
insufficient, and `ProdSecretsCheck` covers both:

- `docker-compose.yml` supplies its own `:-` fallbacks, so the variables are
  always *present* in the container and the placeholders always resolve. The
  check rejects a value that is still one of the published defaults, not just a
  missing one.
- It runs as a `BeanFactoryPostProcessor`, before Flyway opens a connection, so
  a misconfigured deployment is told its secrets are wrong rather than being
  handed a database error first.

**The signing keys matter more than the password.** An admin token is an HMAC
over an expiry timestamp and nothing else, so whoever holds
`CAREERGUIDE_ADMIN_TOKEN_SECRET` mints a valid 24-hour admin session offline --
no login request, so the rate limiter never sees it and rotating the password
changes nothing. `UserTokenService` signs `"<userId>.<expiry>"`, so its key
forges a session for any user. Rotate a leaked key; a leaked password is the
lesser problem.

**Deleting** a career/course/exam/college also removes it from every other
record's related-items list (related courses, exams, stages, etc.) --
that's enforced by `ON DELETE CASCADE` on the join tables in
`V1__schema.sql`, not application code, so it's atomic and can't be
half-applied.

Every DTO's field names mirror the frontend's TypeScript interfaces in
`src/lib/types.ts` field-for-field (e.g. `categorySlug`, `relatedCourseSlugs`,
`salaryRange`), so wiring the frontend onto this API later should be close to
a drop-in swap of its static-data imports.

## Career assessment: adaptive branching

The career assessment (`/assessment` on the frontend, `AssessmentFlow.tsx`)
asks 9 questions rather than showing the same fixed list to everyone. The
first three -- "interest", "strength" and "academics" -- are universal and
always asked in that order. Right after those three, the frontend totals up
the category weights the user has picked so far, maps the leading category
to one of six broad clusters (tech & engineering, science & health,
creative, business, public service, trades & active), and asks that
cluster's dedicated follow-up question next -- so the very next set of
options is actually about the direction the user is leaning toward, instead
of an unrelated generic topic. The remaining five questions ("skills",
"personality", "goals", "salary", "workstyle") follow in their original
order. Going Back and picking a different early answer re-targets the
branch live, since it's recomputed from whatever's currently answered
rather than decided once and cached.

The six cluster questions live in
`V11__assessment_branching_questions.sql`, added as new rows rather than by
editing `V9__seed_assessment.sql` -- Flyway migrations that have already run
against a real database must never be modified after the fact. No
backend/API changes were needed to support this: `GET
/api/assessment/questions` already returns every question with its options
and weights (the frontend needs the weights to decide where to branch), and
`POST /api/assessment/submit` already skips any question id that isn't
present in the submitted answers map, so a user answering 9 of the 14 total
authored questions scores exactly the same way a user answering all of them
would. The category-to-cluster mapping and the branch-selection logic live
entirely in `AssessmentFlow.tsx`.

## Engineering & Technology catalog expansion

Before `V12__engineering_technology_expansion.sql`, the `engineering-technology`
category only had 4 careers (Mechanical, Civil, Electrical, Electronics)
against a much broader industry taxonomy (Chemical & Materials, Aerospace &
Defence, Biotechnology & Biomedical, Energy & Environment, Marine & Ocean,
Mining & Earth Sciences, and the Mechatronics/Robotics corner of Emerging
Tech). The Computing & IT branch of that taxonomy isn't duplicated here --
it's already covered under `it-software` / `emerging-careers` (Software
Engineer, Data Scientist, Cybersecurity Analyst, AI/ML Engineer).

V12 adds one career per genuinely-missing branch -- Chemical Engineer,
Aerospace Engineer, Biomedical Engineer, Environmental Engineer, Marine
Engineer, Mining Engineer, Mechatronics Engineer and Robotics Engineer --
plus the 7 new B.Tech courses and the 1 new exam (IMU-CET, marine
engineering's real entrance route) needed to link them in, following the
existing courses/exams/stages relation pattern. It deliberately does not add
a row per fine-grained specialization named in the source taxonomy (e.g.
VLSI, Quantum, Photonics, AR/VR) -- those are academic sub-specializations,
not distinct job roles, and are already the kind of detail folded into a
career's skills/description rather than split into their own careers
elsewhere in the catalog (see Software Engineer, Electronics Engineer).

As with V11, this is a new migration rather than an edit to
`backend/seed-json/careers.json` / `courses.json` / `exams.json`: those JSON
files are regenerated wholesale into V4/V5/V6 by
`backend/scripts/generate_seed_sql.py`, so content meant to coexist with a
later migration has to be hand-written SQL instead. Four new icons (`pulse`,
`ship`, `pickaxe`, `robot`) were added to `src/components/ui/Icon.tsx` for
the new careers/courses/exam that didn't already have a fitting one to
reuse.

### V13: richer detail for those 8 careers

`V13__engineering_career_details.sql` adds, for those same 8 careers only
(every other career is untouched): a longer, more concrete description (what
the day-to-day work is like and who it suits, not just what the role is), a
short `top_recruiters` list of real companies that commonly hire for the
role, a salary breakdown by experience stage (`salary_entry_level` /
`salary_mid_level` / `salary_senior_level`, alongside the existing single
`salary_range`), and links to real colleges known for that specialization
via a new `career_colleges` junction table -- careers had no direct link to
colleges before this at all (only courses and exams did).

Two colleges are also added (`imu-chennai`, `iit-ism-dhanbad`) because
neither Marine nor Mining Engineering was well represented by the existing
17 curated colleges (all generic IITs/NITs); forcing those two careers onto
an unrelated IIT would have been less accurate than adding the real
institute. `career_colleges` is deliberately unidirectional -- `College` has
no inverse mapping back to `Career` -- since this is a brand new
relationship, not an existing bidirectional one being extended.

`top_recruiters` defaults to `'{}'` and the three salary-stage columns are
nullable, so the other 47 careers keep returning exactly what they did
before (empty list / null), and the frontend (`careers/[slug]/page.tsx`)
only renders the "Salary by Experience", "Top Recruiters" and "Top Colleges"
sections when that data is actually present. The admin create/update API
(`CareerUpsertRequest`) was deliberately NOT extended to cover these fields
-- they can only be set via migration for now, which is fine since editing
an existing career through the admin panel never touches fields it doesn't
know about, so these values survive an admin edit untouched. Wiring them
into the admin form is a reasonable future improvement, not done here.

### V14: fixes a real bug from V12 (sort_order gaps)

`V12__engineering_technology_expansion.sql` linked the 8 new careers back to
the 4 pre-existing exams they use (`gate`, `jee-main`, `jee-advanced`,
`polytechnic-cet`) via new `exam_careers` rows, but gave those rows
`sort_order` values of 100, 101, 102... to "avoid clashing" with the
existing rows instead of continuing their sequence. That's wrong:
`Exam.relatedCareers` is mapped with `@OrderColumn(name = "sort_order")`,
which Hibernate treats as a dense, zero-based `List` index. A gap between
the existing rows (`0..N-1`) and the new ones (`100..107`) makes Hibernate
build a ~100-element list padded with `null`s for every missing index, and
`DtoMapper.toDto(Exam)` throws a `NullPointerException` on the first null it
maps `Career::getSlug` over -- which was exactly the `500` on `GET
/api/exams/gate` (and the other 3 exams, and the `GET /api/exams` list
endpoint, since it builds every exam's DTO in one call).

`V14__fix_exam_careers_sort_order_gaps.sql` renumbers just those 21 rows to
continue each exam's existing sequence instead of jumping to 100, preserving
the same relative order they were inserted in. Every other relation touched
by V12/V13 was checked for the same kind of gap (grouping every
`@OrderColumn`-backed junction table by its owning key) and none had the
problem -- they all belong to brand-new rows (the 8 careers, 7 courses, 2
colleges, 1 exam) whose own list starts fresh at 0, so there was nothing to
collide with. The lesson for any future migration that links new rows back
to an *existing* row on the non-owning side of an `@OrderColumn` relation:
the new `sort_order` values must continue that row's existing max, not pick
an arbitrary offset -- the throwaway Node mock server used for frontend
verification doesn't replicate Hibernate's List-with-gaps failure mode, so
this only surfaces against the real Postgres + Spring Boot stack.

### V15: top recruiters for the other 47 careers

`top_recruiters` (added in V13) was only populated for the 8 engineering
careers. `V15__top_recruiters_for_remaining_careers.sql` fills it in for 46
of the other 47 -- a short list of real organizations that commonly hire for
that role in India, same idea and format as V13's.

`entrepreneur` is deliberately left with `top_recruiters = '{}'`. Every
other career in the catalog is something you get hired for; an entrepreneur
isn't hired by anyone, they found and run their own venture, so "top
recruiters" doesn't have an honest answer for that one -- listing VCs or
accelerators would be answering a different question ("who funds you")
dressed up as this one. For single-track government/PSU/judicial roles
(IAS Officer, Judge, SEBI Grade A Officer, etc.) the list names the actual
organs/bodies a person in that role serves in or is posted to, since there's
no set of competing employers the way there is for a private-sector role --
that's the closest honest equivalent.

### V16: specializations, linked to courses/exams (Aerospace Engineer)

`V16__specializations.sql` adds `specializations` as a new first-class
catalog entity, architecturally the same kind of thing as courses/exams/
colleges: it has its own table (slug, name, description, icon) and its own
junction tables (`career_specializations`, `specialization_courses`,
`specialization_exams`) rather than being a plain string list on `careers`.

That distinction is deliberate. `top_recruiters` and `skills` are plain
`text[]` columns because there's nothing in the catalog for "Google India" or
"CAD (CATIA)" to link to -- they're just labels. A specialization is
different: "Propulsion" or "Avionics" is a real sub-discipline that maps to
specific existing courses and exams, so making it a flat tag would throw away
a real relation the same way career_courses/career_exams already avoid doing
for careers themselves. Specializations get the same "does it actually
connect to something" treatment.

For now this is only populated for Aerospace Engineer, per the request that
prompted it -- 5 specializations (Aerodynamics, Propulsion, Avionics,
Aerospace Structures, Space Systems), each linked to whichever of
`btech-aerospace` / `btech-ece` / `jee-main` / `jee-advanced` / `gate` /
`isro-icrb` genuinely covers it (e.g. Avionics also links to the ECE course,
and Propulsion/Space Systems link to ISRO's own ICRB exam rather than the
generic engineering entrances). Every other career has zero specializations
and the frontend simply omits the section when the list is empty, the same
pattern as `relatedCollegeSlugs` in V13.

`career_specializations` is unidirectional like `career_colleges` (no
inverse mapping from Specialization back to Career) since this is a brand
new relation, not one with an existing reverse side to keep in sync. While
writing this migration, the "connect Aerospace Engineer to ISRO's ICRB exam"
insert was checked against `isro-icrb`'s *existing* `exam_careers`/
`exam_courses` rows first (learned from the V14 postmortem above) and found
a real collision -- `isro-icrb` already had rows at index 0 and 0-3
respectively -- so those inserts continue at index 1 and 4 instead of
colliding. The full migration was verified with the same sort_order gap-check
query used for V14/V15, on both the live database and a from-scratch
V1-to-latest run, with zero gaps in either.

As with College, there is no admin create/update/delete wiring for
Specialization yet -- `SpecializationService` is read-only (`findAll` /
`findBySlug`), matching the precedent set by Stage rather than College's
full CRUD. Adding admin support is a reasonable future improvement, not done
here.

### V17: specializations for every other career

V16 deliberately scoped specializations to Aerospace Engineer only, since
that's what was asked for at the time. `V17__specializations_for_all_careers.sql`
extends the same treatment to the other 54 careers, adding 142 more
specializations (147 total) so every career in the catalog now has some.

No entity/DTO/service/controller changes were needed for this one -- V16
built `Specialization` as a generic, career-agnostic relation from the
start (the same way `career_colleges` isn't special-cased to one career), so
extending it to the rest of the catalog is a pure data migration.

The same "linked to real courses/exams, not a plain tag" bar from V16
applies here too. Every specialization links to a course and/or exam that's
already in the catalog -- mostly the same ones already on that career via
`career_courses`/`career_exams`, occasionally one more clearly relevant
catalog entry (the same pattern V16 used for Avionics -> the ECE course).
Seven careers with no standardized entrance exam of their own in the catalog
today (School Principal, Entrepreneur, Digital Marketing Manager,
Sustainability Consultant, Electrician, Plumber, Fitness Trainer) have
specializations linked to courses only -- that's an honest reflection of a
gap already in the exam catalog, not something papered over here.

Every `career_specializations`/`specialization_courses`/`specialization_exams`
row this migration adds belongs to a brand-new group (a career that had zero
specializations before, or a specialization slug that didn't exist before),
so every sort_order sequence starts fresh at 0 -- there's no V14-style gap
risk here, and the migration was still run through the same gap-check query
as every migration since V14, on both the live database and a from-scratch
V1-to-latest run, with zero gaps in either.

### V18: IT & Software careers moved into Engineering & Technology

`V18__move_it_software_into_engineering_technology.sql` re-categorizes all 4
"IT & Software" careers (Data Scientist, Software Engineer, Cybersecurity
Analyst, Cloud Architect) into "Engineering & Technology", per request. The
`it-software` category row is deliberately left in the `categories` table
rather than deleted -- it now just has zero careers -- since removing a
whole taxonomy category is a bigger, less reversible decision than moving
careers out of it, and wasn't what was asked for.

`sort_order` on `careers` is "index of this career within its category"
(read by `CareerService.nextSortOrder` and `AssessmentService`'s
per-category recommendation ordering), not an `@OrderColumn`-mapped list
index -- so unlike V14, a gap here can't crash anything. The 4 moved careers
still got fresh values continuing `engineering-technology`'s existing 0..11
sequence (12..15) rather than colliding with it, preserving their original
relative order.

This also touches the assessment quiz, which was easy to miss: quiz answers
carry weights against category slugs (`assessment_option_weights`), and
`AssessmentService.getRecommendedCareers` pools recommended careers straight
from whichever categories scored highest. With `it-software` now empty,
leaving its 7 weight rows pointed at it would let "IT & Software" surface as
someone's top-scoring category with literally nothing to recommend inside
it -- a visible dead end. This migration renames those rows' `category_slug`
to `engineering-technology` instead (checked first that no `option_id` had
weights in both categories already, so this is a plain rename, not a
merge-and-sum). `AssessmentFlow.tsx`'s `CATEGORY_TO_CLUSTER` map had its now
dead `"it-software": "cluster-tech"` entry removed for the same reason --
that key can no longer appear in a computed score.

### V19: a shared "Computer Science & Engineering" specialization (superseded by V20)

`V19__computer_science_engineering_specialization.sql` added a
specialization -- "Computer Science & Engineering" -- shared by all 4 IT &
Software careers (Data Scientist, Software Engineer, Cybersecurity Analyst,
Cloud Architect). It turned out that wasn't the right shape: CS&E was meant
to be an engineering branch in its own right, not a sub-topic tucked inside
other careers. **V20 deletes this specialization and everything it
linked.** V19 itself is left as-is (already-applied migrations are never
edited, see the standing rule above) -- its net effect after V20 is zero,
but the file stays as a record of what was tried. See V20 below for what
replaced it.

### V20: Computer Science Engineer becomes its own career

`V20__computer_science_engineer_career.sql` does two things. First, it
undoes V19 (`DELETE FROM specializations WHERE slug =
'computer-science-engineering'`, which cascades to every row that pointed
at it). Second, it adds "Computer Science Engineer" as a new, full career
under Engineering & Technology -- on par with Mechanical Engineer, Civil
Engineer, Aerospace Engineer and the rest, the same way B.Tech CSE is one of
the standard engineering branches alongside B.Tech Mechanical, B.Tech Civil,
and so on.

Data Scientist, Software Engineer, Cybersecurity Analyst and Cloud Architect
are untouched by this migration -- they stay exactly as they were, full
careers with their own salary ranges, growth paths and top recruiters. An
earlier option (folding them into Computer Science Engineer as
specializations) was considered and explicitly rejected: Specialization has
no salary/growth-path/recruiters fields the way Career does, so that would
have silently discarded already-authored content for no real gain.

Mechanically this is a normal "add one new career" migration, following the
same reverse-relation lesson as V14/V16 onward: `career_courses`/
`career_exams`/`career_stages`/`career_colleges` are all fresh
`career_slug`-grouped lists (start at 0), but the *other* side of each
relation -- `course_careers`, `exam_careers`, `stage_careers` -- is grouped
by `course_slug`/`exam_slug`/`stage_slug` instead, so each of those rows
continues that course/exam/stage's own existing max `sort_order` (checked
first) rather than colliding with it.

### V21: IT & Software careers moved back out of Engineering & Technology

`V21__move_it_software_back_from_engineering_technology.sql` reverses V18
for exactly the 4 careers it originally moved: Data Scientist, Software
Engineer, Cybersecurity Analyst and Cloud Architect go back to being
categorized under `it-software`, per request. Since `it-software` was left
empty (not deleted) by V18, these get a fresh `sort_order` 0..3, preserving
their original relative order with no collision risk.

**Computer Science Engineer (V20) is explicitly out of scope and untouched**
-- it was added after V18/V19 as a new, independent career, not one of the
4 originally moved, so it stays under Engineering & Technology.

This also symmetrically reverses the assessment-quiz side of V18: the same
7 `assessment_option_weights` rows (option_ids 33, 35, 23, 25, 13, 5, 29)
that V18 moved from `it-software` to `engineering-technology` (to avoid
`it-software` surfacing as a scoring category with nothing to recommend)
are moved back to `it-software` now that the category has its careers
again. Checked first that none of these option_ids already had an
`it-software` row, so this is a plain rename, not a merge. Leaving these
weights on `engineering-technology` after this migration would have
reintroduced the same kind of imbalance V18 fixed, just pointed the other
way. `AssessmentFlow.tsx`'s `CATEGORY_TO_CLUSTER` map has its
`"it-software": "cluster-tech"` entry restored to match -- that key is live
again now that `it-software` can be a real top-scoring category.

### V22: Specializations for Computer Science Engineer

`V22__computer_science_engineer_specializations.sql` gives Computer Science
Engineer (V20) its own specializations, the same way V17 gave every other
career 2-3 of its own: Data Structures & Algorithms, Systems Programming &
Operating Systems, and Database Systems & Engineering. All 3 are brand new
specialization slugs, chosen to match the career's own stated foundations
("algorithms, operating systems, databases and networks") minus the 4
already-separate careers (Software Engineer, Data Scientist, Cybersecurity
Analyst, Cloud Architect) a CSE graduate might branch into later --
pointing at those directly wouldn't fit the Specialization model (a
specialization is a sub-topic of one career, not a link to a sibling career
with its own salary/growth-path/recruiters), which is the same reasoning
V20 used to reject folding those 4 careers into CS&E as specializations.

Mechanically this is a plain "add specializations" migration like V17:
`career_specializations` (grouped by `career_slug`) was empty for
`computer-science-engineer`, so its 3 rows start fresh at 0..2, and
`specialization_courses`/`specialization_exams` (grouped by
`specialization_slug`) are brand-new groups for all 3 new slugs, so they
start fresh at 0 too -- no gap risk either way.

### V23-V25: the Data Model Roadmap's Phases 1-3 (branches, skills, industries)

> **Branch was removed in V116.** The rest of this section is kept as the
> record of what V23 did, but `branches` and `careers.branch_slug` no longer
> exist. The 13 careers V23 assigned a branch to were all later deleted and
> re-created under different slugs (`mechanical-engineer` ->
> `mechanical-engineering`); the assignments were never redone, so by V116 the
> table had 12 rows and no career referenced any of them. Category (coarse)
> and Specialization (fine) cover the grouping between them, and Branch had no
> admin form field, so it could only ever be populated by hand-written SQL.
> See V116's migration header.

These three migrations implement the additive first slice of a much larger
proposal for reshaping the catalog (taxonomy, entities, relationships,
Career vs. Job Role, hierarchical courses, and so on) -- see the "Data
Model Roadmap" doc for the full ten-point plan and phase-by-phase risk
review. Only the phases marked safe to start immediately are here; the
Career vs. Job Role rename is deliberately not part of this batch, since it
touches every career already built and needs its own confirmation first.

**V23** (`engineering_branches` -> `branches` table) inserts a grouping
layer between category and career, exactly as scoped in the earlier
Taxonomy Blueprint artifact: a new `branches` table (`slug`, `name`,
`icon`, `category_slug`, `sort_order`) and a nullable `careers.branch_slug`
FK. `categories`/`careers.category_slug` are completely untouched, so
nothing that already reads them (assessment scoring, category counts)
changes. Only Engineering & Technology's 12 branches are seeded -- the only
category the Taxonomy Blueprint actually designed -- and only the 13
careers currently in that category are backfilled with a `branch_slug`.
Computing & IT deliberately does **not** include Software Engineer, Data
Scientist, Cybersecurity Analyst or Cloud Architect, even though the
original taxonomy sketch listed them there: those 4 are in the
`it-software` category (V21), not `engineering-technology`, and a career's
branch should stay inside its own category. That cross-category question
(should Computing & IT pull them in anyway?) is left open rather than
guessed at. `ai-ml-engineer` is excluded for the same reason -- it's in
`emerging-careers`.

**V24** (`skills` table) and **V25** (`industries` table) both turn a
`careers` text array (`skills`, `top_recruiters` respectively) into a real
entity plus a junction table, so "which careers need Python" or "which
careers hire at TCS" becomes a join instead of a text scan. Both are
deliberately **unidirectional with no `sort_order`/`@OrderColumn`** --
unlike every junction table before them (`career_courses`,
`career_exams`, and so on): a skill's or recruiter's position in a
career's array was never curated data, just seed order, so there was
nothing worth a dense per-group index for, and skipping `@OrderColumn`
here avoids the exact bookkeeping cost the Scaling Read & Write Paths
review flagged as this project's real scaling friction. `Skill`/`Industry`
are also deliberately minimal -- `slug` + `name` only, not the
`description`/`icon` shape `Specialization` uses, since the source data has
no description to backfill and inventing one per row would be fabricated
content.

Both backfills were checked for lossy collisions before writing the
migration: slugifying and deduping `careers.skills` collapses 221 mentions
into 197 distinct skills with zero different-name collisions on the same
slug; `top_recruiters` collapses 263 mentions into 191 industries, same
check, same result. `careers.skills`/`top_recruiters` themselves are left
in place rather than dropped -- nothing reads `career_skills`/
`career_industries` yet, keeping both migrations purely additive.

`GET /branches` (optionally `?category=`), `GET /skills` and
`GET /industries` mirror the existing `/specializations` controller shape;
`CareerDto` gains `branchSlug`, `relatedSkillSlugs` and
`relatedIndustrySlugs`, following the existing `relatedXSlugs` pattern
(`GET /branches` and `CareerDto.branchSlug` were both removed in V116)
(the javadoc on `CareerDto` notes that the skill/industry lists, unlike
every other `relatedXSlugs` field, carry no meaningful order).

### Phase 4: Career vs. Job Role, via routing rather than a rename

The original proposal called for independent `Career` and `JobRole`
entities -- "Career: broad professional direction, Job Role: specific
role within that career" -- as two of several independent entities, not
one entity reused for both. Taken at face value that means real,
separate tables. But V23's `branches` table, floated earlier as the
`Career` (broad-direction) table under the rename, only covers 13 of 56
careers -- Engineering & Technology is the only category with a curated
sub-taxonomy. Reusing it as-is would mean 43 careers have no `Career`
parent at all.

`categories` already is that broad-direction layer, and already has 100%
coverage:

```
 total_careers | with_branch | without_branch
----------------+-------------+----------------
             56 |          13 |             43

 total_careers | with_category
----------------+---------------
             56 |            56
```

So no new table, migration, or invented taxonomy was needed to close the
gap -- `categories` already models "broad professional direction" for
every career, and `branches` already models the finer subdivision for the
one category that has curated sub-branches. What Phase 4 actually needed
was the vocabulary, not new schema.

That's implemented as pure routing, not a rename: `CategoryController` now
answers on both `/api/categories` (unchanged) and `/api/career-directions`
(new -- this is "Career" in the roadmap's vocabulary); `CareerController`
now answers on both `/api/careers` (unchanged) and `/api/job-roles` (new --
this is "Job Role"). Same controllers, same services, same entities, same
DTOs, same data -- `@RequestMapping({"...", "..."})` takes an array, so
both paths resolve to the identical methods. Nothing existing changes
shape or breaks.

Deliberately **not** done here, and left for separate confirmation before
touching it:

- Renaming the `Career` Java class/`careers` table/`CareerDto` themselves,
  or dropping the legacy `/api/careers`/`/api/categories` paths -- that
  touches the admin panel, every career-reading query, and the Next.js
  frontend's routes and `types.ts` in one shot, on an entity with 56 live
  rows, in a sandbox that can't run `mvn compile` to catch a mistake.
- Building out curated branches for the other 11 categories -- doing that
  well needs the same kind of source taxonomy the user supplied for
  Engineering & Technology, not invented groupings.

Both remain straightforward follow-ups once wanted; the vocabulary and the
data-coverage question are no longer blockers for either.

> **Superseded by V26 (see below).** Two uploaded spec documents ("Content &
> Data Architecture" and "ER & Data Model") were matched against this
> codebase after Phase 4 shipped, and both independently confirmed that the
> existing `careers` table already sits at the specs' own "Career" grain
> (their own example lists -- Software Engineering, Data Science, Cybersecurity,
> etc. -- are broad fields, not the specific titles already seeded here).
> That means the `/api/job-roles` alias on `CareerController` was answering
> with the wrong data (Career rows pretending to be Job Role rows), and
> `/api/career-directions` on `CategoryController` was occupying a name the
> specs use for something else. Both aliases have been retired
> (`CareerController`/`CategoryController` are back to their single original
> `@RequestMapping`); `/api/job-roles` is now owned by a real
> `JobRoleController` backed by an independent `job_roles` table. The
> vocabulary lesson from Phase 4 (`categories` = broad direction) still
> holds; only the job-role routing decision was wrong and has been corrected.

## Job Role, Certification, Resource, Stream, and the User Data Model (V26-V32)

Two documents were uploaded and matched against this codebase in sequence --
"CareerGuide -- Content & Data Architecture" and "CareerGuide -- ER & Data
Model" -- producing two gap-analysis tabs in the Data Model Roadmap doc
before any code was written. This section is what came out of implementing
those findings: seven new additive migrations (V26-V32) and their backing
Java code. Nothing existing was renamed, dropped, or reinterpreted --
every table here is new, and `careers`/`categories`/`courses`/etc. are
untouched.

**V26 (`job_roles`)** adds the independent entity both spec documents
describe alongside Career, related to it via a many-to-many junction
(`career_job_roles`) rather than a simple FK, since a job role can in
principle span more than one career even though the seed data here only
ever links one. `JobRole` is deliberately thin -- `slug`/`name`/
`description`/`experience_level`/`salary_min`/`salary_max`, matching the ER
doc's own column list -- plus `job_role_skills`/`job_role_industries`
junctions mirroring Career's existing ones. Only 7 job roles are seeded
(backend/frontend/full-stack developer, DevOps engineer, cloud engineer,
software architect, engineering manager), all linked to
`software-engineer`, because that's the only career either uploaded
document gives concrete job-role examples for -- inventing job roles for
the other 55 careers would be fabricated content, the same discipline V24/
V25 followed for skills/industries.

**V27 (`certifications`)**, **V28 (`resources`)**, and **V29 (`streams`)**
follow the same shape: a new catalog table plus junctions to whichever
existing entities the spec ties it to (Career and Skill for
certifications; Career, Course, Exam, and Skill for resources; Stage for
streams). Certifications and resources ship with **no seed rows** --
neither document gives concrete certification or resource examples to
backfill from, only the schema shape, so the tables exist and the API
answers `[]` rather than 404 until real content is added. Streams *does*
seed the 4 canonical after-12th streams (Science, Commerce, Arts &
Humanities, Vocational) linked to the `after-12th` stage, since both
documents use exactly these as their running example.

**V30-V32: the User Data Model.** Both spec-match tabs flagged this as the
single largest gap: a 0%-built pillar covering accounts, profiles, saved
items, and personalization. Before V30 the only authentication anywhere in
this codebase was `AdminAuthService`'s single shared admin password, and
"saved items" meant `src/lib/savedItems.ts` -- browser localStorage only,
covering courses and colleges but not careers or exams, gone the moment a
visitor clears their browser or switches devices.

- **V30** adds `users` (`BIGSERIAL` id -- this is a user-generated table,
  not a catalog one, so it follows the `counselling_requests`/
  `assessment_options` id convention rather than the catalog tables' slug
  convention), `user_profiles` (one-to-one, FK to `stages` and the new
  `streams`), `user_interests` (plain text, not a lookup table -- the ER
  doc's `user_interests.interest_id` implies a dedicated interests
  reference table, but neither document actually defines one, only an
  example list; inventing that table would be guessing at a shape the spec
  never gave), and `user_skills` (a user's self-reported skills, distinct
  from `career_skills`/`job_role_skills` which describe a role, not a
  person).
- **V31** adds `user_saved_careers`/`courses`/`colleges`/`exams` -- the
  server-backed replacement for `savedItems.ts`, extended to cover careers
  and exams which localStorage never did.
- **V32** adds `user_assessments`, `user_recommendations`, `user_roadmaps`,
  `user_roadmap_steps`, and `user_progress` -- **schema only, nothing reads
  or writes them yet**. `POST /api/assessment/submit` still computes and
  returns a result per-request without persisting it, exactly as before;
  persisting a result, generating recommendations from it, and building a
  real per-user roadmap all need their own scoring/generation design, which
  is a separate, larger piece of work than adding the tables it will
  eventually write to. `user_progress`'s shape is inferred (the ER doc
  names the table but never shows its columns in either upload) to match
  `user_recommendations`'s pattern, not copied from an explicit spec.

**No new Maven dependency.** The sandbox this was built in has no network
access to Maven Central (see "How this was built and verified" below), so a
real dependency add -- Spring Security, a bcrypt library, a JWT library --
couldn't even be verified here. Passwords are hashed with
`PBKDF2WithHmacSHA256` (`UserPasswordService`, 210,000 iterations, a
standard `javax.crypto` algorithm already in the JDK) rather than bcrypt,
and sessions are stateless HMAC-SHA256-signed tokens (`UserTokenService`,
`<base64url userId.expiry>.<base64url signature>`) mirroring
`AdminTokenService`'s existing pattern rather than pulling in JWT -- the
only difference from the admin token is that a user token carries a user
id, since (unlike the single shared admin account) there's more than one
user to distinguish.

**API surface:**

- `POST /api/auth/register`, `POST /api/auth/login` -- unauthenticated,
  same as `/api/admin/login`. Return `{ token, user }`.
- `GET /api/me`, `GET/PUT /api/me/profile`, `PUT /api/me/interests`,
  `GET/PUT/DELETE /api/me/skills[/{skillSlug}]` -- everything under
  `/api/me/**` is guarded by the new `UserAuthInterceptor`
  (`UserWebConfig`), which mirrors `AdminAuthInterceptor` but additionally
  resolves *which* user is calling (via `UserTokenService.resolveUserId`)
  and stashes their id as a request attribute, so a controller can never
  act on a different user's data by editing a URL.
- `GET/POST/DELETE /api/me/saved/{careers,courses,colleges,exams}[/{slug}]`
  -- also under `/api/me/**`, so it's covered by the same interceptor. GET
  returns full DTOs (`CareerDto`, not just a slug), so a saved-items page
  doesn't need a second round trip per item.
- `GET /api/job-roles[?career=]`, `/api/job-roles/{slug}`,
  `GET /api/certifications[/{slug}]`, `GET /api/resources[/{slug}]`,
  `GET /api/streams[/{slug}]` -- unauthenticated read-only, same shape as
  every other catalog controller (`SkillController`, `IndustryController`).

**Deliberately out of scope for this pass:** the actual recommendation
scoring, roadmap-step generation, and progress-tracking business logic.
V32's tables exist so that work isn't blocked on a schema change later, but
building the algorithms that populate them is a separate design task,
flagged as such in both the "Spec v1.0 Match" and "ER Data Model Match"
tabs before this migration batch was written. Wiring the frontend's
`savedItems.ts` and `/profile` page onto the new `/api/me/**` endpoints
(instead of localStorage) is likewise a follow-up, not done here.

## Reconciling two more uploaded documents: additive gap-fill, not a PK rewrite (V33-V38)

Two more documents were uploaded: "CareerGuide -- PostgreSQL Database
Schema" (a from-scratch, 32-page schema spec) and "CareerGuide -- Sample
Master Data & Seed SQL" (31 pages of concrete rows for that schema), with
the instruction to "use both file in restructure." Reading both in full
surfaced a real conflict worth stating plainly: the schema doc specifies
`id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` plus a separate unique
`slug` column on every table, whereas this codebase's live, 32-migration
schema (V1 onward) uses the slug itself as the `VARCHAR` primary key
everywhere. Those are two different foreign-key wiring schemes across every
catalog table and roughly 25 junction tables, all of it already carrying
real seeded content and around 100 Java files built against the slug-PK
shape.

**What this pass does instead, and why:** rather than a literal full
rewrite of the PK strategy -- unverifiable end-to-end in this sandbox (no
compiler, no Maven Central access; see "How this was built and verified")
and destructive to redo across data that already exists -- this pass reads
both documents strictly for their genuinely new *content*, cross-checks
every candidate against the live database via direct `psql` queries, and
adds only what doesn't already exist under a different (existing) slug. The
slug-PK architecture is preserved throughout; V33-V38 are additive
migrations in exactly the same style as every migration before them.

This matters because it's easy to get wrong in the other direction: every
single "career" named in the seed doc turns out to already exist here under
a more specific, existing slug (its "Cybersecurity" is this codebase's
`cybersecurity-analyst`, its "Medicine" is `doctor-mbbs`, its "Digital
Marketing" is `digital-marketing-manager`, and so on for all of them) --
verified name-by-name against the live `careers` table, not assumed. Blindly
inserting the seed doc's rows would have silently duplicated most of the
catalog under near-duplicate slugs. Zero new career rows come out of this
pass as a result.

What *is* genuinely new (confirmed missing from the live database before
writing each migration):

- **V33 (`course_types`)** -- a finer, named degree-type lookup (B.Tech,
  B.E., BCA, B.Sc, MCA, M.Tech, MBA, Diploma, Certificate, PhD) layered on
  top of the existing `courses.level` column (which only buckets into 6
  coarse groups) via a new nullable `courses.course_type_slug` FK.
  Backfilled only where a course's name unambiguously names one of these 10
  types (`B.Tech %` -> `b-tech`, `MBA %` -> `mba`, exact slug matches for
  the MCA/PhD/diploma-prefixed courses, `level = 'Certification'` ->
  `certificate`) -- 36 of the 57 existing courses matched, the other 21
  (BDS, MBBS, the law/arts/design/nursing degrees, ITI trades, the
  bootcamp, B.Ed, and the non-CS M.A./M.Sc postgrads) are left `NULL`
  rather than guessed at, same discipline as every prior backfill in this
  project.
- **V34 (`skills.skill_type`)** -- adds a nullable classification column
  plus 8 new skill rows confirmed missing from the existing 197 (`java`,
  `javascript`, `react`, `spring-boot`, `aws`, `docker`, `kafka`,
  `cybersecurity`), and backfills `skill_type` on the 8 pre-existing skills
  the seed doc also names (`python`, `sql`, `git`, `data-analysis`,
  `machine-learning`, `communication`, `leadership`, `problem-solving`).
  The other 189 pre-existing skills are left `NULL`.
- **V35 (`industries.is_sector`)** -- adds a boolean plus 10 new
  industry-*sector* rows (Information Technology, SaaS, Fintech,
  E-Commerce, Banking, Healthcare, Automotive, Telecommunications,
  Education, Government). `Industry.java` already self-documented this
  exact gap before this pass ("'industry' here doubles as 'known
  employer' -- there was no independent industry taxonomy in the source
  data"); the 191 existing rows are all company names (Accenture, Amazon,
  Bosch, Canara Bank, ...) and stay `is_sector = false`.
- **V36 (`security-engineer` job role)** -- the one job role from the seed
  doc confirmed missing from the existing 7, linked to the existing
  `cybersecurity-analyst` career (there's no separate "Security" career)
  and the new `cybersecurity` skill.
- **V37 (`nit-patna` college)** -- the one college confirmed missing from
  the existing 19, matching the `nit-trichy`/`nit-warangal`/`iit-delhi`
  row shape exactly (`type = 'NIT'`, one-sentence description,
  `tags = {Engineering}`). `established = 2004` is NIT Patna's real,
  publicly documented founding year, not an invented value.
- **V38 (`course_colleges`, `exam_colleges`)** -- the two reverse-direction
  junction tables confirmed missing via `information_schema.tables`
  (`college_courses`/`college_exams` already existed, but not their
  inverse), mirroring this project's own established convention of storing
  every many-to-many relationship in both directions (already used for
  `career_courses`/`course_careers`, `career_exams`/`exam_careers`, etc).
  Both are backfilled from the existing `college_courses`/`college_exams`
  rows, so no relationship is invented -- only mirrored.

**Java layer:** a new minimal `CourseType` entity/DTO/repository/service/
controller (`GET /api/course-types[/{slug}]`), matching `Skill`/
`Industry`'s existing shape exactly. `Course` gains a `courseType`
`@ManyToOne` and a `relatedColleges` `@ManyToMany` (the V38 reverse
junction); `Exam` gains a matching `relatedColleges`; `Skill` gains
`skillType`; `Industry` gains `isSector`. `CourseDto` gains
`courseTypeSlug`/`collegeSlugs`, `ExamDto` gains `collegeSlugs`, `SkillDto`
gains `skillType`, `IndustryDto` gains `isSector` -- all additive fields
appended at the end of each record, so no existing field position shifts.

**Verified:** all six migrations applied cleanly against the live database
in order, then the entire chain was re-run from scratch (`V1` through
`V38` against a throwaway database) to confirm order-independence -- the
from-scratch counts matched the incrementally-applied live database
exactly on every changed table (205 skills, 201 industries, 8 job roles,
20 colleges, 10 course types, 42 `course_colleges` / 20 `exam_colleges`
rows, 36 courses with a non-null `course_type_slug`).

**Disclosed plainly:** "restructure" was not implemented as the literal
BIGINT-identity-PK rewrite the schema document specifies. That conversion
remains undone. What's here is a targeted, verified, additive gap-fill of
the two documents' genuinely new content, on top of the existing
architecture -- the judgment call made was that a full PK rewrite, done
without a compiler and against a database with real seeded content, was
too high-risk to perform unverified, whereas this pass could be checked
end-to-end at every step.

## Counselling requests

A "Book a Counselling Call" feature lets visitors ask a real person to reach
out, instead of (or alongside) using the assessment/browsing flow. It's
deliberately simple: no user accounts, no scheduling system, no email
integration -- just a form that lands in a submissions inbox, plus WhatsApp
as the actual conversation channel once contact is made.

**Public side** (`/counselling`, and every career page's "Book a Counselling
Call" button, which pre-fills the career): a form collecting name, email,
phone, an optional preferred date/time, an optional "current stage", and an
optional free-text message. Submitting it hits `POST
/api/counselling-requests` (no auth -- see "API overview" above) and stores a
row via `CounsellingRequestService.submit(...)`; there's no confirmation
email, just an on-page "Request received!" message telling them you'll reach
out on the phone number they gave.

Next to the form is an optional **"Chat with us on WhatsApp" button** that
lets a visitor skip the form entirely and message your business WhatsApp
number directly, using a plain `wa.me` "click-to-chat" link (see
`src/lib/whatsapp.ts`) -- no WhatsApp Business API, Meta approval, or paid
integration involved, just a link that opens WhatsApp with your number and a
pre-filled message (mentioning the specific career, when there is one).
That button only appears if you've set your number: put it in the
frontend's environment as

```
NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER=+91XXXXXXXXXX
```

If it's left unset, the button simply doesn't render (the panel falls back
to "The form on the left is the best way to reach us right now.") -- there's
no error either way. **This is a `NEXT_PUBLIC_*` variable, so Next.js bakes
it into the JavaScript bundle at *build* time, not read at server startup**:
after setting or changing it, you need to rebuild the frontend
(`npm run build`, or rebuild its Docker image) for the new value to take
effect, not just restart it.

**Admin side** (`/admin/counselling-requests`, linked from the admin nav and
dashboard): an inbox listing every submission newest-first, each showing all
the fields the visitor submitted, a status badge, and two actions:

- A **"Message on WhatsApp" link that works immediately with zero
  configuration**, since it's built from the *requester's own phone number*
  (also a `wa.me` click-to-chat link) -- unlike the public button above,
  this doesn't depend on `NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER` at all.
- A status dropdown to move the request through its lifecycle: `PENDING` →
  `CONTACTED` → `COMPLETED`. This is enforced twice -- once in
  `CounsellingRequestService.updateStatus(...)` (rejects anything outside
  that set with a 400) and once at the database level via a `CHECK`
  constraint on `counselling_requests.status` (`V10__counselling_requests.sql`)
  -- so a bad value can't get written even by a future bug that bypasses the
  service layer.

There's also a **Delete** button (with a confirmation prompt) for removing a
submission once it's been handled.

Like the rest of the admin API, `/api/admin/counselling-requests` sits under
the `/api/admin/**` prefix, so it's automatically covered by the existing
`AdminAuthInterceptor` -- no separate auth wiring was needed for it.

## Post-launch backend audit fixes

A full backend audit (architecture, entities, repositories, services, DTOs,
controllers, exception handling, validation, indexes, pagination, and
security) was run against the already-implemented API described above. Most
of it held up; six real issues were found and fixed, in this order:

1. **Bidirectional relationship drift (the most serious finding).**
   `career_courses`/`course_careers`, `career_exams`/`exam_careers`, and
   `course_exams`/`exam_courses` are each two independently-writable
   directions of the same relationship (see "Junction tables are directional,
   not deduplicated" below for why they're two tables at all). The bug: only
   ever the *owning* side was written. Editing a career's related courses via
   `PUT /api/admin/careers/{slug}` updated `career_courses` but left every
   affected course's own `course_careers` silently stale — a course's
   "related careers" list (as seen from `CourseService`/`CourseController`)
   would drift from what the careers admin panel actually showed. Fixed by
   having `CareerService`/`CourseService`/`ExamService` each diff the
   old-vs-new related list on create/update and push the corresponding
   add/remove onto the *other* entity's reverse collection inside the same
   transaction (`syncRelatedCourses`/`syncRelatedExams`/`syncRelatedCareers`
   in each service). This relies on JPA's persistence-context identity
   guarantee (the same DB row is always the same Java reference within one
   `@Transactional` method), so plain `List.contains`/`remove`/`add` correctly
   means "the same row" — no `equals()`/`hashCode()` override was added to
   any entity for this.
2. **No catch-all exception handler.** Before this, an unexpected exception
   (a bug, a null somewhere) fell through to Spring Boot's default `/error`
   handling, which returns a differently-shaped JSON body than this API's own
   `ApiError`. `GlobalExceptionHandler` now has an `Exception.class` fallback
   (500, generic message, full exception logged server-side — never
   `ex.getMessage()` in the response body) plus two handlers added
   specifically so that fallback doesn't *break* existing behavior:
   `HttpRequestMethodNotSupportedException` (wrong HTTP method → 405, not
   500) and `HttpMessageNotReadableException` (malformed JSON body → 400, not
   500) — both would otherwise have been intercepted by the new catch-all
   before Spring MVC's own defaults got to handle them. A
   `DataIntegrityViolationException` handler (409) was also added for the
   race-condition case where two concurrent admin writes both pass an
   `existsById` check before either commits.
3. **Unbounded catalog list endpoints.** `GET /api/careers` /
   `/api/courses` / `/api/exams` / `/api/colleges` always returned every
   matching row with no way to page through them, and each repository's
   `search(...)` returned a plain `List`. Since the Next.js frontend's
   `src/data/*.ts` already calls these expecting a bare JSON array (not an
   envelope), the fix had to be backward-compatible rather than a breaking
   `Page<T>` response: each repository's `search` now takes a `Pageable` and
   returns `Page<T>` (with an explicit `countQuery`, not auto-derived); each
   controller accepts optional `page`/`size` query params
   (`PaginationSupport.resolve`, defaulting to `Pageable.unpaged()` — i.e.
   today's exact behavior — when neither is given) and returns the total
   matching row count in an `X-Total-Count` response header, with the
   response body staying a plain array either way.
4. **`UpdateProfileRequest` had no validation**, unlike every other
   admin/auth request DTO. Added `@Size(max = 64)` on `educationLevel`,
   `@Min(1950)/@Max(2100)` on `graduationYear`, `@Min(0)/@Max(60)` on
   `experienceYears`, and `@Size(max = 160)` on `location`, plus `@Valid` on
   `MeController.updateProfile`'s request body.
   `educationStageSlug`/`streamSlug` were deliberately left without format
   validation here, since `UserService` already resolves each against its
   repository and throws a 404 for an unknown slug — the same de facto FK
   check the admin upsert endpoints rely on.
5. **No rate limiting on the three unauthenticated credential endpoints**
   (`POST /api/auth/login`, `/api/auth/register`, `/api/admin/login`) — an
   attacker could otherwise brute-force the single shared admin password, or
   a consumer account's password, or spam account creation, without limit.
   `AuthRateLimiter` is a simple in-memory, per-key (caller IP + path)
   fixed-window counter (`ConcurrentHashMap`, no new dependency — no
   Bucket4j/Redis) — deliberately the simplest thing that stops a naive
   script, not a distributed rate limiter; it needs a shared store to work
   correctly behind more than one backend instance. Default: 10 attempts per
   15 minutes per IP per endpoint (`careerguide.rate-limit.auth.*` in
   `application.yml`), returning 429 with a `Retry-After` header once
   exceeded. `AuthRateLimitInterceptor`/`AuthRateLimitWebConfig` apply it to
   exactly those three paths — every other endpoint is either already behind
   a bearer token or a public read with no attempt-limited resource behind
   it.
6. **No tests existed anywhere in the backend.** Added
   `src/test/java/.../service/CareerServiceTest.java` (pure Mockito unit
   tests: sort-order assignment on create, unknown-slug/unknown-category
   error handling, and a dedicated regression test for the bidirectional
   sync fix in #1 above) and `.../controller/CareerControllerTest.java` /
   `AdminCareerControllerTest.java` (`@WebMvcTest` slices covering
   list/filter/search/get-by-slug/404 on the public side and
   create/duplicate/update/delete/validation on the admin side). These are a
   starting point for the `CareerController`/`CareerService` module, not
   full coverage of the API.

None of the above needed a new Maven dependency, a new migration, or a
change to the package structure — see "How this was built and verified"
below for why that last point matters here, and "Deliberate simplifications"
above for the two related-table design decisions (#1's directional junction
tables, #3's `ILIKE` search) this pass deliberately left alone rather than
"fixing" further, since they weren't bugs.

## Deliberate simplifications

- **`career.entranceExams` was not migrated.** Grepping the frontend
  confirmed this field (defined in `types.ts`, populated in `careers.ts`) is
  never read by any page or component — only `career.relatedExamSlugs` and
  `stage.relatedExamSlugs` actually drive the UI. It's also redundant with
  `relatedExamSlugs` in nearly every existing record. Rather than migrate
  dead data into a real schema, the API always returns `entranceExams: []`
  and documents why in `CareerDto`'s Javadoc. `career.stageSlugs`, which
  looked similarly unused at first glance, *is* migrated (as a
  `career_stages` join table) since preserving it is essentially free and it
  is faithful to the source data.
- **Junction tables are directional, not deduplicated.** e.g. `career_courses`
  (from `career.relatedCourseSlugs`) and `course_careers` (from
  `course.careerSlugs`) are separate tables, not two views of one
  relationship. A spot check found the frontend's hand-maintained arrays
  aren't always symmetric (the MCA course lists `software-engineer` as a
  related career, but `software-engineer` doesn't list `mca` back) — mirroring
  the static data faithfully meant keeping both directions independent
  rather than silently "fixing" that inconsistency.
- **`careers.sort_order`** records each career's original index within its
  category from `careers.ts`, purely so `POST /api/assessment/submit` can
  reproduce the frontend's `getRecommendedCareers()` behavior (which picks
  careers in array order per top-scoring category) instead of an arbitrary
  database row order.
- **Search is `ILIKE`/JPQL `like`, not full-text.** Fine at ~150 rows; would
  want `to_tsvector`/`pg_trgm` (or Elasticsearch) at real scale.

## How this was built and verified

This backend was written inside a cloud sandbox whose network policy blocks
every JVM package host (Maven Central, Spring's own repo, Gradle's plugin
portal, etc. all return `403` at the network boundary) — so the Java code in
this repo has **not** been compiled or run in that sandbox; there was no way
to resolve dependencies there at all. It also meant Spring Initializr
couldn't be used to scaffold the project, so `pom.xml` and the project layout
were hand-written using conservative, well-established Spring Boot 3.x/Java
21 idioms.

To manage that risk, effort went in proportion to what could and couldn't be
checked:

- The highest-risk, highest-volume part — the schema and ~150 records plus
  their several hundred relational cross-references — was generated
  end-to-end (TypeScript data → JSON via a small `tsx` script, JSON → SQL via
  `backend/scripts/generate_seed_sql.py`) rather than transcribed by hand,
  and then **actually executed** against a real local PostgreSQL 16 instance,
  with the row counts and specific known relationships (e.g. `data-scientist`
  → its three related courses, the `after-10th` stage → its two related
  careers) checked against the original TypeScript source.
- The Java application layer (entities, repositories, services, controllers)
  could only be reviewed, not compiled or run, in that sandbox. The
  `docker-compose.yml` setup means the first real build and run happens on
  your machine, with normal internet access to Maven Central. If `docker
  compose up --build` surfaces a compile error, it's most likely a small
  thing (an import, a Hibernate annotation detail) — the schema and data
  layer underneath it have already been verified independently.
- **V26-V32 specifically**: every new migration was applied against a live
  local PostgreSQL 16 instance and re-verified with a from-scratch
  `DROP DATABASE`/`CREATE DATABASE` rebuild running V1 through V32 in
  order, and every new entity's `@Table`/`@Column`/`@JoinColumn` mapping
  was cross-checked column-by-column against `psql \d` output for its
  table (see the migrations themselves for the exact DDL). Every new Java
  file was also checked for brace balance and cross-referenced (DTO record
  field counts against `DtoMapper` constructor calls, getters against the
  fields callers actually read) since `mvn compile` still isn't available
  here.
- **V33-V38 specifically**: same discipline as V26-V32 -- each migration
  applied against the live database individually, then the full chain
  re-run from scratch (`V1` through `V38`) to confirm order-independence,
  with resulting row counts cross-checked against the incrementally-applied
  live database. Every genuinely-new row (skills, industry sectors, the
  job role, the college) was first confirmed absent via a direct `psql`
  query before being added, specifically to avoid duplicating content
  under a new slug for something that already existed under a different
  one -- see "Reconciling two more uploaded documents" above for why that
  check mattered here.
- **The audit fixes above** (bidirectional relationship sync, exception
  handling, pagination, validation, rate limiting, tests) are Java-only
  changes -- no new migration, no new dependency -- so they carried none of
  the schema-side risk the bullets above are about. They still couldn't be
  compiled here (Maven Central is still `403` from this sandbox, unchanged
  from when this backend was first written), so the same manual discipline
  applied: every touched/new file was checked for brace/paren balance, every
  new type's constructor arity was cross-checked against every call site
  (`CareerDto`'s 26-field record against both the mapper and the new test
  fixtures, `CareerUpsertRequest`'s 16 against the new controller tests,
  etc.), and every new class's dependencies were confirmed to actually exist
  in this codebase or in `spring-boot-starter-test`/`-web`/`-data-jpa` (all
  already `pom.xml` dependencies -- no new one was added). The sync fix
  specifically was cross-checked against JPA's persistence-context identity
  guarantee rather than assumed. As before, a real `mvn test` on your own
  machine is the first real compile+run these files get -- see "New tests"
  in Project layout below if that surfaces anything.

## Project layout

```
backend/
  pom.xml
  Dockerfile
  docker-compose.yml
  src/main/java/com/careerguide/api/
    CareerGuideApplication.java
    config/          # CORS, admin/user auth interceptors
    controller/       # REST controllers
    service/          # business logic, incl. assessment scoring
    repository/       # Spring Data JPA repositories
    entity/           # JPA entities
    dto/              # response DTOs mirroring the frontend's TS types
    mapper/           # entity -> DTO mapping
    web/              # exception handling, pagination support
  src/main/resources/
    application.yml
    db/migration/     # Flyway migrations V1 (schema) .. V25 (branches, skills, industries -- Data Model Roadmap Phases 1-3)
                      # .. V26-V32 (job roles, certifications, resources, streams, User Data Model -- ER model implementation)
                      # .. V33-V38 (course types, skill/industry classification, security-engineer role, NIT Patna, reverse college junctions -- additive gap-fill, see README section above)
  src/test/java/com/careerguide/api/   # New tests -- see "Post-launch backend audit fixes" above.
    service/CareerServiceTest.java         # Mockito unit tests, incl. the bidirectional-sync regression test
    controller/CareerControllerTest.java       # @WebMvcTest slice: public list/filter/search/get-by-slug/404
    controller/AdminCareerControllerTest.java  # @WebMvcTest slice: admin create/duplicate/update/delete/validation
  scripts/generate_seed_sql.py   # regenerates V2..V9 from seed-json/
  seed-json/                      # JSON dump of the frontend's data files (inputs to the script above)
```
