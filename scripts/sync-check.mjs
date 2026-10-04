/**
 * Regression guard for the @OrderColumn relationship-sync hazard.
 *
 * WHY THIS IS NOT A UNIT TEST. The bug class it guards lives inside Hibernate:
 * @OrderColumn requires sort_order to be dense 0..n-1, and removing an element
 * from the middle of such a collection makes Hibernate UPDATE the remaining rows
 * *by position*, which collides with primary keys that already hold those
 * positions. A Mockito repository has no Hibernate, so a unit test cannot
 * reach it. This drives the real API against the real database, the way
 * scripts/smoke.mjs does.
 *
 * WHY IT EXISTS AT ALL. This project has been bitten twice. @OrderColumn broke
 * Career.syncCareerLinks, and a sort_order gap left by a cascade delete in V119
 * stopped the application booting until V120 re-densified it. College.exams and
 * College.specializations both carry @OrderColumn today, and CollegeService
 * happens to be safe because it REPLACES those collections wholesale
 * (setExams(resolveEach(...))) rather than patching them in place. Nothing
 * enforces that. Rewriting either into a removeIf-and-patch loop -- which is the
 * obvious-looking change, and precisely what went wrong the first time --
 * reintroduces the bug silently, because the admin UI keeps working until the
 * day a collection is edited in the wrong order.
 *
 * Order is checked through the API rather than by querying sort_order directly:
 * Hibernate reads an @OrderColumn list positionally, so a gap surfaces as a
 * wrong order or a null element. That keeps this script dependency-free, like
 * smoke.mjs.
 *
 * Usage:
 *   node scripts/sync-check.mjs
 *   API=http://127.0.0.1:8081 ADMIN_PASSWORD=admin123 node scripts/sync-check.mjs
 *
 * 127.0.0.1 rather than localhost by default: on at least one development
 * machine Docker's wslrelay holds [::1] while the daemon serves 0.0.0.0, and
 * Node resolves localhost to ::1 first, so localhost reaches a relay that
 * accepts connections and never answers.
 */

const API = (process.env.API ?? "http://127.0.0.1:8081").replace(/\/$/, "");
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD ?? "admin123";
const COLLEGE = process.env.COLLEGE ?? "iit-bombay";

const UPSERT_FIELDS = [
  "slug", "name", "location", "type", "ownershipType", "stateSlug", "citySlug",
  "universitySlug", "nirfRank", "nirfCategory", "nirfYear", "website", "status",
  "established", "tags", "description", "degreeOfferings", "specializationSlugs",
  "examSlugs", "careerOfferings",
];

const failures = [];
let checks = 0;

async function call(method, path, body, token) {
  const res = await fetch(`${API}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    ...(body === undefined ? {} : { body: JSON.stringify(body) }),
  });
  const text = await res.text();
  let json = null;
  try { json = text ? JSON.parse(text) : null; } catch { json = text; }
  return { status: res.status, body: json };
}

function expectOrder(label, actual, expected) {
  checks++;
  const a = JSON.stringify(actual ?? []);
  const e = JSON.stringify(expected);
  if (a === e) {
    console.log(`  ok    ${label}`);
    return true;
  }
  console.log(`  FAIL  ${label}`);
  console.log(`          expected ${e}`);
  console.log(`          actual   ${a}`);
  failures.push(label);
  return false;
}

async function main() {
  const login = await call("POST", "/api/admin/login", { password: ADMIN_PASSWORD });
  if (login.status !== 200 || !login.body?.token) {
    throw new Error(`admin login failed (${login.status}). Set ADMIN_PASSWORD if it is not the dev default.`);
  }
  const token = login.body.token;

  const read = await call("GET", `/api/colleges/${COLLEGE}`);
  if (read.status !== 200) throw new Error(`could not read ${COLLEGE} (${read.status})`);

  const original = {};
  for (const f of UPSERT_FIELDS) original[f] = read.body[f];
  original.slug = COLLEGE;

  // Degrees use @OrderBy rather than @OrderColumn, so they are not the hazard --
  // but they are synced by the same applyRequest call, so an assertion that they
  // come back untouched catches collateral damage.
  const originalDegrees = (original.degreeOfferings ?? []).map((d) => d.degreeSlug);

  const exams = (await call("GET", "/api/exams")).body.map((e) => e.slug).slice(0, 6);
  const specs = (await call("GET", "/api/specializations")).body.map((s) => s.slug).slice(0, 6);
  if (exams.length < 5 || specs.length < 5) {
    throw new Error("need at least 5 exams and 5 specializations in the catalogue to exercise this");
  }

  async function set(examSlugs, specializationSlugs, label) {
    const put = await call("PUT", `/api/admin/colleges/${COLLEGE}`,
      { ...original, examSlugs, specializationSlugs }, token);
    if (put.status !== 200) {
      console.log(`  FAIL  ${label} -> HTTP ${put.status} ${JSON.stringify(put.body).slice(0, 200)}`);
      failures.push(`${label} (HTTP ${put.status})`);
      return null;
    }
    const after = await call("GET", `/api/colleges/${COLLEGE}`);
    return after.body;
  }

  try {
    console.log(`\n@OrderColumn sync check on ${COLLEGE}\n`);

    let s = await set(exams.slice(0, 5), specs.slice(0, 5), "grow to 5");
    if (s) {
      expectOrder("grow: exams", s.examSlugs, exams.slice(0, 5));
      expectOrder("grow: specializations", s.specializationSlugs, specs.slice(0, 5));
    }

    // The hazard: dropping an element from the middle is what forces Hibernate
    // to rewrite the positions of everything after it.
    const examsMid = [...exams.slice(0, 2), ...exams.slice(3, 5)];
    const specsMid = [...specs.slice(0, 2), ...specs.slice(3, 5)];
    s = await set(examsMid, specsMid, "remove the middle element");
    if (s) {
      expectOrder("middle removal: exams", s.examSlugs, examsMid);
      expectOrder("middle removal: specializations", s.specializationSlugs, specsMid);
    }

    // Reversing rewrites every position at once.
    s = await set([...examsMid].reverse(), [...specsMid].reverse(), "reverse the order");
    if (s) {
      expectOrder("reverse: exams", s.examSlugs, [...examsMid].reverse());
      expectOrder("reverse: specializations", s.specializationSlugs, [...specsMid].reverse());
    }

    s = await set([], [], "empty both");
    if (s) {
      expectOrder("empty: exams", s.examSlugs, []);
      expectOrder("empty: specializations", s.specializationSlugs, []);
    }

    s = await set(exams.slice(0, 3), specs.slice(0, 3), "repopulate from empty");
    if (s) {
      expectOrder("repopulate: exams", s.examSlugs, exams.slice(0, 3));
      expectOrder("repopulate: specializations", s.specializationSlugs, specs.slice(0, 3));
    }
  } finally {
    // Always restore, including after a failure: this edits real content, and
    // leaving a college mangled because an assertion failed would be a worse
    // bug than the one being tested for.
    const restore = await call("PUT", `/api/admin/colleges/${COLLEGE}`, original, token);
    const after = await call("GET", `/api/colleges/${COLLEGE}`);
    console.log("");
    if (restore.status !== 200) {
      console.log(`  FAIL  restore -> HTTP ${restore.status}`);
      failures.push("restore failed");
    }
    expectOrder("restored: exams", after.body?.examSlugs, original.examSlugs ?? []);
    expectOrder("restored: specializations", after.body?.specializationSlugs, original.specializationSlugs ?? []);
    expectOrder("restored: degrees untouched",
      (after.body?.degreeOfferings ?? []).map((d) => d.degreeSlug), originalDegrees);
  }

  console.log("");
  if (failures.length > 0) {
    console.log(`FAILED -- ${failures.length} of ${checks} checks:`);
    for (const f of failures) console.log(`  - ${f}`);
    process.exit(1);
  }
  console.log(`OK -- ${checks} checks, sort_order stayed dense through every edit, state restored`);
}

main().catch((err) => {
  console.error(`sync-check failed: ${err.message}`);
  process.exit(1);
});
