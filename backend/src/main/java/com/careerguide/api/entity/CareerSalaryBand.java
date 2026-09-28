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

import java.math.BigDecimal;

/**
 * What a career pays at one experience level -- "Entry Level, 4-10 LPA".
 * Added in V110.
 *
 * <p>Numbers, not a display string, for the reasons V107 spelled out: a
 * string cannot be filtered, sorted, compared or validated, and nothing
 * rejects a malformed one. {@link SalaryRange} composes the display form from
 * these, so the career's overall range and its per-level breakdown are always
 * written the same way.
 *
 * <p>{@code maxLpa} is null on the top band and means open-ended --
 * "Leadership 40+ LPA" -- the same convention as
 * {@link CareerGrowthStage#getMaxYears()}.
 *
 * <p>SHIPS EMPTY, deliberately. These are figures a student plans around and
 * none of them exist anywhere in the catalog: growth-stage titles match a real
 * job role only 32 times in 210, and tiering job roles by name puts 250 of 290
 * in one bucket because the catalog does not encode seniority. Splitting the
 * career's overall range into four plausible-looking bands would produce
 * numbers that read as researched and are not. The page renders the verified
 * overall range until real bands are entered.
 */
@Entity
@Table(name = "career_salary_bands")
public class CareerSalaryBand {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "career_slug", nullable = false)
    private Career career;

    /** Free text rather than an enum: "Leadership" on one career is "Partner"
     *  on another, and the ladder length differs by field. */
    @Column(nullable = false, length = 48)
    private String band;

    @Column(name = "min_lpa", nullable = false, precision = 6, scale = 2)
    private BigDecimal minLpa;

    // Null means open-ended -- see the class javadoc.
    @Column(name = "max_lpa", precision = 6, scale = 2)
    private BigDecimal maxLpa;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    protected CareerSalaryBand() {
        // JPA
    }

    public CareerSalaryBand(Career career, String band, BigDecimal minLpa, BigDecimal maxLpa, Integer sortOrder) {
        this.career = career;
        this.band = band;
        this.minLpa = minLpa;
        this.maxLpa = maxLpa;
        this.sortOrder = sortOrder;
    }

    public Long getId() {
        return id;
    }

    public Career getCareer() {
        return career;
    }

    public String getBand() {
        return band;
    }

    public BigDecimal getMinLpa() {
        return minLpa;
    }

    public BigDecimal getMaxLpa() {
        return maxLpa;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    // Admin write path only (CareerService.syncSalaryBands).

    public void setBand(String band) {
        this.band = band;
    }

    public void setMinLpa(BigDecimal minLpa) {
        this.minLpa = minLpa;
    }

    public void setMaxLpa(BigDecimal maxLpa) {
        this.maxLpa = maxLpa;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
}
