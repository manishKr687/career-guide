import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Container from "@/components/ui/Container";
import SectionHeader from "@/components/ui/SectionHeader";
import Reveal from "@/components/ui/Reveal";
import { getCategories } from "@/data/categories";

export default async function CategoryGrid() {
  const categories = await getCategories();
  return (
    <section className="mt-24 sm:mt-28">
      <Container>
        <Reveal>
          <SectionHeader
            kicker="Taxonomy"
            kickerColor="bg-purple-soft text-purple"
            title="Explore by Category"
            description="Discover careers across every field, from engineering to entrepreneurship."
            action={
              <Link
                href="/categories"
                className="text-[13px] font-bold text-navy border border-line rounded-xl px-4 py-2.5 hover:border-navy/30 hover:bg-bg-soft transition-colors inline-flex items-center gap-2 shrink-0"
              >
                View All Careers
                <Icon name="arrowRight" className="w-3.5 h-3.5" />
              </Link>
            }
          />
        </Reveal>
        <Reveal delay={100} className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
          {categories.map((cat) => (
            <Link
              key={cat.slug}
              href={`/careers?category=${cat.slug}`}
              className={`flex items-center gap-2.5 rounded-2xl px-3.5 py-3 text-[13px] font-semibold hover:-translate-y-0.5 hover:shadow-card transition-all ${cat.color}`}
            >
              <span className="w-8 h-8 rounded-[9px] bg-white/70 flex items-center justify-center shrink-0">
                <Icon name={cat.icon} className="w-4 h-4" />
              </span>
              {cat.name}
            </Link>
          ))}
        </Reveal>
      </Container>
    </section>
  );
}
