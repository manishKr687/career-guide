"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Input from "@/components/ui/Input";
import Select from "@/components/ui/Select";
import Button from "@/components/ui/Button";
import CollegeCard from "@/components/cards/CollegeCard";
import CareerCard from "@/components/cards/CareerCard";
import ExamCard from "@/components/cards/ExamCard";
import { useUser } from "@/components/providers/UserProvider";
import { useSavedItems } from "@/components/providers/SavedItemsProvider";
import { loadAssessment, submitAssessment } from "@/lib/assessment";
import {
  UserSkill,
  getMySkills,
  upsertMySkill,
  removeMySkill,
  updateMyInterests,
} from "@/lib/userApi";
import { getManyColleges } from "@/data/colleges";
import { getManyCareers } from "@/data/careers";
import { getManyExams } from "@/data/exams";
import { getSkills } from "@/data/skills";
import { Category, Career, College, Exam, Skill } from "@/lib/types";
import { indexBySlug, formatDate } from "@/lib/utils";

// Preview counts on the profile page are smaller than the assessment
// results page's (3 vs. the API's defaults of 4 top categories / 6
// recommended careers). Both arrays the API returns are already ordered
// most-to-least relevant, so slicing down to a shorter preview here is
// equivalent to asking the scoring algorithm for a smaller count.
const PROFILE_TOP_CATEGORY_COUNT = 3;
const PROFILE_RECOMMENDED_CAREER_COUNT = 3;

const PROFICIENCY_LEVELS = ["Beginner", "Intermediate", "Advanced", "Expert"];

// Every tile now links somewhere real (they used to be plain divs with no
// href at all). `authHref` is used instead of `href` once the person is
// logged in, for the two tiles that live inside the account panel below
// (My Interests, Skill Progress) -- signed out there's nothing at #account
// to show, so those route to sign-in instead. `soon` tiles (My Education,
// Applications, Achievements) have no implemented feature anywhere in the
// app yet, so rather than a dead link they render disabled with a badge.
const MENU_ITEMS: Array<{
  icon: string;
  label: string;
  href?: string;
  authHref?: string;
  primary?: boolean;
  soon?: boolean;
}> = [
  { icon: "cap", label: "My Education", soon: true },
  { icon: "heart", label: "My Interests", href: "/login?next=/profile", authHref: "#account" },
  { icon: "target", label: "Career Assessment", href: "#assessment-section", primary: true },
  { icon: "award", label: "Recommended Careers", href: "#assessment-section" },
  { icon: "bld", label: "Saved Colleges", href: "#saved-colleges" },
  { icon: "mappin", label: "My Career Roadmap", href: "/roadmap" },
  { icon: "cal", label: "Exam Preparation", href: "/exams" },
  { icon: "trend", label: "Skill Progress", href: "/login?next=/profile", authHref: "#account" },
  { icon: "clip", label: "Applications", soon: true },
  { icon: "trophy", label: "Achievements", soon: true },
];

export default function ProfileView() {
  const { user, loading: userLoading, logout } = useUser();
  const { getSavedSlugs, ready: savedReady } = useSavedItems();

  const [ready, setReady] = useState(false);
  const [assessmentDone, setAssessmentDone] = useState(false);
  const [topCategories, setTopCategories] = useState<Category[]>([]);
  const [recommended, setRecommended] = useState<Career[]>([]);
  const [savedCareers, setSavedCareers] = useState<Career[]>([]);
  const [savedColleges, setSavedColleges] = useState<College[]>([]);
  const [savedExams, setSavedExams] = useState<Exam[]>([]);

  // Assessment results are local-only (see lib/assessment) and independent
  // of login state, so this loads once on mount regardless of auth.
  useEffect(() => {
    let cancelled = false;
    async function load() {
      const stored = loadAssessment();
      const assessmentResult = stored ? await submitAssessment(stored.answers) : null;
      if (cancelled) return;
      if (assessmentResult) {
        setTopCategories(assessmentResult.topCategories.slice(0, PROFILE_TOP_CATEGORY_COUNT));
        setRecommended(assessmentResult.recommendedCareers.slice(0, PROFILE_RECOMMENDED_CAREER_COUNT));
        setAssessmentDone(true);
      }
      setReady(true);
    }
    load();
    return () => {
      cancelled = true;
    };
  }, []);

  // Saved-item slugs come from SavedItemsProvider (server-backed once logged
  // in, localStorage otherwise), so this re-runs whenever that source
  // changes -- e.g. right after the post-login migration finishes.
  useEffect(() => {
    if (!savedReady) return;
    let cancelled = false;
    async function load() {
      const [careers, colleges, exams] = await Promise.all([
        getManyCareers(getSavedSlugs("careers")),
        getManyColleges(getSavedSlugs("colleges")),
        getManyExams(getSavedSlugs("exams")),
      ]);
      if (cancelled) return;
      setSavedCareers(careers);
      setSavedColleges(colleges);
      setSavedExams(exams);
    }
    load();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [savedReady, user]);

  const categoriesBySlug = indexBySlug(topCategories);

  if (!ready) return null;

  const progress = Math.round(
    (assessmentDone ? 25 : 0) +
      (savedCareers.length > 0 ? 25 : 0) +
      (savedColleges.length > 0 ? 25 : 0) +
      (savedExams.length > 0 ? 25 : 0)
  );

  const savedTabs = [
    tabContent("saved-careers", "Careers", savedCareers, "/careers", "careers", (c: Career) => (
      <CareerCard key={c.slug} career={c} />
    )),
    tabContent("saved-colleges", "Colleges", savedColleges, "/colleges", "colleges", (c: College) => (
      <CollegeCard key={c.slug} college={c} />
    )),
    tabContent("saved-exams", "Exams", savedExams, "/exams", "exams", (e: Exam) => (
      <ExamCard key={e.slug} exam={e} />
    )),
  ];

  return (
    <div>
      {!userLoading && !user && (
        <div className="mb-8 rounded-2xl border border-dashed border-line p-6 sm:p-7 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-6 bg-bg-soft">
          <div className="w-11 h-11 rounded-xl bg-white flex items-center justify-center shrink-0 border border-line">
            <Icon name="user" className="w-5 h-5 text-navy" />
          </div>
          <div className="flex-1">
            <div className="font-display font-extrabold text-navy text-[15px]">
              Sign in to save your progress across devices
            </div>
            <p className="text-[13px] text-subtle mt-1">
              Your saved careers, colleges and exams are stored on this device only.
              Create a free account to keep them synced everywhere.
            </p>
          </div>
          <Link
            href="/login?next=/profile"
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-2.5 rounded-xl hover:bg-navy-2 transition-colors whitespace-nowrap"
          >
            Sign In
          </Link>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-[0.85fr_1.15fr] gap-6">
        <div className="rounded-3xl p-7 bg-gradient-to-br from-navy to-navy-2 text-white flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 rounded-xl bg-white/10 flex items-center justify-center">
                <Icon name="user" className="w-5 h-5" />
              </div>
              <div className="font-display font-extrabold text-lg">
                {user ? user.name : "Career Journey"}
              </div>
            </div>
            <p className="text-white/60 text-[13px] mt-3 leading-relaxed">
              {user
                ? `Signed in as ${user.email}`
                : "Complete your assessment and save careers, colleges & exams to build out your profile."}
            </p>
          </div>
          <div className="mt-8">
            {progress > 0 ? (
              <>
                <div className="flex justify-between text-[12px] font-bold text-white/60 mb-2">
                  <span>Progress</span>
                  <span className="text-amber">{progress}% Complete</span>
                </div>
                <div className="h-2.5 rounded-full bg-white/15 overflow-hidden">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-amber to-yellow-300 transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              </>
            ) : (
              <div className="rounded-xl bg-white/10 px-4 py-3.5 flex items-center justify-between gap-3">
                <p className="text-[12.5px] font-semibold text-white/80">
                  Take the assessment to start building your profile.
                </p>
                <Link
                  href="/assessment"
                  className="shrink-0 text-[12px] font-bold text-navy bg-amber px-3.5 py-2 rounded-lg hover:bg-yellow-300 transition-colors whitespace-nowrap"
                >
                  Start
                </Link>
              </div>
            )}
          </div>
        </div>

        <div className="rounded-3xl border border-line p-6 bg-white">
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {MENU_ITEMS.map((item) => {
              const href = item.soon ? undefined : user && item.authHref ? item.authHref : item.href;
              const inner = (
                <>
                  <span
                    className={`w-8 h-8 rounded-[9px] flex items-center justify-center shrink-0 ${
                      item.primary ? "bg-white/15 text-white" : "bg-white text-navy"
                    }`}
                  >
                    <Icon name={item.icon} className="w-4 h-4" />
                  </span>
                  <span className="flex-1">{item.label}</span>
                  {item.soon && (
                    <span className="text-[9.5px] font-bold uppercase tracking-wide text-subtle bg-white px-1.5 py-0.5 rounded-full shrink-0">
                      Soon
                    </span>
                  )}
                </>
              );

              if (item.soon) {
                return (
                  <div
                    key={item.label}
                    aria-disabled="true"
                    className="flex items-center gap-2.5 rounded-xl px-3.5 py-3 text-[12.5px] font-semibold bg-bg-soft text-ink/40 cursor-not-allowed"
                  >
                    {inner}
                  </div>
                );
              }

              return (
                <Link
                  key={item.label}
                  href={href ?? "/login?next=/profile"}
                  className={`flex items-center gap-2.5 rounded-xl px-3.5 py-3 text-[12.5px] font-semibold transition-colors ${
                    item.primary
                      ? "bg-navy text-white hover:bg-navy-2"
                      : "bg-bg-soft text-ink/80 hover:bg-line/60"
                  }`}
                >
                  {inner}
                </Link>
              );
            })}
          </div>
        </div>
      </div>

      {!userLoading && user && (
        <div className="mt-14 scroll-mt-24" id="account">
          <AccountPanel user={user} onLogout={logout} />
        </div>
      )}

      <div className="mt-14 scroll-mt-24" id="assessment-section">
        <div className="flex items-center justify-between mb-5">
          <h2 className="font-display font-extrabold text-navy text-xl">
            Career Assessment
          </h2>
          <Link
            href="/assessment"
            className="text-[13px] font-bold text-navy border border-line rounded-xl px-4 py-2.5 hover:border-navy/30 transition-colors"
          >
            {assessmentDone ? "Retake" : "Take Assessment"}
          </Link>
        </div>
        {assessmentDone ? (
          <>
            <div className="flex flex-wrap gap-2.5 mb-6">
              {topCategories.map((cat) => (
                <span
                  key={cat.slug}
                  className={`inline-flex items-center gap-2 text-[12.5px] font-bold px-3.5 py-2 rounded-full ${cat.color}`}
                >
                  <Icon name={cat.icon} className="w-3.5 h-3.5" />
                  {cat.name}
                </span>
              ))}
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
              {recommended.map((c) => (
                <CareerCard key={c.slug} career={c} category={categoriesBySlug.get(c.categorySlug)} />
              ))}
            </div>
          </>
        ) : (
          <div className="rounded-2xl border border-dashed border-line p-8 text-center text-muted text-[13.5px]">
            You haven&rsquo;t taken the career assessment yet.
          </div>
        )}
      </div>

      <SavedItemsTabs tabs={savedTabs} />
    </div>
  );
}

/**
 * Renders one saved-item tab's content ahead of time (rather than passing
 * the raw items + render callback through to SavedItemsTabs) so that
 * component can stay a plain, non-generic function -- four different item
 * types (Career/College/Exam) can't share one generic prop type
 * without losing type safety on the individual `render` callbacks above.
 */
function tabContent<T extends { slug: string }>(
  id: string,
  label: string,
  items: T[],
  emptyHref: string,
  emptyLabel: string,
  render: (item: T) => React.ReactNode
): { id: string; label: string; count: number; content: React.ReactNode } {
  return {
    id,
    label,
    count: items.length,
    content:
      items.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">{items.map(render)}</div>
      ) : (
        <div className="rounded-2xl border border-dashed border-line p-8 text-center text-muted text-[13.5px]">
          No saved {emptyLabel} yet. Browse{" "}
          <Link href={emptyHref} className="font-bold text-navy underline">
            {emptyLabel}
          </Link>{" "}
          and save the ones you&rsquo;re considering.
        </div>
      ),
  };
}

/**
 * Replaces four separately-stacked "Saved X" sections (each with its own
 * near-identical empty state) with one tabbed section. Defaults to the
 * first tab (Careers) rather than the first non-empty one -- picking a
 * data-dependent default would mean waiting on the saved-items fetch
 * before rendering, which isn't worth the complexity here. A quick-link
 * tile (e.g. "Saved Colleges" -> #saved-colleges) can still land directly on
 * the right tab via the URL hash, checked once on mount below.
 */
function SavedItemsTabs({
  tabs,
}: {
  tabs: Array<{ id: string; label: string; count: number; content: React.ReactNode }>;
}) {
  const [activeId, setActiveId] = useState(tabs[0]?.id ?? "");

  useEffect(() => {
    const hash = window.location.hash.replace("#", "");
    if (tabs.some((t) => t.id === hash)) {
      setActiveId(hash);
    }
    // Intentionally only on mount: this is for landing on a quick-link's
    // hash, not for following later hash changes while on the page.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const active = tabs.find((t) => t.id === activeId) ?? tabs[0];
  if (!active) return null;

  return (
    <div className="mt-14 scroll-mt-24" id="saved-items">
      <div className="flex items-center justify-between mb-5 flex-wrap gap-3">
        <h2 className="font-display font-extrabold text-navy text-xl">Saved Items</h2>
        <div className="flex gap-1 p-1 rounded-xl bg-bg-soft">
          {tabs.map((t) => (
            <button
              key={t.id}
              type="button"
              onClick={() => setActiveId(t.id)}
              className={`text-[12.5px] font-bold px-3.5 py-2 rounded-lg transition-colors ${
                active.id === t.id ? "bg-white text-navy shadow-sm" : "text-subtle hover:text-ink/70"
              }`}
            >
              {t.label}
              {t.count > 0 && (
                <span className={active.id === t.id ? "text-navy/50 ml-1.5" : "text-subtle/70 ml-1.5"}>
                  {t.count}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>
      {active.content}
    </div>
  );
}

/**
 * Interests and skills editing, shown only when logged in -- both are
 * account fields (UpdateInterestsRequest / /api/me/skills), so there's
 * nothing meaningful to show or edit here for an anonymous visitor.
 */
function AccountPanel({ user, onLogout }: { user: { name: string; email: string; createdAt: string; interests: string[] }; onLogout: () => void }) {
  const [interests, setInterests] = useState<string[]>(user.interests);
  const [newInterest, setNewInterest] = useState("");
  const [interestsSaving, setInterestsSaving] = useState(false);

  const [skills, setSkills] = useState<UserSkill[]>([]);
  const [skillsReady, setSkillsReady] = useState(false);
  const [availableSkills, setAvailableSkills] = useState<Skill[]>([]);
  const [skillSlugToAdd, setSkillSlugToAdd] = useState("");
  const [proficiencyToAdd, setProficiencyToAdd] = useState(PROFICIENCY_LEVELS[0]);
  const [yearsToAdd, setYearsToAdd] = useState("");
  const [skillSaving, setSkillSaving] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setInterests(user.interests);
  }, [user.interests]);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      const [mySkills, allSkills] = await Promise.all([getMySkills(), getSkills()]);
      if (cancelled) return;
      setSkills(mySkills);
      setAvailableSkills(allSkills);
      setSkillsReady(true);
    }
    load().catch(() => {
      if (!cancelled) setSkillsReady(true);
    });
    return () => {
      cancelled = true;
    };
  }, []);

  async function handleAddInterest(e: React.FormEvent) {
    e.preventDefault();
    const value = newInterest.trim();
    if (!value || interests.includes(value)) {
      setNewInterest("");
      return;
    }
    const next = [...interests, value];
    setInterestsSaving(true);
    try {
      await updateMyInterests(next);
      setInterests(next);
      setNewInterest("");
    } catch {
      // Leave the input as-is so the person can retry.
    } finally {
      setInterestsSaving(false);
    }
  }

  async function handleRemoveInterest(value: string) {
    const next = interests.filter((i) => i !== value);
    setInterestsSaving(true);
    try {
      await updateMyInterests(next);
      setInterests(next);
    } finally {
      setInterestsSaving(false);
    }
  }

  async function handleAddSkill(e: React.FormEvent) {
    e.preventDefault();
    if (!skillSlugToAdd) return;
    setSkillSaving(true);
    try {
      const years = yearsToAdd.trim() ? Number(yearsToAdd) : undefined;
      const saved = await upsertMySkill(skillSlugToAdd, proficiencyToAdd, years);
      setSkills((prev) => [...prev.filter((s) => s.skillSlug !== saved.skillSlug), saved]);
      setSkillSlugToAdd("");
      setYearsToAdd("");
    } finally {
      setSkillSaving(false);
    }
  }

  async function handleRemoveSkill(skillSlug: string) {
    setSkills((prev) => prev.filter((s) => s.skillSlug !== skillSlug));
    try {
      await removeMySkill(skillSlug);
    } catch {
      // Re-fetch isn't worth the complexity here -- worst case the skill
      // reappears next time this panel mounts.
    }
  }

  const addableSkills = availableSkills.filter(
    (s) => !skills.some((mine) => mine.skillSlug === s.slug)
  );

  return (
    <div className="rounded-3xl border border-line p-6 sm:p-7 bg-white">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6">
        <div>
          <h2 className="font-display font-extrabold text-navy text-xl">My Account</h2>
          <p className="text-[13px] text-subtle mt-1">
            {user.email} &middot; Member since {formatDate(user.createdAt)}
          </p>
        </div>
        <button
          onClick={onLogout}
          className="text-[13px] font-bold text-ink/70 border border-line rounded-xl px-4 py-2.5 hover:border-navy/30 transition-colors self-start sm:self-auto"
        >
          Log out
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div>
          <h3 className="font-display font-extrabold text-navy text-[15px] mb-3">Interests</h3>
          <div className="flex flex-wrap gap-2 mb-3">
            {interests.length > 0 ? (
              interests.map((interest) => (
                <span
                  key={interest}
                  className="inline-flex items-center gap-1.5 text-[12px] font-semibold px-3 py-1.5 rounded-full bg-bg-soft text-ink/70 border border-line"
                >
                  {interest}
                  <button
                    onClick={() => handleRemoveInterest(interest)}
                    disabled={interestsSaving}
                    aria-label={`Remove ${interest}`}
                    className="text-subtle hover:text-red transition-colors"
                  >
                    <Icon name="close" className="w-3 h-3" />
                  </button>
                </span>
              ))
            ) : (
              <p className="text-[13px] text-subtle">No interests added yet.</p>
            )}
          </div>
          <form onSubmit={handleAddInterest} className="flex gap-2">
            <Input
              value={newInterest}
              onChange={(e) => setNewInterest(e.target.value)}
              placeholder="e.g. Data Science"
              className="flex-1"
              aria-label="Add an interest"
            />
            <Button type="submit" disabled={interestsSaving || !newInterest.trim()}>
              Add
            </Button>
          </form>
        </div>

        <div>
          <h3 className="font-display font-extrabold text-navy text-[15px] mb-3">Skills</h3>
          {skillsReady && skills.length > 0 && (
            <div className="flex flex-col gap-2 mb-3">
              {skills.map((s) => (
                <div
                  key={s.skillSlug}
                  className="flex items-center justify-between gap-3 text-[13px] px-3.5 py-2.5 rounded-xl bg-bg-soft border border-line"
                >
                  <span className="font-semibold text-ink/80">
                    {s.skillName}
                    {s.proficiencyLevel && (
                      <span className="text-subtle font-medium"> &middot; {s.proficiencyLevel}</span>
                    )}
                    {typeof s.yearsOfExperience === "number" && (
                      <span className="text-subtle font-medium"> &middot; {s.yearsOfExperience}y</span>
                    )}
                  </span>
                  <button
                    onClick={() => handleRemoveSkill(s.skillSlug)}
                    aria-label={`Remove ${s.skillName}`}
                    className="text-subtle hover:text-red transition-colors shrink-0"
                  >
                    <Icon name="close" className="w-3.5 h-3.5" />
                  </button>
                </div>
              ))}
            </div>
          )}
          {skillsReady && skills.length === 0 && (
            <p className="text-[13px] text-subtle mb-3">No skills added yet.</p>
          )}
          {skillsReady && addableSkills.length > 0 && (
            <form onSubmit={handleAddSkill} className="grid grid-cols-1 sm:grid-cols-[1.4fr_1fr_0.7fr_auto] gap-2">
              <Select
                value={skillSlugToAdd}
                onChange={(e) => setSkillSlugToAdd(e.target.value)}
                aria-label="Skill"
              >
                <option value="">Select a skill&hellip;</option>
                {addableSkills.map((s) => (
                  <option key={s.slug} value={s.slug}>
                    {s.name}
                  </option>
                ))}
              </Select>
              <Select
                value={proficiencyToAdd}
                onChange={(e) => setProficiencyToAdd(e.target.value)}
                aria-label="Proficiency"
              >
                {PROFICIENCY_LEVELS.map((level) => (
                  <option key={level} value={level}>
                    {level}
                  </option>
                ))}
              </Select>
              <Input
                type="number"
                min={0}
                max={60}
                value={yearsToAdd}
                onChange={(e) => setYearsToAdd(e.target.value)}
                placeholder="Years"
                aria-label="Years of experience"
              />
              <Button type="submit" disabled={skillSaving || !skillSlugToAdd}>
                Add
              </Button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
