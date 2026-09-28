import Container from "@/components/ui/Container";
import { cn } from "@/lib/utils";

export default function PageHero({
  kicker,
  kickerColor = "bg-blue-soft text-blue",
  title,
  description,
  className,
  children,
}: {
  kicker?: string;
  kickerColor?: string;
  title: string;
  description?: string;
  className?: string;
  children?: React.ReactNode;
}) {
  return (
    <section className={cn("pt-10 sm:pt-14 pb-4", className)}>
      <Container>
        {kicker && (
          <span
            className={cn(
              "inline-block text-[11px] font-bold tracking-widest uppercase px-3 py-1.5 rounded-full mb-4 font-display",
              kickerColor
            )}
          >
            {kicker}
          </span>
        )}
        <h1 className="font-display font-extrabold text-navy text-3xl sm:text-4xl leading-tight text-balance max-w-3xl">
          {title}
        </h1>
        {description && (
          <p className="text-muted text-[15px] mt-3 leading-relaxed max-w-2xl">
            {description}
          </p>
        )}
        {children}
      </Container>
    </section>
  );
}
