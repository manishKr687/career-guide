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
 * One education route into a {@link Specialization}: a {@link Degree}, and the
 * {@link Subject} it is taken in. Added in V108.
 *
 * <p>Deliberately the same shape as {@link CareerDegree}, down to the
 * surrogate key, rather than a plain {@code @ManyToMany} to Degree. A degree
 * row is a qualification TYPE -- "B.Tech", never "B.Tech in Artificial
 * Intelligence" -- so a bare degree link on a specialization would render the
 * same four words on all 16 specializations of Computer Science &amp;
 * Engineering and distinguish none of them. Carrying the subject here is the
 * whole point of the relation.
 *
 * <p>Sharing the shape also means {@link QualificationTitle} composes the
 * display string for both, so a career and a specialization can never disagree
 * about how "B.Tech" plus "Artificial Intelligence" is written.
 *
 * <p>{@code subject} is null where the qualification already names its own
 * field (MCA) -- the same rule as {@code Degree.requiresSubject}.
 */
@Entity
@Table(name = "specialization_degrees")
public class SpecializationDegree {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "specialization_slug", nullable = false)
    private Specialization specialization;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "degree_slug", nullable = false)
    private Degree degree;

    // Nullable on purpose -- see the class javadoc.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_slug")
    private Subject subject;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected SpecializationDegree() {
        // JPA
    }

    public SpecializationDegree(Specialization specialization, Degree degree, Subject subject, Integer sortOrder) {
        this.specialization = specialization;
        this.degree = degree;
        this.subject = subject;
        this.sortOrder = sortOrder;
    }

    public Long getId() {
        return id;
    }

    public Specialization getSpecialization() {
        return specialization;
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

    // Admin write path only (SpecializationService.syncEducation) -- lets an
    // existing row be reordered or have its subject corrected without being
    // deleted and recreated.

    public void setSubject(Subject subject) {
        this.subject = subject;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
