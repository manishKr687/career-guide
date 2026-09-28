package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * One (career, degree) pair from {@code college_career_degrees} (V55) --
 * the specific degree a college's career/discipline offering is actually
 * awarded through. See {@code CollegeCareerDegree}'s javadoc.
 *
 * <p>Doubles as the request-side shape for {@code CollegeUpsertRequest}'s
 * {@code careerOfferings} field -- the two components are the only ones
 * that need validating there, so no separate request DTO.
 */
public record CollegeCareerOfferingDto(
        @NotBlank String careerSlug,
        @NotBlank String degreeSlug
) {
}
