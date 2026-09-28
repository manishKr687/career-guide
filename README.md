# CareerGuide

A Next.js (App Router + TypeScript + Tailwind CSS v4) web app for CareerGuide — an Indian career guidance platform covering every stage from After 10th through Working Professional / Career Switch.

This first version is the **core information architecture with sample data**: homepage, stage pages, career/course/exam/college explorers and detail pages, a career assessment quiz, a roadmap, and a local (no login) "My Career" profile. There is no authentication yet — profile-like features (assessment results, saved courses/colleges) are stored in the browser via `localStorage`.

## Getting started

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) (or whichever port you pass with `-p`) to view it.

To build for production:

```bash
npm run build
npm start
```

The production build prerenders all 138 pages (careers, courses, exams, colleges, and stage detail pages all use `generateStaticParams`), so `npm run build` is a good way to catch any broken links or missing data before shipping.

## Project structure

- `src/app/` — routes (App Router). Each list page (`/careers`, `/courses`, `/exams`, `/colleges`) has a matching `[slug]` detail route.
- `src/components/` — UI split into `ui/` (shared primitives), `layout/` (navbar, footer), `home/` (homepage sections), `cards/` (list-item cards), `listing/` (search + filter explorers), `assessment/`, `profile/`.
- `src/data/` — the sample dataset: `categories.ts`, `careers.ts` (37), `courses.ts` (43), `exams.ts` (22), `colleges.ts` (17), `stages.ts` (6), `assessmentQuestions.ts`. Everything is cross-referenced by slug, with defensive lookups so a mismatched slug is dropped rather than crashing.
- `src/lib/` — `assessment.ts` (quiz scoring + localStorage persistence), `savedItems.ts` (saved courses/colleges), `types.ts`, `utils.ts`.

## Notes for whoever picks this up next

- **Tailwind v4** here uses the CSS-first `@theme` config in `src/app/globals.css` (no `tailwind.config.js`). Its class scanner needs **literal class name strings** in source — do not build class names with template literals (e.g. `` `bg-${color}-soft` ``); store the full class string in the data file instead, the way `stages.ts` and `careers.ts` do.
- **No Google Fonts** — the build environment this was developed in blocked outbound requests to `fonts.googleapis.com`, so the theme uses system font stacks (`--font-sans` / `--font-display` in `globals.css`) instead of `next/font/google`. Feel free to swap in a hosted font if your environment can reach it.
- **Dynamic route `params` are async** in this Next.js version — every `[slug]/page.tsx` types `params` as `Promise<{ slug: string }>` and awaits it in both the page component and `generateMetadata`. Keep that pattern for any new dynamic routes.
- No backend or auth yet — that's intentionally deferred to a follow-up phase. When you add it, the `localStorage`-backed helpers in `src/lib/assessment.ts` and `src/lib/savedItems.ts` are the natural spots to swap for real API calls.
