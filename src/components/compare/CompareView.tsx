"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Select from "@/components/ui/Select";
import { Career, Category, Degree, Industry, Skill } from "@/lib/types";
import { getCareers, getManyCareers } from "@/data/careers";
import { getCategories } from "@/data/categories";
import { getIndustries } from "@/data/industries";
import { getSkills } from "@/data/skills";
import { getDegrees } from "@/data/degrees";
import { getCompareSlugs, setCompareSlugs, MAX_COMPARE } from "@/lib/compareList";

const DEMAND_STYLES: Record<string, string> = {
  "High Demand": "bg-amber-soft text-amber",
  Emerging: "bg-purple-soft text-purple",
  Evergreen: "bg-green-soft text-green",
  Stable: "bg-blue-soft text-blue",
  Competitive: "bg-pink-soft text-pink",
};

type Row = {
  label: string;
  render: (
    c: Career,
    category?: Category,
    industriesBySlug?: Map<string, Industry>,
    skillsBySlug?: Map<string, Skill>,
    degreesBySlug?: Map<string, Degree>
  ) => React.ReactNode;
};

const ROWS: Row[] = [
  { label: "Category", render: (c, category) => category?.name ?? "—" },
  {
    label: "Demand",
    render: (c) => (
      <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${DEMAND_STYLES[c.demand]}`}>
        {c.demand}
      </span>
    ),
  },
  {
    label: "Education",
    // Titles are composed server-side (V103) -- the rule is level-dependent
    // ("B.A. (Psychology)" but "PhD in Psychology"), so rebuilding it here
    // from a degree lookup would drop the subject and drift from every other
    // page that shows education.
    render: (c) =>
      c.education.length > 0 ? c.education.map((e) => e.title).join(" / ") : "—",
  },
  { label: "Salary Range", render: (c) => c.salaryRange || "—" },
  { label: "Typical Work", render: (c) => c.typicalWork || "—" },
  {
    label: "Key Skills",
    render: (c, _category, _industriesBySlug, skillsBySlug) => {
      const names = c.relatedSkillSlugs
        .map((slug) => skillsBySlug?.get(slug)?.name)
        .filter((name): name is string => Boolean(name));
      return names.length > 0 ? (
        <div className="flex flex-wrap gap-1.5">
          {names.map((name) => (
            <span key={name} className="text-[11px] font-semibold px-2 py-1 rounded-full bg-bg-soft text-ink/70">
              {name}
            </span>
          ))}
        </div>
      ) : (
        "—"
      );
    },
  },
  {
    label: "Growth Path",
    render: (c) => (c.growthPath.length > 0 ? c.growthPath.join(" → ") : "—"),
  },
  {
    label: "Top Recruiters",
    render: (c, _category, industriesBySlug) => {
      const names = c.relatedIndustrySlugs
        .map((slug) => industriesBySlug?.get(slug)?.name)
        .filter((name): name is string => Boolean(name));
      return names.length > 0 ? names.join(", ") : "—";
    },
  },
];

/**
 * Client-driven so it can read/write the compare list in localStorage (see
 * lib/compareList.ts) while also keeping the URL in sync -- matching the
 * "shareable and bookmarkable" URL-state pattern used by useUrlListState
 * elsewhere, but one-directional here: this page is the only place that
 * writes ?careers=..., so there's no risk of fighting with a hook that also
 * wants to own the URL.
 */
export default function CompareView({
  initialCareers,
  hasUrlParam,
}: {
  initialCareers: Career[];
  /**
   * False for a bare `/compare` visit (no `?careers=` at all, e.g. from the
   * nav) -- then the visitor's existing localStorage compare list is the
   * source of truth instead of the (necessarily empty) server-rendered
   * list, and it's loaded client-side below. True whenever `?careers=` was
   * present, even if it resolved to nothing (a shared link whose careers
   * were since removed) -- that case should NOT fall back to localStorage.
   */
  hasUrlParam: boolean;
}) {
  const router = useRouter();
  const pathname = usePathname();

  const [careers, setCareers] = useState<Career[]>(initialCareers);
  const [categories, setCategories] = useState<Category[]>([]);
  const [industries, setIndustries] = useState<Industry[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [degrees, setDegrees] = useState<Degree[]>([]);
  const [allCareers, setAllCareers] = useState<Career[] | null>(null);
  const [addSlug, setAddSlug] = useState("");

  useEffect(() => {
    getCategories().then(setCategories).catch(() => setCategories([]));
    getIndustries().then(setIndustries).catch(() => setIndustries([]));
    getSkills().then(setSkills).catch(() => setSkills([]));
    getDegrees().then(setDegrees).catch(() => setDegrees([]));
    getCareers().then(setAllCareers).catch(() => setAllCareers([]));

    if (hasUrlParam) {
      // This page's URL is the source of truth (a shared link, or one this
      // page just wrote itself) -- mirror it into localStorage so the
      // CompareButton/CompareBar elsewhere on the site reflect it too.
      setCompareSlugs(initialCareers.map((c) => c.slug));
      return;
    }

    // Bare /compare: load whatever's already in localStorage instead, and
    // turn the URL into a shareable link for it once loaded.
    const storedSlugs = getCompareSlugs();
    if (storedSlugs.length === 0) return;
    getManyCareers(storedSlugs).then((loaded) => {
      setCareers(loaded);
      const qs = loaded.length > 0 ? `?careers=${loaded.map((c) => encodeURIComponent(c.slug)).join(",")}` : "";
      router.replace(`${pathname}${qs}`, { scroll: false });
    });
    // Only run once on mount -- `initialCareers`/`hasUrlParam` describe this
    // page's starting point, not values that should re-trigger this effect.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const categoriesBySlug = useMemo(() => new Map(categories.map((c) => [c.slug, c])), [categories]);
  const industriesBySlug = useMemo(() => new Map(industries.map((i) => [i.slug, i])), [industries]);
  const skillsBySlug = useMemo(() => new Map(skills.map((s) => [s.slug, s])), [skills]);
  const degreesBySlug = useMemo(() => new Map(degrees.map((d) => [d.slug, d])), [degrees]);

  const syncTo = useCallback(
    (next: Career[]) => {
      setCareers(next);
      const slugs = next.map((c) => c.slug);
      setCompareSlugs(slugs);
      const qs = slugs.length > 0 ? `?careers=${slugs.map(encodeURIComponent).join(",")}` : "";
      router.replace(`${pathname}${qs}`, { scroll: false });
    },
    [router, pathname]
  );

  function removeCareer(slug: string) {
    syncTo(careers.filter((c) => c.slug !== slug));
  }

  function addCareer(slug: string) {
    if (!slug || careers.some((c) => c.slug === slug) || careers.length >= MAX_COMPARE) return;
    const found = allCareers?.find((c) => c.slug === slug);
    if (!found) return;
    syncTo([...careers, found]);
    setAddSlug("");
  }

  const availableToAdd = (allCareers ?? []).filter((c) => !careers.some((sel) => sel.slug === c.slug));

  return (
    <Container className="py-10 pb-24">
      <div className="flex flex-wrap items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-navy text-2xl sm:text-3xl">Compare Careers</h1>
          <p className="text-muted text-[14px] mt-1.5">
            Compare up to {MAX_COMPARE} careers side by side. This link updates as you add or remove one, so you can share it.
          </p>
        </div>
        {careers.length < MAX_COMPARE && allCareers !== null && (
          <div className="w-full sm:w-64">
            <Select
              label="Add a career"
              value={addSlug}
              onChange={(e) => addCareer(e.target.value)}
            >
              <option value="">Select a career…</option>
              {availableToAdd.map((c) => (
                <option key={c.slug} value={c.slug}>
                  {c.title}
                </option>
              ))}
            </Select>
          </div>
        )}
      </div>

      {careers.length === 0 ? (
        <div className="text-center py-24 border border-line rounded-2xl">
          <div className="w-14 h-14 rounded-2xl bg-blue-soft flex items-center justify-center text-blue mx-auto mb-4">
            <Icon name="scale" className="w-7 h-7" />
          </div>
          <p className="text-navy font-display font-bold text-[16px] mb-1.5">No careers to compare yet</p>
          <p className="text-muted text-[13.5px] mb-6">
            Add a career above, or use the Compare button on any career card.
          </p>
          <Link
            href="/careers"
            className="inline-flex text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors"
          >
            Browse Careers
          </Link>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-line">
          <table className="w-full text-left text-[13.5px] border-collapse">
            <thead>
              <tr className="bg-bg-soft">
                <th className="px-4 py-4 font-bold text-ink w-40 align-bottom">Career</th>
                {careers.map((c) => (
                  <th key={c.slug} className="px-4 py-4 align-bottom min-w-[220px]">
                    <div className="flex items-start justify-between gap-2">
                      <Link
                        href={`/careers/${c.slug}`}
                        className="font-display font-extrabold text-navy text-[15px] hover:underline"
                      >
                        {c.title}
                      </Link>
                      <button
                        onClick={() => removeCareer(c.slug)}
                        aria-label={`Remove ${c.title} from comparison`}
                        className="text-subtle hover:text-red transition-colors shrink-0"
                      >
                        <Icon name="close" className="w-4 h-4" />
                      </button>
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {ROWS.map((row) => (
                <tr key={row.label} className="border-t border-line">
                  <td className="px-4 py-4 font-bold text-ink/70 align-top">{row.label}</td>
                  {careers.map((c) => (
                    <td key={c.slug} className="px-4 py-4 text-ink align-top">
                      {row.render(c, categoriesBySlug.get(c.categorySlug), industriesBySlug, skillsBySlug, degreesBySlug)}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Container>
  );
}
