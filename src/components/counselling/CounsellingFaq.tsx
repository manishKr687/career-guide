"use client";

import { useState } from "react";
import Icon from "@/components/ui/Icon";

const FAQS: { q: string; a: string }[] = [
  {
    q: "Is this really free?",
    a: "Yes — every counselling call is completely free, with no hidden fees and no obligation to use any paid service afterward.",
  },
  {
    q: "Who will I actually talk to?",
    a: "A member of our counselling team, one-on-one. There's no bot or automated call — you'll speak with a real person.",
  },
  {
    q: "What if I don't know my preferred time yet?",
    a: "Leave the date and time fields blank. We'll reach out by phone or WhatsApp to find a slot that works for you.",
  },
  {
    q: "Can I book on behalf of my child?",
    a: "Yes — just use your own contact details in the form and mention in the message field who the call is for.",
  },
];

export default function CounsellingFaq() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <div className="py-24 flex flex-col items-center gap-3">
      <span className="text-[11px] font-bold tracking-widest uppercase px-3.5 py-1.5 rounded-full bg-blue-soft text-blue font-display">
        FAQ
      </span>
      <h2 className="font-display font-extrabold text-navy text-2xl sm:text-[28px]">Common questions</h2>
      <p className="text-[14px] text-muted max-w-md text-center leading-relaxed mb-2">
        Still unsure about booking a call? Here&rsquo;s what most people ask first.
      </p>

      <div className="w-full max-w-2xl flex flex-col gap-2.5">
        {FAQS.map((item, i) => {
          const open = openIndex === i;
          return (
            <div key={item.q} className="bg-white border border-line rounded-2xl overflow-hidden">
              <button
                type="button"
                onClick={() => setOpenIndex(open ? null : i)}
                aria-expanded={open}
                className="w-full flex items-center justify-between gap-4 text-left px-5 sm:px-6 py-4"
              >
                <span className="font-display font-bold text-navy text-[14px]">{item.q}</span>
                <Icon
                  name="arrowDown"
                  className={`w-4 h-4 text-subtle shrink-0 transition-transform ${open ? "rotate-180" : ""}`}
                />
              </button>
              {open && (
                <p className="px-5 sm:px-6 pb-4 -mt-1 text-[13px] text-muted leading-relaxed">{item.a}</p>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
