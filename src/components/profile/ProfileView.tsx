"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { useToast } from "@/components/ui/Toast";
import CollegeCard from "@/components/cards/CollegeCard";
import CareerCard from "@/components/cards/CareerCard";
import ExamCard from "@/components/cards/ExamCard";
import MyCareerJourney, { PendingGoal, goalKicker } from "@/components/profile/MyCareerJourney";
import { useUser } from "@/components/providers/UserProvider";
import { useSavedItems } from "@/components/providers/SavedItemsProvider";
import { loadAssessment, submitAssessment } from "@/lib/assessment";
import {
  GoalType,
  Journey,
  User,
  UserProfile,
  getJourney,
  getMyProfile,
  updateMyInterests,
  updateMyProfile,
} from "@/lib/userApi";
import { getFriendlyErrorMessage } from "@/lib/errors";
import { getManyColleges } from "@/data/colleges";
import { getManyCareers } from "@/data/careers";
import { getManyExams } from "@/data/exams";
import { getStages } from "@/data/stages";
import { getStreams } from "@/data/streams";
import { Category, Career, College, Exam, Stage, Stream } from "@/lib/types";
import { indexBySlug, formatDate } from "@/lib/utils";

// Preview counts on the profile page are smaller than the assessment
// results page's (3 vs. the API's defaults of 4 top categories / 6
// recommended careers). Both arrays the API returns are already ordered
// most-to-least relevant, so slicing down to a shorter preview here is
// equivalent to asking the scoring algorithm for a smaller count.
const PROFILE_TOP_CATEGORY_COUNT = 3;
const PROFILE_RECOMMENDED_CAREER_COUNT = 3;

type TabId = "line" | "saved" | "assessment" | "account";
type SavedType = "careers" | "colleges" | "exams";

const TAB_LABEL: Record<TabId, string> = { line: "Your line", saved: "Saved", assessment: "Assessment", account: "Account" };
const SAVED_TYPES: SavedType[] = ["careers", "colleges", "exams"];
const TAB_STORAGE_KEY = "careerguide.profile.tab";

// The page used to be one long scroll with in-page anchors (the old menu
// tiles linked to these). Mapped onto tabs so a bookmarked link still lands
// on the right content.
const LEGACY_HASH: Record<string, { tab: TabId; saved?: SavedType }> = {
  account: { tab: "account" },
  "assessment-section": { tab: "assessment" },
  "saved-items": { tab: "saved" },
  "saved-careers": { tab: "saved", saved: "careers" },
  "saved-colleges": { tab: "saved", saved: "colleges" },
  "saved-exams": { tab: "saved", saved: "exams" },
};

const CARD = "rounded-3xl border border-line bg-white p-6";
const BTN_PRIMARY = "inline-flex items-center justify-center min-h-[44px] px-[18px] rounded-xl bg-blue text-white text-[14px] font-bold hover:opacity-90 transition-opacity disabled:opacity-50 whitespace-nowrap";
const BTN_SECONDARY = "inline-flex items-center justify-center min-h-[44px] px-4 rounded-xl border border-line bg-white text-[13.5px] font-bold text-[#6e4620] hover:border-blue/40 transition-colors disabled:opacity-50 whitespace-nowrap";
const INPUT = "min-h-[44px] w-full rounded-xl border border-[#ddd6cb] bg-white px-3 text-[14px] text-ink placeholder:text-subtle";
const LABEL = "text-[12.5px] font-bold text-navy";

function readStoredTab(): string | null {
  try {
    return window.localStorage.getItem(TAB_STORAGE_KEY);
  } catch {
    return null;
  }
}

function isTab(v: string | null | undefined): v is TabId {
  return v === "line" || v === "saved" || v === "assessment" || v === "account";
}

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

  // The journey is tagged with whose it is, so a different account signing
  // in never sees the previous one's goal while its own loads.
  const [journeyState, setJourneyState] = useState<{ userId: number; journey: Journey | null; error: boolean } | null>(null);
  const [pending, setPending] = useState<PendingGoal | null>(null);
  const [requestedTab, setRequestedTab] = useState<TabId | null>(null);
  // null until the person or a link picks one; then the first non-empty type is shown.
  const [chosenSavedType, setSavedType] = useState<SavedType | null>(null);

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

  useEffect(() => {
    if (!user) return;
    let cancelled = false;
    getJourney()
      .then((j) => { if (!cancelled) setJourneyState({ userId: user.id, journey: j, error: false }); })
      .catch(() => { if (!cancelled) setJourneyState({ userId: user.id, journey: null, error: true }); });
    return () => {
      cancelled = true;
    };
  }, [user]);

  // Which tab to open: ?tab= first, then an old in-page anchor, then the
  // tab this person last used on this device.
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const legacy = LEGACY_HASH[window.location.hash.slice(1)];
    const tab = legacy?.tab ?? params.get("tab") ?? readStoredTab();
    const type = legacy?.saved ?? params.get("type");
    // Deliberately setState-in-effect: the URL and localStorage are only
    // readable on the client, and choosing a different tab during the first
    // render would not match the server's HTML.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    if (isTab(tab)) setRequestedTab(tab);
    if (SAVED_TYPES.includes(type as SavedType)) setSavedType(type as SavedType);
  }, []);

  if (!ready || userLoading) return null;

  const journey = user && journeyState?.userId === user.id ? journeyState.journey : null;
  const journeyError = !!user && journeyState?.userId === user.id && journeyState.error;
  const currentGoal = journey?.goal ?? null;

  const allowed: TabId[] = user ? ["line", "saved", "assessment", "account"] : ["saved", "assessment"];
  const tab: TabId = requestedTab && allowed.includes(requestedTab) ? requestedTab : allowed[0];
  const savedTotal = savedCareers.length + savedColleges.length + savedExams.length;
  const savedCounts: Record<SavedType, number> = { careers: savedCareers.length, colleges: savedColleges.length, exams: savedExams.length };
  const savedType: SavedType = chosenSavedType ?? SAVED_TYPES.find((t) => savedCounts[t] > 0) ?? "careers";

  function writeUrl(nextTab: TabId, nextType: SavedType) {
    const params = new URLSearchParams(window.location.search);
    params.set("tab", nextTab);
    if (nextTab === "saved") params.set("type", nextType);
    else params.delete("type");
    window.history.replaceState(null, "", `${window.location.pathname}?${params.toString()}`);
  }

  function selectTab(id: TabId) {
    setRequestedTab(id);
    writeUrl(id, savedType);
    try {
      window.localStorage.setItem(TAB_STORAGE_KEY, id);
    } catch {
      // Storage unavailable: the tab just isn't remembered.
    }
  }

  function selectSavedType(t: SavedType) {
    setSavedType(t);
    writeUrl("saved", t);
  }

  function showTop() {
    document.getElementById("my-career-tabs")?.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function askGoal(p: PendingGoal) {
    setPending(p);
    selectTab("line");
    showTop();
  }

  function logLearning() {
    selectTab("line");
    // The log card mounts with the tab; wait a frame for it to exist.
    requestAnimationFrame(() =>
      document.getElementById("learning-log")?.scrollIntoView({ behavior: "smooth", block: "start" }));
  }

  function onTabKey(e: React.KeyboardEvent, id: TabId) {
    const i = allowed.indexOf(id);
    let next: TabId | null = null;
    if (e.key === "ArrowRight") next = allowed[(i + 1) % allowed.length];
    else if (e.key === "ArrowLeft") next = allowed[(i - 1 + allowed.length) % allowed.length];
    else if (e.key === "Home") next = allowed[0];
    else if (e.key === "End") next = allowed[allowed.length - 1];
    if (!next) return;
    e.preventDefault();
    selectTab(next);
    document.getElementById(`tab-${next}`)?.focus();
  }

  const goalProps = { signedIn: !!user, currentGoal, onMakeGoal: askGoal };

  return (
    <div className="flex flex-col gap-5">
      {user ? (
        <ProfileHeader user={user} journey={journey} onLogLearning={logLearning} onSetGoal={() => { selectTab("line"); showTop(); }} />
      ) : (
        <div className="rounded-3xl border border-dashed border-[#cfc8bc] bg-white p-6 flex flex-wrap items-center gap-5">
          <div className="flex-1 basis-[320px] min-w-0">
            <p className="font-display font-extrabold text-navy text-[17px]">Set a goal and track your learning</p>
            <p className="text-[13.5px] text-muted mt-1">
              Pick a career, exam, college or job to work towards, and log what you learn each day.
              Your saves below stay on this device until you sign in.
            </p>
          </div>
          <div className="flex flex-wrap gap-2.5">
            <Link href="/login?next=/profile" className="inline-flex items-center min-h-[44px] px-[18px] rounded-xl bg-navy text-white text-[14px] font-bold hover:bg-navy-2 transition-colors">
              Sign in
            </Link>
            <Link href="/register?next=/profile" className={BTN_SECONDARY}>Create a free account</Link>
          </div>
        </div>
      )}

      <div id="my-career-tabs" role="tablist" aria-label="My Career sections" className="scroll-mt-24 flex gap-1 overflow-x-auto border-b border-line">
        {allowed.map((id) => (
          <button
            key={id}
            id={`tab-${id}`}
            type="button"
            role="tab"
            aria-selected={tab === id}
            aria-controls={`panel-${id}`}
            tabIndex={tab === id ? 0 : -1}
            onClick={() => selectTab(id)}
            onKeyDown={(e) => onTabKey(e, id)}
            className={`shrink-0 min-h-[48px] px-4 -mb-px border-b-[3px] inline-flex items-center gap-2 text-[14.5px] font-bold transition-colors ${
              tab === id ? "border-blue text-navy" : "border-transparent text-muted hover:text-navy"
            }`}
          >
            {TAB_LABEL[id]}
            {id === "saved" && savedTotal > 0 && (
              <span className="text-[12px] font-bold text-slate bg-slate-soft rounded-full px-2 py-0.5">{savedTotal}</span>
            )}
          </button>
        ))}
      </div>

      <div id={`panel-${tab}`} role="tabpanel" aria-labelledby={`tab-${tab}`} tabIndex={-1}>
        {tab === "line" && user && (
          <MyCareerJourney
            journey={journey}
            loadError={journeyError}
            onChange={(j) => setJourneyState({ userId: user.id, journey: j, error: false })}
            pending={pending}
            onPendingDone={() => setPending(null)}
          />
        )}

        {tab === "saved" && (
          <SavedPanel
            type={savedType}
            onType={selectSavedType}
            careers={savedCareers}
            colleges={savedColleges}
            exams={savedExams}
            {...goalProps}
          />
        )}

        {tab === "assessment" && (
          <AssessmentPanel
            done={assessmentDone}
            topCategories={topCategories}
            recommended={recommended}
            {...goalProps}
          />
        )}

        {tab === "account" && user && <AccountPanel user={user} onLogout={logout} />}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------ header

function ProfileHeader({ user, journey, onLogLearning, onSetGoal }: {
  user: User; journey: Journey | null; onLogLearning: () => void; onSetGoal: () => void;
}) {
  const goal = journey?.goal ?? null;
  const initials = user.name.split(/\s+/).filter(Boolean).slice(0, 2).map((w) => w[0]!.toUpperCase()).join("") || "?";
  const C = 2 * Math.PI * 22;
  const readiness = journey?.readiness ?? 0;
  const details = goal
    ? [goal.targetMonth ? `Target ${new Date(`${goal.targetMonth}-01T00:00:00`).toLocaleDateString("en-IN", { month: "short", year: "numeric" })}` : null,
        journey && journey.streak > 0 ? `${journey.streak}-day streak` : null].filter(Boolean).join(" · ")
    : "";

  return (
    <div className={`${CARD} !py-5 flex flex-wrap items-center gap-5`}>
      <div className="flex items-center gap-3.5 flex-1 basis-[260px] min-w-0">
        <span aria-hidden="true" className="w-[52px] h-[52px] shrink-0 rounded-2xl bg-navy text-white flex items-center justify-center font-display font-extrabold text-[18px]">
          {initials}
        </span>
        <div className="min-w-0">
          <p className="font-display font-extrabold text-navy text-[18px] truncate">{user.name}</p>
          <p className="text-[13px] text-muted [overflow-wrap:anywhere]">
            {user.email} &middot; Member since {formatDate(user.createdAt)}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3.5 flex-1 basis-[300px] min-w-0 sm:border-l sm:border-line sm:pl-5">
        {goal ? (
          <>
            <svg width="56" height="56" viewBox="0 0 56 56" role="img" aria-label={`${readiness} percent ready for ${goal.name}`} className="shrink-0">
              <circle cx="28" cy="28" r="22" fill="none" stroke="#efe8dd" strokeWidth="6" />
              <circle cx="28" cy="28" r="22" fill="none" stroke="#8a5a2b" strokeWidth="6" strokeLinecap="round"
                strokeDasharray={`${((C * readiness) / 100).toFixed(1)} ${C.toFixed(1)}`} transform="rotate(-90 28 28)" />
              <text x="28" y="32" textAnchor="middle" fontSize="12" fontWeight="800" fill="#16181d">{readiness}%</text>
            </svg>
            <div className="min-w-0">
              <p className="text-[12.5px] font-bold text-muted">{goalKicker(goal.type)}</p>
              <p className="font-display font-extrabold text-navy text-[16px] leading-snug">{goal.name}</p>
              {details && <p className="text-[12.5px] text-muted">{details}</p>}
            </div>
          </>
        ) : (
          <div className="min-w-0">
            <p className="font-display font-extrabold text-navy text-[15px]">No goal yet</p>
            <p className="text-[12.5px] text-muted">Pick what you&rsquo;re working towards to start your line.</p>
          </div>
        )}
      </div>

      {goal ? (
        <button type="button" onClick={onLogLearning} className={BTN_PRIMARY}>+ Log learning</button>
      ) : journey ? (
        <button type="button" onClick={onSetGoal} className={BTN_PRIMARY}>Set a goal</button>
      ) : null}
    </div>
  );
}

// ------------------------------------------------------------- goal action

type GoalActionProps = {
  signedIn: boolean;
  currentGoal: { type: GoalType; slug: string } | null;
  onMakeGoal: (p: PendingGoal) => void;
};

function GoalAction({ type, slug, name, signedIn, currentGoal, onMakeGoal }: GoalActionProps & PendingGoal) {
  if (!signedIn) return null;
  if (currentGoal && currentGoal.type === type && currentGoal.slug === slug) {
    return <span className="self-start text-[12.5px] font-bold text-[#24554e] bg-teal-soft rounded-full px-3 py-1.5">Your current goal</span>;
  }
  return (
    <button type="button" onClick={() => onMakeGoal({ type, slug, name })} className={`${BTN_SECONDARY} self-start border-blue`}>
      Make this my goal
    </button>
  );
}

// ------------------------------------------------------------------- saved

function SavedPanel({ type, onType, careers, colleges, exams, ...goal }: {
  type: SavedType;
  onType: (t: SavedType) => void;
  careers: Career[];
  colleges: College[];
  exams: Exam[];
} & GoalActionProps) {
  const counts: Record<SavedType, number> = { careers: careers.length, colleges: colleges.length, exams: exams.length };
  const label: Record<SavedType, string> = { careers: "Careers", colleges: "Colleges", exams: "Exams" };

  const empty = (
    <div className="rounded-3xl border border-dashed border-line p-8 text-center text-muted text-[13.5px]">
      No saved {type} yet. Browse{" "}
      <Link href={`/${type}`} className="font-bold text-navy underline">{type}</Link>{" "}
      and save the ones you&rsquo;re considering.
    </div>
  );
  const grid = "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5";
  const cell = "flex flex-col gap-2.5";

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div role="group" aria-label="Saved type" className="inline-flex gap-1 p-1 rounded-2xl bg-slate-soft">
          {SAVED_TYPES.map((t) => (
            <button
              key={t}
              type="button"
              aria-pressed={type === t}
              onClick={() => onType(t)}
              className={`min-h-[44px] px-3.5 rounded-xl text-[13.5px] font-bold transition-colors ${
                type === t ? "bg-white text-navy shadow-sm" : "text-slate hover:text-navy"
              }`}
            >
              {label[t]} &middot; {counts[t]}
            </button>
          ))}
        </div>
        {!goal.signedIn && (
          <p className="text-[13px] text-muted">
            Saved on this device only.{" "}
            <Link href="/login?next=/profile" className="font-bold">Sign in</Link> to keep them everywhere and make one your goal.
          </p>
        )}
      </div>

      {type === "careers" && (careers.length === 0 ? empty : (
        <div className={grid}>
          {careers.map((c) => (
            <div key={c.slug} className={cell}>
              <CareerCard career={c} />
              <GoalAction type="career" slug={c.slug} name={c.title} {...goal} />
            </div>
          ))}
        </div>
      ))}
      {type === "colleges" && (colleges.length === 0 ? empty : (
        <div className={grid}>
          {colleges.map((c) => (
            <div key={c.slug} className={cell}>
              <CollegeCard college={c} />
              <GoalAction type="college" slug={c.slug} name={c.name} {...goal} />
            </div>
          ))}
        </div>
      ))}
      {type === "exams" && (exams.length === 0 ? empty : (
        <div className={grid}>
          {exams.map((e) => (
            <div key={e.slug} className={cell}>
              <ExamCard exam={e} />
              <GoalAction type="exam" slug={e.slug} name={e.name} {...goal} />
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

// -------------------------------------------------------------- assessment

function AssessmentPanel({ done, topCategories, recommended, ...goal }: {
  done: boolean;
  topCategories: Category[];
  recommended: Career[];
} & GoalActionProps) {
  if (!done) {
    return (
      <div className={`${CARD} py-10 flex flex-col items-center gap-3 text-center`}>
        <h2 className="font-display font-extrabold text-navy text-[20px]">Not sure what to aim for yet?</h2>
        <p className="text-[14px] text-muted max-w-[460px]">
          Answer a few questions about what you enjoy and we&rsquo;ll suggest careers that fit.
          {goal.signedIn ? " You can make any of them your goal." : ""}
        </p>
        <Link href="/assessment" className={BTN_PRIMARY}>Take the career assessment</Link>
      </div>
    );
  }

  const categoriesBySlug = indexBySlug(topCategories);
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="font-display font-extrabold text-navy text-[20px]">Careers that fit you</h2>
          <p className="text-[13.5px] text-muted mt-1">From your career assessment.</p>
        </div>
        <Link href="/assessment" className={BTN_SECONDARY}>Retake assessment</Link>
      </div>
      <div className="flex flex-wrap gap-2.5">
        {topCategories.map((cat) => (
          <span key={cat.slug} className={`inline-flex items-center gap-2 text-[12.5px] font-bold px-3.5 py-2 rounded-full ${cat.color}`}>
            <Icon name={cat.icon} className="w-3.5 h-3.5" />
            {cat.name}
          </span>
        ))}
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        {recommended.map((c) => (
          <div key={c.slug} className="flex flex-col gap-2.5">
            <CareerCard career={c} category={categoriesBySlug.get(c.categorySlug)} />
            <GoalAction type="career" slug={c.slug} name={c.title} {...goal} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ----------------------------------------------------------------- account

// Streams are chosen after 10th; someone after 12th is still in theirs.
// Past school the field means nothing, so it's hidden and cleared.
const STAGES_WITH_STREAM = new Set(["after-10th", "after-12th"]);

function AccountPanel({ user, onLogout }: { user: User; onLogout: () => void }) {
  return (
    <div className="flex flex-wrap items-start gap-5">
      <AboutYou />
      <div className="flex-1 basis-[340px] min-w-0 flex flex-col gap-5">
        <Interests initial={user.interests} />
        <div className={`${CARD} flex flex-wrap items-center justify-between gap-3`}>
          <div className="min-w-0">
            <p className="font-display font-extrabold text-navy text-[15px]">Signed in</p>
            <p className="text-[13px] text-muted [overflow-wrap:anywhere]">{user.email}</p>
          </div>
          <button type="button" onClick={onLogout} className={`${BTN_SECONDARY} !text-red`}>Log out</button>
        </div>
      </div>
    </div>
  );
}

function AboutYou() {
  const { showToast } = useToast();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [stages, setStages] = useState<Stage[]>([]);
  const [streams, setStreams] = useState<Stream[]>([]);
  const [failed, setFailed] = useState(false);
  const [stage, setStage] = useState("");
  const [stream, setStream] = useState("");
  const [location, setLocation] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    let alive = true;
    Promise.all([getMyProfile(), getStages(), getStreams()])
      .then(([p, st, sr]) => {
        if (!alive) return;
        setProfile(p);
        setStages(st);
        setStreams(sr);
        setStage(p.educationStageSlug ?? "");
        setStream(p.streamSlug ?? "");
        setLocation(p.location ?? "");
      })
      .catch(() => { if (alive) setFailed(true); });
    return () => { alive = false; };
  }, []);

  const showStream = STAGES_WITH_STREAM.has(stage);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!profile) return;
    setSaving(true);
    try {
      // The endpoint replaces the whole profile, so fields this form doesn't
      // show are sent back exactly as they were loaded.
      const saved = await updateMyProfile({
        ...profile,
        educationStageSlug: stage || null,
        streamSlug: showStream && stream ? stream : null,
        location: location.trim() || null,
      });
      setProfile(saved);
      showToast("Saved", "success");
    } catch (err) {
      showToast(getFriendlyErrorMessage(err), "error");
    } finally {
      setSaving(false);
    }
  }

  return (
    <form onSubmit={save} className={`${CARD} flex-1 basis-[460px] min-w-0 flex flex-col gap-4`}>
      <div>
        <h2 className="font-display font-extrabold text-navy text-[18px]">About you</h2>
        <p className="text-[13px] text-muted mt-1">Used to suggest careers, exams and colleges that fit where you are.</p>
      </div>
      {failed ? (
        <p className="text-[13px] text-muted">We couldn&rsquo;t load your details. Refresh the page to try again.</p>
      ) : (
        <>
          <div className="grid grid-cols-[repeat(auto-fit,minmax(200px,1fr))] gap-3">
            <label className="flex flex-col gap-1.5">
              <span className={LABEL}>Where you are now</span>
              <select value={stage} onChange={(e) => setStage(e.target.value)} disabled={!profile} className={INPUT}>
                <option value="">Not set</option>
                {stages.map((s) => <option key={s.slug} value={s.slug}>{s.name}</option>)}
              </select>
            </label>
            {showStream && (
              <label className="flex flex-col gap-1.5">
                <span className={LABEL}>Stream</span>
                <select value={stream} onChange={(e) => setStream(e.target.value)} disabled={!profile} className={INPUT}>
                  <option value="">Not set</option>
                  {streams.map((s) => <option key={s.slug} value={s.slug}>{s.name}</option>)}
                </select>
              </label>
            )}
            <label className="flex flex-col gap-1.5">
              <span className={LABEL}>Location</span>
              <input value={location} maxLength={160} onChange={(e) => setLocation(e.target.value)} disabled={!profile}
                placeholder="e.g. Patna, Bihar" className={INPUT} />
            </label>
          </div>
          <button type="submit" disabled={!profile || saving} className={`${BTN_PRIMARY} self-start`}>Save</button>
        </>
      )}
    </form>
  );
}

function Interests({ initial }: { initial: string[] }) {
  const { showToast } = useToast();
  const [interests, setInterests] = useState<string[]>(initial);
  const [text, setText] = useState("");
  const [saving, setSaving] = useState(false);

  async function write(next: string[], onDone?: () => void) {
    setSaving(true);
    try {
      await updateMyInterests(next);
      setInterests(next);
      onDone?.();
    } catch (err) {
      showToast(getFriendlyErrorMessage(err), "error");
    } finally {
      setSaving(false);
    }
  }

  function add(e: React.FormEvent) {
    e.preventDefault();
    const value = text.trim();
    if (!value) return;
    if (interests.some((i) => i.toLowerCase() === value.toLowerCase())) {
      setText("");
      return;
    }
    write([...interests, value], () => setText(""));
  }

  return (
    <div className={`${CARD} flex flex-col gap-3.5`}>
      <div>
        <h2 className="font-display font-extrabold text-navy text-[18px]">Interests</h2>
        <p className="text-[13px] text-muted mt-1">Shapes your recommendations.</p>
      </div>
      {interests.length > 0 ? (
        <ul className="flex flex-wrap gap-2">
          {interests.map((i) => (
            <li key={i} className="inline-flex items-center text-[13px] font-semibold text-[#6e4620] bg-blue-soft rounded-full pl-3">
              {i}
              <button type="button" onClick={() => write(interests.filter((x) => x !== i))} disabled={saving}
                aria-label={`Remove ${i}`} className="w-9 h-9 flex items-center justify-center rounded-full hover:text-navy disabled:opacity-50">
                <Icon name="close" className="w-3 h-3" />
              </button>
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-[13px] text-muted">No interests added yet.</p>
      )}
      <form onSubmit={add} className="flex gap-2 items-end">
        <label className="flex-1 min-w-0 flex flex-col gap-1.5">
          <span className={LABEL}>Add an interest</span>
          <input value={text} maxLength={60} onChange={(e) => setText(e.target.value)} placeholder="e.g. Space science" className={INPUT} />
        </label>
        <button type="submit" disabled={saving || !text.trim()} className={BTN_SECONDARY}>Add</button>
      </form>
    </div>
  );
}
