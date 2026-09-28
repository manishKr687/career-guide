package com.careerguide.api.dto;

import jakarta.validation.constraints.NotNull;

import java.util.Map;

/**
 * Body for {@code POST /api/assessment/submit}. Mirrors the frontend's
 * {@code AssessmentAnswers} type: a map of questionId -> chosen optionId.
 */
public record AssessmentSubmissionRequest(
        @NotNull Map<String, String> answers
) {
}
