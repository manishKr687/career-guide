package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

// Added in V55 -- the specific degree a college's career/discipline
// offering is actually awarded through. See that migration's header
// comment for why this needs its own three-way join entity rather than
// reusing career_colleges or college_degrees. Admin-editable via
// CollegeService.syncCareerOfferings; see College.java's careerOfferings
// field.
@Entity
@Table(name = "college_career_degrees")
public class CollegeCareerDegree {

    // first = collegeSlug, second = careerSlug, third = degreeSlug -- see
    // SlugTripleId's javadoc.
    @EmbeddedId
    private SlugTripleId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("first")
    @JoinColumn(name = "college_slug")
    private College college;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("second")
    @JoinColumn(name = "career_slug")
    private Career career;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("third")
    @JoinColumn(name = "degree_slug")
    private Degree degree;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected CollegeCareerDegree() {
        // JPA
    }

    public CollegeCareerDegree(College college, Career career, Degree degree, Integer sortOrder) {
        this.id = new SlugTripleId(college.getSlug(), career.getSlug(), degree.getSlug());
        this.college = college;
        this.career = career;
        this.degree = degree;
        this.sortOrder = sortOrder;
    }

    public SlugTripleId getId() {
        return id;
    }

    public College getCollege() {
        return college;
    }

    public Career getCareer() {
        return career;
    }

    public Degree getDegree() {
        return degree;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    // Admin write path only (CollegeService.syncCareerOfferings) -- reorders
    // an existing row without deleting/recreating it.
    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
