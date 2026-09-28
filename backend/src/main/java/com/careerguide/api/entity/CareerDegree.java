package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * One education route into a career: a {@link Degree}, and the
 * {@link Subject} it is taken in.
 *
 * <p>Degree and Subject are separate models (V103-V105). `degrees` holds
 * qualification TYPES only -- B.A., not "B.A. (Psychology)" -- so the
 * combination lives here, on the row that selects them, and the displayed
 * title is composed from the two parts rather than stored. It therefore
 * cannot drift from them, and `level` stays a fact about the degree while
 * `category` stays a fact about the subject.
 *
 * <p>Promoted from a plain {@code @ManyToMany} join table in V103, because a
 * join table cannot carry an extra column. The old mapping also keyed
 * career_degrees (career_slug, degree_slug), allowing one row per degree per
 * career -- so "B.Sc in Computer Science OR B.Sc in Statistics" was
 * inexpressible.
 *
 * <p>Unlike {@link CollegeCareerDegree} this does NOT use the shared
 * {@link SlugTripleId}: that pattern needs every key component non-null, and
 * subject is optional. The surrogate {@code id} plus a unique index over
 * {@code COALESCE(subject_slug, '')} enforces the same natural key while
 * tolerating the null. That is a consequence of optionality, not an
 * inconsistency to tidy away.
 *
 * <p>{@code subject} is null in two legitimate cases: a fused qualification
 * that takes none (MBBS, GNM -- see {@code Degree.requiresSubject}), and a
 * subject-bearing degree whose subject has not been filled in yet. 78 rows
 * were in the second state when this was introduced; the old model could not
 * distinguish them from the first, which is why the gap went unnoticed.
 */
@Entity
@Table(name = "career_degrees")
public class CareerDegree {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "career_slug", nullable = false)
    private Career career;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "degree_slug", nullable = false)
    private Degree degree;

    // Nullable on purpose -- see the class javadoc.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_slug")
    private Subject subject;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected CareerDegree() {
        // JPA
    }

    public CareerDegree(Career career, Degree degree, Subject subject, Integer sortOrder) {
        this.career = career;
        this.degree = degree;
        this.subject = subject;
        this.sortOrder = sortOrder;
    }

    public Long getId() {
        return id;
    }

    public Career getCareer() {
        return career;
    }

    public Degree getDegree() {
        return degree;
    }

    public Subject getSubject() {
        return subject;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    // Admin write path only (CareerService.syncEducation) -- lets an existing
    // row be reordered or have its subject corrected without being deleted
    // and recreated.

    public void setSubject(Subject subject) {
        this.subject = subject;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
