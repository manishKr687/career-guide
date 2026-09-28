import { API_BASE_URL, ApiError } from "@/lib/api";

const TOKEN_STORAGE_KEY = "careerguide_admin_token";

/**
 * The admin session token lives in localStorage (not an in-conversation
 * artifact -- this is a real deployed app, so browser storage is fine and
 * is the right place for it). It's a per-browser convenience: losing it
 * just means logging in again, nothing is lost server-side since there's
 * no server-side session state at all (see AdminTokenService's javadoc on
 * the backend).
 */
export function getAdminToken(): string | null {
  if (typeof window === "undefined") return null;
  try {
    return window.localStorage.getItem(TOKEN_STORAGE_KEY);
  } catch {
    return null;
  }
}

function setAdminToken(token: string): void {
  try {
    window.localStorage.setItem(TOKEN_STORAGE_KEY, token);
  } catch {
    // Storage unavailable (e.g. private browsing) -- login still "works" for
    // this page load, it just won't survive a refresh.
  }
}

export function clearAdminToken(): void {
  try {
    window.localStorage.removeItem(TOKEN_STORAGE_KEY);
  } catch {
    // ignore
  }
}

/** Thrown when the server rejects the stored token (missing/expired). Callers should send the user back to /admin/login. */
export class AdminUnauthorizedError extends Error {
  constructor() {
    super("Your admin session has expired. Please log in again.");
    this.name = "AdminUnauthorizedError";
  }
}

async function errorMessage(res: Response, fallback: string): Promise<string> {
  try {
    const body = (await res.json()) as { message?: string };
    if (body && typeof body.message === "string" && body.message.trim() !== "") {
      return body.message;
    }
  } catch {
    // Response wasn't JSON (or had no body) -- fall back to the generic message.
  }
  return fallback;
}

/** Logs in against POST /api/admin/login and stores the returned token. Throws ApiError with the server's message on failure. */
export async function adminLogin(password: string): Promise<void> {
  const res = await fetch(`${API_BASE_URL}/api/admin/login`, {
    method: "POST",
    cache: "no-store",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ password }),
  });
  if (!res.ok) {
    throw new ApiError(res.status, await errorMessage(res, `Login failed: ${res.status} ${res.statusText}`));
  }
  const data = (await res.json()) as { token: string };
  setAdminToken(data.token);
}

/**
 * Authenticated fetch for /api/admin/** write endpoints. Throws
 * AdminUnauthorizedError on 401 (after clearing the stale token), or
 * ApiError (with the backend's message, e.g. a validation error or an
 * unknown related slug) for any other non-2xx response.
 */
async function adminFetch<T>(path: string, options: RequestInit): Promise<T> {
  const token = getAdminToken();
  const res = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    cache: "no-store",
    headers: {
      ...(options.headers as Record<string, string> | undefined),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (res.status === 401) {
    clearAdminToken();
    throw new AdminUnauthorizedError();
  }
  if (!res.ok) {
    const method = options.method ?? "GET";
    throw new ApiError(res.status, await errorMessage(res, `${method} ${path} failed: ${res.status} ${res.statusText}`));
  }
  // See userApi.ts's meFetch for why this reads as text first rather than
  // trusting res.status === 204 -- a void-returning admin delete endpoint
  // sends 200 with an empty body by default, and res.json() on that throws.
  const text = await res.text();
  if (!text) {
    return undefined as T;
  }
  return JSON.parse(text) as T;
}

export type AdminResource = "careers" | "degrees" | "exams" | "colleges" | "skills" | "job-roles" | "industries" | "certifications" | "resources" | "specializations" | "states" | "cities" | "universities";

export function adminCreate<T>(resource: AdminResource, payload: unknown): Promise<T> {
  return adminFetch<T>(`/api/admin/${resource}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function adminUpdate<T>(resource: AdminResource, slug: string, payload: unknown): Promise<T> {
  return adminFetch<T>(`/api/admin/${resource}/${encodeURIComponent(slug)}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function adminDelete(resource: AdminResource, slug: string): Promise<void> {
  return adminFetch<void>(`/api/admin/${resource}/${encodeURIComponent(slug)}`, {
    method: "DELETE",
  });
}

// --- Counselling requests: a submissions inbox, not a slugged content
// resource, so it doesn't fit the create/update/delete-by-slug shape above.

export type CounsellingRequestStatus = "PENDING" | "CONTACTED" | "COMPLETED";

export interface AdminCounsellingRequest {
  id: number;
  name: string;
  email: string;
  phone: string;
  preferredDate: string | null;
  preferredTime: string | null;
  stageSlug: string | null;
  careerSlug: string | null;
  message: string | null;
  status: CounsellingRequestStatus;
  createdAt: string;
}

export function adminListCounsellingRequests(): Promise<AdminCounsellingRequest[]> {
  return adminFetch<AdminCounsellingRequest[]>("/api/admin/counselling-requests", { method: "GET" });
}

export function adminUpdateCounsellingStatus(id: number, status: CounsellingRequestStatus): Promise<AdminCounsellingRequest> {
  return adminFetch<AdminCounsellingRequest>(`/api/admin/counselling-requests/${id}/status`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}

export function adminDeleteCounsellingRequest(id: number): Promise<void> {
  return adminFetch<void>(`/api/admin/counselling-requests/${id}`, { method: "DELETE" });
}

// --- Dashboard: one aggregate payload rather than counting entity lists in
// the browser. See AdminDashboardService for why the shape differs from the
// content DTOs.

export interface AdminEntityCount {
  entity: string;
  label: string;
  count: number;
  adminPath: string;
}

export interface AdminContentGap {
  label: string;
  affected: number;
  total: number;
  detail: string;
  adminPath: string;
}

export interface AdminRecentChange {
  entity: string;
  label: string;
  slug: string;
  title: string;
  at: string | null;
  isNew: boolean;
}

export interface AdminRecentUser {
  name: string;
  email: string;
  joinedAt: string | null;
}

export interface AdminDashboard {
  counts: AdminEntityCount[];
  gaps: AdminContentGap[];
  recentChanges: AdminRecentChange[];
  recentUsers: AdminRecentUser[];
  totalUsers: number;
  counsellingRequests: number;
  pendingCounsellingRequests: number;
  /** Rows seeded before V115 added timestamps, so with no creation date. */
  undatedRows: number;
}

export function adminGetDashboard(): Promise<AdminDashboard> {
  return adminFetch<AdminDashboard>("/api/admin/dashboard", { method: "GET" });
}
