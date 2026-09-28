import Container from "@/components/ui/Container";
import Skeleton from "@/components/ui/Skeleton";

/**
 * Loading state for a catalog listing page (careers/courses/exams/colleges),
 * shaped to roughly match the real layout -- a hero title/description, a
 * search+filter row, and a grid of card-shaped blocks -- so there's no
 * layout jump once real content replaces it. See the UI architecture doc's
 * "Loading States" section: every data-driven page should have one instead
 * of a blank screen while its Server Component awaits the catalog API.
 */
export default function ListPageSkeleton({ count = 9 }: { count?: number }) {
  return (
    <>
      <section className="pt-10 sm:pt-14 pb-4">
        <Container>
          <Skeleton className="h-5 w-28 rounded-full mb-4" />
          <Skeleton className="h-9 w-72 max-w-full mb-3" />
          <Skeleton className="h-4 w-96 max-w-full" />
        </Container>
      </section>
      <Container className="pb-24">
        <div className="flex flex-col sm:flex-row gap-3 mb-6">
          <Skeleton className="h-[46px] flex-1 min-w-[220px] rounded-xl" />
        </div>
        <div className="mb-8 flex gap-2">
          <Skeleton className="h-9 w-24 rounded-lg" />
          <Skeleton className="h-9 w-28 rounded-lg" />
          <Skeleton className="h-9 w-20 rounded-lg" />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {Array.from({ length: count }).map((_, i) => (
            <div key={i} className="rounded-2xl border border-line p-5 bg-white flex flex-col">
              <div className="flex items-start justify-between">
                <Skeleton className="w-11 h-11 rounded-[13px]" />
                <Skeleton className="h-5 w-20 rounded-full" />
              </div>
              <Skeleton className="h-4 w-3/4 mt-4" />
              <Skeleton className="h-3 w-full mt-2" />
              <Skeleton className="h-3 w-2/3 mt-3 pt-3" />
            </div>
          ))}
        </div>
      </Container>
    </>
  );
}
