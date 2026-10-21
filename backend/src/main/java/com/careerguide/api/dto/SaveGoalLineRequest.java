package com.careerguide.api.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

/** The whole line, in order; the last station is the goal. 2-12 stations, the same bounds a user's line keeps. */
public record SaveGoalLineRequest(
        @NotNull @Size(min = 2, max = 12) List<@Valid @NotNull GoalLineStationDto> stations
) {
}
