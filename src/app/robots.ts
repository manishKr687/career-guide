import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/siteUrl";

/**
 * robots.txt, generated rather than static so the sitemap URL follows
 * NEXT_PUBLIC_SITE_URL instead of being hard-coded to one domain.
 *
 * The disallow list is everything with no reason to be in an index: the admin
 * (which is behind a token and would only ever return its login shell to a
 * crawler), the auth pages, and the signed-in profile. `/search` is excluded
 * too -- a search route generates unbounded URL permutations from query strings,
 * which is the classic way a crawler burns its budget on a site this size
 * without finding anything it could not reach from the listings.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/admin", "/login", "/register", "/profile", "/search"],
    },
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
