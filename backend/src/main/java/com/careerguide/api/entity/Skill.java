package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

// Added in V24 -- see the Data Model Roadmap doc's Phase 2 and the backend
// README. Deliberately minimal (slug + name only, no description/icon like
// Specialization): the source data backfilled into this table is a plain
// skill name per career, with nothing to fill a description from.
@Entity
@Table(name = "skills")
public class Skill {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    // Added in V34 -- classifies a skill (Programming Language, Technical,
    // Cloud, Tool, Domain Skill, Soft Skill, ...). Nullable: only backfilled
    // for the skills the uploaded seed doc actually named a type for; the
    // other pre-existing skills are left NULL rather than guessing.
    @Column(name = "skill_type", length = 50)
    private String skillType;

    // V114: the filterable classification -- Soft / Programming / Tools /
    // Analytical / Domain. Derived by rule from the name, not typed by an
    // editor, which is why it is separate from `skillType` above: that one is
    // free text and was NULL for 384 of 413 rows, so it could never drive a
    // facet.
    @Column(nullable = false, length = 24)
    private String category;

    // V114: unseeded. 413 descriptions is a content task, and the listing
    // reads fine without one -- it shows a skill's REACH (how many job roles
    // and careers use it) instead, which the catalog can prove.
    @Column(columnDefinition = "text")
    private String description;

    // Public rather than protected: JPA only needs a no-arg constructor
    // (Hibernate uses reflection regardless of visibility), but the admin
    // write path added for Skill Management also calls `new Skill()`
    // directly from SkillService, which is in a different package -- same
    // reasoning as Career's public no-arg constructor.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public Skill() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getCategory() {
        return category;
    }

    public String getDescription() {
        return description;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSkillType() {
        return skillType;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setSkillType(String skillType) {
        this.skillType = skillType;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
