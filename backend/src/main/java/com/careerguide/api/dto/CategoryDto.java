package com.careerguide.api.dto;

/** Mirrors the frontend's {@code Category} TypeScript interface (src/lib/types.ts). */
public record CategoryDto(
        String slug,
        String name,
        String icon,
        String color
) {
}
