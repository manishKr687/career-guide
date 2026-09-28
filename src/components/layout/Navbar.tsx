"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import { useUser } from "@/components/providers/UserProvider";

// Primary links stay visible at every width the nav shows a top-level list
// at. Secondary/taxonomy links (added as the catalog grew past the original
// 4 domains) live under the "More" dropdown below instead of being appended
// here forever -- see MORE_LINKS.
const PRIMARY_LINKS = [
  { href: "/careers", label: "Careers" },
  { href: "/degrees", label: "Degrees" },
  { href: "/exams", label: "Exams" },
  { href: "/colleges", label: "Colleges" },
  { href: "/specializations", label: "Specializations" },
  { href: "/counselling", label: "Counselling" },
];

// Reference/taxonomy pages and secondary tools -- each one is a way of
// slicing or working with the same career catalog (by skill, industry, job
// role, certification, resource, category, or a side-by-side comparison)
// rather than a primary destination someone starts a session at, so they're
// grouped behind one "More" entry instead of crowding the main nav.
const MORE_LINKS = [
  { href: "/skills", label: "Skills" },
  { href: "/industries", label: "Industries" },
  { href: "/job-roles", label: "Job Roles" },
  { href: "/certifications", label: "Certifications" },
  { href: "/resources", label: "Resources" },
  { href: "/roadmap", label: "Roadmap" },
  { href: "/categories", label: "Categories" },
  { href: "/compare", label: "Compare Careers" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [moreOpen, setMoreOpen] = useState(false);
  const moreRef = useRef<HTMLDivElement>(null);
  const { user, loading, logout } = useUser();
  const router = useRouter();
  const pathname = usePathname();

  // Prefix rather than equality, so a detail page keeps its section lit --
  // /specializations/artificial-intelligence-and-machine-learning is still
  // "Specializations". The boundary check stops /careers matching a future
  // /careers-something.
  const isActive = (href: string) =>
    pathname === href || pathname.startsWith(`${href}/`);

  function handleLogout() {
    logout();
    router.push("/");
  }

  useEffect(() => {
    if (!moreOpen) return;
    function handleClick(e: MouseEvent) {
      if (moreRef.current && !moreRef.current.contains(e.target as Node)) {
        setMoreOpen(false);
      }
    }
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") setMoreOpen(false);
    }
    document.addEventListener("mousedown", handleClick);
    document.addEventListener("keydown", handleKey);
    return () => {
      document.removeEventListener("mousedown", handleClick);
      document.removeEventListener("keydown", handleKey);
    };
  }, [moreOpen]);

  return (
    <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-line">
      <Container>
        <div className="flex items-center justify-between h-16">
          <Link href="/" className="flex items-center gap-2.5 shrink-0">
            <span className="w-9 h-9 rounded-[10px] bg-navy flex items-center justify-center">
              <Icon name="cap" className="w-5 h-5 text-white" />
            </span>
            <span className="leading-tight">
              <span className="block font-display font-extrabold text-navy text-[17px] tracking-tight">
                CareerGuide
              </span>
              <span className="block text-[10px] font-semibold text-subtle tracking-wide -mt-0.5">
                Explore &middot; Learn &middot; Plan &middot; Grow
              </span>
            </span>
          </Link>

          <nav className="hidden lg:flex items-center gap-7">
            {PRIMARY_LINKS.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                aria-current={isActive(l.href) ? "page" : undefined}
                className={`text-[13.5px] font-semibold transition-colors relative py-5 ${
                  isActive(l.href)
                    ? "text-blue after:absolute after:left-0 after:right-0 after:bottom-0 after:h-[2.5px] after:bg-blue after:rounded-full"
                    : "text-ink/80 hover:text-navy"
                }`}
              >
                {l.label}
              </Link>
            ))}

            <div className="relative" ref={moreRef}>
              <button
                onClick={() => setMoreOpen((v) => !v)}
                aria-expanded={moreOpen}
                className={`flex items-center gap-1 text-[13.5px] font-semibold transition-colors ${
                  MORE_LINKS.some((m) => isActive(m.href))
                    ? "text-blue"
                    : "text-ink/80 hover:text-navy"
                }`}
              >
                More
                <Icon name="arrowDown" className={`w-3 h-3 transition-transform ${moreOpen ? "rotate-180" : ""}`} />
              </button>
              {moreOpen && (
                <div className="absolute top-full right-0 mt-3 w-56 rounded-2xl border border-line bg-white shadow-card p-2 z-10">
                  {MORE_LINKS.map((l) => (
                    <Link
                      key={l.href}
                      href={l.href}
                      onClick={() => setMoreOpen(false)}
                      aria-current={isActive(l.href) ? "page" : undefined}
                      className={`block text-[13.5px] font-semibold rounded-lg px-3 py-2.5 transition-colors ${
                        isActive(l.href)
                          ? "text-blue bg-blue-soft"
                          : "text-ink/80 hover:text-navy hover:bg-bg-soft"
                      }`}
                    >
                      {l.label}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          </nav>

          <div className="hidden lg:flex items-center gap-3">
            <Link
              href="/search"
              aria-label="Search"
              className="w-9 h-9 flex items-center justify-center rounded-lg text-ink/70 hover:text-navy hover:bg-bg-soft transition-colors"
            >
              <Icon name="search" className="w-4.5 h-4.5" />
            </Link>
            {!loading && (
              user ? (
                <button
                  onClick={handleLogout}
                  className="text-[13.5px] font-semibold text-ink/70 hover:text-navy transition-colors"
                >
                  Log out
                </button>
              ) : (
                <Link
                  href="/login"
                  className="text-[13.5px] font-semibold text-ink/70 hover:text-navy transition-colors"
                >
                  Sign In
                </Link>
              )
            )}
            <Link
              href="/profile"
              className="text-[13.5px] font-semibold text-navy px-4 py-2 rounded-lg border border-line hover:border-navy/30 transition-colors"
            >
              My Career
            </Link>
            <Link
              href="/assessment"
              className="text-[13.5px] font-bold text-white bg-navy px-4 py-2 rounded-lg hover:bg-navy-2 transition-colors flex items-center gap-2"
            >
              Take Career Test
              <Icon name="arrowRight" className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div className="lg:hidden flex items-center gap-1">
            <Link
              href="/search"
              aria-label="Search"
              className="w-9 h-9 flex items-center justify-center text-navy"
            >
              <Icon name="search" className="w-5 h-5" />
            </Link>
            <button
              className="w-9 h-9 flex items-center justify-center text-navy"
              onClick={() => setOpen((v) => !v)}
              aria-label="Toggle menu"
            >
              <Icon name={open ? "close" : "menu"} className="w-6 h-6" />
            </button>
          </div>
        </div>
      </Container>

      {open && (
        <div className="lg:hidden border-t border-line bg-white">
          <Container className="py-4 flex flex-col gap-1">
            {PRIMARY_LINKS.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                onClick={() => setOpen(false)}
                aria-current={isActive(l.href) ? "page" : undefined}
                className={`text-[14px] font-semibold py-2.5 ${
                  isActive(l.href) ? "text-blue" : "text-ink/80 hover:text-navy"
                }`}
              >
                {l.label}
              </Link>
            ))}

            <div className="text-[11px] font-bold uppercase tracking-wide text-subtle mt-3 pt-3 border-t border-line">
              More to Explore
            </div>
            {MORE_LINKS.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                onClick={() => setOpen(false)}
                aria-current={isActive(l.href) ? "page" : undefined}
                className={`text-[14px] font-semibold py-2.5 ${
                  isActive(l.href) ? "text-blue" : "text-ink/80 hover:text-navy"
                }`}
              >
                {l.label}
              </Link>
            ))}

            {!loading && (
              user ? (
                <button
                  onClick={() => {
                    setOpen(false);
                    handleLogout();
                  }}
                  className="text-left text-[14px] font-semibold text-ink/80 hover:text-navy py-2.5 mt-1"
                >
                  Log out
                </button>
              ) : (
                <Link
                  href="/login"
                  onClick={() => setOpen(false)}
                  className="text-[14px] font-semibold text-ink/80 hover:text-navy py-2.5 mt-1"
                >
                  Sign In
                </Link>
              )
            )}

            <div className="flex items-center gap-3 mt-2 pt-3 border-t border-line">
              <Link
                href="/profile"
                onClick={() => setOpen(false)}
                className="flex-1 text-center text-[13.5px] font-semibold text-navy px-4 py-2.5 rounded-lg border border-line"
              >
                My Career
              </Link>
              <Link
                href="/assessment"
                onClick={() => setOpen(false)}
                className="flex-1 text-center text-[13.5px] font-bold text-white bg-navy px-4 py-2.5 rounded-lg"
              >
                Career Test
              </Link>
            </div>
          </Container>
        </div>
      )}
    </header>
  );
}
