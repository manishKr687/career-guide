package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Added in V53 (College MVP). Unlike {@link State} (an exhaustive, stable
 * 36-row list), only the cities actually in use by a college or university
 * are seeded -- see V53's migration comment. Admin adds more as more
 * colleges are entered.
 */
@Entity
@Table(name = "cities")
public class City {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 128)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_slug", nullable = false)
    private State state;

    // Public rather than protected -- see the equivalent note in Career.java.
    public City() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public State getState() {
        return state;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setState(State state) {
        this.state = state;
    }
}
