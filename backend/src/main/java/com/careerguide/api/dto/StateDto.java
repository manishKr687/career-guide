package com.careerguide.api.dto;

/** Mirrors the frontend's {@code State} TypeScript interface (src/lib/types.ts). Added in V53 (College MVP). */
public record StateDto(
        String slug,
        String name,
        String code
) {
}
