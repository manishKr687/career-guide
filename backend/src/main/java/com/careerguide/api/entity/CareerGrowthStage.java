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
 * One rung of a career's progression ladder: a role title and the experience
 * range at which it typically happens. Added in V110.
 *
 * <p>Replaces the flat {@code careers.growth_path} text[], which could name
 * the rungs ("Software Engineer", "Tech Lead") but never say when each one
 * happens -- so the ladder read as a list of job titles rather than a
 * timeline.
 *
 * <p>{@code maxYears} is null on the last rung and means open-ended. "12+
 * years" is the honest rendering; inventing a ceiling would put a number on
 * the page that nothing supports.
 *
 * <p>The seeded year bands come from the rung's POSITION in the ladder, not
 * from per-career research -- see V110's comment. They are a convention worth
 * correcting per career, which is exactly why they are editable rows rather
 * than a formula in the page.
 */
@Entity
@Table(name = "career_growth_stages")
public class CareerGrowthStage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "career_slug", nullable = false)
    private Career career;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(name = "min_years", nullable = false)
    private Short minYears;

    // Null means open-ended -- see the class javadoc.
    @Column(name = "max_years")
    private Short maxYears;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected CareerGrowthStage() {
        // JPA
    }

    public CareerGrowthStage(Career career, String title, Short minYears, Short maxYears, Integer sortOrder) {
        this.career = career;
        this.title = title;
        this.minYears = minYears;
        this.maxYears = maxYears;
        this.sortOrder = sortOrder;
    }

    public Long getId() {
        return id;
    }

    public Career getCareer() {
        return career;
    }

    public String getTitle() {
        return title;
    }

    public Short getMinYears() {
        return minYears;
    }

    public Short getMaxYears() {
        return maxYears;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    // Admin write path only (CareerService.syncGrowthStages) -- lets an
    // existing rung be reordered or re-dated without being deleted and
    // recreated.

    public void setTitle(String title) {
        this.title = title;
    }

    public void setMinYears(Short minYears) {
        this.minYears = minYears;
    }

    public void setMaxYears(Short maxYears) {
        this.maxYears = maxYears;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
