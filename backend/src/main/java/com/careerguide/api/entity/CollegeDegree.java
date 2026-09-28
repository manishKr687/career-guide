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
 * One qualification a college awards: a {@link Degree}, optionally in a
 * {@link Subject}.
 *
 * <p>Same promotion and the same reasoning as {@link CareerDegree} (V103): a
 * plain {@code @ManyToMany} cannot carry the subject column, and the old
 * (college_slug, degree_slug) key allowed only one row per degree per
 * college -- fatal for a college offering M.Tech in a dozen branches.
 *
 * <p>The immediate driver was phd-engineering: 54 colleges pointed at that
 * single product row, which is now 54 rows of (phd, engineering).
 *
 * <p>Distinct from {@link CollegeCareerDegree}, which is a three-way join
 * recording "this college offers this CAREER via this degree". This one is
 * just "this college awards this qualification", with no career involved.
 */
@Entity
@Table(name = "college_degrees")
public class CollegeDegree {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "college_slug", nullable = false)
    private College college;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "degree_slug", nullable = false)
    private Degree degree;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_slug")
    private Subject subject;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected CollegeDegree() {
        // JPA
    }

    public CollegeDegree(College college, Degree degree, Subject subject, Integer sortOrder) {
        this.college = college;
        this.degree = degree;
        this.subject = subject;
        this.sortOrder = sortOrder;
    }

    public Long getId() {
        return id;
    }

    public College getCollege() {
        return college;
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

    public void setSubject(Subject subject) {
        this.subject = subject;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
