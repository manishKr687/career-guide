package com.careerguide.api.dto;

import java.util.List;
import java.util.Map;

/**
 * Result of scoring a submitted assessment, replicating what the frontend's
 * {@code computeCategoryScores} / {@code getTopCategories} /
 * {@code getRecommendedCareers} (src/lib/assessment.ts) compute client-side.
 */
public record AssessmentResultDto(
        Map<String, Integer> categoryScores,
        List<CategoryDto> topCategories,
        List<CareerDto> recommendedCareers
) {
}
