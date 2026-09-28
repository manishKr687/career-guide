package com.careerguide.api.dto;

/** Added in V23 -- see Branch.java and the Data Model Roadmap doc's Phase 1. */
public record BranchDto(
        String slug,
        String name,
        String icon,
        String categorySlug
) {
}
