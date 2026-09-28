"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "@/components/ui/Icon";
import Button from "@/components/ui/Button";
import { getAssessmentQuestions } from "@/data/assessmentQuestions";
import { saveAssessment, AssessmentAnswers } from "@/lib/assessment";
import { AssessmentQuestion } from "@/lib/types";
import { getFriendlyErrorMessage } from "@/lib/errors";
import { cn } from "@/lib/utils";

/**
 * Maps each career category to one of six broad "clusters". After the first
 * two (universal) questions, we total up the category weights the user has
 * picked so far, find their leading cluster, and ask that cluster's
 * dedicated follow-up question next -- so the options right after a choice
 * are actually about the direction they just leaned toward, instead of an
 * unrelated generic topic. See V11__assessment_branching_questions.sql for
 * the six cluster questions this points at.
 */
const CATEGORY_TO_CLUSTER: Record<string, string> = {
  "engineering-technology": "cluster-tech",
  "science-research": "cluster-science-health",
  "medical-healthcare": "cluster-science-health",
  agriculture: "cluster-science-health",
  "design-creative": "cluster-creative",
  "media-communication": "cluster-creative",
  "arts-humanities": "cluster-creative",
  "commerce-finance": "cluster-business",
  "banking-insurance": "cluster-business",
  "management-business": "cluster-business",
  "government-civil-services": "cluster-public-service",
  defence: "cluster-public-service",
  law: "cluster-public-service",
  "education-teaching": "cluster-public-service",
  "skilled-trades": "cluster-trades-active",
  "sports-fitness": "cluster-trades-active",
  "hospitality-tourism": "cluster-trades-active",
};
const DEFAULT_CLUSTER = "cluster-tech";

// The universal questions asked before branching, then the branch point
// (resolved once all of these are answered), then the rest of the
// universal questions in their original order. Three questions' worth of
// signal is used for routing (rather than just one) so the branch reflects
// an emerging pattern in the user's answers, not a single early guess --
// and so every cluster is actually reachable: with only "interest" +
// "strength", ties in the underlying category weights always favored the
// same couple of clusters and a user could never land on "business" or
// "public service" as the very next question.
const SEQUENCE_BEFORE_BRANCH = ["interest", "strength", "academics"];
const SEQUENCE_AFTER_BRANCH = ["skills", "personality", "goals", "salary", "workstyle"];

/** Sums category weights across whichever of `ids` the user has already answered. */
function scoreSoFar(
  ids: string[],
  answers: AssessmentAnswers,
  questionsById: Map<string, AssessmentQuestion>
): Record<string, number> {
  const scores: Record<string, number> = {};
  for (const id of ids) {
    const chosenOptionId = answers[id];
    if (!chosenOptionId) continue;
    const option = questionsById.get(id)?.options.find((o) => o.id === chosenOptionId);
    if (!option) continue;
    for (const [category, weight] of Object.entries(option.weights)) {
      scores[category] = (scores[category] ?? 0) + (weight ?? 0);
    }
  }
  return scores;
}

/** Picks whichever cluster the user's answers so far lean toward most. */
function pickLeadingCluster(categoryScores: Record<string, number>): string {
  const clusterScores: Record<string, number> = {};
  for (const [category, score] of Object.entries(categoryScores)) {
    const cluster = CATEGORY_TO_CLUSTER[category];
    if (!cluster) continue;
    clusterScores[cluster] = (clusterScores[cluster] ?? 0) + score;
  }
  const ranked = Object.entries(clusterScores).sort((a, b) => b[1] - a[1]);
  return ranked[0]?.[0] ?? DEFAULT_CLUSTER;
}

export default function AssessmentFlow() {
  const router = useRouter();
  const [questions, setQuestions] = useState<AssessmentQuestion[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<AssessmentAnswers>({});

  // A bump here re-triggers the fetch below, so "Try again" doesn't need a
  // full page reload -- same recovery affordance as the root error.tsx
  // boundary's reset(), for a failure this local effect wouldn't otherwise
  // ever reach (an error thrown inside a useEffect's promise chain doesn't
  // propagate to a React error boundary the way a render-time throw does).
  const [retryCount, setRetryCount] = useState(0);

  useEffect(() => {
    let cancelled = false;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setLoadError(null);
    getAssessmentQuestions()
      .then((qs) => {
        if (!cancelled) setQuestions(qs);
      })
      .catch((err) => {
        if (!cancelled) setLoadError(getFriendlyErrorMessage(err));
      });
    return () => {
      cancelled = true;
    };
  }, [retryCount]);

  const retry = useCallback(() => {
    setLoadError(null);
    setRetryCount((n) => n + 1);
  }, []);

  const questionsById = useMemo(() => new Map((questions ?? []).map((q) => [q.id, q])), [questions]);

  // The branch slot is resolved live from the current answers, so going
  // Back and picking something different re-targets it automatically.
  const branchQuestionId = useMemo(
    () => pickLeadingCluster(scoreSoFar(SEQUENCE_BEFORE_BRANCH, answers, questionsById)),
    [answers, questionsById]
  );

  const sequence = useMemo(
    () => [...SEQUENCE_BEFORE_BRANCH, branchQuestionId, ...SEQUENCE_AFTER_BRANCH],
    [branchQuestionId]
  );

  if (loadError) {
    return (
      <div className="max-w-2xl mx-auto text-center py-16">
        <p className="text-muted text-[14.5px] mb-6">{loadError}</p>
        <Button onClick={retry}>Try again</Button>
      </div>
    );
  }

  if (!questions) {
    return (
      <div className="max-w-2xl mx-auto text-center py-16 text-muted text-sm">
        Loading assessment...
      </div>
    );
  }

  const questionId = sequence[step];
  const question = questionsById.get(questionId);
  const total = sequence.length;
  const progress = Math.round(((step + 1) / total) * 100);
  const isLast = step === total - 1;
  const isBranchStep = step === SEQUENCE_BEFORE_BRANCH.length;
  const selected = question ? answers[question.id] : undefined;

  if (!question) {
    // Shouldn't happen (every id in `sequence` comes from the fetched
    // question pool), but fail gracefully rather than crash the flow.
    return (
      <div className="max-w-2xl mx-auto text-center py-16 text-muted text-sm">
        Something went wrong loading this question. Please refresh and try again.
      </div>
    );
  }

  function choose(optionId: string) {
    setAnswers((prev) => ({ ...prev, [question!.id]: optionId }));
  }

  function next() {
    if (isLast) {
      // Only keep answers for questions actually in the final sequence --
      // if the branch target changed after going Back, this drops any
      // leftover answer to the cluster question that's no longer shown.
      const relevant: AssessmentAnswers = {};
      for (const id of sequence) {
        if (answers[id]) relevant[id] = answers[id];
      }
      saveAssessment(relevant);
      router.push("/assessment/results");
    } else {
      setStep((s) => s + 1);
    }
  }

  function back() {
    setStep((s) => Math.max(0, s - 1));
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between text-[12.5px] font-bold text-subtle mb-2.5">
        <span>
          Question {step + 1} of {total}
        </span>
        <span>{progress}%</span>
      </div>
      <div className="h-2 rounded-full bg-bg-soft overflow-hidden mb-8">
        <div
          className="h-full bg-purple rounded-full transition-all duration-300"
          style={{ width: `${progress}%` }}
        />
      </div>

      {isBranchStep && (
        <div className="inline-flex items-center gap-1.5 text-[11.5px] font-bold px-3 py-1.5 rounded-full bg-purple-soft text-purple mb-3">
          <Icon name="target" className="w-3.5 h-3.5" />
          Based on what you picked so far
        </div>
      )}

      <h2 className="font-display font-extrabold text-navy text-xl sm:text-2xl leading-snug text-balance">
        {question.question}
      </h2>

      <div className="flex flex-col gap-3 mt-7">
        {question.options.map((opt) => (
          <button
            key={opt.id}
            onClick={() => choose(opt.id)}
            className={cn(
              "text-left rounded-2xl border-2 px-5 py-4 text-[14.5px] font-semibold transition-colors flex items-center gap-3",
              selected === opt.id
                ? "border-purple bg-purple-soft text-navy"
                : "border-line bg-white text-ink/80 hover:border-navy/20"
            )}
          >
            <span
              className={cn(
                "w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0",
                selected === opt.id ? "border-purple bg-purple" : "border-line"
              )}
            >
              {selected === opt.id && (
                <Icon name="check" className="w-3 h-3 text-white" strokeWidth={3} />
              )}
            </span>
            {opt.label}
          </button>
        ))}
      </div>

      <div className="flex items-center justify-between mt-10">
        <button
          onClick={back}
          disabled={step === 0}
          className="text-[13.5px] font-bold text-ink/60 px-5 py-3 rounded-xl disabled:opacity-30 hover:text-navy transition-colors"
        >
          Back
        </button>
        <button
          onClick={next}
          disabled={!selected}
          className="text-[13.5px] font-bold text-white bg-navy px-6 py-3 rounded-xl disabled:opacity-30 hover:bg-navy-2 transition-colors flex items-center gap-2"
        >
          {isLast ? "See My Results" : "Next"}
          <Icon name="arrowRight" className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}
