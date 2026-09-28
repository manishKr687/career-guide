package com.careerguide.api.dto;

/** Mirrors the frontend's {@code City} TypeScript interface (src/lib/types.ts). Added in V53 (College MVP). */
public record CityDto(
        String slug,
        String name,
        String stateSlug
) {
}
