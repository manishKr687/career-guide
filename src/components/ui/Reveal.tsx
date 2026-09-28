"use client";

import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

// Lightweight, dependency-free scroll reveal (fade + slight rise) used across
// the homepage's "premium" pass -- IntersectionObserver rather than a
// scroll listener so it's cheap, and it fires once (unobserve on enter)
// rather than replaying on every scroll up/down, which reads as jittery
// rather than premium. `motion-reduce:` (Tailwind's built-in
// prefers-reduced-motion variant) forces full opacity with no transition
// unconditionally, in pure CSS -- simpler and hydration-safe compared to
// feature-detecting the media query in JS state (matchMedia isn't
// available during SSR, so that state would diverge between the server
// and client's first render).
export default function Reveal({
  children,
  className,
  delay = 0,
}: {
  children: React.ReactNode;
  className?: string;
  delay?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const node = ref.current;
    if (!node) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true);
          observer.unobserve(node);
        }
      },
      { threshold: 0.15, rootMargin: "0px 0px -40px 0px" }
    );
    observer.observe(node);
    return () => observer.disconnect();
  }, []);

  return (
    <div
      ref={ref}
      className={cn(
        "transition-all duration-700 ease-out motion-reduce:transition-none motion-reduce:!opacity-100 motion-reduce:!translate-y-0",
        visible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4",
        className
      )}
      style={delay ? { transitionDelay: `${delay}ms` } : undefined}
    >
      {children}
    </div>
  );
}
