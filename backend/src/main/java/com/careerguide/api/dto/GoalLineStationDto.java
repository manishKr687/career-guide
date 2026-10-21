package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** One station of a goal line as the admin edits it. Same limits as a user's station (V148). */
public record GoalLineStationDto(
        @NotBlank @Size(max = 80) String name,
        @NotBlank @Size(max = 32) String kind,
        @Size(max = 200) String detail,
        @Size(max = 200) String nextStep
) {
}
