import Link from "next/link";
import Icon from "@/components/ui/Icon";

export default function SearchResultRow({
  href,
  icon,
  title,
  subtitle,
}: {
  href: string;
  icon: string;
  title: string;
  subtitle?: string;
}) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3.5 px-4 py-3.5 rounded-xl hover:bg-bg-soft transition-colors"
    >
      <div className="w-9 h-9 rounded-[11px] bg-bg-soft flex items-center justify-center text-navy shrink-0">
        <Icon name={icon} className="w-4.5 h-4.5" />
      </div>
      <div className="min-w-0">
        <div className="font-semibold text-ink text-[14px] truncate">{title}</div>
        {subtitle && <div className="text-[12px] text-subtle truncate">{subtitle}</div>}
      </div>
      <Icon name="chevRight" className="w-4 h-4 text-subtle ml-auto shrink-0" />
    </Link>
  );
}
