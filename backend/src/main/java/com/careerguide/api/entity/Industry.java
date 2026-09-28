package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

// Added in V25 -- same shape and reasoning as Skill (see the Data Model
// Roadmap doc's Phase 2 and the backend README). Backfilled from
// careers.top_recruiters, so "industry" here doubles as "known employer" --
// there was no independent industry taxonomy in the source data.
@Entity
@Table(name = "industries")
public class Industry {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    // Added in V35 -- distinguishes a broad industry-sector taxonomy row
    // (e.g. "Healthcare", "Fintech") from the pre-existing "known employer"
    // rows in this same table (e.g. "Apollo Hospitals"). Defaults to false,
    // so every pre-V35 row stays a non-sector employer row.
    @Column(name = "is_sector", nullable = false)
    private boolean isSector;

    // Public rather than protected -- same reasoning as Skill/Career's
    // public no-arg constructors: the admin write path calls `new Industry()`
    // directly from IndustryService, a different package.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public Industry() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public boolean isSector() {
        return isSector;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setSector(boolean sector) {
        isSector = sector;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
