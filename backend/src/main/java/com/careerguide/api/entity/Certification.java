package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

import java.util.HashSet;
import java.util.Set;

// Added in V27 -- see the Data Model Roadmap doc's "Spec v1.0 Match" tab.
// No content seeded (neither uploaded doc gives real certification data
// tied to careers/skills in this database) -- the table and this entity
// existed ready for real content, and now has an admin write path for it.
//
// Owns both certification_careers and certification_skills outright --
// neither Career nor Skill has a corresponding inverse field, so (like
// Resource below) there's no second join table to keep in sync when this
// entity's own relations change.
@Entity
@Table(name = "certifications")
public class Certification {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "text")
    private String description;

    @Column(length = 160)
    private String provider;

    @Column(length = 32)
    private String level;

    @Column(length = 64)
    private String duration;

    @Column(name = "official_url", length = 500)
    private String officialUrl;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "certification_careers",
            joinColumns = @JoinColumn(name = "certification_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    private Set<Career> relatedCareers = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "certification_skills",
            joinColumns = @JoinColumn(name = "certification_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    private Set<Skill> relatedSkills = new HashSet<>();

    // Public rather than protected -- same reasoning as the other entities
    // in this pass: the admin write path calls `new Certification()`
    // directly from CertificationService, a different package.
    public Certification() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getProvider() {
        return provider;
    }

    public String getLevel() {
        return level;
    }

    public String getDuration() {
        return duration;
    }

    public String getOfficialUrl() {
        return officialUrl;
    }

    public Set<Career> getRelatedCareers() {
        return relatedCareers;
    }

    public Set<Skill> getRelatedSkills() {
        return relatedSkills;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public void setOfficialUrl(String officialUrl) {
        this.officialUrl = officialUrl;
    }

    public void setRelatedCareers(Set<Career> relatedCareers) {
        this.relatedCareers = relatedCareers;
    }

    public void setRelatedSkills(Set<Skill> relatedSkills) {
        this.relatedSkills = relatedSkills;
    }
}
