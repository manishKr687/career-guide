package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.time.Instant;

// Added in V28 -- see the Data Model Roadmap doc's "Spec v1.0 Match" tab.
// No content seeded yet, but this entity now has a real admin write path.
// Deliberately not tightly coupled to one entity (per the ER doc's own
// "Resources should not be tightly coupled to one entity" note) -- it can
// relate to careers, courses, exams and skills all at once.
//
// Owns every one of its four join tables outright -- none of Career,
// Course, Exam or Skill has a corresponding inverse field for these, so
// (unlike Career.relatedCourses / Course.relatedCareers) there's no second,
// independently-owned join table to keep in sync when this entity's own
// relations change.
@Entity
@Table(name = "resources")
public class Resource {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 300)
    private String title;

    @Column(name = "resource_type", nullable = false, length = 32)
    private String resourceType;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "content_url", length = 500)
    private String contentUrl;

    @Column(length = 160)
    private String author;

    @Column(name = "published_at")
    private LocalDate publishedAt;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "resource_careers",
            joinColumns = @JoinColumn(name = "resource_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    private Set<Career> relatedCareers = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "resource_exams",
            joinColumns = @JoinColumn(name = "resource_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    private Set<Exam> relatedExams = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "resource_skills",
            joinColumns = @JoinColumn(name = "resource_slug"),
            inverseJoinColumns = @JoinColumn(name = "skill_slug")
    )
    private Set<Skill> relatedSkills = new HashSet<>();

    // Public rather than protected -- same reasoning as the other entities
    // in this pass: the admin write path calls `new Resource()` directly
    // from ResourceService, a different package.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public Resource() {
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public String getResourceType() {
        return resourceType;
    }

    public String getDescription() {
        return description;
    }

    public String getContentUrl() {
        return contentUrl;
    }

    public String getAuthor() {
        return author;
    }

    public LocalDate getPublishedAt() {
        return publishedAt;
    }

    public Set<Career> getRelatedCareers() {
        return relatedCareers;
    }

    public Set<Exam> getRelatedExams() {
        return relatedExams;
    }

    public Set<Skill> getRelatedSkills() {
        return relatedSkills;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setResourceType(String resourceType) {
        this.resourceType = resourceType;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setContentUrl(String contentUrl) {
        this.contentUrl = contentUrl;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setPublishedAt(LocalDate publishedAt) {
        this.publishedAt = publishedAt;
    }

    public void setRelatedCareers(Set<Career> relatedCareers) {
        this.relatedCareers = relatedCareers;
    }

    public void setRelatedExams(Set<Exam> relatedExams) {
        this.relatedExams = relatedExams;
    }

    public void setRelatedSkills(Set<Skill> relatedSkills) {
        this.relatedSkills = relatedSkills;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
