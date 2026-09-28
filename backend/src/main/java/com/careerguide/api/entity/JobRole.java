package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;
import java.time.Instant;

// Added in V26, per both uploaded specs' "Career is not the same as a Job
// Role" section -- see the Data Model Roadmap doc's "Spec v1.0 Match" /
// "ER Data Model Match" tabs. Deliberately thin: no education/growth/salary
// range of its own beyond experienceLevel/salaryMin/salaryMax -- a Job Role
// inherits the rest from its Career(s) and only adds skills/industries and
// seniority on top. Many-to-many with Career (career_job_roles), matching
// the ER doc's own cardinality rather than a simple one-career FK.
//
// This is the OWNING side of career_job_roles (see the @JoinTable below) --
// Career.jobRoles is declared `mappedBy = "careers"` on the Career side, so
// setCareers() here is all that's needed to persist the relationship; there
// is no separate reverse join table to keep in sync (unlike, say,
// Career.relatedCourses / Course.relatedCareers, which really are two
// independent join tables -- see CareerService's syncRelatedCourses).
@Entity
@Table(name = "job_roles")
public class JobRole {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "experience_level", length = 32)
    private String experienceLevel;

    @Column(name = "salary_min", length = 64)
    private String salaryMin;

    @Column(name = "salary_max", length = 64)
    private String salaryMax;

    // Salary as numbers, added in V107. The text columns above hold "4 LPA"
    // style strings, which cannot be filtered, sorted or compared against
    // Career's "₹4L" spelling of the same figure. Lakhs per annum,
    // NUMERIC(6,2) -- 9 roles are "2.5 LPA", so an integer would lose data.
    // Nullable: 8 roles have no salary recorded at all.
    @Column(name = "salary_min_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMinLpa;

    @Column(name = "salary_max_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMaxLpa;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "career_job_roles",
            joinColumns = @JoinColumn(name = "job_role_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    private Set<Career> careers = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "job_role_skills",
            joinColumns = @JoinColumn(name = "job_role_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    private Set<Skill> relatedSkills = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "job_role_industries",
            joinColumns = @JoinColumn(name = "job_role_slug"),
            inverseJoinColumns = @JoinColumn(name = "industry_slug")
    )
    private Set<Industry> relatedIndustries = new HashSet<>();

    // Added in V68 -- the inverse of Exam.relatedJobRoles (same
    // exam_job_roles table), mirroring this project's "store every
    // relationship in both directions" convention (see
    // College.disciplines / Exam.relatedColleges for the same pattern).
    @ManyToMany(mappedBy = "relatedJobRoles", fetch = FetchType.LAZY)
    private Set<Exam> relatedExams = new HashSet<>();

    // Added in V72 -- the certification-side counterpart to relatedExams:
    // some job roles are entered via a certification instead of (or as
    // well as) an exam. Owned outright by JobRole, no inverse on
    // Certification -- same unidirectional shape as relatedSkills/
    // relatedIndustries above, not the bidirectional relatedExams shape.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "job_role_certifications",
            joinColumns = @JoinColumn(name = "job_role_slug"),
            inverseJoinColumns = @JoinColumn(name = "certification_slug")
    )
    private Set<Certification> relatedCertifications = new HashSet<>();

    // Public rather than protected -- same reasoning as Skill/Career/
    // Industry's public no-arg constructors: the admin write path calls
    // `new JobRole()` directly from JobRoleService, a different package.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public JobRole() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getExperienceLevel() {
        return experienceLevel;
    }

    public BigDecimal getSalaryMinLpa() {
        return salaryMinLpa;
    }

    public BigDecimal getSalaryMaxLpa() {
        return salaryMaxLpa;
    }

    public String getSalaryMin() {
        return salaryMin;
    }

    public String getSalaryMax() {
        return salaryMax;
    }

    public Set<Career> getCareers() {
        return careers;
    }

    public Set<Skill> getRelatedSkills() {
        return relatedSkills;
    }

    public Set<Industry> getRelatedIndustries() {
        return relatedIndustries;
    }

    public Set<Exam> getRelatedExams() {
        return relatedExams;
    }

    public Set<Certification> getRelatedCertifications() {
        return relatedCertifications;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setExperienceLevel(String experienceLevel) {
        this.experienceLevel = experienceLevel;
    }

    public void setSalaryMinLpa(BigDecimal salaryMinLpa) {
        this.salaryMinLpa = salaryMinLpa;
    }

    public void setSalaryMaxLpa(BigDecimal salaryMaxLpa) {
        this.salaryMaxLpa = salaryMaxLpa;
    }

    public void setSalaryMin(String salaryMin) {
        this.salaryMin = salaryMin;
    }

    public void setSalaryMax(String salaryMax) {
        this.salaryMax = salaryMax;
    }

    public void setCareers(Set<Career> careers) {
        this.careers = careers;
    }

    public void setRelatedSkills(Set<Skill> relatedSkills) {
        this.relatedSkills = relatedSkills;
    }

    public void setRelatedIndustries(Set<Industry> relatedIndustries) {
        this.relatedIndustries = relatedIndustries;
    }

    public void setRelatedCertifications(Set<Certification> relatedCertifications) {
        this.relatedCertifications = relatedCertifications;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
