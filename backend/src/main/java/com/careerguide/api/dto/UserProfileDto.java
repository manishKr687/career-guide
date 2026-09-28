package com.careerguide.api.dto;

public record UserProfileDto(
        String educationStageSlug,
        String streamSlug,
        String educationLevel,
        Integer graduationYear,
        Integer experienceYears,
        String location
) {
}
