package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Added in V53 (College MVP). One of India's 28 states or 8 union
 * territories -- see V53's migration comment for why the full 36 are
 * seeded (stable, well-known reference data) while {@link City} is not.
 */
@Entity
@Table(name = "states")
public class State {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 128)
    private String name;

    @Column(nullable = false, length = 8)
    private String code;

    // Public rather than protected -- see the equivalent note in Career.java.
    public State() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getCode() {
        return code;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
