package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Added in V53 (College MVP). The parent university a {@link College} can
 * (optionally) be affiliated to -- e.g. a typical private engineering
 * college affiliated to a state university. Deliberately seeded with zero
 * rows: every one of the 20 existing colleges is itself either an
 * autonomous degree-granting institute or a university in its own right,
 * so inventing a parent for any of them would misrepresent it -- see V53's
 * migration comment. {@code university} is a simple column on College
 * (not a join table) per the spec's own Section 14 note: "If affiliation
 * history becomes important later, a separate relationship table can be
 * introduced."
 */
@Entity
@Table(name = "universities")
public class University {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "university_type", nullable = false, length = 32)
    private String universityType;

    @Column(name = "ownership_type", nullable = false, length = 32)
    private String ownershipType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_slug")
    private State state;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "city_slug")
    private City city;

    @Column(length = 255)
    private String website;

    @Column(nullable = false, length = 16)
    private String status;

    // Public rather than protected -- see the equivalent note in Career.java.
    public University() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getUniversityType() {
        return universityType;
    }

    public String getOwnershipType() {
        return ownershipType;
    }

    public State getState() {
        return state;
    }

    public City getCity() {
        return city;
    }

    public String getWebsite() {
        return website;
    }

    public String getStatus() {
        return status;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setUniversityType(String universityType) {
        this.universityType = universityType;
    }

    public void setOwnershipType(String ownershipType) {
        this.ownershipType = ownershipType;
    }

    public void setState(State state) {
        this.state = state;
    }

    public void setCity(City city) {
        this.city = city;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
