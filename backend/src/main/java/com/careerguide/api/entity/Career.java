package com.careerguide.api.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "careers")
public class Career {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_slug", nullable = false)
    private Category category;

    // Added in V23 -- see Branch.java and the Data Model Roadmap doc's
    // Phase 1. Nullable and independent of category: only Engineering &
    // Technology's 13 careers have one so far, every other career is null
    // until its own category gets branches.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_slug")
    private Branch branch;

    // Added in V47 as a *-to-one column, replaced in V51 with a real
    // many-to-many relation -- same shape as relatedSpecializations below.
    // V47 assumed "each Career has at most one primary degree path", but
    // its own migration comment already listed many careers with multiple
    // equally-valid degree paths; V51's comment has the full reasoning,
    // including why some disciplines still end up with an empty list here
    // (no degree in this catalog is a clean, direct match).
    // The education routes into this career, in order -- each a Degree plus
    // the Subject it is taken in. "B.A. (Psychology)" is a B.A. row and a
    // Psychology row joined here, not a degrees row of its own (V103-V105).
    //
    // Added in V47 as a *-to-one column, widened to a many-to-many in V51,
    // and promoted to a real entity in V103 so each entry can name its
    // subject. @OrderBy rather than @OrderColumn since this is a mapped
    // entity with its own primary key, same as College.careerOfferings.
    @OneToMany(mappedBy = "career", fetch = FetchType.LAZY,
               cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<CareerDegree> education = new ArrayList<>();

    @Column(nullable = false, length = 255)
    private String tagline;

    @Column(nullable = false, length = 32)
    private String demand;

    @Column(name = "typical_work", nullable = false, columnDefinition = "text")
    private String typicalWork;

    @Column(name = "salary_range", nullable = false, length = 64)
    private String salaryRange;

    // Salary as numbers, added in V107. The display string above is kept in
    // step with these for now but is derivable from them -- see
    // SalaryRange.compose. Stored in lakhs per annum (the unit the domain
    // speaks in) as NUMERIC(6,2): 9 job roles are "2.5 LPA", so an integer
    // column would lose data.
    //
    // Nullable because 8 job roles genuinely have no salary recorded; a zero
    // would read as "unpaid" rather than "unknown".
    @Column(name = "salary_min_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMinLpa;

    @Column(name = "salary_max_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMaxLpa;

    // Superseded by `growthStages` in V110, which carries an experience range
    // per rung. Kept only until nothing reads it, the same staged retirement
    // `salaryRange` is in -- see V110's header.
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "growth_path", nullable = false, columnDefinition = "text[]")
    private List<String> growthPath = new ArrayList<>();

    // V110: the progression ladder with experience attached, so it reads as a
    // timeline rather than a list of job titles. @OrderBy rather than
    // @OrderColumn since this is a mapped entity with its own primary key,
    // same as `education` above.
    @OneToMany(mappedBy = "career", fetch = FetchType.LAZY,
               cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<CareerGrowthStage> growthStages = new ArrayList<>();

    // V110: what the career pays at each experience level. Ships empty for
    // all 42 -- see CareerSalaryBand's javadoc for why it was not generated.
    @OneToMany(mappedBy = "career", fetch = FetchType.LAZY,
               cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<CareerSalaryBand> salaryBands = new ArrayList<>();
    // No setters for either: orphanRemoval=true means the list instance must
    // be mutated in place. See CareerService.syncGrowthStages/syncSalaryBands.

    // V110: short claims about the career. Empty for all 42 -- the page
    // derives them from facts it can prove and a stored value overrides that.
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(nullable = false, columnDefinition = "text[]")
    private List<String> highlights = new ArrayList<>();

    // V110: work settings -- Product Companies, Research Labs, Remote.
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "work_environments", nullable = false, columnDefinition = "text[]")
    private List<String> workEnvironments = new ArrayList<>();

    // V110: typical years in the field, and open roles. Both nullable and
    // unseeded: neither can be derived from anything in the catalog, and a
    // guessed market statistic is worse than a missing one.
    @Column(name = "experience_min_years")
    private Short experienceMinYears;

    @Column(name = "experience_max_years")
    private Short experienceMaxYears;

    @Column(name = "job_openings")
    private Integer jobOpenings;

    @Column(nullable = false, length = 32)
    private String icon;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    // Index of this career within its category in the frontend's careers.ts
    // array — lets us reproduce getRecommendedCareers()'s array-order pick
    // instead of an arbitrary DB row order.
    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    // Mirrors career.relatedExamSlugs from the frontend data model.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_exams",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Exam> relatedExams = new ArrayList<>();

    // Mirrors career.stageSlugs from the frontend data model. Note:
    // career.entranceExams from the frontend TS type is intentionally NOT
    // migrated — it is dead data never read by any page/component, and is
    // redundant with relatedExamSlugs in almost every existing record. See
    // the backend README for details.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_stages",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "stage_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Stage> stages = new ArrayList<>();

    // New in V13, and unidirectional (College has no inverse mapping back to
    // Career) -- unlike career_courses/career_exams, colleges were never
    // linked to careers at all before this, so there's no existing reverse
    // relation to keep symmetric with.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_colleges",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "college_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<College> relatedColleges = new ArrayList<>();

    // New in V16, unidirectional like relatedColleges above -- for now only
    // populated for Aerospace Engineer, see backend README.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_specializations",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "specialization_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Specialization> relatedSpecializations = new ArrayList<>();

    // Added in V24 -- see Skill.java and the Data Model Roadmap doc's Phase 2.
    //
    // Ordered as of V81, when this became the SINGLE source of truth for a
    // career's skills. The old careers.skills text[] held the same data plus
    // a curated "most central skill first" sequence (all 42 careers were in a
    // custom, non-alphabetical order), and both were independently editable,
    // so the two could diverge at any time. V81 moved that sequence into
    // sort_order here and V82 dropped the column; this list is now the only
    // place a career's skills live.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_skills",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Skill> relatedSkills = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_industries",
            joinColumns = @JoinColumn(name = "career_slug"),
            inverseJoinColumns = @JoinColumn(name = "industry_slug")
    )
    private Set<Industry> relatedIndustries = new HashSet<>();

    // Added in V26 -- see JobRole.java. Non-owning side of the
    // many-to-many; JobRole.careers (via career_job_roles) is the owner.
    // Empty for every career except software-engineer so far.
    @ManyToMany(mappedBy = "careers", fetch = FetchType.LAZY)
    private Set<JobRole> jobRoles = new HashSet<>();

    // Public rather than protected: JPA only needs a no-arg constructor
    // (Hibernate uses reflection regardless of visibility), but the admin
    // write path also calls `new Career()` directly from CareerService,
    // which is in a different package.
    public Career() {
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public Category getCategory() {
        return category;
    }

    public String getTagline() {
        return tagline;
    }

    public String getDemand() {
        return demand;
    }

    public String getTypicalWork() {
        return typicalWork;
    }

    public String getSalaryRange() {
        return salaryRange;
    }

    public BigDecimal getSalaryMinLpa() {
        return salaryMinLpa;
    }

    public BigDecimal getSalaryMaxLpa() {
        return salaryMaxLpa;
    }

    public List<String> getGrowthPath() {
        return growthPath;
    }

    public String getIcon() {
        return icon;
    }

    public String getDescription() {
        return description;
    }

    public List<College> getRelatedColleges() {
        return relatedColleges;
    }

    public List<Specialization> getRelatedSpecializations() {
        return relatedSpecializations;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public List<Exam> getRelatedExams() {
        return relatedExams;
    }

    public List<Stage> getStages() {
        return stages;
    }

    public Branch getBranch() {
        return branch;
    }

    public List<CareerDegree> getEducation() {
        return education;
    }

    public List<CareerGrowthStage> getGrowthStages() {
        return growthStages;
    }

    public List<CareerSalaryBand> getSalaryBands() {
        return salaryBands;
    }

    public List<String> getHighlights() {
        return highlights;
    }

    public List<String> getWorkEnvironments() {
        return workEnvironments;
    }

    public Short getExperienceMinYears() {
        return experienceMinYears;
    }

    public Short getExperienceMaxYears() {
        return experienceMaxYears;
    }

    public Integer getJobOpenings() {
        return jobOpenings;
    }

    public void setHighlights(List<String> highlights) {
        this.highlights = highlights;
    }

    public void setWorkEnvironments(List<String> workEnvironments) {
        this.workEnvironments = workEnvironments;
    }

    public void setExperienceMinYears(Short experienceMinYears) {
        this.experienceMinYears = experienceMinYears;
    }

    public void setExperienceMaxYears(Short experienceMaxYears) {
        this.experienceMaxYears = experienceMaxYears;
    }

    public void setJobOpenings(Integer jobOpenings) {
        this.jobOpenings = jobOpenings;
    }

    public List<Skill> getRelatedSkills() {
        return relatedSkills;
    }

    public Set<Industry> getRelatedIndustries() {
        return relatedIndustries;
    }

    public Set<JobRole> getJobRoles() {
        return jobRoles;
    }

    // --- Mutators below are only used by the admin write path (services in
    // com.careerguide.api.service, via AdminCareerController). The read path
    // never calls these -- Hibernate populates fields directly via
    // reflection (field-based access), it doesn't need these setters either.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public void setBranch(Branch branch) {
        this.branch = branch;
    }

    // No setEducation(): the collection is orphanRemoval=true, so replacing
    // the list instance detaches the managed one and Hibernate throws.
    // CareerService.syncEducation mutates it in place instead.

    public void setTagline(String tagline) {
        this.tagline = tagline;
    }

    public void setDemand(String demand) {
        this.demand = demand;
    }

    public void setTypicalWork(String typicalWork) {
        this.typicalWork = typicalWork;
    }

    public void setSalaryRange(String salaryRange) {
        this.salaryRange = salaryRange;
    }

    public void setSalaryMinLpa(BigDecimal salaryMinLpa) {
        this.salaryMinLpa = salaryMinLpa;
    }

    public void setSalaryMaxLpa(BigDecimal salaryMaxLpa) {
        this.salaryMaxLpa = salaryMaxLpa;
    }

    public void setGrowthPath(List<String> growthPath) {
        this.growthPath = growthPath;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setRelatedColleges(List<College> relatedColleges) {
        this.relatedColleges = relatedColleges;
    }

    public void setRelatedSpecializations(List<Specialization> relatedSpecializations) {
        this.relatedSpecializations = relatedSpecializations;
    }

    public void setRelatedSkills(List<Skill> relatedSkills) {
        this.relatedSkills = relatedSkills;
    }

    public void setRelatedIndustries(Set<Industry> relatedIndustries) {
        this.relatedIndustries = relatedIndustries;
    }

    public void setJobRoles(Set<JobRole> jobRoles) {
        this.jobRoles = jobRoles;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }

    public void setRelatedExams(List<Exam> relatedExams) {
        this.relatedExams = relatedExams;
    }

    public void setStages(List<Stage> stages) {
        this.stages = stages;
    }
}
