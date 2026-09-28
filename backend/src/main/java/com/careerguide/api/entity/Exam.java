package com.careerguide.api.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.time.Instant;

@Entity
@Table(name = "exams")
public class Exam {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(name = "full_name", nullable = false, length = 255)
    private String fullName;

    @Column(nullable = false, length = 64)
    private String category;

    @Column(name = "conducted_by", nullable = false, length = 255)
    private String conductedBy;

    @Column(nullable = false, length = 128)
    private String frequency;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(nullable = false, length = 32)
    private String icon;

    // Added in V66 -- MVP set of static reference fields, all nullable
    // (not backfilled for the existing 30-exam catalog; see that
    // migration's comment).
    @Column(length = 32)
    private String mode;

    @Column(name = "eligibility_min_qualification", columnDefinition = "text")
    private String eligibilityMinQualification;

    @Column(name = "official_website", length = 255)
    private String officialWebsite;

    @Column(name = "syllabus_overview", columnDefinition = "text")
    private String syllabusOverview;

    // Added in V68 -- orthogonal to `category` (which answers "who's it
    // for / what stage"): this answers "what do you actually get for
    // passing" -- Admission, Recruitment or Eligibility. See that
    // migration's comment for the full taxonomy and why it's a plain,
    // always-explicit column rather than derived from category.
    // V112: the FIELD the exam belongs to, as a real FK into the shared
    // `categories` taxonomy. Distinct from `category` above, which is free
    // text holding the STAGE axis ("After 12th", "Postgraduate Entrance") --
    // the two were conflated in one column and neither could be filtered on.
    //
    // Null for CUET and NTSE, which genuinely span every field.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_slug")
    private Category fieldCategory;

    // V112: what the exam gets you -- Undergraduate, Postgraduate, Research,
    // Certification, Recruitment, Diploma, School. Not derivable from
    // `examType` (which says what the exam IS) or from the eligibility text
    // (which says what you need BEFORE it): "Bachelor's Degree" covers both
    // CAT and UPSC CSE.
    @Column(nullable = false, length = 24)
    private String level;

    // V112: `frequency` normalised to a filterable bucket. The prose column
    // stays, because "Once a year (state-wise)" says something the bucket
    // cannot -- but four spellings of "annually" cannot be a facet.
    @Column(name = "frequency_type", nullable = false, length = 24)
    private String frequencyType;

    @Column(name = "exam_type", nullable = false, length = 32)
    private String examType;

    // Added in V68 -- the Recruitment-side counterpart to
    // careerDegreeOfferings (which is Admission-side): which JobRole this
    // exam gets you hired/commissioned into. Plain unordered Set, matching
    // JobRole's own other relations (careers/relatedSkills/
    // relatedIndustries) -- an exam realistically has 1-2 job-role
    // outcomes, so there's no ordering to preserve the way
    // Exam.relatedCareers has.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "exam_job_roles",
            joinColumns = @JoinColumn(name = "exam_slug"),
            inverseJoinColumns = @JoinColumn(name = "job_role_slug")
    )
    private Set<JobRole> relatedJobRoles = new HashSet<>();

    // Added in V66 -- which degree an exam is the entry gate into a career
    // through. Admin-editable via ExamService.syncCareerDegreeOfferings --
    // cascade+orphanRemoval so adding/removing entries in this list
    // persists/deletes the corresponding ExamCareerDegree row. @OrderBy
    // rather than @OrderColumn since this is a real mapped entity with its
    // own primary key, not a plain @ManyToMany join-table collection --
    // same reasoning as College.careerOfferings.
    @OneToMany(mappedBy = "exam", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<ExamCareerDegree> careerDegreeOfferings = new ArrayList<>();

    // Mirrors exam.careerSlugs from the frontend data model.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "exam_careers",
            joinColumns = @JoinColumn(name = "exam_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Career> relatedCareers = new ArrayList<>();

    // Inverse side of College.exams (college_exams) as of V78. This owned a
    // second table, exam_colleges, holding the same relationship reversed --
    // and nothing ever maintained it: CollegeService writes college_exams
    // only, ExamUpsertRequest has no collegeSlugs field, so no write path
    // touched it after V38 seeded 20 rows. By V75 it had fallen 72 rows
    // behind. Reading one table from both sides removes the failure mode
    // instead of repairing it repeatedly.
    //
    // Ordered by college name: an inverse side cannot own the join table's
    // order column, and alphabetical is deterministic without a second
    // sequence to keep dense (see V58 for what a broken @OrderColumn costs).
    @ManyToMany(mappedBy = "exams", fetch = FetchType.LAZY)
    @OrderBy("name ASC")
    private List<College> relatedColleges = new ArrayList<>();

    // Public rather than protected -- see the equivalent note in Career.java.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public Exam() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getFullName() {
        return fullName;
    }

    public String getCategory() {
        return category;
    }

    public String getConductedBy() {
        return conductedBy;
    }

    public String getFrequency() {
        return frequency;
    }

    public String getDescription() {
        return description;
    }

    public String getIcon() {
        return icon;
    }

    public String getMode() {
        return mode;
    }

    public String getEligibilityMinQualification() {
        return eligibilityMinQualification;
    }

    public String getOfficialWebsite() {
        return officialWebsite;
    }

    public String getSyllabusOverview() {
        return syllabusOverview;
    }

    public Category getFieldCategory() {
        return fieldCategory;
    }

    public String getLevel() {
        return level;
    }

    public String getFrequencyType() {
        return frequencyType;
    }

    public void setFieldCategory(Category fieldCategory) {
        this.fieldCategory = fieldCategory;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public void setFrequencyType(String frequencyType) {
        this.frequencyType = frequencyType;
    }

    public String getExamType() {
        return examType;
    }

    public Set<JobRole> getRelatedJobRoles() {
        return relatedJobRoles;
    }

    public List<ExamCareerDegree> getCareerDegreeOfferings() {
        return careerDegreeOfferings;
    }

    public List<Career> getRelatedCareers() {
        return relatedCareers;
    }

    public List<College> getRelatedColleges() {
        return relatedColleges;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setConductedBy(String conductedBy) {
        this.conductedBy = conductedBy;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }

    public void setEligibilityMinQualification(String eligibilityMinQualification) {
        this.eligibilityMinQualification = eligibilityMinQualification;
    }

    public void setOfficialWebsite(String officialWebsite) {
        this.officialWebsite = officialWebsite;
    }

    public void setSyllabusOverview(String syllabusOverview) {
        this.syllabusOverview = syllabusOverview;
    }

    public void setExamType(String examType) {
        this.examType = examType;
    }

    public void setRelatedJobRoles(Set<JobRole> relatedJobRoles) {
        this.relatedJobRoles = relatedJobRoles;
    }

    public void setRelatedCareers(List<Career> relatedCareers) {
        this.relatedCareers = relatedCareers;
    }

    public void setRelatedColleges(List<College> relatedColleges) {
        this.relatedColleges = relatedColleges;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
