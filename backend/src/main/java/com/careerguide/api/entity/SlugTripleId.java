package com.careerguide.api.entity;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Reusable composite-key shape for a three-part (X, Y, Z) junction table --
 * same idea as {@link UserSlugId} (which does this for two-part
 * user/slug junctions), extended to three parts so the next three-way
 * relation this codebase needs doesn't get its own hand-rolled id class.
 *
 * <p>The Java fields are named generically ({@code first}/{@code second}/
 * {@code third}); the actual DB column names are supplied per-entity via
 * {@code @JoinColumn} on each {@code @MapsId} association. For
 * {@link CollegeCareerDegree}: first = collegeSlug, second = careerSlug,
 * third = degreeSlug.
 */
@Embeddable
public class SlugTripleId implements Serializable {

    private String first;

    private String second;

    private String third;

    protected SlugTripleId() {
        // JPA
    }

    public SlugTripleId(String first, String second, String third) {
        this.first = first;
        this.second = second;
        this.third = third;
    }

    public String getFirst() {
        return first;
    }

    public String getSecond() {
        return second;
    }

    public String getThird() {
        return third;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof SlugTripleId that)) {
            return false;
        }
        return Objects.equals(first, that.first)
                && Objects.equals(second, that.second)
                && Objects.equals(third, that.third);
    }

    @Override
    public int hashCode() {
        return Objects.hash(first, second, third);
    }
}
