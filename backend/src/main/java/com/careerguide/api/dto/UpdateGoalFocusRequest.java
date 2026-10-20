package com.careerguide.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** Sets a focus item's level: 0 not started, 1 learning, 2 comfortable, 3 confident. */
public record UpdateGoalFocusRequest(@NotNull @Min(0) @Max(3) Integer level) {
}
