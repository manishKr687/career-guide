import Container from "@/components/ui/Container";
import Skeleton from "@/components/ui/Skeleton";

/**
 * Loading state for a `/careers/[slug]`-style detail page -- see
 * ListPageSkeleton's javadoc-equivalent comment for why this exists.
 */
export default function DetailPageSkeleton() {
  return (
    <Container className="pt-10 sm:pt-14 pb-24">
      <Skeleton className="h-4 w-48 mb-6" />
      <Skeleton className="h-5 w-32 rounded-full mb-4" />
      <Skeleton className="h-9 w-96 max-w-full mb-3" />
      <Skeleton className="h-4 w-64 mb-10" />
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-4">
          <Skeleton className="h-32 w-full rounded-2xl" />
          <Skeleton className="h-48 w-full rounded-2xl" />
          <Skeleton className="h-40 w-full rounded-2xl" />
        </div>
        <div className="space-y-4">
          <Skeleton className="h-40 w-full rounded-2xl" />
          <Skeleton className="h-40 w-full rounded-2xl" />
        </div>
      </div>
    </Container>
  );
}
