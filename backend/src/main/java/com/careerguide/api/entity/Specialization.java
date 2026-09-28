package com.careerguide.api.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.ArrayList;
import java.util.List;

/**
 * A sub-discipline within a career (e.g. Propulsion within Aerospace
 * Engineering, added in V16). Admin create/update/delete wiring covers the
 * core fields plus its Course/Exam/Career relations (see
 * AdminSpecializationController), plus the "career path" fields added in
 * V40 (relatedJobRoles/relatedHardSkills/relatedSoftSkills/responsibilities/
 * salary by level) so a specialization can describe an actual career path
 * the way the uploaded "Mechanical Engineering Career Paths" reference image
 * does: roles you'd hold, what you'd actually do, the skills it takes, and
 * what it pays at each stage.
 */
@Entity
@Table(name = "specializations")
public class Specialization {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(nullable = false, length = 32)
    private String icon;

    // V108: what the FIELD covers, as opposed to `description` (one line, for
    // cards and search) and `responsibilities` (what a person in the role does
    // day to day). Nullable -- most of the 263 rows do not have one yet, and
    // an empty string would not be distinguishable from a real blank.
    @Column(columnDefinition = "text")
    private String overview;

    // V108: short claims about the field ("Applied across almost every
    // industry"). Same plain-text storage as `responsibilities` above: there
    // is nothing in the catalog for a highlight to link to.
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(nullable = false, columnDefinition = "text[]")
    private List<String> highlights = new ArrayList<>();

    // V108: the education routes into this specialization -- each a Degree
    // plus the Subject it is taken in. Same shape as Career.education, and
    // for the same reason: `degrees` holds qualification types only, so the
    // subject has to live on the row that selects it. @OrderBy rather than
    // @OrderColumn since this is a mapped entity with its own primary key.
    @OneToMany(mappedBy = "specialization", fetch = FetchType.LAZY,
               cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<SpecializationDegree> education = new ArrayList<>();
    // No setEducation(): orphanRemoval=true means the list instance must be
    // mutated in place, never replaced. See SpecializationService.syncEducation.

    // Mirrors specialization.relatedExamSlugs from the frontend data model.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_exams",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Exam> relatedExams = new ArrayList<>();

    // Read-only reverse of Career.relatedSpecializations -- career_specializations
    // is owned entirely by Career (see that field's javadoc), so this side
    // carries no @JoinTable and JPA ignores writes to it directly. A
    // specialization's career links are changed by SpecializationService
    // updating the owning Career entities instead (see syncCareerLinks).
    @ManyToMany(mappedBy = "relatedSpecializations", fetch = FetchType.LAZY)
    private List<Career> careers = new ArrayList<>();

    // --- V40: "career path" fields, modeled on the reference image's per-path
    // Key Roles / Responsibilities / Hard Skills / Soft Skills / Salary blocks.

    // The job roles this specialization's holders would actually work as
    // (e.g. Mechanical Design Engineer, Product Development Engineer within
    // Product Design & Development). Owned entirely by Specialization, same
    // ownership shape as relatedCourses/relatedExams above -- nothing needs
    // to read this back from JobRole, so no mappedBy field there.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_job_roles",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "job_role_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<JobRole> relatedJobRoles = new ArrayList<>();

    // Split into two separate join tables (hard vs soft) rather than one
    // table filtered by Skill.skillType, since skillType is sparsely
    // backfilled (null for most existing skills) and the reference image
    // draws a firm line between the two -- letting admin assign a skill to
    // Hard or Soft explicitly is simpler and more reliable than relying on
    // skillType being set correctly on every skill involved.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_hard_skills",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Skill> relatedHardSkills = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_soft_skills",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Skill> relatedSoftSkills = new ArrayList<>();

    // Plain text list, same storage pattern as Career.skills/growthPath/
    // topRecruiters -- there's nothing in the catalog for a "responsibility"
    // to link to, it's just descriptive text.
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(nullable = false, columnDefinition = "text[]")
    private List<String> responsibilities = new ArrayList<>();

    // Salary, reinstated in V110 -- as two numbers, not the three per-level
    // VARCHARs V107 dropped. Those existed from V13, never held a value across
    // 263 rows, and had no reader; these have one (the specialization page's
    // hero) and are numbers for the reasons V107 set out.
    //
    // Nullable and unseeded: a specialization pays differently from its parent
    // career -- that is the point of recording it separately -- but nobody has
    // researched the figures, so the page falls back to the parent career's
    // range under a label that says whose range it is.
    @Column(name = "salary_min_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMinLpa;

    @Column(name = "salary_max_lpa", precision = 6, scale = 2)
    private BigDecimal salaryMaxLpa;

    // Added alongside the certifications/industries relations below --
    // plain string (HIGH/MEDIUM/LOW), same "keep it simple" shape used by
    // the CSE Specialization Model doc rather than a real enum table.
    @Column(length = 16)
    private String demand;

    // Owned entirely by Specialization, same shape as relatedJobRoles/
    // relatedHardSkills above -- nothing needs to read this back from
    // Certification, so no mappedBy field there.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_certifications",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "certification_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Certification> relatedCertifications = new ArrayList<>();

    // "Recruiters": which companies commonly hire for this specialization.
    // Reuses the Industry entity, the same way Career.relatedIndustries
    // models a career's own "Top Recruiters" -- rather than a new,
    // duplicate plain-text company list or a dedicated recruiter entity.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_industries",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "industry_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Industry> relatedIndustries = new ArrayList<>();

    // V108: reading material for this field. Owned entirely by Specialization,
    // same shape as relatedJobRoles above -- Resource is already a shared
    // entity, so this only records which specializations it is relevant to.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "specialization_resources",
            joinColumns = @JoinColumn(name = "specialization_slug"),
            inverseJoinColumns = @JoinColumn(name = "resource_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Resource> relatedResources = new ArrayList<>();

    // Read-only reverse of College.specializations -- college_specializations
    // is owned by College, exactly as career_specializations is owned by
    // Career (see the `careers` field above). Exposed here in V108 so the
    // specialization page can answer "who teaches this" without the client
    // fetching all 90 colleges to find out; writes still go through College.
    @ManyToMany(mappedBy = "specializations", fetch = FetchType.LAZY)
    private List<College> colleges = new ArrayList<>();

    // Public rather than protected -- see the equivalent note in Career.java.
    public Specialization() {
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

    public String getIcon() {
        return icon;
    }

    public List<Exam> getRelatedExams() {
        return relatedExams;
    }

    public List<Career> getCareers() {
        return careers;
    }

    public List<JobRole> getRelatedJobRoles() {
        return relatedJobRoles;
    }

    public List<Skill> getRelatedHardSkills() {
        return relatedHardSkills;
    }

    public List<Skill> getRelatedSoftSkills() {
        return relatedSoftSkills;
    }

    public List<String> getResponsibilities() {
        return responsibilities;
    }




    public String getDemand() {
        return demand;
    }

    public List<Certification> getRelatedCertifications() {
        return relatedCertifications;
    }

    public List<Industry> getRelatedIndustries() {
        return relatedIndustries;
    }

    public String getOverview() {
        return overview;
    }

    public List<String> getHighlights() {
        return highlights;
    }

    public List<SpecializationDegree> getEducation() {
        return education;
    }

    public List<Resource> getRelatedResources() {
        return relatedResources;
    }

    public List<College> getColleges() {
        return colleges;
    }

    public BigDecimal getSalaryMinLpa() {
        return salaryMinLpa;
    }

    public BigDecimal getSalaryMaxLpa() {
        return salaryMaxLpa;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setRelatedExams(List<Exam> relatedExams) {
        this.relatedExams = relatedExams;
    }

    public void setRelatedJobRoles(List<JobRole> relatedJobRoles) {
        this.relatedJobRoles = relatedJobRoles;
    }

    public void setRelatedHardSkills(List<Skill> relatedHardSkills) {
        this.relatedHardSkills = relatedHardSkills;
    }

    public void setRelatedSoftSkills(List<Skill> relatedSoftSkills) {
        this.relatedSoftSkills = relatedSoftSkills;
    }

    public void setResponsibilities(List<String> responsibilities) {
        this.responsibilities = responsibilities;
    }




    public void setDemand(String demand) {
        this.demand = demand;
    }

    public void setRelatedCertifications(List<Certification> relatedCertifications) {
        this.relatedCertifications = relatedCertifications;
    }

    public void setRelatedIndustries(List<Industry> relatedIndustries) {
        this.relatedIndustries = relatedIndustries;
    }

    public void setOverview(String overview) {
        this.overview = overview;
    }

    public void setHighlights(List<String> highlights) {
        this.highlights = highlights;
    }

    public void setRelatedResources(List<Resource> relatedResources) {
        this.relatedResources = relatedResources;
    }

    public void setSalaryMinLpa(BigDecimal salaryMinLpa) {
        this.salaryMinLpa = salaryMinLpa;
    }

    public void setSalaryMaxLpa(BigDecimal salaryMaxLpa) {
        this.salaryMaxLpa = salaryMaxLpa;
    }

    // No setEducation(): orphanRemoval=true on that collection means replacing
    // the list instance detaches the old rows without deleting them, which
    // Hibernate rejects. SpecializationService.syncEducation mutates it in
    // place instead.
}
