# CareerGuide

A career guidance platform for Indian students, covering the path from After
10th through Working Professional. It answers "what can I become, what do I
study for it, and where" over a real, related catalog rather than a set of
static pages.

Two services in one repository:

- **Frontend** — Next.js 16 (App Router), TypeScript, Tailwind CSS v4. This
  directory.
- **Backend** — Spring Boot 3.5.5 on Java 21, PostgreSQL 16, Flyway. In
  [`backend/`](backend/), with its own [README](backend/README.md) covering
  the data model and migration history in detail.

The frontend holds no data of its own. Everything under `src/data/` is a thin
typed wrapper over the backend's REST API.

## The content model

The spine is a three-level hierarchy, and the levels do not overlap:

```
Career             Computer Science & Engineering      what you become
  └─ Specialization    Artificial Intelligence & ML    the focused area within it
       └─ Job Role        AI Engineer, ML Engineer     the post you are hired into
```

Related to that spine, and to each other: **Degrees** (what you study),
**Exams** (how you get in), **Colleges** (where), **Skills**, **Industries**,
**Certifications** and **Resources**. Careers are filed under 20
**Categories**; **Streams** (after 10th) and **Stages** (the student timeline)
are the entry points a visitor actually starts from.

Current catalog, from a running instance:

| | | | |
|---|---|---|---|
| Careers **42** | Specializations **263** | Job Roles **255** | Degrees **76** |
| Exams **34** | Colleges **90** | Skills **413** | Industries **329** |
| Certifications **12** | Resources **14** | Categories **20** | Streams **4** |

## Running it

The backend comes first — without it the frontend renders errors, since it is
the only data source.

```bash
cd backend
docker compose up --build        # Postgres + API on :8081, migrations run on boot
```

Then, from the repository root:

```bash
npm install
npm run dev                      # http://localhost:3000
```

The frontend defaults to `http://localhost:8081` for the API. Point it
elsewhere with `NEXT_PUBLIC_API_BASE_URL` in `.env.local` — copy
[`.env.example`](.env.example).

To build for production:

```bash
npm run build
npm start
```

Note that `next build` in Next.js 16 **no longer runs ESLint**. Lint is a
separate step:

```bash
npm run lint                     # eslint
npx tsc --noEmit                 # types
```

## Tests

```bash
cd backend && mvn test           # unit + MockMvc, no database needed
npm run smoke                    # renders every page in the catalog
```

The backend suite also runs during `docker compose up --build`, so a broken
test fails the image build rather than waiting for someone to remember.

`npm run smoke` needs the site and the API both running. It asks the API what
exists, then renders every listing page and every detail page -- around 1,550
of them -- and fails on a non-200, a missing or empty `<h1>`, or output
containing `[object Object]`, `NaN` or a bare `undefined`. That is aimed
squarely at this project's recurring bug: a section that renders empty, or a
null reaching a formatter, neither of which a type check can see.

The full pass takes about 14 minutes against `next dev`, which is too slow to
run on every change -- most of that is the dev server re-rendering each page.
Use `npm run smoke -- --sample 20` while working (a minute or so, and it still
touches every route family), and keep the full run for CI or before a release.
`CONCURRENCY`, `SITE` and `API` are all overridable by environment variable.

`/admin/**` is deliberately not covered: it is a client component behind a
token, so its server-rendered HTML is a placeholder and asserting on it would
test the redirect rather than the page.

## Admin panel

`/admin` is a CRUD interface over the whole catalog, behind a single shared
password (there is no admin users table — see `AdminAuthService`'s javadoc for
why). `/admin` itself is a dashboard: entity counts, how the catalog splits
across content types, and a **Content Gaps** panel that queries for the rows
still missing data worth filling in.

Log in with `CAREERGUIDE_ADMIN_PASSWORD`, which defaults to `admin123` for
local development. **Both admin secrets and the user token secret have
dev-only defaults committed to this repository.** Before this is reachable
from anywhere but your own machine, set real values — see
[backend/README.md](backend/README.md#admin-panel) under "Admin panel".

## Project layout

- `src/app/` — routes. Each catalog entity has a listing page and a
  `[slug]` detail page: `/careers`, `/specializations`, `/job-roles`,
  `/degrees`, `/exams`, `/colleges`, `/skills`, `/industries`,
  `/certifications`, `/resources`. Plus `/categories`, `/stream/[slug]`,
  `/stage/[slug]`, `/assessment`, `/roadmap`, `/compare`, `/search`,
  `/counselling`, `/profile`, `/login`, `/register`, and `/admin`.
- `src/components/detail/DetailKit.tsx` and
  `src/components/listing/ListingKit.tsx` — **the two kits every page is built
  from.** Cards, sections, metric rows, filter rails, result headers. They
  exist so ten detail pages and ten listing pages cannot drift apart; a change
  to a card's hover state happens once. Prefer extending a kit over styling a
  page locally.
- `src/data/` — one module per entity, each a typed wrapper over the API.
- `src/lib/` — `api.ts` (fetch + error shape), `userApi.ts` / `adminApi.ts`
  (token-authenticated calls), `types.ts` (every API response type),
  `assessment.ts`, `savedItems.ts`, `compareList.ts`, `utils.ts`.

## Conventions worth knowing before you edit

- **Tailwind v4 is CSS-first.** The theme lives in an `@theme` block in
  `src/app/globals.css`; there is no `tailwind.config.js`. Its scanner needs
  **literal class strings** in source — never build one with a template
  literal (`` `bg-${color}-soft` ``). Store the full class string in data, the
  way `stages.ts` does, or pick from a fixed palette array, the way
  `DetailKit`'s `tint()` does.
- **Dynamic route `params` are a Promise** in this Next.js version. Every
  `[slug]/page.tsx` types `params` as `Promise<{ slug: string }>` and awaits
  it in both the component and `generateMetadata`. Same for `searchParams`.
- **System fonts, no `next/font`.** The environment this was developed in
  could not reach `fonts.googleapis.com`, so `--font-sans` / `--font-display`
  in `globals.css` are system stacks. Swap in a hosted font if you can reach
  one.
- **Don't invent data.** Where the catalog has no figure, pages leave the
  metric out rather than showing `--` or a plausible number; where a page
  falls back to its parent's data, it says so in the section subtitle. Salary
  bands, NIRF ranks and several other fields are deliberately empty with the
  plumbing in place — the migration headers in `backend/src/main/resources/db/migration/`
  record why for each one.
- **The backend owns the schema.** 116 Flyway migrations, forward-only and
  checksummed once applied. Schema changes are new migrations, never edits to
  old ones. An integrity check runs on every boot and fails the build on a
  broken relationship.

## Status

The catalog, both explorers and detail pages, user accounts, the assessment
and the admin panel are all working. Known gaps, in rough priority order:

- Test coverage is thin beyond the render smoke test and 23 backend unit
  tests: there is nothing exercising the admin write paths end to end, and no
  regression test on the listing filters.
- 262 of 263 specializations have no overview of their own and borrow the
  parent career's copy under a label saying so.
- Salary bands (0/42 careers) and NIRF ranks (0/90 colleges) are unpopulated,
  waiting on figures worth trusting.
- The Career → Specialization → Role hierarchy is not yet enforced: 81 pairs
  violate it and 57 roles have no parent specialization.

The admin dashboard's Content Gaps panel is the live version of that list.
