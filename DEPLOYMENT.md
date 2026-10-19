# Going live

The order matters. Each phase assumes the one before it is done.

Nothing here is generic advice — every requirement below comes from this
codebase, and the verification steps are things that actually fail when the
configuration is wrong.

---

## Phase 0 — Fix these first (code changes)

These are open defects, not preferences. Two are exploitable by anyone the day
the site is reachable.

### 0.1 Rate-limit the counselling endpoint — DONE

`POST /api/counselling-requests` had no authentication, no rate limit and no
size cap on `message`. It is the only unauthenticated endpoint that *persists*
anything, and what it persists is name, email, phone and free text from students
who are often minors — the table you are the DPDP data fiduciary for.

Measured before: 30 rapid submissions → 30 × `201`, 0 × `429`; a 2 MB `message`
→ `201 Created`, stored as 1953 kB.

Three layers now, each covering what the others cannot:

| | |
|---|---|
| Rate limit | `/api/counselling-requests` registered in `AuthRateLimitWebConfig` with its own budget of 3 per 15 minutes, separate from the credential endpoints' 10 |
| `@Size(max = 2000)` on `message` | Bounds what gets stored. Runs after Jackson parses, so it protects the column, not memory |
| `RequestSizeLimitFilter` | Rejects a body over 64 KB with `413` before anything parses it. Bean Validation cannot do this, and Spring Boot has no property for it — `server.tomcat.max-http-form-post-size` covers form-encoded posts only |

Measured after:

```
30 rapid submissions   ->  3 x 201, 27 x 429, Retry-After: 896
2 MB body              ->  413 Payload Too Large
message of 2001 chars  ->  400 Bad Request
normal 1500-char message -> 201 Created
/api/admin/login       ->  still 10 before 429, not 3
```

Covered by `AuthRateLimitInterceptorTest` and `RequestSizeLimitFilterTest`
(13 tests), including that exhausting the form does not lock the same caller out
of logging in, and that one abusive IP does not take the form offline for
everyone.

**One known gap, recorded rather than glossed:** the filter reads
`Content-Length`, so a client using `Transfer-Encoding: chunked` sends no length
and passes through, bounded only by `@Size` after parsing. Closing it means
wrapping the input stream and counting bytes as they are read. Every ordinary
HTTP client sends `Content-Length`.

### 0.2 Get SonarQube out of the production compose file — DONE

It was a service in `backend/docker-compose.yml` — the file a deployment runs —
published on `0.0.0.0:9000` with SonarQube's default `admin/admin`. Anyone who
found the port owned it, and the analysis history of the whole codebase with it.

Now `backend/docker-compose.sonar.yml`, run on its own and bound to loopback:

```bash
docker compose -f docker-compose.sonar.yml up -d
docker compose -f docker-compose.sonar.yml down
```

Docker names volumes after the project directory, so it reuses the existing
`backend_sonarqube_*` volumes — the analysis history, quality profiles and admin
password survived the move, verified by reading `careerguide-backend`'s measures
back afterwards. `docker compose up` for the app no longer waits on a service
that wants ~2 GB and a minute to become healthy.

### 0.3 Do not publish the API directly — DONE

`careerguide-api` published `0.0.0.0:8081->8080` over plain HTTP, so on a real
host the API was reachable from the internet unencrypted — and every admin
password, user password and session token on it travels in a request body or an
Authorization header.

Now `127.0.0.1:8081:8080`, matching postgres. Verified from both sides rather
than assumed:

```
http://127.0.0.1:8081    -> answers
http://<lan-address>:8081 -> REFUSED (not listening)
http://<lan-address>:9000 -> REFUSED (not listening)
```

Loopback is still enough for everything that needs it: `next start` on the host,
the smoke and sync-check scripts, and a reverse proxy on the same machine. A
containerised frontend would reach the API over the compose network by service
name, which needs no published port at all.

**This does not give you HTTPS.** It removes the public plaintext port; Phase 2
is still required before anything is reachable from the internet.

---

## Phase 1 — Decisions only you can make

Nobody else can answer these, and two of them are legal.

### 1.1 Finish `/privacy`

`src/app/privacy/page.tsx` renders amber `TO CONFIRM` markers for four things,
deliberately left visible rather than filled with plausible defaults:

| | |
|---|---|
| Retention period | How long counselling enquiries are kept after they are answered, and what happens to a dormant account |
| Contact address | Where deletion requests go, and how fast you will respond |
| Under-18s | Your position on minors, and how verifiable parental consent is obtained and recorded |
| Third parties | Whether email, analytics or WhatsApp ever receive this data |

You are already collecting consent — V133 stamps `consented_at` server-side on
every submission. The page explaining what that consent covers is unfinished.
A policy stating a retention period nobody chose is worse than one that visibly
isn't done, which is why these were left showing.

The page also carries `DRAFT` and a line saying no lawyer has reviewed it.
Remove both only when both are untrue.

### 1.2 Domain and hosting — DECIDED

| | Where | Why |
|---|---|---|
| Frontend | **Vercel**, region `bom1` (Mumbai) — pinned in `vercel.json` | Vercel's Mumbai region runs on AWS Mumbai, the same region as the API |
| Backend + Postgres | **AWS Lightsail, Mumbai, 2 GB plan** (~$12/month) | Runs the existing `docker compose` unchanged. Measured locally: API 512 MB + Postgres 59 MB idle, so 2 GB leaves headroom; 1 GB would not |

Two hostnames, because Vercel serves the site and Lightsail serves the API:

```
yourdomain.com       -> Vercel     (the site)
api.yourdomain.com   -> Lightsail  (the API, behind Caddy)
```

Vercel's Hobby plan does not allow commercial use; a startup site needs Pro
(~$20/month).

### 1.3 WhatsApp number

`NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER` is baked into the build. Decide the
real number or leave the feature off deliberately.

---

## Phase 2 — Infrastructure: AWS Lightsail

### 2.1 Create the server

In the Lightsail console → **Create instance**:

- Region: **Mumbai (ap-south-1)**
- Platform: Linux/Unix → **OS Only → Ubuntu 24.04 LTS**
- Plan: **2 GB RAM**

Then, on the instance:

- **Networking → Attach static IP.** Without one the IP changes on restart and
  DNS breaks. Free while attached.
- **Networking → IPv4 firewall:** keep SSH (22) and HTTP (80), add HTTPS (443),
  delete anything else. If you restrict SSH to your own IP, keep **"Allow
  Lightsail browser SSH"** ticked or the console's SSH button stops working.
  **Repeat for the IPv6 firewall** — it is a separate list.
- **Snapshots → Enable automatic snapshots.** A daily copy of the whole disk,
  which also covers the "off-machine copy" gap in 7.1 below.

### 2.2 DNS

At your domain registrar: an **A record** for `api` → the static IP. (The site's
own records come from Vercel in Phase 5.)

### 2.3 Prepare the server

SSH in from the Lightsail console (browser SSH works), then:

```bash
# 2 GB swap: the image builds on this box, and the Maven build plus a running
# Postgres is the peak memory moment
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker ubuntu
exit    # log out and back in so the group change applies

# The code
git clone https://github.com/manishKr687/career-guide.git
```

### 2.4 HTTPS with Caddy

There is no TLS in the app itself; Caddy terminates it and obtains and renews
the certificate on its own. `deploy/Caddyfile` is ready to use:

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy

sudo cp ~/career-guide/deploy/Caddyfile /etc/caddy/Caddyfile
sudo sed -i 's/api.yourdomain.com/api.YOURREALDOMAIN.com/' /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

What that Caddyfile does, each point tested locally against the real API:

- Only `/api/*` and `/actuator/health` are public. Swagger UI, `/v3/api-docs`
  and `/actuator/info` return 404 — they list every admin endpoint.
- It **ignores any `X-Forwarded-For` the client sends** and sets the real
  address. The rate limiter keys on that header, so this matters: sending five
  counselling submissions with a different forged IP each time, the API alone
  accepted all five; through Caddy the 4th and 5th got 429.

That second point is also why the API must only be reachable through Caddy.
The compose file publishes it on `127.0.0.1:8081` and Postgres on
`127.0.0.1:5432` — loopback only. Leave both that way.

---

## Phase 3 — Secrets

Under `SPRING_PROFILES_ACTIVE=prod`, `application-prod.yml` declares every
secret with **no default**, so an unset variable makes Spring refuse to start
and name the one that's missing. `ProdSecretsCheck` additionally rejects the
published defaults, blank values, signing keys under 32 characters, and a CORS
policy that still allows localhost.

Generate the secrets:

```bash
openssl rand -base64 48      # CAREERGUIDE_ADMIN_TOKEN_SECRET
openssl rand -base64 48      # CAREERGUIDE_USER_TOKEN_SECRET
openssl rand -base64 24      # SPRING_DATASOURCE_PASSWORD
openssl rand -base64 18      # CAREERGUIDE_ADMIN_PASSWORD
```

Put them in `~/career-guide/backend/.env` on the server (`nano` works) —
gitignored, and Docker Compose loads it automatically. **Never in
`docker-compose.yml`.**

```ini
SPRING_PROFILES_ACTIVE=prod
CAREERGUIDE_ADMIN_PASSWORD=<generated>
CAREERGUIDE_ADMIN_TOKEN_SECRET=<generated, >=32 chars>
CAREERGUIDE_USER_TOKEN_SECRET=<generated, >=32 chars>
SPRING_DATASOURCE_PASSWORD=<generated>
CAREERGUIDE_CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

CORS lists the **site's** origins, not the API's: browsers call the API
directly from the site for login, sign-up and the counselling form. Comma-
separated, no trailing slashes.

Until this was fixed, `docker-compose.yml` set the CORS value as a literal, and
compose reads `.env` only to fill `${...}` placeholders — so this line never
reached the container, which kept the localhost list, and `ProdSecretsCheck`
then refused to start. It is a placeholder now; `docker compose config` on the
server shows the value the container will actually get.

### Why the token secrets matter more than the password

`AdminTokenService` signs a token over nothing but an expiry — it carries no
identity. So **whoever holds `CAREERGUIDE_ADMIN_TOKEN_SECRET` can mint a valid
24-hour admin session offline**: no password, no request to your server, nothing
in your logs until they start writing. Changing the admin password does not
help, and the rate limiter never sees it.

That is pinned as a test (`AdminTokenServiceTest`), not just a comment. Treat
that secret as equal in value to the admin password. The same trick forges any
user's session with `CAREERGUIDE_USER_TOKEN_SECRET`.

`SPRING_PROFILES_ACTIVE=prod` is the single most important line in that file.
Without it the guard never runs, and the app boots happily on credentials
published in a public repository.

---

## Phase 4 — Deploy the backend

```bash
cd ~/career-guide/backend
docker compose up -d --build
docker compose logs api | grep -E "relationship integrity|Started CareerGuideApplication"
curl -s https://api.yourdomain.com/actuator/health
```

Expect `relationship integrity: OK`, a started application, and
`{"status":"UP"}` over HTTPS. Flyway applies all 146 migrations to the empty
database and the catalogue arrives with them.

**That catalogue matches the local one, with one exception** — checked by
building a database from the migrations alone and comparing all 75 tables,
timestamps excluded. The only content that exists locally and not in the
migrations is the specialization *Additive Manufacturing*: `demand = HIGH`,
`salary_min_lpa = 2.5` with no maximum, and its links to B.Eng, B.Tech, M.Eng
and M.Tech. Re-enter it through the admin after launch if it was meant, skip it
if it was a test edit. Nothing else needs copying, and the one local user and
one counselling request rightly stay behind.

If the app refuses to start, read the message — under the prod profile that is
almost always a missing or rejected secret, and it says which.

---

## Phase 5 — Deploy the frontend

**`NEXT_PUBLIC_*` variables are baked in at build time.** Setting them on a
running server has no effect. Get them wrong and the site builds and serves
happily while pointing at the wrong host — the failure is silent.

On Vercel:

1. **Add New → Project**, import `manishKr687/career-guide`. Framework is
   detected as Next.js; the root directory is the repo root.
2. **Before the first deploy**, under Environment Variables (Production):

   | Name | Value |
   |---|---|
   | `NEXT_PUBLIC_API_BASE_URL` | `https://api.yourdomain.com` — **no `/api` on the end** |
   | `NEXT_PUBLIC_SITE_URL` | `https://yourdomain.com` |
   | `NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER` | the number, or leave unset |

   **Why no `/api`:** the frontend adds `/api/...` itself, two different ways.
   Catalogue pages use `new URL("/api/careers", base)`, which ignores any path
   in the base, so they work either way. Login, sign-up and the admin build
   `` `${base}/api/...` `` by string, so a base ending in `/api` produces
   `/api/api/admin/login`. The result is a site whose pages all load while
   every login, registration and admin action returns 404 — the earlier
   version of this runbook said to use `.../api`, which would have done exactly
   that.

3. Deploy. `vercel.json` pins the functions to `bom1`; check it under
   Settings → Functions. Every page calls the API per request, so a US region
   would pay the round trip to Mumbai several times per page.
4. **Settings → Domains**: add `yourdomain.com` and `www.yourdomain.com`, and
   create the DNS records Vercel shows you.

Deploy the backend first: the site's pages fetch from the API as they render.

The same build, done by hand for a local check:

```bash
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com \
NEXT_PUBLIC_SITE_URL=https://yourdomain.com \
NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER=<number> \
npm ci && npm run build
```

`NEXT_PUBLIC_SITE_URL` drives `robots.txt`, `sitemap.xml` (about 1,550 URLs) and
every canonical and Open Graph URL. Its default is `http://localhost:3000`,
chosen deliberately: obviously wrong beats a plausible wrong domain that
silently tells crawlers your pages live somewhere they don't.

### A local gotcha that will cost you an hour

On this machine `localhost` does not reach the containers. Docker's `wslrelay`
is bound to `[::1]:8081` while `com.docker.backend` serves `0.0.0.0:8081`, and
Windows resolves `localhost` to `::1` first — so requests go to the relay, which
accepts the connection and never answers.

```
http://127.0.0.1:8081/actuator/health  -> 200
http://localhost:8081/actuator/health  -> hangs, then fails
```

Use `127.0.0.1` for local builds and for `SITE`/`API` when running the smoke
test. This is a local Docker Desktop quirk and does not affect a Linux server.

---

## Phase 6 — Verify, after deploying

Reading your own config proves nothing. Test the deployed system.

### 6.1 The one check that matters most

```bash
curl -s -X POST https://api.yourdomain.com/api/admin/login \
  -H "Content-Type: application/json" -d '{"password":"admin123"}'
```

**If that returns a token, stop and fix Phase 3.** It means the prod profile
isn't active and your site is running on a password published on GitHub. Ten
seconds, and decisive in a way reading a config file is not.

### 6.2 The rest

```bash
# HTTPS, and HTTP redirects to it -- for the site and the API
curl -sI http://yourdomain.com | head -1
curl -sI https://yourdomain.com | head -1
curl -sI http://api.yourdomain.com/actuator/health | head -1

# On the server nothing but 80/443 is reachable -- all three must fail from outside
curl --max-time 5 http://api.yourdomain.com:8081/actuator/health
nc -zv -w 5 api.yourdomain.com 5432
nc -zv -w 5 api.yourdomain.com 9000

# Swagger and the API docs stay internal -- both must print 404
curl -s -o /dev/null -w "%{http_code}\n" https://api.yourdomain.com/swagger-ui.html
curl -s -o /dev/null -w "%{http_code}\n" https://api.yourdomain.com/v3/api-docs

# The catalogue is really there
curl -s https://api.yourdomain.com/api/careers | head -c 200

# Every page renders
SITE=https://yourdomain.com API=https://api.yourdomain.com npm run smoke -- --sample 25

# SEO files point at the real domain
curl -s https://yourdomain.com/robots.txt
curl -s https://yourdomain.com/sitemap.xml | head -20

# The counselling rate limit holds, and a forged IP cannot dodge it.
# An empty body on purpose: the limiter counts the request before validation
# rejects it, so this proves the limit without leaving fake enquiries in the
# production database.
for i in 1 2 3 4 5; do curl -s -o /dev/null -w "%{http_code} " -X POST \
  https://api.yourdomain.com/api/counselling-requests -H "Content-Type: application/json" \
  -H "X-Forwarded-For: 10.0.0.$i" -d '{}'; done
# expect: 400 400 400 429 429   (five 400s means the forged header is trusted)
```

Then by hand: log into `/admin` with the real password, edit one record, confirm
it changes on the public page. That proves the whole write path.

---

## Phase 7 — Before you sleep on launch night

### 7.1 Backups, on the server

`schedule-backup.ps1` currently runs on your workstation. That is not where the
production database lives. Put a cron entry on the server:

```cron
0 2 * * * cd /path/to/backend && KEEP_DAYS=30 ./scripts/backup-db.sh
```

Then **copy the dumps off that machine.** A backup on the same disk as the
database survives a mistake, not a dead disk. That copy step does not exist yet.

This matters more than it used to: the database is the source of truth for the
catalogue, so anything edited through the admin exists in exactly one place.
Replaying migrations rebuilds the catalogue as it stood at V146 and nothing
after. This project has already lost three admin-created exams and a user
account to a dropped volume, because they existed in no migration.

### 7.2 Test the restore

An untested backup is a guess. `backup-db` now verifies its own output — it
greps for `pg_dump`'s completion marker and deletes the file rather than keep a
truncated one — but that checks the dump is whole, not that it restores.

```bash
docker compose exec -T postgres psql -U careerguide -d postgres \
  -c "CREATE DATABASE restore_test OWNER careerguide;"
docker compose exec -T postgres psql -U careerguide -d restore_test -f /backups/<file>.sql
# compare row counts across every table, then:
docker compose exec -T postgres psql -U careerguide -d postgres -c "DROP DATABASE restore_test;"
```

Done once locally: 76 tables, identical row counts, all 146 migrations recorded
in the restored `flyway_schema_history`. Do it again on the server.

### 7.3 Monitoring

There is none. At minimum, something that tells you the site is down —
an uptime checker on `https://yourdomain.com` and on
`https://api.yourdomain.com/api/careers`, since the site can render while the
API is broken.

---

## Not blockers, but the honest state of things

| | |
|---|---|
| 31 exams have no syllabus overview; 20 lack mode and eligibility | Needs a pass against each conducting body's information bulletin. |
| Assessment content is SQL-only | 155 rows across questions, options and weights have no admin screen. Subjects and `degree_subjects` (100 rows) likewise. |
| 22 of 26 backend services have no tests | The auth layer is covered — password hashing, both token signers, login and registration. `CollegeService` and `SpecializationService` relationship sync are not. |
| No CI deployment | CI tests, it does not deploy. Phases 4 and 5 are manual. |

## After go-live

Content changes happen in the admin, never in a migration — `MigrationPolicyTest`
fails the build if a migration after V146 writes to a content table. Schema
changes still go in a `V147+` migration as always. See
`backend/README.md`, "What owns the content".
