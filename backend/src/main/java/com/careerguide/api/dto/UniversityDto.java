package com.careerguide.api.dto;

/** Mirrors the frontend's {@code University} TypeScript interface (src/lib/types.ts). Added in V53 (College MVP). */
public record UniversityDto(
        String slug,
        String name,
        String universityType,
        String ownershipType,
        String stateSlug,
        String citySlug,
        String website,
        String status
) {
}
