package com.careerguide.api.dto;

import java.util.List;

/** Mirrors the frontend's {@code AssessmentQuestion} TypeScript interface (src/lib/types.ts). */
public record AssessmentQuestionDto(
        String id,
        String question,
        List<AssessmentOptionDto> options
) {
}
