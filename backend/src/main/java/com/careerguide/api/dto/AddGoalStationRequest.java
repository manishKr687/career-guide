package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** A station the user adds to their own line; it goes before the goal station. */
public record AddGoalStationRequest(@NotBlank @Size(max = 80) String name) {
}
