const DEFAULT_API_BASE_URL = "http://localhost:8081";

/**
 * Base URL of the CareerGuide content API (the Spring Boot / Postgres
 * backend in backend/). Override with NEXT_PUBLIC_API_BASE_URL if it's not
 * on localhost:8081 (see backend/docker-compose.yml for the default port).
 *
 * This is a NEXT_PUBLIC_ var — it ends up in the client bundle too, since a
 * few components (assessment submission, saved-item lookups) fetch from the
 * browser rather than a Server Component.
 */
export const API_BASE_URL = (process.env.NEXT_PUBLIC_API_BASE_URL ?? DEFAULT_API_BASE_URL).replace(/\/$/, "");

export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

function buildUrl(path: string, params?: Record<string, string | undefined>): string {
  const url = new URL(path, `${API_BASE_URL}/`);
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined && value !== "") url.searchParams.set(key, value);
    }
  }
  return url.toString();
}

/**
 * Every call here uses `cache: "no-store"` — the catalog lives in Postgres
 * now and can change at any time, and (just as importantly) it keeps
 * `next build` from trying to hit the API at build time to prerender pages.
 * Static generation / ISR can be layered back in once there's a deployment
 * target where that staleness tradeoff is worth making.
 */
const NO_STORE: RequestInit = { cache: "no-store" };

/**
 * GET a resource that's expected to exist (a list, or a lookup you already
 * know is valid). Throws ApiError on any non-2xx response, including 404.
 */
export async function apiGet<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  const res = await fetch(buildUrl(path, params), NO_STORE);
  if (!res.ok) {
    throw new ApiError(res.status, `GET ${path} failed: ${res.status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

/**
 * GET a by-slug lookup that may legitimately not exist. Returns null on a
 * 404 instead of throwing, mirroring the Array.prototype.find() behaviour
 * the frontend's data helpers used to have when the data was static arrays.
 */
export async function apiGetOptional<T>(path: string): Promise<T | null> {
  const res = await fetch(buildUrl(path), NO_STORE);
  if (res.status === 404) return null;
  if (!res.ok) {
    throw new ApiError(res.status, `GET ${path} failed: ${res.status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

/** POST a JSON body and parse the JSON response. Never cached. */
export async function apiPost<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(buildUrl(path), {
    ...NO_STORE,
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new ApiError(res.status, `POST ${path} failed: ${res.status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

/**
 * Fetch several by-slug lookups in parallel, preserving input order and
 * dropping any slug that no longer resolves — same contract the old
 * getManyCareers/getManyCourses/getManyExams array helpers had.
 */
export async function fetchManyBySlug<T extends { slug: string }>(
  slugs: string[],
  listPath: string
): Promise<T[]> {
  const wanted = Array.from(new Set(slugs.filter((s) => s)));
  if (wanted.length === 0) return [];

  // One request for the whole set, via the `slugs` parameter the list endpoints
  // accept. This used to issue one request per slug: rendering
  // /careers/computer-science-and-engineering meant 159 HTTP requests and 159
  // database queries -- 40 skills, 54 colleges, 24 job roles, 16
  // specializations, 14 industries, 6 exams, 5 degrees. Parallel, so it hid
  // completely behind a local API, and the page still rendered in 0.29s.
  //
  // The server returns them in its own order and omits anything that no longer
  // resolves, so the caller's order is restored here -- the pages rely on it
  // (a career's skills are shown in the order the admin arranged them).
  const batch = await apiGet<T[]>(listPath, { slugs: wanted.join(",") });
  const bySlug = new Map(batch.map((item) => [item.slug, item]));
  return slugs.map((slug) => bySlug.get(slug)).filter((item): item is T => item !== undefined);
}

/**
 * Chunks a slug list so no request exceeds the server's cap, then flattens the
 * results back into one ordered list.
 *
 * Nothing in the catalogue needs this today -- the largest real fan-out is 54,
 * against a limit of 200. It exists because the limit is enforced server-side
 * with a 400, so without chunking a career that one day relates to more than 200
 * of anything would start failing to render rather than merely being slow, and
 * the cause would be hard to see from the page.
 */
const SLUGS_PER_REQUEST = 200;

export async function fetchManyBySlugChunked<T extends { slug: string }>(
  slugs: string[],
  listPath: string
): Promise<T[]> {
  if (slugs.length <= SLUGS_PER_REQUEST) return fetchManyBySlug<T>(slugs, listPath);

  const chunks: string[][] = [];
  for (let i = 0; i < slugs.length; i += SLUGS_PER_REQUEST) {
    chunks.push(slugs.slice(i, i + SLUGS_PER_REQUEST));
  }
  const results = await Promise.all(chunks.map((chunk) => fetchManyBySlug<T>(chunk, listPath)));
  return results.flat();
}
