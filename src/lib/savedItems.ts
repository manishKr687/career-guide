const STORAGE_KEY = "careerguide.saved.v1";

// Extended to "careers"/"exams" alongside the original "colleges" once the
// backend's saved-items endpoints (V31) covered all three -- see
// SavedItemsProvider, which uses this as the logged-out fallback and syncs
// it to the server on login. ("courses" was removed along with the Courses
// feature -- see V43__remove_courses.sql.)
export type SavedType = "careers" | "colleges" | "exams";

interface SavedStore {
  careers: string[];
  colleges: string[];
  exams: string[];
}

function readStore(): SavedStore {
  const empty: SavedStore = { careers: [], colleges: [], exams: [] };
  if (typeof window === "undefined") return empty;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return empty;
    const parsed = JSON.parse(raw);
    return {
      careers: parsed.careers ?? [],
      colleges: parsed.colleges ?? [],
      exams: parsed.exams ?? [],
    };
  } catch {
    return empty;
  }
}

function writeStore(store: SavedStore) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  } catch {
    // ignore
  }
}

export function isSaved(type: SavedType, slug: string): boolean {
  return readStore()[type].includes(slug);
}

export function toggleSaved(type: SavedType, slug: string): boolean {
  const store = readStore();
  const list = store[type];
  const idx = list.indexOf(slug);
  if (idx >= 0) {
    list.splice(idx, 1);
  } else {
    list.push(slug);
  }
  writeStore(store);
  return list.includes(slug);
}

export function getSavedSlugs(type: SavedType): string[] {
  return readStore()[type];
}

/** Empties one type's local list -- used after migrating it to the server on login, so a later logout doesn't resurrect already-migrated slugs. */
export function clearSavedType(type: SavedType): void {
  const store = readStore();
  store[type] = [];
  writeStore(store);
}
