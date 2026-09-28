import Icon from "@/components/ui/Icon";
import { cn } from "@/lib/utils";

export default function IconBadge({
  icon,
  className,
  iconClassName,
  size = "md",
}: {
  icon: string;
  className?: string;
  iconClassName?: string;
  size?: "sm" | "md" | "lg";
}) {
  const sizes = {
    sm: "w-8 h-8 rounded-[9px]",
    md: "w-11 h-11 rounded-[13px]",
    lg: "w-13 h-13 rounded-2xl",
  };
  const iconSizes = { sm: "w-4 h-4", md: "w-5 h-5", lg: "w-6 h-6" };
  return (
    <div
      className={cn(
        "flex items-center justify-center shrink-0",
        sizes[size],
        className
      )}
    >
      <Icon name={icon} className={cn(iconSizes[size], iconClassName)} />
    </div>
  );
}
