package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * A degree/qualification type (B.Tech, M.Tech, Diploma, B.Ed, ...) -- added
 * in V44 to replace the removed Courses section (V43). Unlike Course, this
 * isn't one row per discipline (there's no "Degree: Chemical Engineering");
 * it's a general pursuit guide for the degree itself: which entrance exams
 * lead into it, how to prepare, the skills it takes, and curated resources.
 *
 * <p>That "not one row per discipline" rule held only as a comment, and by
 * V86 it had been broken 62 times over -- B.A. (Economics), M.Sc Nursing,
 * PhD in Engineering. Each such row silently duplicated `level` (all 17 B.Sc
 * variants said 'Undergraduate') and carried a category describing its
 * subject rather than itself. {@link Subject} gives the discipline somewhere
 * to live, and {@code requiresSubject} below is the rule made checkable
 * instead of merely written down.
 * Every relation is owned entirely by Degree (same shape as
 * Specialization.relatedJobRoles/relatedHardSkills/relatedSoftSkills) --
 * none of Exam/Skill/Resource has an inverse field, so there's no second
 * join table to keep in sync.
 */
@Entity
@Table(name = "degrees")
public class Degree {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(nullable = false, length = 32)
    private String icon;

    // Free text guidance paragraph -- there's nothing in the catalog for
    // "how to prepare" to link to, same reasoning as Specialization's
    // responsibilities field.
    @Column(name = "preparation_strategy", columnDefinition = "text")
    private String preparationStrategy;

    // Added in V70 -- see that migration's comment for the level taxonomy
    // and why it's an explicit column rather than derived from title.
    @Column(nullable = false, length = 32)
    private String level;

    // Added in V71 -- nullable, unlike Career.category: 3 generic rows
    // (Certificate, Diploma, PhD with no subject named) have no confident
    // category, see that migration's comment.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_slug")
    private Category category;

    // Added in V88. Whether this qualification is incomplete without a field
    // of study: "M.Sc" alone means nothing, "MBBS" is already complete. Drives
    // whether the admin form offers a Subject picker alongside the degree.
    // False for fused qualifications (MBBS, B.Arch, B.Ed), dual degrees
    // (BA LLB, BSc BEd) and vocational ones (GNM, BHM) -- see V88's comment
    // for why each group differs.
    @Column(name = "requires_subject", nullable = false)
    private boolean requiresSubject;

    // V111: what the abbreviation stands for -- "Bachelor of Technology" for
    // B.Tech. Null where `title` is already the full name (Diploma,
    // Certificate), rather than storing it twice.
    @Column(name = "full_title", length = 200)
    private String fullTitle;

    // V111: how long the programme runs, as a range with both bounds set --
    // equal where it is fixed (4 = "4 years"), different where it genuinely
    // varies (PhD 3-5). NUMERIC because the medical qualifications are real
    // half-years: MBBS is 4.5 years plus a one-year internship.
    //
    // Null on both means "not a taught programme with a fixed length", not
    // "unknown": DSc, DLitt and LLD are awarded on submitted published work.
    @Column(name = "duration_min_years", precision = 3, scale = 1)
    private BigDecimal durationMinYears;

    @Column(name = "duration_max_years", precision = 3, scale = 1)
    private BigDecimal durationMaxYears;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "degree_exams",
            joinColumns = @JoinColumn(name = "degree_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Exam> relatedExams = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "degree_skills",
            joinColumns = @JoinColumn(name = "degree_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Skill> relatedSkills = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "degree_resources",
            joinColumns = @JoinColumn(name = "degree_slug"),
            inverseJoinColumns = @JoinColumn(name = "resource_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Resource> relatedResources = new ArrayList<>();

    // The fields of study this qualification is offered in (V101), e.g. B.Sc
    // -> Computer Science, Data Science, Economics... Together they read as
    // "B.Sc (Computer Science)" -- the title is composed at render time from
    // the two parts rather than stored, so it cannot drift from them.
    //
    // Replaces the 42 product rows V102 deleted, which each baked a subject
    // into the qualification and restated `level` from their family.
    //
    // Empty for most degrees, and that is normal: fused qualifications (MBBS,
    // B.Arch) take no subject at all -- see requiresSubject above -- and the
    // product rows that still have live references have not been converted
    // yet. @OrderBy rather than @OrderColumn: degree_subjects has no
    // sort_order column and the ordering is not curated.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "degree_subjects",
            joinColumns = @JoinColumn(name = "degree_slug"),
            inverseJoinColumns = @JoinColumn(name = "subject_slug")
    )
    @OrderBy("title ASC")
    private List<Subject> subjects = new ArrayList<>();

    // Public rather than protected -- see the equivalent note in Career.java.
    public Degree() {
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getIcon() {
        return icon;
    }

    public String getPreparationStrategy() {
        return preparationStrategy;
    }

    public String getLevel() {
        return level;
    }

    public Category getCategory() {
        return category;
    }

    public String getFullTitle() {
        return fullTitle;
    }

    public BigDecimal getDurationMinYears() {
        return durationMinYears;
    }

    public BigDecimal getDurationMaxYears() {
        return durationMaxYears;
    }

    public void setFullTitle(String fullTitle) {
        this.fullTitle = fullTitle;
    }

    public void setDurationMinYears(BigDecimal durationMinYears) {
        this.durationMinYears = durationMinYears;
    }

    public void setDurationMaxYears(BigDecimal durationMaxYears) {
        this.durationMaxYears = durationMaxYears;
    }

    public boolean isRequiresSubject() {
        return requiresSubject;
    }

    public List<Exam> getRelatedExams() {
        return relatedExams;
    }

    public List<Skill> getRelatedSkills() {
        return relatedSkills;
    }

    public List<Resource> getRelatedResources() {
        return relatedResources;
    }

    public List<Subject> getSubjects() {
        return subjects;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setPreparationStrategy(String preparationStrategy) {
        this.preparationStrategy = preparationStrategy;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public void setRequiresSubject(boolean requiresSubject) {
        this.requiresSubject = requiresSubject;
    }

    public void setRelatedExams(List<Exam> relatedExams) {
        this.relatedExams = relatedExams;
    }

    public void setRelatedSkills(List<Skill> relatedSkills) {
        this.relatedSkills = relatedSkills;
    }

    public void setRelatedResources(List<Resource> relatedResources) {
        this.relatedResources = relatedResources;
    }

    public void setSubjects(List<Subject> subjects) {
        this.subjects = subjects;
    }
}
