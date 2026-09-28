"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import Link from "next/link";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import { adminListCounsellingRequests, clearAdminToken, getAdminToken } from "@/lib/adminApi";

/**
 * The admin shell: a fixed left sidebar and a top bar.
 *
 * It replaced a single horizontal nav bar that had to hold all 15 links in a
 * row -- workable at ten, and by fifteen it wrapped onto a second line and
 * the grouping was gone. A vertical rail has room for the labels, and more
 * importantly room to say which group each one belongs to: the catalog, the
 * places, the inbox.
 */

interface NavLink {
  href: string;
  label: string;
  icon: string;
}

interface NavGroup {
  /** Null for the first group, which needs no heading above the first item. */
  heading: string | null;
  links: NavLink[];
}

const NAV_GROUPS: NavGroup[] = [
  {
    heading: null,
    links: [{ href: "/admin", label: "Dashboard", icon: "grid" }],
  },
  {
    heading: "Catalog",
    links: [
      { href: "/admin/careers", label: "Careers", icon: "brief" },
      { href: "/admin/specializations", label: "Specializations", icon: "layers" },
      { href: "/admin/job-roles", label: "Job Roles", icon: "users" },
      { href: "/admin/degrees", label: "Degrees", icon: "cap" },
      { href: "/admin/exams", label: "Exams", icon: "doc" },
      { href: "/admin/colleges", label: "Colleges", icon: "bld" },
      { href: "/admin/skills", label: "Skills", icon: "bolt" },
      { href: "/admin/industries", label: "Industries", icon: "building" },
      { href: "/admin/certifications", label: "Certifications", icon: "award" },
      { href: "/admin/resources", label: "Resources", icon: "book" },
    ],
  },
  {
    heading: "Places",
    links: [
      { href: "/admin/universities", label: "Universities", icon: "bank" },
      { href: "/admin/states", label: "States", icon: "mappin" },
      { href: "/admin/cities", label: "Cities", icon: "mappin" },
    ],
  },
  {
    heading: "Inbox",
    links: [{ href: "/admin/counselling-requests", label: "Counselling Requests", icon: "mail" }],
  },
];

const ALL_LINKS = NAV_GROUPS.flatMap((g) => g.links);

function isActive(pathname: string, href: string): boolean {
  return href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
}

/** The longest matching nav label, so /admin/careers/x/edit still reads "Careers". */
function pageTitle(pathname: string): string {
  const match = ALL_LINKS.filter((l) => isActive(pathname, l.href)).sort(
    (a, b) => b.href.length - a.href.length
  )[0];
  return match?.label ?? "Admin";
}

export default function AdminProtectedLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [checked, setChecked] = useState(false);
  const [navOpen, setNavOpen] = useState(false);

  // The one number in the chrome, and it is a real queue rather than a
  // decorative bell: pending counselling requests are the only thing in this
  // admin that someone is waiting on. Fails silent -- an unreachable backend
  // shows no badge rather than a zero, because zero would read as "nothing
  // to do".
  const [pending, setPending] = useState<number | null>(null);

  useEffect(() => {
    if (!getAdminToken()) {
      router.replace("/admin/login");
      return;
    }
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setChecked(true);
  }, [router]);

  useEffect(() => {
    if (!checked) return;
    let cancelled = false;
    adminListCounsellingRequests()
      .then((requests) => {
        if (!cancelled) setPending(requests.filter((r) => r.status === "PENDING").length);
      })
      .catch(() => {
        if (!cancelled) setPending(null);
      });
    return () => {
      cancelled = true;
    };
  }, [checked]);

  function handleLogout() {
    clearAdminToken();
    router.push("/admin/login");
  }

  if (!checked) {
    return (
      <Container className="py-20">
        <p className="text-[13.5px] text-subtle">Checking admin session...</p>
      </Container>
    );
  }

  const sidebar = (
    <div className="flex flex-col h-full bg-navy">
      <div className="flex items-center gap-2.5 px-5 h-16 shrink-0 border-b border-white/10">
        <span className="w-8 h-8 rounded-lg bg-blue text-white flex items-center justify-center shrink-0">
          <Icon name="compass" className="w-[18px] h-[18px]" />
        </span>
        <span className="font-display font-extrabold text-white text-[14.5px] leading-tight">
          CareerGuide
          <span className="block text-[11px] font-bold text-white/45 tracking-wide uppercase">Admin</span>
        </span>
      </div>

      <nav className="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-5">
        {NAV_GROUPS.map((group, gi) => (
          <div key={group.heading ?? `group-${gi}`}>
            {group.heading && (
              <div className="text-[10.5px] font-bold text-white/35 uppercase tracking-widest px-3 mb-1.5">
                {group.heading}
              </div>
            )}
            <ul className="flex flex-col gap-0.5">
              {group.links.map((link) => {
                const active = isActive(pathname, link.href);
                return (
                  <li key={link.href}>
                    <Link
                      href={link.href}
                      className={`flex items-center gap-2.5 text-[13px] font-bold px-3 py-2 rounded-lg transition-colors ${
                        active ? "bg-white/15 text-white" : "text-white/60 hover:text-white hover:bg-white/5"
                      }`}
                    >
                      <Icon name={link.icon} className="w-4 h-4 shrink-0" />
                      <span className="truncate">{link.label}</span>
                      {link.href === "/admin/counselling-requests" && pending !== null && pending > 0 && (
                        <span className="ml-auto text-[11px] font-bold px-1.5 py-0.5 rounded-md bg-amber text-white shrink-0">
                          {pending}
                        </span>
                      )}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      <div className="px-3 py-4 shrink-0 border-t border-white/10">
        <Link
          href="/"
          className="flex items-center gap-2.5 text-[13px] font-bold text-white/60 hover:text-white px-3 py-2 rounded-lg hover:bg-white/5 transition-colors"
        >
          <Icon name="external" className="w-4 h-4 shrink-0" />
          View site
        </Link>
      </div>
    </div>
  );

  return (
    <div className="bg-bg-soft min-h-screen lg:flex">
      {/* Desktop rail: sticky rather than fixed, so the main column keeps its
          own normal document flow and needs no left padding hack. */}
      <aside className="hidden lg:block w-60 shrink-0 sticky top-0 h-screen">{sidebar}</aside>

      {navOpen && (
        <div className="lg:hidden fixed inset-0 z-40 flex">
          {/* Closing on bubbled clicks rather than on a pathname effect: any
              link inside the drawer both navigates and dismisses it, and the
              drawer never has to re-render the whole shell to do it. */}
          <div className="w-64 h-full shadow-xl" onClick={() => setNavOpen(false)}>
            {sidebar}
          </div>
          <button
            aria-label="Close menu"
            onClick={() => setNavOpen(false)}
            className="flex-1 h-full bg-navy/50"
          />
        </div>
      )}

      <div className="flex-1 min-w-0 flex flex-col">
        <header className="sticky top-0 z-30 bg-white border-b border-line">
          <div className="flex items-center gap-4 h-16 px-4 sm:px-6">
            <button
              aria-label="Open menu"
              onClick={() => setNavOpen(true)}
              className="lg:hidden w-9 h-9 rounded-lg border border-line text-navy flex items-center justify-center shrink-0"
            >
              <Icon name="menu" className="w-[18px] h-[18px]" />
            </button>

            <h1 className="font-display font-extrabold text-navy text-[17px] truncate">
              {pageTitle(pathname)}
            </h1>

            <div className="ml-auto flex items-center gap-2 sm:gap-3">
              <Link
                href="/admin/counselling-requests"
                aria-label="Counselling requests"
                className="relative w-9 h-9 rounded-lg border border-line text-muted hover:text-navy hover:border-navy/30 flex items-center justify-center transition-colors"
              >
                <Icon name="mega" className="w-[17px] h-[17px]" />
                {pending !== null && pending > 0 && (
                  <span className="absolute -top-1 -right-1 min-w-[17px] h-[17px] px-1 rounded-full bg-amber text-white text-[10px] font-bold flex items-center justify-center">
                    {pending}
                  </span>
                )}
              </Link>

              <span className="hidden sm:flex items-center gap-2.5 pl-1">
                <span className="w-9 h-9 rounded-full bg-navy text-white font-display font-bold text-[13px] flex items-center justify-center shrink-0">
                  A
                </span>
                <span className="leading-tight">
                  <span className="block text-[13px] font-bold text-navy">Administrator</span>
                  <span className="block text-[11.5px] text-subtle">Full access</span>
                </span>
              </span>

              <button
                onClick={handleLogout}
                className="text-[12.5px] font-bold text-muted hover:text-navy px-3 py-2 rounded-lg border border-line hover:border-navy/30 transition-colors"
              >
                Log out
              </button>
            </div>
          </div>
        </header>

        <main className="flex-1 px-4 sm:px-6 py-7">{children}</main>
      </div>
    </div>
  );
}
