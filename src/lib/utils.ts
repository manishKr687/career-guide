export function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

/** Indexes a list of slugged items by their slug, for O(1) lookup during render. */
export function indexBySlug<T extends { slug: string }>(items: T[]): Map<string, T> {
  return new Map(items.map((item) => [item.slug, item]));
}

/** Formats an ISO date string ("YYYY-MM-DD") for display, falling back to the raw string on a parse failure. */
export function formatDate(iso: string): string {
  try {
    return new Date(iso).toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
  } catch {
    return iso;
  }
}

/**
 * Whether `description` is the generated placeholder rather than written prose.
 *
 * 262 of 263 specializations carry a description of the exact form "<name> is a
 * specialization within <career>." It says nothing the <h1> and the category
 * chip beside it do not already say, and it was filling the two places on this
 * page a reader and a crawler look first: the paragraph under the title, and the
 * meta description Google prints as the search snippet.
 *
 * V134-V146 wrote a real `overview` for every specialization, so there is now
 * something better to show in both places. This detects the stub instead of
 * ignoring `description` altogether, because a description someone has actually
 * written is worth showing and the admin form can set one.
 *
 * Matched by prefix rather than by regex: names contain characters that would
 * need escaping (UI/UX Design, Petroleum & Petrochemicals, CAD/CAM).
 */
export function isGeneratedStub({ name, description }: { name: string; description: string }): boolean {
  const d = description.trim();
  return d.length === 0 || d.startsWith(`${name} is a specialization within `);
}

/**
 * Whether a career's `tagline` is the generated placeholder. All 55 careers
 * carry one of the form "<title> -- specializations, skills & career paths",
 * which restates the title the card already shows in bold above it. Detected
 * rather than ignored for the same reason as isGeneratedStub: a tagline
 * someone has actually written is worth showing.
 */
export function isCareerTaglineStub({ title, tagline }: { title: string; tagline: string | null }): boolean {
  const t = (tagline ?? "").trim();
  return t.length === 0 || t === `${title} -- specializations, skills & career paths`;
}
