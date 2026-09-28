package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

// Added in V66 -- the specific degree an exam is the entry gate into a
// career through (e.g. jee-main -> computer-science-and-engineering ->
// b-tech, neet-ug -> medicine -> mbbs). Same three-way-join shape as
// CollegeCareerDegree (V55), sharing SlugTripleId rather than a new
// hand-rolled id class -- see SlugTripleId's javadoc. Admin-editable via
// ExamService.syncCareerDegreeOfferings; see Exam.java's
// careerDegreeOfferings field.
@Entity
@Table(name = "exam_career_degrees")
public class ExamCareerDegree {

    // first = examSlug, second = careerSlug, third = degreeSlug.
    @EmbeddedId
    private SlugTripleId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("first")
    @JoinColumn(name = "exam_slug")
    private Exam exam;

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

    protected ExamCareerDegree() {
        // JPA
    }

    public ExamCareerDegree(Exam exam, Career career, Degree degree, Integer sortOrder) {
        this.id = new SlugTripleId(exam.getSlug(), career.getSlug(), degree.getSlug());
        this.exam = exam;
        this.career = career;
        this.degree = degree;
        this.sortOrder = sortOrder;
    }

    public SlugTripleId getId() {
        return id;
    }

    public Exam getExam() {
        return exam;
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

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
