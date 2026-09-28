package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * One (career, degree) pair from {@code exam_career_degrees} (V66) -- the
 * specific degree an exam is the entry gate into a career through. See
 * {@code ExamCareerDegree}'s javadoc.
 *
 * <p>Doubles as the request-side shape for {@code ExamUpsertRequest}'s
 * {@code careerDegreeOfferings} field, same as {@code CollegeCareerOfferingDto}
 * does for colleges -- kept as its own record rather than shared with that
 * one so each entity's DTO set stays self-contained.
 */
public record ExamCareerDegreeDto(
        @NotBlank String careerSlug,
        @NotBlank String degreeSlug
) {
}
