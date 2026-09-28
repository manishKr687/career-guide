package com.careerguide.api.dto;

/** Added in V25 -- see Industry.java and the Data Model Roadmap doc's Phase 2. */
public record IndustryDto(
        String slug,
        String name,
        boolean isSector
) {
}
