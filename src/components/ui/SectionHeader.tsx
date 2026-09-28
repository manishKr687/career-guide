import { cn } from "@/lib/utils";

export default function SectionHeader({
  kicker,
  kickerColor = "text-purple bg-purple-soft",
  title,
  description,
  align = "left",
  action,
}: {
  kicker?: string;
  kickerColor?: string;
  title: string;
  description?: string;
  align?: "left" | "center";
  action?: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        "flex flex-col gap-4 mb-8 sm:mb-10",
        align === "center" ? "items-center text-center" : "sm:flex-row sm:items-end sm:justify-between"
      )}
    >
      <div className={align === "center" ? "max-w-2xl" : ""}>
        {kicker && (
          <span
            className={cn(
              "inline-flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1.5 rounded-full mb-3 font-display",
              kickerColor
            )}
          >
            <span className="w-1.5 h-1.5 rounded-full bg-current opacity-70" />
            {kicker}
          </span>
        )}
        <h2 className="font-display font-extrabold text-navy text-2xl sm:text-3xl leading-tight text-balance">
          {title}
        </h2>
        {description && (
          <p className="text-muted text-sm sm:text-[15px] mt-2.5 leading-relaxed max-w-2xl">
            {description}
          </p>
        )}
      </div>
      {action}
    </div>
  );
}
