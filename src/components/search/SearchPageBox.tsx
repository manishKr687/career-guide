"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import SearchInput from "@/components/ui/SearchInput";

/**
 * A single search box for /search -- deliberately simpler than
 * useUrlListState (no filter/page state to carry), since this page has
 * neither a filter chip row nor pagination, just one query synced to `?q=`.
 */
export default function SearchPageBox() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [query, setQuery] = useState(() => searchParams.get("q") ?? "");

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setQuery(searchParams.get("q") ?? "");
  }, [searchParams]);

  useEffect(() => {
    const id = setTimeout(() => {
      const qs = query.trim() ? `?q=${encodeURIComponent(query.trim())}` : "";
      router.replace(`${pathname}${qs}`, { scroll: false });
    }, 400);
    return () => clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query]);

  return (
    <SearchInput
      value={query}
      onChange={setQuery}
      placeholder="Search careers, degrees, exams, skills..."
    />
  );
}
