package com.careerguide.api.dto;

import java.util.Map;

/** Mirrors the frontend's {@code AssessmentOption} TypeScript interface (src/lib/types.ts). */
public record AssessmentOptionDto(
        String id,
        String label,
        Map<String, Integer> weights
) {
}
