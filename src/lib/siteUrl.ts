/**
 * The site's own public origin, used for canonical URLs, Open Graph images,
 * robots.txt and the sitemap.
 *
 * Set NEXT_PUBLIC_SITE_URL at BUILD time, the same as NEXT_PUBLIC_API_BASE_URL
 * -- a NEXT_PUBLIC_ value is inlined during `next build`, so setting it in the
 * running container has no effect. Getting this wrong does not break the site,
 * it breaks the things nobody checks: link previews resolve against the wrong
 * host and every canonical URL points somewhere else.
 *
 * The localhost default is deliberate rather than a placeholder for a real
 * domain. A wrong absolute domain baked into a build looks correct in the HTML
 * and silently tells crawlers your pages live somewhere they do not; localhost
 * is obviously wrong the moment anyone looks.
 */
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000").replace(/\/$/, "");

/** Absolute URL for a site-relative path. */
export function absoluteUrl(path: string): string {
  return `${SITE_URL}${path.startsWith("/") ? path : `/${path}`}`;
}
