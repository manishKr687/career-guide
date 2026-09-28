import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";

const COLUMNS = [
  {
    title: "Discover",
    links: [
      { href: "/careers", label: "Careers" },
      { href: "/degrees", label: "Degrees" },
      { href: "/exams", label: "Exams" },
      { href: "/colleges", label: "Colleges & Universities" },
      { href: "/categories", label: "Career Categories" },
    ],
  },
  {
    title: "Explore More",
    links: [
      { href: "/skills", label: "Skills" },
      { href: "/industries", label: "Industries" },
      { href: "/job-roles", label: "Job Roles" },
      { href: "/certifications", label: "Certifications" },
      { href: "/resources", label: "Resources" },
    ],
  },
  {
    title: "Plan",
    links: [
      { href: "/assessment", label: "Career Assessment" },
      { href: "/roadmap", label: "Career Roadmap" },
      { href: "/compare", label: "Compare Careers" },
      { href: "/profile", label: "My Career" },
    ],
  },
  {
    title: "Stages",
    links: [
      { href: "/stage/after-10th", label: "After 10th" },
      { href: "/stage/after-12th", label: "After 12th" },
      { href: "/stage/graduation", label: "After Graduation" },
      { href: "/stage/post-graduation", label: "Post-Graduation" },
    ],
  },
];

export default function Footer() {
  return (
    <footer className="relative mt-24 rounded-t-[32px] bg-navy text-white overflow-hidden">
      <div className="h-[3px] bg-gradient-to-r from-blue via-purple to-green" />
      <div className="pointer-events-none absolute -top-20 -right-16 w-64 h-64 rounded-full bg-blue/10 blur-3xl" />

      <Container className="relative py-14">
        <div className="grid grid-cols-2 md:grid-cols-6 gap-10">
          <div className="col-span-2">
            <Link href="/" className="flex items-center gap-2.5">
              <span className="w-9 h-9 rounded-[10px] bg-white/10 flex items-center justify-center">
                <Icon name="cap" className="w-5 h-5 text-white" />
              </span>
              <span className="font-display font-extrabold text-[17px]">
                CareerGuide
              </span>
            </Link>
            <p className="text-[13.5px] text-white/60 mt-4 leading-relaxed max-w-xs">
              One platform guiding every learner and professional through
              every stage of their career journey &mdash; not just Class 10.
            </p>
          </div>
          {COLUMNS.map((col) => (
            <div key={col.title}>
              <div className="font-display font-bold text-[12.5px] uppercase tracking-wide text-white/50 mb-4">
                {col.title}
              </div>
              <ul className="flex flex-col gap-2.5">
                {col.links.map((l) => (
                  <li key={l.href}>
                    <Link
                      href={l.href}
                      className="text-[13.5px] text-white/80 hover:text-white transition-colors"
                    >
                      {l.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="border-t border-white/10 mt-12 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="font-display font-bold text-[15px] text-center sm:text-left">
            One Platform. Every Career Stage.
          </div>
          <div className="text-[12px] text-white/50">
            &copy; {new Date().getFullYear()} CareerGuide. Built for every
            stage of the journey.
          </div>
        </div>
      </Container>
    </footer>
  );
}
