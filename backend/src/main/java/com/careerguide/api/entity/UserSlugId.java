package com.careerguide.api.entity;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Reusable composite-key shape for the {@code user_id + <entity>_slug}
 * junction tables added in V30/V31 (user_skills, user_saved_careers,
 * user_saved_courses, user_saved_colleges, user_saved_exams) -- each is a
 * plain (user, slug) pair with no surrogate id column of its own, so a
 * shared {@code @Embeddable} avoids five near-identical id classes. The
 * Java field is named generically ({@code slug}); the actual DB column name
 * (career_slug, skill_slug, ...) is supplied per-entity via
 * {@code @JoinColumn} on the {@code @MapsId} association.
 */
@Embeddable
public class UserSlugId implements Serializable {

    private Long userId;

    private String slug;

    protected UserSlugId() {
        // JPA
    }

    public UserSlugId(Long userId, String slug) {
        this.userId = userId;
        this.slug = slug;
    }

    public Long getUserId() {
        return userId;
    }

    public String getSlug() {
        return slug;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof UserSlugId that)) {
            return false;
        }
        return Objects.equals(userId, that.userId) && Objects.equals(slug, that.slug);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, slug);
    }
}
