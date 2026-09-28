package com.careerguide.api.dto;

public record UserSkillDto(
        String skillSlug,
        String skillName,
        String proficiencyLevel,
        Integer yearsOfExperience
) {
}
