package com.careerguide.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * One learning-log line, dated today (India time) by the server. A score is
 * optional, but if either {@code score} or {@code scoreMax} is sent both must
 * be, with the score no higher than the maximum -- checked in GoalService, as
 * it spans two fields.
 */
public record AddLearningLogRequest(
        @NotBlank @Size(max = 280) String note,
        @NotBlank @Size(max = 80) String target,
        @NotNull @Min(1) @Max(600) Integer minutes,
        @Min(0) @Max(1000) Integer score,
        @Min(1) @Max(1000) Integer scoreMax
) {
}
