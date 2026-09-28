import { API_BASE_URL, ApiError } from "@/lib/api";

const TOKEN_STORAGE_KEY = "careerguide_user_token";

// End-user auth, mirroring lib/adminApi.ts's pattern exactly (Bearer token
// in localStorage, no server-side session) -- see UserAuthInterceptor on the
// backend for why this is safe: it resolves the token to a user id itself,
// so a client never sends a user id it could tamper with.
export function getUserToken(): string | null {
  if (typeof window === "undefined") return null;
  try {
    return window.localStorage.getItem(TOKEN_STORAGE_KEY);
  } catch {
    return null;
  }
}

function setUserToken(token: string): void {
  try {
    window.localStorage.setItem(TOKEN_STORAGE_KEY, token);
  } catch {
    // Storage unavailable (e.g. private browsing) -- login still "works" for
    // this page load, it just won't survive a refresh.
  }
}

export function clearUserToken(): void {
  try {
    window.localStorage.removeItem(TOKEN_STORAGE_KEY);
  } catch {
    // ignore
  }
}

/** Thrown when the server rejects the stored token (missing/expired). Callers should treat the user as logged out. */
export class UserUnauthorizedError extends Error {
  constructor() {
    super("Your session has expired. Please log in again.");
    this.name = "UserUnauthorizedError";
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

export interface User {
  id: number;
  email: string;
  name: string;
  createdAt: string;
  interests: string[];
}

export interface UserProfile {
  educationStageSlug: string | null;
  streamSlug: string | null;
  educationLevel: string | null;
  graduationYear: number | null;
  experienceYears: number | null;
  location: string | null;
}

export interface UserSkill {
  skillSlug: string;
  skillName: string;
  proficiencyLevel: string | null;
  yearsOfExperience: number | null;
}

/** Registers a new account, stores the returned token, and returns the created user. */
export async function userRegister(email: string, password: string, name: string): Promise<User> {
  const res = await fetch(`${API_BASE_URL}/api/auth/register`, {
    method: "POST",
    cache: "no-store",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password, name }),
  });
  if (!res.ok) {
    throw new ApiError(res.status, await errorMessage(res, `Registration failed: ${res.status} ${res.statusText}`));
  }
  const data = (await res.json()) as { token: string; user: User };
  setUserToken(data.token);
  return data.user;
}

/** Logs in against POST /api/auth/login, stores the returned token, and returns the user. */
export async function userLogin(email: string, password: string): Promise<User> {
  const res = await fetch(`${API_BASE_URL}/api/auth/login`, {
    method: "POST",
    cache: "no-store",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) {
    throw new ApiError(res.status, await errorMessage(res, `Login failed: ${res.status} ${res.statusText}`));
  }
  const data = (await res.json()) as { token: string; user: User };
  setUserToken(data.token);
  return data.user;
}

export function userLogout(): void {
  clearUserToken();
}

/**
 * Authenticated fetch for /api/me/** endpoints. Throws UserUnauthorizedError
 * on 401 (after clearing the stale token), or ApiError (with the backend's
 * message) for any other non-2xx response.
 */
async function meFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = getUserToken();
  const res = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    cache: "no-store",
    headers: {
      ...(options.headers as Record<string, string> | undefined),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (res.status === 401) {
    clearUserToken();
    throw new UserUnauthorizedError();
  }
  if (!res.ok) {
    const method = options.method ?? "GET";
    throw new ApiError(res.status, await errorMessage(res, `${method} ${path} failed: ${res.status} ${res.statusText}`));
  }
  // A void-returning Spring @RestController method (saveEntity/unsaveEntity/
  // removeMySkill's DELETE) sends 200 with an EMPTY body by default, not 204,
  // unless the controller opts into @ResponseStatus(NO_CONTENT) -- res.json()
  // on that empty body throws a SyntaxError ("Unexpected end of JSON input"),
  // which every caller here treats as a failed save/unsave/remove. Read as
  // text first and only parse if there's actually something to parse, so
  // this doesn't depend on getting the exact status code the backend sends.
  const text = await res.text();
  if (!text) {
    return undefined as T;
  }
  return JSON.parse(text) as T;
}

export function getMe(): Promise<User> {
  return meFetch<User>("/api/me");
}

export function getMyProfile(): Promise<UserProfile> {
  return meFetch<UserProfile>("/api/me/profile");
}

export function updateMyProfile(body: UserProfile): Promise<UserProfile> {
  return meFetch<UserProfile>("/api/me/profile", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

export function updateMyInterests(interests: string[]): Promise<User> {
  return meFetch<User>("/api/me/interests", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ interests }),
  });
}

export function getMySkills(): Promise<UserSkill[]> {
  return meFetch<UserSkill[]>("/api/me/skills");
}

export function upsertMySkill(skillSlug: string, proficiencyLevel?: string, yearsOfExperience?: number): Promise<UserSkill> {
  return meFetch<UserSkill>("/api/me/skills", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ skillSlug, proficiencyLevel, yearsOfExperience }),
  });
}

export function removeMySkill(skillSlug: string): Promise<void> {
  return meFetch<void>(`/api/me/skills/${encodeURIComponent(skillSlug)}`, { method: "DELETE" });
}

// --- Server-backed saved items (V31) -- one save/unsave/list trio per type,
// matching SavedItemsController exactly. `Saved` here is intentionally a
// generic name shared with lib/types.ts's catalog interfaces (Career,
// College, etc.) since these endpoints return the same full DTOs.
export type SavedEntityType = "careers" | "colleges" | "exams";

export function getSavedEntitySlugs<T extends { slug: string }>(type: SavedEntityType): Promise<T[]> {
  return meFetch<T[]>(`/api/me/saved/${type}`);
}

export function saveEntity(type: SavedEntityType, slug: string): Promise<void> {
  return meFetch<void>(`/api/me/saved/${type}/${encodeURIComponent(slug)}`, { method: "POST" });
}

export function unsaveEntity(type: SavedEntityType, slug: string): Promise<void> {
  return meFetch<void>(`/api/me/saved/${type}/${encodeURIComponent(slug)}`, { method: "DELETE" });
}
