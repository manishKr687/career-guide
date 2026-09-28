const STORAGE_KEY = "careerguide.compare.v1";
export const MAX_COMPARE = 4;

// Compare is career-only for v1 -- the catalog's richest entity, and the one
// with enough shared fields (demand, education, salary, skills, growth
// path) to make a side-by-side table actually useful. Courses/exams/
// colleges could get their own compare lists later using this same shape.
function readList(): string[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter((s): s is string => typeof s === "string") : [];
  } catch {
    return [];
  }
}

function writeList(list: string[]) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
  } catch {
    // ignore
  }
  // Notify same-tab listeners (CompareButton instances, the floating
  // CompareBar) immediately -- the native `storage` event only fires in
  // OTHER tabs/windows, never the one that made the write.
  window.dispatchEvent(new Event("compare:change"));
}

export function getCompareSlugs(): string[] {
  return readList();
}

export function isComparing(slug: string): boolean {
  return readList().includes(slug);
}

/**
 * Adds/removes `slug`. Returns `{ slugs, added }` -- `added` is false both
 * when removing and when adding was refused for being at MAX_COMPARE, so
 * callers (CompareButton) can tell "removed" apart from "list is full" and
 * show the right toast.
 */
export function toggleCompare(slug: string): { slugs: string[]; added: boolean } {
  const list = readList();
  const idx = list.indexOf(slug);
  if (idx >= 0) {
    list.splice(idx, 1);
    writeList(list);
    return { slugs: list, added: false };
  }
  if (list.length >= MAX_COMPARE) {
    return { slugs: list, added: false };
  }
  list.push(slug);
  writeList(list);
  return { slugs: list, added: true };
}

export function setCompareSlugs(slugs: string[]): void {
  writeList(slugs.slice(0, MAX_COMPARE));
}

export function removeFromCompare(slug: string): string[] {
  const list = readList().filter((s) => s !== slug);
  writeList(list);
  return list;
}
