// Renders every page in the catalog and checks it came out intact.
//
// WHY THIS EXISTS. Ten listing pages and ten detail pages are built from two
// shared component kits and fed by data that is uneven on purpose -- some
// careers have salary bands, most do not; most specializations borrow their
// parent's copy. The bugs that kept appearing were all the same shape: a
// section rendering empty, or a null reaching a formatter. Neither shows up in
// a type check, and both are obvious the moment the page is actually rendered.
//
// WHY A SCRIPT AND NOT A TEST FRAMEWORK. There is no test runner on the
// frontend yet, and adding one to assert "every URL returns a page" would be
// more configuration than assertion. This needs a running site and a running
// API, which is integration testing whatever it is called. It exits non-zero
// on failure, so CI treats it like any other test.
//
// The URL list is derived from the API rather than hard-coded, so it covers
// whatever is in the catalog today and grows with it.
//
// Usage:
//   node scripts/smoke.mjs                 # against localhost:3000 / :8081
//   SITE=... API=... node scripts/smoke.mjs
//   node scripts/smoke.mjs --sample 50     # 50 per route family, for a quick pass

const SITE = (process.env.SITE ?? "http://localhost:3000").replace(/\/$/, "");
const API = (process.env.API ?? "http://localhost:8081").replace(/\/$/, "");
const CONCURRENCY = Number(process.env.CONCURRENCY ?? 12);

const sampleFlag = process.argv.indexOf("--sample");
const SAMPLE = sampleFlag === -1 ? Infinity : Number(process.argv[sampleFlag + 1]);

/** API list endpoint -> the detail route its slugs render at. */
const DETAIL_ROUTES = [
  ["careers", "/careers"],
  ["specializations", "/specializations"],
  ["job-roles", "/job-roles"],
  ["degrees", "/degrees"],
  ["exams", "/exams"],
  ["colleges", "/colleges"],
  ["skills", "/skills"],
  ["industries", "/industries"],
  ["certifications", "/certifications"],
  ["resources", "/resources"],
  ["stages", "/stage"],
  ["streams", "/stream"],
];

const STATIC_PAGES = [
  "/",
  "/careers",
  "/specializations",
  "/job-roles",
  "/degrees",
  "/exams",
  "/colleges",
  "/skills",
  "/industries",
  "/certifications",
  "/resources",
  "/categories",
  "/assessment",
  "/roadmap",
  "/compare",
  "/search",
  "/counselling",
  "/login",
  "/register",
];

// /admin/** is deliberately absent: it is a client component behind a token, so
// server-rendered HTML is the "Checking admin session..." placeholder with no
// heading. Asserting on it would test the redirect, not the page.

// Strings that are never legitimate rendered output. `undefined` is matched only
// as an element's entire text, because the word appears in prose and in JSON-LD.
const POISON = [/\[object Object\]/, /\bNaN\b/, />\s*undefined\s*</, />\s*Infinity\s*</];

async function slugsFor(endpoint) {
  const res = await fetch(`${API}/api/${endpoint}`);
  if (!res.ok) throw new Error(`GET /api/${endpoint} -> ${res.status}`);
  const rows = await res.json();
  return rows.map((r) => r.slug).filter(Boolean);
}

async function checkOne(url) {
  let res;
  try {
    res = await fetch(`${SITE}${url}`);
  } catch (err) {
    return { url, problem: `request failed: ${err.message}` };
  }
  if (res.status !== 200) return { url, problem: `HTTP ${res.status}` };

  const html = await res.text();

  // A page with no <h1> rendered its shell but not its content -- the usual
  // symptom of a detail page whose entity came back undefined.
  const h1 = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/);
  if (!h1) return { url, problem: "no <h1>" };
  // React inserts <!-- --> between adjacent expressions, so strip comments and
  // tags before deciding the heading is empty.
  const heading = h1[1].replace(/<!--[\s\S]*?-->/g, "").replace(/<[^>]+>/g, "").trim();
  if (heading === "") return { url, problem: "empty <h1>" };

  for (const pattern of POISON) {
    if (pattern.test(html)) return { url, problem: `rendered ${pattern.source}` };
  }
  return null;
}

/** Fixed-size worker pool; 1,500 simultaneous fetches would just time out. */
async function runPool(urls, worker) {
  const failures = [];
  let index = 0;
  let done = 0;
  const workers = Array.from({ length: Math.min(CONCURRENCY, urls.length) }, async () => {
    while (index < urls.length) {
      const url = urls[index++];
      const failure = await worker(url);
      if (failure) failures.push(failure);
      done++;
      if (done % 100 === 0) process.stderr.write(`  ${done}/${urls.length}\n`);
    }
  });
  await Promise.all(workers);
  return failures;
}

async function main() {
  process.stderr.write(`site ${SITE}\napi  ${API}\n\n`);

  const urls = [...STATIC_PAGES];
  const families = [["static", STATIC_PAGES.length]];

  for (const [endpoint, route] of DETAIL_ROUTES) {
    const slugs = await slugsFor(endpoint);
    const taken = slugs.slice(0, SAMPLE);
    urls.push(...taken.map((slug) => `${route}/${slug}`));
    families.push([route, taken.length]);
  }

  process.stderr.write(`${urls.length} pages:\n`);
  for (const [name, n] of families) process.stderr.write(`  ${String(n).padStart(5)}  ${name}\n`);
  process.stderr.write("\n");

  const started = Date.now();
  const failures = await runPool(urls, checkOne);
  const seconds = ((Date.now() - started) / 1000).toFixed(1);

  if (failures.length === 0) {
    process.stderr.write(`\nOK -- ${urls.length} pages in ${seconds}s\n`);
    return;
  }

  process.stderr.write(`\nFAILED -- ${failures.length} of ${urls.length} pages (${seconds}s)\n\n`);
  const byProblem = new Map();
  for (const f of failures) {
    if (!byProblem.has(f.problem)) byProblem.set(f.problem, []);
    byProblem.get(f.problem).push(f.url);
  }
  for (const [problem, list] of [...byProblem].sort((a, b) => b[1].length - a[1].length)) {
    process.stderr.write(`${problem} (${list.length})\n`);
    for (const url of list.slice(0, 15)) process.stderr.write(`    ${url}\n`);
    if (list.length > 15) process.stderr.write(`    ... and ${list.length - 15} more\n`);
    process.stderr.write("\n");
  }
  process.exitCode = 1;
}

main().catch((err) => {
  process.stderr.write(`smoke test could not run: ${err.message}\n`);
  process.exitCode = 1;
});
