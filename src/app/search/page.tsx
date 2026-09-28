import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import PageHero from "@/components/ui/PageHero";
import Icon from "@/components/ui/Icon";
import SearchPageBox from "@/components/search/SearchPageBox";
import SearchResultSection from "@/components/search/SearchResultSection";
import SearchResultRow from "@/components/search/SearchResultRow";
import { getCareers } from "@/data/careers";
import { getDegrees } from "@/data/degrees";
import { getExams } from "@/data/exams";
import { getColleges } from "@/data/colleges";
import { getSkills } from "@/data/skills";
import { getIndustries } from "@/data/industries";
import { getJobRoles } from "@/data/jobRoles";
import { getCertifications } from "@/data/certifications";
import { getResources } from "@/data/resources";
import { getCategories } from "@/data/categories";

export const metadata: Metadata = {
  title: "Search — CareerGuide",
  description: "Search across every career, degree, exam, college, skill and more on CareerGuide.",
};

const PREVIEW_LIMIT = 5;

function matches(text: string, query: string): boolean {
  return text.toLowerCase().includes(query);
}

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();
  const lowerQuery = query.toLowerCase();

  if (!query) {
    return (
      <>
        <PageHero
          kicker="Search"
          kickerColor="bg-blue-soft text-blue"
          title="Search CareerGuide"
          description="Find careers, degrees, exams, colleges, skills, industries, job roles, certifications and resources -- all in one place."
        />
        <Container className="pb-24">
          <div className="max-w-xl">
            <SearchPageBox />
          </div>
          <div className="text-center py-20">
            <div className="w-14 h-14 rounded-2xl bg-blue-soft flex items-center justify-center text-blue mx-auto mb-4">
              <Icon name="search" className="w-7 h-7" />
            </div>
            <p className="text-muted text-[13.5px]">Start typing to search the whole catalog.</p>
          </div>
        </Container>
      </>
    );
  }

  // Careers/Exams/Colleges already have a server-side `q` filter
  // (CareerController/ExamController/CollegeController all support it --
  // see the backend README's pagination work), so those go straight to the
  // API. Degrees, the 5 newer domains and Categories have no such param, so
  // -- same reasoning as getCareersBySkill/getCareersByIndustry -- this
  // fetches each in full and filters here; every one of them is small
  // enough that this costs nothing.
  const [careers, exams, colleges, degrees, skills, industries, jobRoles, certifications, resources, categories] =
    await Promise.all([
      getCareers({ q: query }),
      getExams({ q: query }),
      getColleges({ q: query }),
      getDegrees(),
      getSkills(),
      getIndustries(),
      getJobRoles(),
      getCertifications(),
      getResources(),
      getCategories(),
    ]);

  const matchedDegrees = degrees.filter((d) => matches(d.title, lowerQuery));
  const matchedSkills = skills.filter((s) => matches(s.name, lowerQuery));
  const matchedIndustries = industries.filter((i) => matches(i.name, lowerQuery));
  const matchedJobRoles = jobRoles.filter((r) => matches(r.name, lowerQuery));
  const matchedCertifications = certifications.filter(
    (c) => matches(c.name, lowerQuery) || matches(c.provider, lowerQuery)
  );
  const matchedResources = resources.filter(
    (r) => matches(r.title, lowerQuery) || matches(r.author, lowerQuery)
  );
  const matchedCategories = categories.filter((c) => matches(c.name, lowerQuery));

  const totalResults =
    careers.length +
    exams.length +
    colleges.length +
    matchedDegrees.length +
    matchedSkills.length +
    matchedIndustries.length +
    matchedJobRoles.length +
    matchedCertifications.length +
    matchedResources.length +
    matchedCategories.length;

  return (
    <>
      <PageHero
        kicker="Search"
        kickerColor="bg-blue-soft text-blue"
        title={`Results for "${query}"`}
        description={`${totalResults} result${totalResults === 1 ? "" : "s"} across the whole catalog.`}
      />
      <Container className="pb-24">
        <div className="max-w-xl mb-10">
          <SearchPageBox />
        </div>

        {totalResults === 0 ? (
          <div className="text-center py-20">
            <div className="w-14 h-14 rounded-2xl bg-bg-soft flex items-center justify-center text-subtle mx-auto mb-4">
              <Icon name="search" className="w-7 h-7" />
            </div>
            <p className="text-navy font-display font-bold text-[16px] mb-1.5">No results for &quot;{query}&quot;</p>
            <p className="text-muted text-[13.5px]">Try a different search term, or browse from the nav.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-x-8">
            <SearchResultSection title="Careers" totalCount={careers.length} viewAllHref={`/careers?q=${encodeURIComponent(query)}`}>
              {careers.slice(0, PREVIEW_LIMIT).map((c) => (
                <SearchResultRow key={c.slug} href={`/careers/${c.slug}`} icon={c.icon} title={c.title} subtitle={c.tagline} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Degrees" totalCount={matchedDegrees.length} viewAllHref={`/degrees?q=${encodeURIComponent(query)}`}>
              {matchedDegrees.slice(0, PREVIEW_LIMIT).map((d) => (
                <SearchResultRow key={d.slug} href={`/degrees/${d.slug}`} icon={d.icon} title={d.title} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Exams" totalCount={exams.length} viewAllHref={`/exams?q=${encodeURIComponent(query)}`}>
              {exams.slice(0, PREVIEW_LIMIT).map((e) => (
                <SearchResultRow key={e.slug} href={`/exams/${e.slug}`} icon={e.icon} title={e.name} subtitle={e.fullName} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Colleges" totalCount={colleges.length} viewAllHref={`/colleges?q=${encodeURIComponent(query)}`}>
              {colleges.slice(0, PREVIEW_LIMIT).map((c) => (
                <SearchResultRow key={c.slug} href={`/colleges/${c.slug}`} icon="bld" title={c.name} subtitle={c.location} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Skills" totalCount={matchedSkills.length} viewAllHref={`/skills?q=${encodeURIComponent(query)}`}>
              {matchedSkills.slice(0, PREVIEW_LIMIT).map((s) => (
                <SearchResultRow key={s.slug} href={`/skills/${s.slug}`} icon="chip" title={s.name} subtitle={s.skillType ?? undefined} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Industries" totalCount={matchedIndustries.length} viewAllHref={`/industries?q=${encodeURIComponent(query)}`}>
              {matchedIndustries.slice(0, PREVIEW_LIMIT).map((i) => (
                <SearchResultRow key={i.slug} href={`/industries/${i.slug}`} icon="building" title={i.name} subtitle={i.isSector ? "Sector" : "Employer"} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Job Roles" totalCount={matchedJobRoles.length} viewAllHref={`/job-roles?q=${encodeURIComponent(query)}`}>
              {matchedJobRoles.slice(0, PREVIEW_LIMIT).map((r) => (
                <SearchResultRow key={r.slug} href={`/job-roles/${r.slug}`} icon="brief" title={r.name} subtitle={r.experienceLevel || undefined} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Certifications" totalCount={matchedCertifications.length} viewAllHref={`/certifications?q=${encodeURIComponent(query)}`}>
              {matchedCertifications.slice(0, PREVIEW_LIMIT).map((c) => (
                <SearchResultRow key={c.slug} href={`/certifications/${c.slug}`} icon="award" title={c.name} subtitle={c.provider || undefined} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Resources" totalCount={matchedResources.length} viewAllHref={`/resources?q=${encodeURIComponent(query)}`}>
              {matchedResources.slice(0, PREVIEW_LIMIT).map((r) => (
                <SearchResultRow key={r.slug} href={`/resources/${r.slug}`} icon="doc" title={r.title} subtitle={r.resourceType || undefined} />
              ))}
            </SearchResultSection>

            <SearchResultSection title="Categories" totalCount={matchedCategories.length} viewAllHref="/categories">
              {matchedCategories.slice(0, PREVIEW_LIMIT).map((c) => (
                <SearchResultRow key={c.slug} href={`/careers?category=${c.slug}`} icon={c.icon} title={c.name} />
              ))}
            </SearchResultSection>
          </div>
        )}
      </Container>
    </>
  );
}
