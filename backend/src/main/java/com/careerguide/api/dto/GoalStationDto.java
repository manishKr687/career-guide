package com.careerguide.api.dto;

/** One station on the user's line. {@code custom} marks one the user added. */
public record GoalStationDto(
        Long id,
        String name,
        String kind,
        String detail,
        String nextStep,
        boolean done,
        boolean custom
) {
}
