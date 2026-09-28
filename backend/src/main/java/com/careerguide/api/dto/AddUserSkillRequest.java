package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;

public record AddUserSkillRequest(
        @NotBlank String skillSlug,
        String proficiencyLevel,
        Integer yearsOfExperience
) {
}
