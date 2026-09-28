import Link from "next/link";

export default function SearchResultSection({
  title,
  totalCount,
  viewAllHref,
  children,
}: {
  title: string;
  totalCount: number;
  viewAllHref: string;
  children: React.ReactNode;
}) {
  if (totalCount === 0) return null;
  return (
    <div className="mb-8">
      <div className="flex items-center justify-between mb-2 px-1">
        <h2 className="font-display font-extrabold text-navy text-[15px]">
          {title} <span className="text-subtle font-semibold">({totalCount})</span>
        </h2>
        <Link href={viewAllHref} className="text-[12.5px] font-bold text-blue hover:underline">
          View all
        </Link>
      </div>
      <div className="bg-white rounded-2xl border border-line p-2">{children}</div>
    </div>
  );
}
