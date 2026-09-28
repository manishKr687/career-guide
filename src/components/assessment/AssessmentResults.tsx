"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import CareerCard from "@/components/cards/CareerCard";
import { loadAssessment, submitAssessment } from "@/lib/assessment";
import { Category, Career } from "@/lib/types";
import { indexBySlug } from "@/lib/utils";

export default function AssessmentResults() {
  const [ready, setReady] = useState(false);
  const [hasResults, setHasResults] = useState(false);
  const [topCategories, setTopCategories] = useState<Category[]>([]);
  const [recommended, setRecommended] = useState<Career[]>([]);

  useEffect(() => {
    // One-time client-only hydration from localStorage (unavailable during
    // SSR), so this must run after mount rather than during render.
    let cancelled = false;
    const stored = loadAssessment();
    if (stored) {
      submitAssessment(stored.answers)
        .then((result) => {
          if (cancelled) return;
          setTopCategories(result.topCategories);
          setRecommended(result.recommendedCareers);
          setHasResults(true);
        })
        .finally(() => {
          if (!cancelled) setReady(true);
        });
    } else {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setReady(true);
    }
    return () => {
      cancelled = true;
    };
  }, []);

  const categoriesBySlug = indexBySlug(topCategories);

  if (!ready) return null;

  if (!hasResults) {
    return (
      <div className="max-w-lg mx-auto text-center py-16">
        <div className="w-14 h-14 rounded-2xl bg-purple-soft flex items-center justify-center mx-auto">
          <Icon name="target" className="w-7 h-7 text-purple" />
        </div>
        <h2 className="font-display font-extrabold text-navy text-xl mt-6">
          No results yet
        </h2>
        <p className="text-muted text-[14px] mt-2">
          Take the career assessment to get personalized recommendations.
        </p>
        <Link
          href="/assessment"
          className="inline-flex items-center gap-2 mt-6 text-[13.5px] font-bold text-white bg-navy px-6 py-3 rounded-xl hover:bg-navy-2 transition-colors"
        >
          Take the Assessment
          <Icon name="arrowRight" className="w-4 h-4" />
        </Link>
      </div>
    );
  }

  return (
    <div>
      <div className="text-center max-w-xl mx-auto">
        <div className="w-14 h-14 rounded-2xl bg-green-soft flex items-center justify-center mx-auto">
          <Icon name="award" className="w-7 h-7 text-green" />
        </div>
        <h2 className="font-display font-extrabold text-navy text-2xl mt-5">
          Your Personalized Recommendations
        </h2>
        <p className="text-muted text-[14.5px] mt-2 leading-relaxed">
          Based on your answers, these are the fields and careers that best
          match your interests, strengths and goals.
        </p>
      </div>

      <div className="flex flex-wrap justify-center gap-2.5 mt-8">
        {topCategories.map((cat) => (
          <span
            key={cat.slug}
            className={`inline-flex items-center gap-2 text-[13px] font-bold px-4 py-2.5 rounded-full ${cat.color}`}
          >
            <Icon name={cat.icon} className="w-4 h-4" />
            {cat.name}
          </span>
        ))}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 mt-10">
        {recommended.map((career) => (
          <CareerCard key={career.slug} career={career} category={categoriesBySlug.get(career.categorySlug)} />
        ))}
      </div>

      <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mt-12">
        <Link
          href="/roadmap"
          className="text-[13.5px] font-bold text-white bg-navy px-6 py-3.5 rounded-xl hover:bg-navy-2 transition-colors flex items-center gap-2"
        >
          Build My Career Roadmap
          <Icon name="arrowRight" className="w-4 h-4" />
        </Link>
        <Link
          href="/assessment"
          className="text-[13.5px] font-bold text-navy bg-white px-6 py-3.5 rounded-xl border border-line hover:border-navy/30 transition-colors"
        >
          Retake Assessment
        </Link>
      </div>
    </div>
  );
}
