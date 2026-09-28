import Container from "@/components/ui/Container";
import Icon from "@/components/ui/Icon";
import Button from "@/components/ui/Button";

/**
 * Global 404 -- rendered whenever a route doesn't match, or any page calls
 * `notFound()` (careers/courses/exams/colleges/stage detail pages all do
 * this for an unknown slug). Still renders inside the root layout, so the
 * Navbar/Footer stay visible.
 */
export default function NotFound() {
  return (
    <Container className="py-24 flex flex-col items-center text-center">
      <div className="w-16 h-16 rounded-2xl bg-bg-soft flex items-center justify-center text-navy mb-6">
        <Icon name="compass" className="w-8 h-8" />
      </div>
      <h1 className="font-display font-extrabold text-navy text-2xl sm:text-3xl mb-3">
        We couldn&apos;t find that page
      </h1>
      <p className="text-muted text-[15px] max-w-md mb-8">
        The page or item you&apos;re looking for may have moved, been renamed,
        or never existed. Try exploring from the homepage instead.
      </p>
      <div className="flex flex-wrap items-center justify-center gap-3">
        <Button href="/">Go to homepage</Button>
        <Button href="/careers" variant="secondary">
          Explore careers
        </Button>
      </div>
    </Container>
  );
}
