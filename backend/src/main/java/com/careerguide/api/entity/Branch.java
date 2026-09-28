package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

// Added in V23 as the grouping layer between Category and Career described
// in the Data Model Roadmap doc's Phase 1 (see backend README). Read-only
// like Category -- no admin write path yet, since only Engineering &
// Technology's 12 branches exist so far.
@Entity
@Table(name = "branches")
public class Branch {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(nullable = false, length = 32)
    private String icon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_slug", nullable = false)
    private Category category;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    protected Branch() {
        // JPA
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getIcon() {
        return icon;
    }

    public Category getCategory() {
        return category;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }
}
