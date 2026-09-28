import { AdminResource } from "@/lib/adminApi";
import { getCareers } from "@/data/careers";
import { getDegrees } from "@/data/degrees";
import { getSubjects } from "@/data/subjects";
import { getExams } from "@/data/exams";
import { getColleges } from "@/data/colleges";
import { getCategories } from "@/data/categories";
import { getStages } from "@/data/stages";
import { getSkills } from "@/data/skills";
import { getIndustries } from "@/data/industries";
import { getSpecializations } from "@/data/specializations";
import { getJobRoles } from "@/data/jobRoles";
import { getCertifications } from "@/data/certifications";
import { getResources } from "@/data/resources";
import { getStates } from "@/data/states";
import { getCities } from "@/data/cities";
import { getUniversities } from "@/data/universities";
import { ICON_PATHS } from "@/components/ui/Icon";

export type FieldType = "text" | "textarea" | "number" | "select" | "tags" | "multiselect" | "boolean" | "date" | "pairs" | "rows";

export interface FieldOption {
  value: string;
  label: string;
}

/**
 * Config for a "pairs" field -- a list of (A, B) records, e.g. College's
 * careerOfferings ({careerSlug, degreeSlug}). Generic on purpose: the next
 * relation shaped like this (e.g. an exam's career+degree offerings) reuses
 * the same field type and PairListField component instead of a new one.
 */
export interface PairFieldConfig {
  /** The two object keys each row has, e.g. ["careerSlug", "degreeSlug"]. */
  keys: [string, string];
  /** `optionsKey` (see FieldConfig) for each side's picker. */
  optionsKeys: [string, string];
  /** Display labels for each side, e.g. ["Career", "Degree"]. */
  labels: [string, string];
  /**
   * When true the B side may be left blank, producing a row with only A set.
   * Needed for education: a fused qualification like MBBS takes no subject at
   * all, so requiring one would make those rows unenterable.
   */
  optionalB?: boolean;
  /**
   * An `optionsKey` listing the A values for which the B side applies at all.
   * When set, choosing an A outside that list disables the B picker -- for
   * education it points at the degrees whose `requiresSubject` is true, so
   * the form cannot offer "MBBS in Physics".
   */
  bAppliesToA?: string;
}

/**
 * Config for a "rows" field -- an ordered list of small records whose columns
 * are not all slugs, e.g. Career's growthStages ({title, minYears, maxYears})
 * and salaryBands ({band, minLpa, maxLpa}).
 *
 * Distinct from "pairs", which is two slug pickers. These rows are typed free
 * input, they are ORDERED (the ladder is a sequence, so the rung order is the
 * data), and a column may legitimately be blank to mean open-ended -- the last
 * growth rung has no upper year and the top salary band has no ceiling.
 */
export interface RowFieldConfig {
  columns: {
    key: string;
    label: string;
    type: "text" | "number";
    /** Blank is allowed and posts null -- used for the open-ended upper bound. */
    optional?: boolean;
    placeholder?: string;
  }[];
  /** Button text, e.g. "Add stage". */
  addLabel: string;
}

/** A field in an admin create/edit form. `optionsKey` looks up choices loaded by `loadReferenceOptions`; `staticOptions` is for enums baked into the frontend's TS types (e.g. career demand, course level). */
export interface FieldConfig {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  helpText?: string;
  optionsKey?: string;
  staticOptions?: FieldOption[];
  /** Only for `type: "pairs"`. */
  pairConfig?: PairFieldConfig;
  /** Only for `type: "rows"`. */
  rowConfig?: RowFieldConfig;
}

export type FormValues = Record<string, string | number | boolean | string[] | Array<Record<string, string>> | undefined>;

export interface ColumnConfig {
  label: string;
  render: (item: FormValues) => string;
}

export interface ResourceConfig {
  resource: AdminResource;
  label: string;
  pluralLabel: string;
  fields: FieldConfig[];
  columns: ColumnConfig[];
  /** Loads the pick-lists needed by this resource's select/multiselect fields (categories, related courses, etc). */
  loadReferenceOptions: () => Promise<Record<string, FieldOption[]>>;
  /** Loads the full current list, as plain FormValues records, for the list page and for pre-filling an edit form. */
  loadAll: () => Promise<FormValues[]>;
}

const ICON_OPTIONS: FieldOption[] = Object.keys(ICON_PATHS).map((name) => ({ value: name, label: name }));

function toSlugOptions<T extends { slug: string }>(items: T[], label: (item: T) => string): FieldOption[] {
  return items.map((item) => ({ value: item.slug, label: label(item) }));
}

export const careerConfig: ResourceConfig = {
  resource: "careers",
  label: "Career",
  pluralLabel: "Careers",
  columns: [
    { label: "Title", render: (c) => String(c.title ?? "") },
    { label: "Category", render: (c) => String(c.categorySlug ?? "") },
    { label: "Demand", render: (c) => String(c.demand ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "title", label: "Title", type: "text", required: true },
    { key: "categorySlug", label: "Category", type: "select", required: true, optionsKey: "categories" },
    { key: "tagline", label: "Tagline", type: "text", required: true },
    {
      key: "demand",
      label: "Demand",
      type: "select",
      required: true,
      staticOptions: ["High Demand", "Emerging", "Evergreen", "Stable", "Competitive"].map((v) => ({ value: v, label: v })),
    },
    {
      key: "education",
      label: "Education (Degree + Subject)",
      type: "pairs",
      helpText: "Each entry is a qualification and the subject it's taken in -- B.A. + Psychology renders as \"B.A. (Psychology)\". Leave Subject blank for a fused qualification like MBBS that has no separate field of study. Order matters: list the entry route first.",
      pairConfig: {
        keys: ["degreeSlug", "subjectSlug"],
        optionsKeys: ["degrees", "subjects"],
        labels: ["Degree", "Subject"],
        optionalB: true,
        bAppliesToA: "degreesTakingSubject",
      },
    },
    { key: "typicalWork", label: "Typical Work", type: "textarea", required: true },
    // Numbers, not the display string (V107): the server composes
    // "₹4L – ₹30L / year" from these. Editing the text directly is what let
    // a malformed value into the catalog and made salary unsortable.
    { key: "salaryMinLpa", label: "Salary Min (LPA)", type: "number", required: true, helpText: "Lakhs per annum, e.g. 4 or 2.5" },
    { key: "salaryMaxLpa", label: "Salary Max (LPA)", type: "number", required: true, helpText: "Lakhs per annum. Must be at least the minimum." },
    { key: "growthPath", label: "Growth Path (legacy)", type: "tags", helpText: "Superseded by Career Growth Path below, which carries an experience range per rung. Kept only until nothing reads it." },
    {
      key: "growthStages",
      label: "Career Growth Path",
      type: "rows",
      helpText: "The progression ladder, in order -- each rung is a role and the experience at which it typically happens. Leave Max Years blank on the last rung: that means open-ended and renders as \"12+ yrs\" rather than inventing a ceiling.",
      rowConfig: {
        addLabel: "Add stage",
        columns: [
          { key: "title", label: "Role", type: "text", placeholder: "Senior Software Engineer" },
          { key: "minYears", label: "Min Years", type: "number", placeholder: "5" },
          { key: "maxYears", label: "Max Years", type: "number", optional: true, placeholder: "8 (blank = open-ended)" },
        ],
      },
    },
    {
      key: "salaryBands",
      label: "Salary by Experience Level",
      type: "rows",
      helpText: "Empty for every career today, deliberately: these figures are not derivable from anything in the catalog, and generated ones would read as researched. Enter real ones and the page switches from the single overall range to this breakdown. Leave Max blank on the top band for \"40+ LPA\".",
      rowConfig: {
        addLabel: "Add band",
        columns: [
          { key: "band", label: "Level", type: "text", placeholder: "Entry Level" },
          { key: "minLpa", label: "Min (LPA)", type: "number", placeholder: "4" },
          { key: "maxLpa", label: "Max (LPA)", type: "number", optional: true, placeholder: "10 (blank = open-ended)" },
        ],
      },
    },
    { key: "highlights", label: "Key Highlights", type: "tags", helpText: "Comma-separated. Leave empty and the page derives them from facts it can prove (demand, specialization count, salary ceiling, sector breadth) -- a derived claim cannot go stale against its own data." },
    { key: "workEnvironments", label: "Work Environment", type: "tags", helpText: "Comma-separated, e.g. Product Companies, Tech Startups, Remote." },
    { key: "experienceMinYears", label: "Typical Experience Min (years)", type: "number", helpText: "Blank means unresearched -- the hero omits the metric rather than showing a placeholder." },
    { key: "experienceMaxYears", label: "Typical Experience Max (years)", type: "number" },
    { key: "jobOpenings", label: "Job Openings (India)", type: "number", helpText: "A whole number, e.g. 500000 -- the page formats it as \"5L+\". Blank means unresearched." },
    { key: "relatedExamSlugs", label: "Related Exams", type: "multiselect", optionsKey: "exams" },
    { key: "stageSlugs", label: "Stages", type: "multiselect", optionsKey: "stages" },
    { key: "relatedSkillSlugs", label: "Related Skills", type: "multiselect", optionsKey: "skills" },
    { key: "relatedJobRoleSlugs", label: "Job Roles", type: "multiselect", optionsKey: "jobRoles" },
    { key: "relatedIndustrySlugs", label: "Industries", type: "multiselect", optionsKey: "industries" },
    { key: "relatedCollegeSlugs", label: "Related Colleges", type: "multiselect", optionsKey: "colleges" },
    { key: "relatedSpecializationSlugs", label: "Specializations", type: "multiselect", optionsKey: "specializations" },
    { key: "icon", label: "Icon", type: "select", required: true, staticOptions: ICON_OPTIONS },
    { key: "description", label: "Description", type: "textarea", required: true },
    { key: "sortOrder", label: "Sort Order", type: "number", helpText: "Leave blank to auto-place after the last career in this category" },
  ],
  loadReferenceOptions: async () => {
    const [categories, exams, stages, skills, jobRoles, industries, colleges, specializations, degrees, subjects] = await Promise.all([
      getCategories(),
      getExams(),
      getStages(),
      getSkills(),
      getJobRoles(),
      getIndustries(),
      getColleges(),
      getSpecializations(),
      getDegrees(),
      getSubjects(),
    ]);
    return {
      categories: toSlugOptions(categories, (c) => c.name),
      skills: toSlugOptions(skills, (s) => s.name),
      jobRoles: toSlugOptions(jobRoles, (j) => j.name),
      industries: toSlugOptions(industries, (i) => i.name),
      colleges: toSlugOptions(colleges, (c) => c.name),
      specializations: toSlugOptions(specializations, (s) => s.name),
      exams: toSlugOptions(exams, (e) => e.name),
      stages: toSlugOptions(stages, (s) => s.name),
      degrees: toSlugOptions(degrees, (d) => d.title),
      subjects: toSlugOptions(subjects, (s) => s.title),
      // Degrees a subject can apply to at all (V88's requiresSubject). Used
      // only to enable/disable the Subject picker -- it is a UI hint, not a
      // constraint: subject stays optional even for these.
      degreesTakingSubject: toSlugOptions(degrees.filter((d) => d.requiresSubject), (d) => d.title),
    };
  },
  loadAll: async () => (await getCareers()) as unknown as FormValues[],
};

export const examConfig: ResourceConfig = {
  resource: "exams",
  label: "Exam",
  pluralLabel: "Exams",
  columns: [
    { label: "Name", render: (e) => String(e.name ?? "") },
    { label: "Category", render: (e) => String(e.category ?? "") },
    { label: "Conducted By", render: (e) => String(e.conductedBy ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "fullName", label: "Full Name", type: "text", required: true },
    {
      key: "category",
      label: "Category",
      type: "select",
      required: true,
      staticOptions: [
        "After 10th",
        "After 12th",
        "Undergraduate Entrance",
        "Government",
        "Banking",
        "Defence",
        "Postgraduate Entrance",
        "Professional",
      ].map((v) => ({ value: v, label: v })),
    },
    {
      key: "categorySlug",
      label: "Field",
      type: "select",
      optionsKey: "categories",
      helpText: "Which FIELD the exam belongs to, from the shared category taxonomy. Different from Category above, which records the STAGE (\"After 12th\"). Leave blank only for an exam that genuinely spans every field -- CUET and NTSE are the two.",
    },
    {
      key: "level",
      label: "Exam Level",
      type: "select",
      required: true,
      helpText: "What the exam GETS you -- not what you need to sit it. CAT and UPSC CSE both require a bachelor's, but one is a postgraduate entrance and the other a job exam.",
      staticOptions: [
        "School",
        "Diploma",
        "Undergraduate",
        "Postgraduate",
        "Research",
        "Certification",
        "Recruitment",
      ].map((v) => ({ value: v, label: v })),
    },
    { key: "conductedBy", label: "Conducted By", type: "text", required: true },
    { key: "frequency", label: "Frequency", type: "text", required: true, helpText: "The human wording, e.g. \"Once a year (state-wise)\". Shown on the exam page; the filterable bucket is below." },
    {
      key: "frequencyType",
      label: "Frequency (bucket)",
      type: "select",
      required: true,
      helpText: "The normalised form the listing filters on. Four spellings of \"annually\" cannot be a facet, which is why this exists alongside the prose above.",
      staticOptions: ["Annual", "Biannual", "Quarterly", "Monthly", "Rolling", "As notified"].map(
        (v) => ({ value: v, label: v })
      ),
    },
    { key: "description", label: "Description", type: "textarea", required: true },
    { key: "relatedCareerSlugs", label: "Related Careers", type: "multiselect", optionsKey: "careers" },
    { key: "icon", label: "Icon", type: "select", required: true, staticOptions: ICON_OPTIONS },
    {
      key: "mode",
      label: "Mode",
      type: "select",
      staticOptions: ["Online", "Offline", "Hybrid"].map((v) => ({ value: v, label: v })),
    },
    { key: "eligibilityMinQualification", label: "Minimum Eligibility", type: "text", helpText: "A short degree/qualification name only, e.g. \"Bachelor's Degree\" or \"12th Pass\" -- not a full sentence, this renders as a single info-panel value on the exam page" },
    { key: "officialWebsite", label: "Official Website", type: "text" },
    { key: "syllabusOverview", label: "Syllabus Overview", type: "textarea" },
    {
      key: "careerDegreeOfferings",
      label: "Career Offerings (Degree per Career)",
      type: "pairs",
      helpText: "Which specific degree this exam is the entry gate into a career through, e.g. JEE Main → Computer Science & Engineering → B.Tech",
      pairConfig: {
        keys: ["careerSlug", "degreeSlug"],
        optionsKeys: ["careers", "degrees"],
        labels: ["Career", "Degree"],
      },
    },
    {
      key: "examType",
      label: "Exam Type",
      type: "select",
      required: true,
      helpText: "Orthogonal to Category (which answers \"who's it for\") -- this answers \"what do you actually get for passing\"",
      staticOptions: ["Admission", "Recruitment", "Eligibility"].map((v) => ({ value: v, label: v })),
    },
    {
      key: "jobRoleSlugs",
      label: "Job Roles",
      type: "multiselect",
      optionsKey: "jobRoles",
      helpText: "Only for Recruitment-type exams -- which job role(s) this exam directly hires/commissions you into",
    },
  ],
  loadReferenceOptions: async () => {
    const [careers, degrees, jobRoles, categories] = await Promise.all([
      getCareers(),
      getDegrees(),
      getJobRoles(),
      getCategories(),
    ]);
    return {
      careers: toSlugOptions(careers, (c) => c.title),
      degrees: toSlugOptions(degrees, (d) => d.title),
      jobRoles: toSlugOptions(jobRoles, (j) => j.name),
      categories: toSlugOptions(categories, (c) => c.name),
    };
  },
  loadAll: async () => (await getExams()) as unknown as FormValues[],
};

export const collegeConfig: ResourceConfig = {
  resource: "colleges",
  label: "College",
  pluralLabel: "Colleges",
  columns: [
    { label: "Name", render: (c) => String(c.name ?? "") },
    { label: "Location", render: (c) => String(c.location ?? "") },
    { label: "Type", render: (c) => String(c.type ?? "") },
    { label: "State", render: (c) => String(c.stateSlug ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "location", label: "Location", type: "text", required: true, helpText: "Free-text display location, e.g. \"Chennai, Tamil Nadu\" -- kept alongside the structured State/City below" },
    {
      key: "type",
      label: "College Type",
      type: "select",
      required: true,
      staticOptions: ["IIT", "NIT", "Medical", "Law", "Management", "Polytechnic", "University", "ITI"].map((v) => ({ value: v, label: v })),
    },
    {
      key: "ownershipType",
      label: "Ownership",
      type: "select",
      required: true,
      staticOptions: ["Government", "Private", "Government-Aided"].map((v) => ({ value: v, label: v })),
    },
    { key: "stateSlug", label: "State", type: "select", required: true, optionsKey: "states" },
    { key: "citySlug", label: "City", type: "select", optionsKey: "cities", helpText: "Optional -- only cities already in the catalog. Add a new one under Cities first if needed." },
    { key: "universitySlug", label: "Affiliated University", type: "select", optionsKey: "universities", helpText: "Leave unset for an autonomous institute or a college that is itself a university" },
    {
      key: "nirfRank",
      label: "NIRF Rank",
      type: "number",
      helpText: "Supply Rank, Table and Year together or leave all three blank -- the database rejects a rank with no table, because NIRF publishes a dozen league tables a year and \"#2\" is ambiguous without saying which one.",
    },
    {
      key: "nirfCategory",
      label: "NIRF Table",
      type: "select",
      staticOptions: [
        "Overall",
        "Engineering",
        "Medical",
        "Management",
        "Law",
        "University",
        "Pharmacy",
        "Architecture",
        "Dental",
        "Research",
      ].map((v) => ({ value: v, label: v })),
    },
    { key: "nirfYear", label: "NIRF Year", type: "number", helpText: "e.g. 2024" },
    { key: "website", label: "Official Website", type: "text" },
    {
      key: "status",
      label: "Status",
      type: "select",
      required: true,
      staticOptions: ["Active", "Inactive"].map((v) => ({ value: v, label: v })),
    },
    { key: "established", label: "Established (year)", type: "number", required: true },
    { key: "tags", label: "Tags", type: "tags", helpText: "Comma-separated" },
    { key: "description", label: "Description", type: "textarea", required: true },
    {
      key: "degreeOfferings",
      label: "Degrees Offered (Degree + Subject)",
      type: "pairs",
      helpText: "Leave Subject blank when the college simply awards the qualification; set it to record the branch, e.g. PhD + Engineering.",
      pairConfig: {
        keys: ["degreeSlug", "subjectSlug"],
        optionsKeys: ["degrees", "subjects"],
        labels: ["Degree", "Subject"],
        optionalB: true,
        bAppliesToA: "degreesTakingSubject",
      },
    },
    { key: "specializationSlugs", label: "Specializations", type: "multiselect", optionsKey: "specializations" },
    { key: "examSlugs", label: "Accepted Exams", type: "multiselect", optionsKey: "exams" },
    {
      key: "careerOfferings",
      label: "Career Offerings (Degree per Career)",
      type: "pairs",
      helpText: "Which specific degree this college awards each career/discipline through -- independent of Degrees Offered and Disciplines above (see CollegeUpsertRequest's javadoc)",
      pairConfig: {
        keys: ["careerSlug", "degreeSlug"],
        optionsKeys: ["careers", "degrees"],
        labels: ["Career", "Degree"],
      },
    },
  ],
  loadReferenceOptions: async () => {
    const [exams, states, cities, universities, degrees, specializations, careers, subjects] = await Promise.all([
      getExams(),
      getStates(),
      getCities(),
      getUniversities(),
      getDegrees(),
      getSpecializations(),
      getCareers(),
      getSubjects(),
    ]);
    return {
      exams: toSlugOptions(exams, (e) => e.name),
      states: toSlugOptions(states, (s) => s.name),
      cities: toSlugOptions(cities, (c) => c.name),
      universities: toSlugOptions(universities, (u) => u.name),
      degrees: toSlugOptions(degrees, (d) => d.title),
      subjects: toSlugOptions(subjects, (s) => s.title),
      // Degrees a subject can apply to at all (V88's requiresSubject). Used
      // only to enable/disable the Subject picker -- it is a UI hint, not a
      // constraint: subject stays optional even for these.
      degreesTakingSubject: toSlugOptions(degrees.filter((d) => d.requiresSubject), (d) => d.title),
      specializations: toSlugOptions(specializations, (s) => s.name),
      careers: toSlugOptions(careers, (c) => c.title),
    };
  },
  loadAll: async () => (await getColleges()) as unknown as FormValues[],
};

// Added in V53 (College MVP). Note: disciplineSlugs (Career<->College) is
// deliberately NOT a field here -- it's edited from the Career admin
// form's "Related Colleges" field, same underlying relation, see
// CollegeDto's backend javadoc.
export const stateConfig: ResourceConfig = {
  resource: "states",
  label: "State",
  pluralLabel: "States",
  columns: [
    { label: "Name", render: (s) => String(s.name ?? "") },
    { label: "Code", render: (s) => String(s.code ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "code", label: "Code", type: "text", required: true, helpText: "e.g. MH, DL, TN" },
  ],
  loadReferenceOptions: async () => ({}),
  loadAll: async () => (await getStates()) as unknown as FormValues[],
};

export const cityConfig: ResourceConfig = {
  resource: "cities",
  label: "City",
  pluralLabel: "Cities",
  columns: [
    { label: "Name", render: (c) => String(c.name ?? "") },
    { label: "State", render: (c) => String(c.stateSlug ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "stateSlug", label: "State", type: "select", required: true, optionsKey: "states" },
  ],
  loadReferenceOptions: async () => {
    const [states] = await Promise.all([getStates()]);
    return {
      states: toSlugOptions(states, (s) => s.name),
    };
  },
  loadAll: async () => (await getCities()) as unknown as FormValues[],
};

export const universityConfig: ResourceConfig = {
  resource: "universities",
  label: "University",
  pluralLabel: "Universities",
  columns: [
    { label: "Name", render: (u) => String(u.name ?? "") },
    { label: "Type", render: (u) => String(u.universityType ?? "") },
    { label: "State", render: (u) => String(u.stateSlug ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    {
      key: "universityType",
      label: "University Type",
      type: "select",
      required: true,
      staticOptions: ["Central", "State", "Deemed", "Private"].map((v) => ({ value: v, label: v })),
    },
    {
      key: "ownershipType",
      label: "Ownership",
      type: "select",
      required: true,
      staticOptions: ["Government", "Private", "Government-Aided"].map((v) => ({ value: v, label: v })),
    },
    { key: "stateSlug", label: "State", type: "select", optionsKey: "states" },
    { key: "citySlug", label: "City", type: "select", optionsKey: "cities" },
    { key: "website", label: "Official Website", type: "text" },
    {
      key: "status",
      label: "Status",
      type: "select",
      required: true,
      staticOptions: ["Active", "Inactive"].map((v) => ({ value: v, label: v })),
    },
  ],
  loadReferenceOptions: async () => {
    const [states, cities] = await Promise.all([getStates(), getCities()]);
    return {
      states: toSlugOptions(states, (s) => s.name),
      cities: toSlugOptions(cities, (c) => c.name),
    };
  },
  loadAll: async () => (await getUniversities()) as unknown as FormValues[],
};

export const skillConfig: ResourceConfig = {
  resource: "skills",
  label: "Skill",
  pluralLabel: "Skills",
  columns: [
    { label: "Name", render: (s) => String(s.name ?? "") },
    { label: "Category", render: (s) => String(s.category ?? "") },
    { label: "Skill Type", render: (s) => String(s.skillType ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    {
      key: "category",
      label: "Category",
      type: "select",
      required: true,
      helpText: "The filterable classification the Skills listing groups by. Distinct from Skill Type below, which is free text an editor typed and is blank for most of the catalog. Anything that is field knowledge rather than a generic competency belongs in Domain.",
      staticOptions: ["Programming", "Tools", "Analytical", "Soft", "Domain"].map((v) => ({
        value: v,
        label: v,
      })),
    },
    { key: "description", label: "Description", type: "textarea", helpText: "Optional. Blank for every skill today; the listing card falls back to showing the category." },
    {
      key: "skillType",
      label: "Skill Type (legacy)",
      type: "select",
      helpText: "Optional -- many existing skills are uncategorized",
      staticOptions: ["Programming Language", "Technical", "Cloud", "Tool", "Domain Skill", "Soft Skill"].map((v) => ({ value: v, label: v })),
    },
  ],
  loadReferenceOptions: async () => ({}),
  loadAll: async () => (await getSkills()) as unknown as FormValues[],
};

export const industryConfig: ResourceConfig = {
  resource: "industries",
  label: "Industry",
  pluralLabel: "Industries",
  columns: [
    { label: "Name", render: (i) => String(i.name ?? "") },
    { label: "Sector", render: (i) => (i.isSector ? "Yes" : "No") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    {
      key: "isSector",
      label: "Sector",
      type: "boolean",
      helpText: "On for a broad industry sector (e.g. Healthcare); off for a specific known employer (e.g. Apollo Hospitals)",
    },
  ],
  loadReferenceOptions: async () => ({}),
  loadAll: async () => (await getIndustries()) as unknown as FormValues[],
};

export const jobRoleConfig: ResourceConfig = {
  resource: "job-roles",
  label: "Job Role",
  pluralLabel: "Job Roles",
  columns: [
    { label: "Name", render: (j) => String(j.name ?? "") },
    { label: "Experience Level", render: (j) => String(j.experienceLevel ?? "") },
    { label: "Careers", render: (j) => String(Array.isArray(j.careerSlugs) ? j.careerSlugs.length : 0) },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "description", label: "Description", type: "textarea" },
    { key: "experienceLevel", label: "Experience Level", type: "text", helpText: "e.g. Entry-level, Mid-level, Senior" },
    { key: "salaryMin", label: "Salary Min", type: "text", helpText: "e.g. 6 LPA" },
    { key: "salaryMax", label: "Salary Max", type: "text", helpText: "e.g. 12 LPA" },
    { key: "careerSlugs", label: "Careers", type: "multiselect", optionsKey: "careers" },
    { key: "relatedSkillSlugs", label: "Related Skills", type: "multiselect", optionsKey: "skills" },
    { key: "relatedIndustrySlugs", label: "Industries", type: "multiselect", optionsKey: "industries" },
    {
      key: "relatedCertificationSlugs",
      label: "Certifications",
      type: "multiselect",
      optionsKey: "certifications",
      helpText: "Optional -- some job roles are entered via a certification, some via an exam (set from that exam's own admin form), some both, some neither",
    },
  ],
  loadReferenceOptions: async () => {
    const [careers, skills, industries, certifications] = await Promise.all([
      getCareers(),
      getSkills(),
      getIndustries(),
      getCertifications(),
    ]);
    return {
      careers: toSlugOptions(careers, (c) => c.title),
      skills: toSlugOptions(skills, (s) => s.name),
      industries: toSlugOptions(industries, (i) => i.name),
      certifications: toSlugOptions(certifications, (c) => c.name),
    };
  },
  loadAll: async () => (await getJobRoles()) as unknown as FormValues[],
};

export const certificationConfig: ResourceConfig = {
  resource: "certifications",
  label: "Certification",
  pluralLabel: "Certifications",
  columns: [
    { label: "Name", render: (c) => String(c.name ?? "") },
    { label: "Provider", render: (c) => String(c.provider ?? "") },
    { label: "Level", render: (c) => String(c.level ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "description", label: "Description", type: "textarea" },
    { key: "provider", label: "Provider", type: "text", helpText: "e.g. AWS, Google, Microsoft" },
    { key: "level", label: "Level", type: "text", helpText: "e.g. Associate, Professional" },
    { key: "duration", label: "Duration", type: "text", helpText: "e.g. 3-6 months" },
    { key: "officialUrl", label: "Official URL", type: "text" },
    { key: "relatedCareerSlugs", label: "Related Careers", type: "multiselect", optionsKey: "careers" },
    { key: "relatedSkillSlugs", label: "Related Skills", type: "multiselect", optionsKey: "skills" },
  ],
  loadReferenceOptions: async () => {
    const [careers, skills] = await Promise.all([getCareers(), getSkills()]);
    return {
      careers: toSlugOptions(careers, (c) => c.title),
      skills: toSlugOptions(skills, (s) => s.name),
    };
  },
  loadAll: async () => (await getCertifications()) as unknown as FormValues[],
};

// Named resourceEntityConfig (rather than resourceConfig, which would
// collide with this file's own name and the RESOURCE_CONFIGS map right
// below it) -- this is the config for the "Resource" content entity
// (articles/guides/roadmaps), not to be confused with this file.
export const resourceEntityConfig: ResourceConfig = {
  resource: "resources",
  label: "Resource",
  pluralLabel: "Resources",
  columns: [
    { label: "Title", render: (r) => String(r.title ?? "") },
    { label: "Type", render: (r) => String(r.resourceType ?? "") },
    { label: "Author", render: (r) => String(r.author ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "title", label: "Title", type: "text", required: true },
    { key: "resourceType", label: "Resource Type", type: "text", required: true, helpText: "e.g. Article, Guide, Roadmap, Video" },
    { key: "description", label: "Description", type: "textarea" },
    { key: "contentUrl", label: "Content URL", type: "text" },
    { key: "author", label: "Author", type: "text" },
    { key: "publishedAt", label: "Published Date", type: "date" },
    { key: "relatedCareerSlugs", label: "Related Careers", type: "multiselect", optionsKey: "careers" },
    { key: "relatedExamSlugs", label: "Related Exams", type: "multiselect", optionsKey: "exams" },
    { key: "relatedSkillSlugs", label: "Related Skills", type: "multiselect", optionsKey: "skills" },
  ],
  loadReferenceOptions: async () => {
    const [careers, exams, skills] = await Promise.all([getCareers(), getExams(), getSkills()]);
    return {
      careers: toSlugOptions(careers, (c) => c.title),
      exams: toSlugOptions(exams, (e) => e.name),
      skills: toSlugOptions(skills, (s) => s.name),
    };
  },
  loadAll: async () => (await getResources()) as unknown as FormValues[],
};

export const specializationConfig: ResourceConfig = {
  resource: "specializations",
  label: "Specialization",
  pluralLabel: "Specializations",
  columns: [
    { label: "Name", render: (s) => String(s.name ?? "") },
    { label: "Careers", render: (s) => String(((s.careerSlugs as string[] | undefined) ?? []).length) },
    { label: "Key Roles", render: (s) => String(((s.relatedJobRoleSlugs as string[] | undefined) ?? []).length) },
    { label: "Exams", render: (s) => String(((s.relatedExamSlugs as string[] | undefined) ?? []).length) },
    { label: "Demand", render: (s) => String(s.demand ?? "") },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "name", label: "Name", type: "text", required: true },
    { key: "description", label: "Description", type: "textarea", required: true, helpText: "One line -- this is what cards and search results show." },
    { key: "overview", label: "What You Will Learn", type: "textarea", helpText: "What the FIELD covers, in a paragraph or two. Different from Description (one line) and Responsibilities (what the job involves day to day)." },
    { key: "highlights", label: "Key Highlights", type: "tags", helpText: "Comma-separated short claims about the field, e.g. \"Applied across almost every industry\"." },
    { key: "icon", label: "Icon", type: "select", required: true, staticOptions: ICON_OPTIONS },
    { key: "careerSlugs", label: "Careers", type: "multiselect", optionsKey: "careers", helpText: "Which career(s) this specialization belongs under. Also drives Related Specializations on the page -- siblings are read from here rather than listed a second time." },
    {
      key: "education",
      label: "Education (Degree + Subject)",
      type: "pairs",
      helpText: "Routes into this specialization. B.Tech + Artificial Intelligence renders as \"B.Tech (Artificial Intelligence)\"; a bare B.Tech would read the same on every specialization of the career. Leave Subject blank where the qualification already names its field (MCA). Leave the whole list empty to fall back to the parent career's education on the page.",
      pairConfig: {
        keys: ["degreeSlug", "subjectSlug"],
        optionsKeys: ["degrees", "subjects"],
        labels: ["Degree", "Subject"],
        optionalB: true,
        bAppliesToA: "degreesTakingSubject",
      },
    },
    { key: "resourceSlugs", label: "Resources", type: "multiselect", optionsKey: "resources", helpText: "Reading material for this field." },
    { key: "salaryMinLpa", label: "Salary Min (LPA)", type: "number", helpText: "Lakhs per annum. Blank falls back to the parent career's range on the page, labelled as the career's -- so the career's figure is never shown as this specialization's." },
    { key: "salaryMaxLpa", label: "Salary Max (LPA)", type: "number", helpText: "Lakhs per annum. Must be at least the minimum." },
    { key: "relatedExamSlugs", label: "Related Exams", type: "multiselect", optionsKey: "exams" },
    { key: "relatedJobRoleSlugs", label: "Key Roles", type: "multiselect", optionsKey: "jobRoles", helpText: "Job roles someone in this specialization would actually hold" },
    { key: "relatedHardSkillSlugs", label: "Hard Skills", type: "multiselect", optionsKey: "skills" },
    { key: "relatedSoftSkillSlugs", label: "Soft Skills", type: "multiselect", optionsKey: "skills" },
    { key: "responsibilities", label: "Responsibilities", type: "tags", helpText: "Comma-separated -- what someone in this specialization actually does day to day" },
    { key: "certificationSlugs", label: "Certifications", type: "multiselect", optionsKey: "certifications" },
    // `industries` mixes sectors with employers (is_sector splits them: 10 vs
    // 303). Both are legitimate here -- "Healthcare" is where the field is
    // applied, "GE Healthcare" is who hires for it -- so the label names both
    // rather than the old "Recruiters", which described only half the table.
    { key: "industrySlugs", label: "Industries & Recruiters", type: "multiselect", optionsKey: "industries", helpText: "Sectors this field is applied in, and/or companies that hire for it." },
    {
      key: "demand",
      label: "Demand",
      type: "select",
      staticOptions: ["HIGH", "MEDIUM", "LOW"].map((v) => ({ value: v, label: v })),
    },
  ],
  loadReferenceOptions: async () => {
    const [careers, exams, jobRoles, skills, certifications, industries, degrees, subjects, resources] =
      await Promise.all([
        getCareers(),
        getExams(),
        getJobRoles(),
        getSkills(),
        getCertifications(),
        getIndustries(),
        getDegrees(),
        getSubjects(),
        getResources(),
      ]);
    return {
      careers: toSlugOptions(careers, (c) => c.title),
      exams: toSlugOptions(exams, (e) => e.name),
      jobRoles: toSlugOptions(jobRoles, (r) => r.name),
      skills: toSlugOptions(skills, (s) => s.name),
      certifications: toSlugOptions(certifications, (c) => c.name),
      industries: toSlugOptions(industries, (i) => i.name),
      degrees: toSlugOptions(degrees, (d) => d.title),
      subjects: toSlugOptions(subjects, (s) => s.title),
      resources: toSlugOptions(resources, (r) => r.title),
      // Same UI hint as the Career form: which degrees a subject can apply to
      // at all (V88's requiresSubject). Not a constraint -- subject stays
      // optional even for these.
      degreesTakingSubject: toSlugOptions(degrees.filter((d) => d.requiresSubject), (d) => d.title),
    };
  },
  loadAll: async () => (await getSpecializations()) as unknown as FormValues[],
};

export const degreeConfig: ResourceConfig = {
  resource: "degrees",
  label: "Degree",
  pluralLabel: "Degrees",
  columns: [
    { label: "Title", render: (d) => String(d.title ?? "") },
    { label: "Entrance Exams", render: (d) => String(((d.entranceExamSlugs as string[] | undefined) ?? []).length) },
    { label: "Skills", render: (d) => String(((d.skillSlugs as string[] | undefined) ?? []).length) },
  ],
  fields: [
    { key: "slug", label: "Slug", type: "text", required: true, helpText: "Lowercase letters, numbers and hyphens only. Can't be changed after creation." },
    { key: "title", label: "Title", type: "text", required: true, helpText: "The abbreviation as it is written, e.g. B.Tech." },
    { key: "fullTitle", label: "Full Title", type: "text", helpText: "What the abbreviation stands for, e.g. Bachelor of Technology. Leave blank where the title already IS the full name (Diploma, Certificate) -- storing it twice only creates something to drift." },
    { key: "description", label: "Description", type: "textarea", required: true },
    { key: "icon", label: "Icon", type: "select", required: true, staticOptions: ICON_OPTIONS },
    { key: "durationMinYears", label: "Duration Min (years)", type: "number", helpText: "Set both bounds to the same number for a fixed-length programme (4 = \"4 years\"), and to different ones where it genuinely varies (PhD 3-5). Half-years are allowed: MBBS is 5.5. Leave BOTH blank only for a qualification that is not a taught programme, such as a higher doctorate awarded on published work." },
    { key: "durationMaxYears", label: "Duration Max (years)", type: "number" },
    { key: "preparationStrategy", label: "Preparation Strategy", type: "textarea", helpText: "How to prepare for and get into this degree" },
    {
      key: "level",
      label: "Level",
      type: "select",
      required: true,
      staticOptions: ["Undergraduate", "Postgraduate", "Diploma", "Doctoral", "Certificate"].map((v) => ({ value: v, label: v })),
    },
    {
      key: "categorySlug",
      label: "Category",
      type: "select",
      optionsKey: "categories",
      helpText: "Optional -- leave unset for generic degrees with no single subject (Certificate, Diploma, PhD)",
    },
    { key: "entranceExamSlugs", label: "Entrance Exams", type: "multiselect", optionsKey: "exams" },
    { key: "skillSlugs", label: "Skills", type: "multiselect", optionsKey: "skills" },
    { key: "resourceSlugs", label: "Resources", type: "multiselect", optionsKey: "resources" },
  ],
  loadReferenceOptions: async () => {
    const [exams, skills, resources, categories] = await Promise.all([getExams(), getSkills(), getResources(), getCategories()]);
    return {
      exams: toSlugOptions(exams, (e) => e.name),
      skills: toSlugOptions(skills, (s) => s.name),
      resources: toSlugOptions(resources, (r) => r.title),
      categories: toSlugOptions(categories, (c) => c.name),
    };
  },
  loadAll: async () => (await getDegrees()) as unknown as FormValues[],
};

export const RESOURCE_CONFIGS: Record<AdminResource, ResourceConfig> = {
  careers: careerConfig,
  degrees: degreeConfig,
  exams: examConfig,
  colleges: collegeConfig,
  skills: skillConfig,
  "job-roles": jobRoleConfig,
  industries: industryConfig,
  certifications: certificationConfig,
  resources: resourceEntityConfig,
  specializations: specializationConfig,
  states: stateConfig,
  cities: cityConfig,
  universities: universityConfig,
};

/** Fills in "" / [] for any field missing from an entity (new records start blank) so controlled inputs never flip from uncontrolled to controlled. */
export function toFormValues(config: ResourceConfig, source?: FormValues): FormValues {
  const values: FormValues = {};
  for (const field of config.fields) {
    const raw = source?.[field.key];
    if (
      field.type === "multiselect" ||
      field.type === "tags" ||
      field.type === "pairs" ||
      field.type === "rows"
    ) {
      values[field.key] = Array.isArray(raw) ? raw : [];
    } else if (field.type === "number") {
      values[field.key] = typeof raw === "number" ? raw : undefined;
    } else if (field.type === "boolean") {
      values[field.key] = typeof raw === "boolean" ? raw : false;
    } else {
      values[field.key] = typeof raw === "string" ? raw : "";
    }
  }
  return values;
}

/** Converts form state back into the exact JSON shape the backend's Upsert DTOs expect. */
export function toPayload(config: ResourceConfig, values: FormValues): Record<string, unknown> {
  const payload: Record<string, unknown> = {};
  for (const field of config.fields) {
    const raw = values[field.key];
    if (field.type === "number") {
      payload[field.key] = raw === "" || raw === undefined ? null : Number(raw);
    } else if (field.type === "pairs") {
      // Project each row down to the two configured keys. The API sends
      // education rows with a derived `title` alongside degreeSlug/
      // subjectSlug; echoing it back would post a stale composed string as
      // though it were input. The server ignores it today, but a derived
      // value has no business travelling on a write.
      const keys = field.pairConfig?.keys;
      payload[field.key] = Array.isArray(raw)
        ? (raw as Array<Record<string, string>>).map((row) =>
            keys ? { [keys[0]]: row[keys[0]] ?? "", [keys[1]]: row[keys[1]] ?? "" } : row
          )
        : [];
    } else if (field.type === "rows") {
      // Project to the configured columns, coercing numeric ones. Same reason
      // as the pairs branch: the API sends a derived `label` alongside these
      // rows, and echoing it back would post a composed string as input.
      // A blank optional column posts null, which is what the open-ended
      // upper bound means -- "12+ yrs", "₹40L+" -- not zero.
      const columns = field.rowConfig?.columns ?? [];
      payload[field.key] = Array.isArray(raw)
        ? (raw as Array<Record<string, string>>).map((row) => {
            const out: Record<string, unknown> = {};
            for (const c of columns) {
              const v = row[c.key];
              out[c.key] =
                c.type === "number"
                  ? v === "" || v === undefined || v === null
                    ? null
                    : Number(v)
                  : (v ?? "");
            }
            return out;
          })
        : [];
    } else if (field.type === "multiselect" || field.type === "tags") {
      payload[field.key] = Array.isArray(raw) ? raw : [];
    } else if (field.type === "boolean") {
      payload[field.key] = raw === true;
    } else if (field.type === "date") {
      // A LocalDate field on the backend -- "" doesn't deserialize to a
      // null LocalDate, it fails JSON parsing outright, so an empty date
      // input has to become an actual null rather than falling through to
      // the plain-string branch below.
      payload[field.key] = raw === "" || raw === undefined ? null : raw;
    } else {
      payload[field.key] = typeof raw === "string" ? raw.trim() : raw;
    }
  }
  return payload;
}
