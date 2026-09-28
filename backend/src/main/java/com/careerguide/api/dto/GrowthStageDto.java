package com.careerguide.api.dto;

/**
 * One rung of a career's progression ladder. Added in V110.
 *
 * <p>Replaces the bare strings of {@code CareerDto.growthPath}, which named
 * the rungs but could not say when each happens.
 *
 * <p>{@code maxYears} is null on the last rung and means open-ended -- the UI
 * renders "12+ yrs". {@code label} is the composed display form, supplied by
 * the server so every caller writes the range the same way, exactly as
 * {@code EducationDto.title} does for qualifications.
 */
public record GrowthStageDto(
        String title,
        Short minYears,
        Short maxYears,
        String label
) {
}
