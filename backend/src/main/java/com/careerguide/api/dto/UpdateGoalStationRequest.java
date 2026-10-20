package com.careerguide.api.dto;

import jakarta.validation.constraints.NotNull;

/** Ticks a station off, or un-ticks it. */
public record UpdateGoalStationRequest(@NotNull Boolean done) {
}
