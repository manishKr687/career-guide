package com.careerguide.api.dto;

import java.util.List;

/** Mirrors the frontend's {@code Stage} TypeScript interface (src/lib/types.ts). */
public record StageDto(
        String slug,
        String name,
        String tagline,
        String description,
        String badgeSoft,
        String badgeSolid,
        String icon,
        List<String> highlights,
        List<String> relatedCareerSlugs,
        List<String> relatedExamSlugs
) {
}
