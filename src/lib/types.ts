// Stages are the student timeline, and only that. Two of the original six
// were removed for the same underlying reason -- neither was a point in
// education:
//
//   career-switch         V99  -- can happen at any stage, not a stage
//                                itself; had no exams or streams, so once the
//                                careers section was dropped it rendered an
//                                empty page
//   working-professional  V100 -- describes employment status, not a step in
//                                the timeline, and its "decision" (upskill)
//                                has no admission gate behind it
//
// Its three stage-only exams were re-homed by eligibility rather than deleted
// -- see V100.
export type StageSlug =
  | "after-10th"
  | "after-12th"
  | "graduation"
  | "post-graduation";

export interface Stage {
  slug: StageSlug;
  name: string;
  tagline: string;
  description: string;
  badgeSoft: string; // literal tailwind classes, e.g. "bg-stage-10th-soft text-stage-10th"
  badgeSolid: string; // literal tailwind classes, e.g. "bg-stage-10th text-white"
  icon: string;
  highlights: string[];
  relatedCareerSlugs: string[];
  relatedExamSlugs: string[];
}

export interface Category {
  slug: string;
  name: string;
  icon: string;
  color: string;
}

// Added in V24 -- backfilled from each career's old `skills` text array, so
// for now every Skill's `name` duplicates a string already in that array.
// Kept minimal (no description/icon) since the source data has none.
// `skillType` (V34) classifies a subset of skills (Programming Language,
// Technical, Cloud, Tool, Domain Skill, Soft Skill, ...) and is null for
// every skill the seed data didn't have a type for.
export interface Skill {
  slug: string;
  name: string;
  skillType: string | null;

  // --- V114. `skillType` above is free text an editor typed and is null for
  // 384 of 413 rows, so it could never drive a facet. `category` is derived
  // by rule from the name and is set for every skill.
  //
  // Five buckets, not the seven a skill taxonomy usually has: "Creative" and
  // "Language" were tried and abandoned because deciding from a name alone
  // whether "Experimental Design" is creative or scientific is guesswork.
  // Anything not confidently placed stays in Domain, which is honestly where
  // two thirds of this catalog belongs -- it is largely field knowledge.
  category: "Soft" | "Programming" | "Tools" | "Analytical" | "Domain";
  // Null for every skill today; 413 descriptions is a content task.
  description: string | null;
}

// Added in V25 -- same pattern as Skill, backfilled from `topRecruiters`, so
// "industry" here originally meant "known employer" (e.g. "Apollo
// Hospitals") rather than a sector. `isSector` (V35) distinguishes a broad
// sector taxonomy row (e.g. "Healthcare", "Fintech") added on top of those
// pre-existing employer rows -- defaults to false for every pre-V35 row.
export interface Industry {
  slug: string;
  name: string;
  isSector: boolean;
}

// Added in V26 -- per both uploaded specs' "Career is not the same as a Job
// Role" distinction. Deliberately thin: no education/growth/salary range of
// its own beyond experienceLevel/salaryMin/salaryMax -- a Job Role inherits
// the rest from its Career(s) and only adds skills/industries + seniority on
// top. Many-to-many with Career (career_job_roles). Only backfilled for
// Software Engineer (7 roles) so far; every other career has none yet.
export interface JobRole {
  slug: string;
  name: string;
  description: string;
  experienceLevel: string;
  salaryMin: string;
  salaryMax: string;
  careerSlugs: string[];
  relatedSkillSlugs: string[];
  relatedIndustrySlugs: string[];
  // Added in V72 -- editable from this entity's own admin form (JobRole
  // owns this relation, unlike relatedExamSlugs below).
  relatedCertificationSlugs: string[];
  // The inverse of Exam.jobRoleSlugs (V68) -- read-only here, same
  // convention as College.disciplineSlugs; edited only from the Exam
  // admin form. Some job roles need a certification, some an exam, some
  // both, some neither -- these two relations are independent.
  relatedExamSlugs: string[];

  // V107 converted job_roles' salary to NUMERIC and backfilled 247 of 255
  // rows, but this interface was never updated -- so the app saw only the
  // "5 LPA" strings above and nothing could sort or filter on pay. These
  // are the ones to read; the strings remain only because the admin form
  // still edits them. Null for the 8 roles with no salary recorded, which
  // is not the same as zero.
  salaryMinLpa: number | null;
  salaryMaxLpa: number | null;
  // Composed server-side by SalaryRange, exactly as Career does it.
  salaryRange: string | null;
}

// Added in V27 -- see the Data Model Roadmap doc's "Spec v1.0 Match" tab.
// No content is seeded yet (neither uploaded source doc gave real
// certification data tied to careers/skills), so `/api/certifications`
// currently returns an empty list -- the listing/detail pages below are
// built and ready for when real content is added, same as Skill/Industry
// were before their backfill.
export interface Certification {
  slug: string;
  name: string;
  description: string;
  provider: string;
  level: string;
  duration: string;
  officialUrl: string;
  relatedCareerSlugs: string[];
  relatedSkillSlugs: string[];
}

// Added in V28 -- see the Data Model Roadmap doc's "Resources should not be
// tightly coupled to one entity" note: a Resource can relate to careers,
// courses, exams and skills all at once, unlike Certification (career+skill
// only). No content is seeded yet, same situation as Certification --
// `/api/resources` currently returns an empty list. `publishedAt` is a
// nullable ISO date string ("YYYY-MM-DD"), not a Date object.
export interface Resource {
  slug: string;
  title: string;
  resourceType: string;
  description: string;
  contentUrl: string;
  author: string;
  publishedAt: string | null;
  relatedCareerSlugs: string[];
  relatedExamSlugs: string[];
  relatedSkillSlugs: string[];
}

// A field of study -- Physics, Computer Science, Nursing, Law. Added in V87.
//
// The other half of a qualification: Degree answers "what kind" (M.Sc,
// B.Tech), Subject answers "in what". Together they read as "M.Sc (Physics)",
// composed at render time rather than stored, so the pair cannot drift from
// its parts.
//
// `category` lives here rather than on Degree because the same subject
// carried the same category in every degree family it appeared in, while the
// same degree carried different categories depending on its subject.
// Conversely `level` stays on Degree -- all 17 B.Sc variants independently
// recorded "Undergraduate", one fact about the qualification rather than
// seventeen about subjects.
export interface Subject {
  slug: string;
  title: string;
  description: string;
  icon: string;
  categorySlug: string;
}

// Added in V29 -- the 11th/12th split (Science / Commerce / Arts &
// Humanities / Vocational). Deliberately minimal and small: only these 4
// canonical streams are seeded, and (per the migration's own scope note)
// broader field names like "Engineering" or "Medical" are NOT modeled as
// streams too, since those already exist as Categories/Careers -- adding
// them here would just be a second, overlapping way to say the same thing.
//
// V91 moved stageSlugs from "after-12th" to "after-10th": you CHOOSE a
// stream after 10th, and by 12th you already have one.
//
// V92 finally populated `stream_careers`, which had existed empty and
// unmapped since V29. careerSlugs is a "primary route" list, not everything
// a student is technically permitted to do -- a Science student may sit CLAT,
// but Law is listed under Arts because that is its normal entry path. The
// three academic streams partition all 42 careers exactly once; Vocational
// overlaps them, since a diploma is an alternative route rather than a
// separate set of careers.
// A subject combination inside a stream -- PCM, PCB, PCMB (V97). Only
// Science has any; Commerce, Arts & Humanities and Vocational are leaves
// and return an empty `combinations` array, which is the normal case.
//
// careerSlugs is a subset of the parent stream's: PCM sees 23 of Science's
// 29, the other 6 being Biology-gated. This exists because "Science" alone
// was actively misleading -- it bundled 16 engineering careers (which need
// Mathematics) with 4 medical ones (which need Biology).
export interface StreamCombination {
  slug: string;
  streamSlug: string;
  name: string;
  shortName: string;
  description: string;
  careerSlugs: string[];
}

export interface Stream {
  slug: string;
  name: string;
  description: string;
  stageSlugs: string[];
  careerSlugs: string[];
  combinations: StreamCombination[];
}

export interface CareerGrowthStep {
  label: string;
}

// One education route: a degree, and the subject it is taken in (V103).
// subjectSlug is null for a fused qualification that takes none (MBBS, GNM --
// see Degree.requiresSubject), or where one applies but is not filled in yet.
// `title` is derived server-side; degreeSlug + subjectSlug are the truth.
export interface Education {
  degreeSlug: string;
  subjectSlug: string | null;
  title: string;
}

export interface Career {
  slug: string;
  title: string;
  categorySlug: string;
  tagline: string;
  demand: "High Demand" | "Emerging" | "Evergreen" | "Stable" | "Competitive";
  entranceExams: string[];
  typicalWork: string;
  // Derived server-side from the two numbers below (V107), so it is read-only
  // -- the admin form edits the numbers. Before V107 this string WAS the
  // storage, which made salary impossible to filter, sort or compare: a
  // career's "₹4L" and a job role's "4 LPA" are the same figure and did not
  // match, and ordering put ₹10L before ₹4L.
  salaryRange: string | null;
  // Lakhs per annum. Null means not recorded, which is not the same as zero.
  salaryMinLpa: number | null;
  salaryMaxLpa: number | null;
  growthPath: string[];
  relatedExamSlugs: string[];
  stageSlugs: StageSlug[];
  icon: string;
  description: string;
  relatedCollegeSlugs: string[];
  // Added in V16 -- for now only populated for Aerospace Engineer, empty
  // for every other career.
  relatedSpecializationSlugs: string[];
  // Added in V24/V25 -- normalized versions of `skills`/the former
  // `topRecruiters` (dropped in V41; the career detail page's "Top
  // Recruiters" section now reads relatedIndustrySlugs directly), unordered
  // (see backend/README.md's Phase 1-3 section).
  relatedSkillSlugs: string[];
  relatedIndustrySlugs: string[];
  // Added in V26 -- only populated for Software Engineer (7 job roles) so
  // far; every other career returns an empty list, since no source data
  // exists yet for the other 55.
  relatedJobRoleSlugs: string[];
  // Started in V47 as a single nullable degreeSlug, replaced in V51 with
  // a real many-to-many Degree<->Career relation (career_degrees) -- most
  // disciplines genuinely have more than one valid entry degree, which is
  // exactly what the old *-to-one shape couldn't represent. Empty for any
  // discipline where no degree in the catalog is a clean, direct match --
  // see V51's migration comment for the full per-discipline reasoning.
  // Where nonempty, this is preferred over the shared-entrance-exam
  // heuristic in data/degrees.ts's filterDegreesRelevantToCareer.
  // V103 -- each entry is a (degree, subject) pair. `degrees` holds
  // qualification TYPES only now, so "B.A. (Psychology)" is a B.A. row plus a
  // Psychology row, joined here. `title` is composed by the SERVER (the rule
  // is level-dependent: parentheses for bachelor's/master's, "in" for
  // doctorates) so every caller renders it identically -- do not rebuild it
  // client-side.
  education: Education[];

  // --- V110. A career is the parent of its specializations, so these cover
  // the broad view -- progression, pay by level, where the work happens --
  // while the specialization page covers one focused area within it.

  // The progression ladder with experience attached. Supersedes `growthPath`
  // above, which stays only until nothing reads it.
  growthStages: GrowthStage[];
  // Pay by experience level. Empty for all 42 careers: the figures do not
  // exist anywhere in the catalog and generating plausible ones would put
  // numbers on the page that read as researched and are not. The page shows
  // the verified overall range until real bands are entered.
  salaryBands: SalaryBand[];
  // Short claims about the career. Empty for all 42 -- the page derives them
  // from facts it can prove, and a stored value overrides that.
  highlights: string[];
  workEnvironments: string[];
  // Null means unresearched, which is different from zero. The page omits the
  // metric rather than rendering a placeholder.
  experienceMinYears: number | null;
  experienceMaxYears: number | null;
  jobOpenings: number | null;
}

/** One rung of a career's progression ladder (V110). */
export interface GrowthStage {
  title: string;
  minYears: number;
  // Null on the last rung and means open-ended; `label` renders it as "12+ yrs".
  maxYears: number | null;
  // Composed server-side so the range is written identically everywhere.
  label: string;
}

/** What a career pays at one experience level (V110). */
export interface SalaryBand {
  band: string;
  minLpa: number;
  // Null on the top band -- "₹40L+ / year", no invented ceiling.
  maxLpa: number | null;
  label: string;
}

// A degree/qualification type (B.Tech, M.Tech, Diploma, B.Ed, ...) -- added
// to replace the removed Courses section. Not one row per discipline: a
// general pursuit guide for the degree itself (entrance exams, how to
// prepare, the skills it takes, curated resources). See backend Degree.java.
export interface Degree {
  slug: string;
  title: string;
  description: string;
  icon: string;
  preparationStrategy: string | null;
  // Added in V70 -- see that migration's comment for the taxonomy and why
  // it's an explicit column rather than derived from title.
  level: "Undergraduate" | "Postgraduate" | "Diploma" | "Doctoral" | "Certificate";
  // Added in V71 -- null for the 3 generic degrees (Certificate, Diploma,
  // PhD with no subject named) that have no confident category; see that
  // migration's comment for why this is nullable unlike Career.categorySlug.
  categorySlug: string | null;
  // Added in V88 -- whether a Subject can apply to this qualification at all.
  // "M.Sc" is incomplete without one; "MBBS" is complete already. A UI hint,
  // NOT a constraint: subject stays optional even where this is true.
  requiresSubject: boolean;
  entranceExamSlugs: string[];
  skillSlugs: string[];
  resourceSlugs: string[];
  // V101 -- the fields of study this qualification is offered in, e.g. B.Sc
  // -> Computer Science, Data Science, Economics. Replaces the 42 product
  // rows V102 deleted (a separate `bsc-computer-science` degree per subject),
  // each of which restated `level` from its family and carried a category
  // describing its subject rather than itself.
  //
  // Empty for most degrees and that is normal: fused qualifications (MBBS,
  // B.Arch) take no subject -- see requiresSubject -- and product rows with
  // live references have not been converted yet.
  subjectSlugs: string[];

  // --- V111.

  // What the abbreviation stands for -- "Bachelor of Technology" for B.Tech.
  // Null where `title` is already the full name (Diploma, Certificate).
  fullTitle: string | null;
  // Programme length in years, both bounds set and equal where fixed. Null on
  // both means the qualification is not a taught programme (DSc, DLitt, LLD
  // are awarded on submitted published work), which is not the same as
  // unknown.
  durationMinYears: number | null;
  durationMaxYears: number | null;
  // Composed server-side: "4 years", "3-5 years", "6 months", or null.
  durationLabel: string | null;
}

// Added in V66 -- the specific degree this exam is the entry gate into a
// career through (e.g. jee-main -> computer-science-and-engineering ->
// b-tech). Same shape/purpose as CollegeCareerOffering.
export interface ExamCareerDegreeOffering {
  careerSlug: string;
  degreeSlug: string;
}

export interface Exam {
  slug: string;
  name: string;
  fullName: string;
  category: "After 10th" | "After 12th" | "Undergraduate Entrance" | "Government" | "Banking" | "Defence" | "Postgraduate Entrance" | "Professional";
  conductedBy: string;
  frequency: string;
  description: string;
  careerSlugs: string[];
  icon: string;
  // Colleges that list this exam (college_exams). The API has returned this
  // all along; the interface simply never declared it, so nothing could read
  // it without a type error. Thin -- 12 of 34 exams have any, and GATE lists
  // 2 of the 54 colleges that actually admit through it.
  collegeSlugs: string[];
  // Added in V66 -- all nullable (not backfilled for the pre-existing catalog).
  mode: string | null;
  eligibilityMinQualification: string | null;
  officialWebsite: string | null;
  syllabusOverview: string | null;
  careerDegreeOfferings: ExamCareerDegreeOffering[];
  // Added in V68 -- orthogonal to `category` (which stage/audience this is
  // for): this is what you actually get for passing.
  examType: "Admission" | "Recruitment" | "Eligibility";
  // The Recruitment-side counterpart to careerDegreeOfferings' Admission-side
  // pairing -- which JobRole(s) this exam gets you hired/commissioned into.
  jobRoleSlugs: string[];

  // --- V112.

  // The FIELD this exam belongs to, as a slug from the shared `categories`
  // taxonomy. Distinct from `category` above, which is free text holding the
  // STAGE axis ("After 12th") -- the two were conflated in one column and
  // neither could be filtered on. Null for CUET and NTSE, which genuinely
  // span every field.
  categorySlug: string | null;
  // What the exam gets you. Not the same question as `examType` (what the
  // exam IS) or `eligibilityMinQualification` (what you need before it).
  level: "School" | "Diploma" | "Undergraduate" | "Postgraduate" | "Research" | "Certification" | "Recruitment";
  // `frequency` normalised to a filterable bucket. The prose column stays,
  // because "Once a year (state-wise)" says something the bucket cannot.
  frequencyType: "Annual" | "Biannual" | "Quarterly" | "Monthly" | "Rolling" | "As notified";
}

// Added in V53 (College MVP) -- India's states/UTs and cities, used to
// give College/University a structured location instead of only the
// free-text `location` string below (which is kept for display/search
// backward-compatibility, not replaced).
export interface State {
  slug: string;
  name: string;
  code: string;
}

export interface City {
  slug: string;
  name: string;
  stateSlug: string;
}

// Added in V53 (College MVP). A college's optional parent university --
// most colleges in this catalog have none (they're autonomous
// degree-granting institutes or are themselves universities), see
// backend V53's migration comment.
export interface University {
  slug: string;
  name: string;
  universityType: "Central" | "State" | "Deemed" | "Private";
  ownershipType: "Government" | "Private" | "Government-Aided";
  stateSlug: string | null;
  citySlug: string | null;
  website: string | null;
  status: "Active" | "Inactive";
}

// Added in V55 -- the specific degree a college's career/discipline
// offering is actually awarded through (e.g. NIT Patna's
// computer-science-and-engineering discipline is awarded via b-tech).
// Read-only, same as disciplineSlugs below -- no admin UI yet, see
// CollegeDto's backend javadoc.
export interface CollegeCareerOffering {
  careerSlug: string;
  degreeSlug: string;
}

export interface College {
  slug: string;
  name: string;
  location: string;
  type: "IIT" | "NIT" | "Medical" | "Law" | "Management" | "Polytechnic" | "University" | "ITI";
  established: number;
  tags: string[];
  description: string;
  examSlugs: string[];
  // Added in V53 (College MVP).
  ownershipType: "Government" | "Private" | "Government-Aided";
  universitySlug: string | null;
  stateSlug: string;
  citySlug: string | null;
  website: string | null;
  status: "Active" | "Inactive";
  // V103 -- (degree, subject) pairs rather than bare slugs; 54 colleges award
  // a PhD in Engineering, which a flat slug list cannot express now that the
  // combined degree row is gone.
  degreeOfferings: Education[];
  specializationSlugs: string[];
  // Read-only: the inverse of Career.relatedCollegeSlugs, edited only from
  // the Career admin form -- see CollegeDto's backend javadoc.
  disciplineSlugs: string[];
  careerOfferings: CollegeCareerOffering[];

  // --- V113. All three move together, and the DB CHECK enforces it: NIRF
  // publishes a dozen league tables a year, so a rank without the table it
  // came from is ambiguous. IIT Madras is 1st Overall AND 1st Engineering;
  // IISc is 2nd Overall and not in the Engineering table at all.
  //
  // Null for all 90 today. These are published figures and were not seeded
  // from recall -- every part of the listing that uses them is conditional,
  // so the page is complete without them and gains the rank badge, the NIRF
  // facet and the Top Colleges rail the moment they are entered.
  nirfRank: number | null;
  nirfCategory: string | null;
  nirfYear: number | null;
  // Composed server-side: "NIRF 2024 · Engineering", or null.
  nirfLabel: string | null;
}

// Added in V16 -- a sub-discipline within a career (e.g. Propulsion within
// Aerospace Engineering) linked to the specific course(s)/exam(s) that cover
// it, so it's a real relation rather than a plain text tag.
export interface Specialization {
  slug: string;
  name: string;
  description: string;
  icon: string;
  relatedExamSlugs: string[];
  careerSlugs: string[];
  relatedJobRoleSlugs: string[];
  relatedHardSkillSlugs: string[];
  relatedSoftSkillSlugs: string[];
  responsibilities: string[];
  demand: string | null;
  certificationSlugs: string[];
  industrySlugs: string[];

  // --- V108. Everything below describes the FIELD rather than a person
  // working in it, which is what lets one page render any specialization.

  // "What you will learn". Distinct from `description` (one line, for cards
  // and search) and `responsibilities` (what the job involves day to day).
  // Null where nobody has written one -- 262 of 263 at time of writing.
  overview: string | null;
  // Short claims about the field. Empty where unwritten.
  highlights: string[];
  // Education routes in: a degree plus the subject it is taken in, so the
  // page can say "B.Tech (Artificial Intelligence)" and not just "B.Tech".
  education: Education[];
  // Read-only inverse of College.specializationSlugs -- edited from the
  // college, not here.
  collegeSlugs: string[];
  resourceSlugs: string[];

  // --- V110. Null for all 263: a specialization does pay differently from its
  // parent career, which is why it is recorded separately, but nobody has
  // researched the figures. The page falls back to the career's range under a
  // label naming whose range it is.
  salaryMinLpa: number | null;
  salaryMaxLpa: number | null;
  // Derived server-side from the two numbers above; null when they are.
  salaryRange: string | null;
}

export interface AssessmentOption {
  id: string;
  label: string;
  weights: Partial<Record<string, number>>; // categorySlug -> weight
}

export interface AssessmentQuestion {
  id: string;
  question: string;
  options: AssessmentOption[];
}
