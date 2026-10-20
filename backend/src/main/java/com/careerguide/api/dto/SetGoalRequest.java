package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Sets (or replaces) the user's goal. A different type or slug rebuilds the
 * line and focus list from the catalogue; the same one only changes the date.
 * The learning log is kept either way.
 */
public record SetGoalRequest(
        @NotBlank
        @Pattern(regexp = "^(career|exam|college|degree|job_role|company|sector|certification)$",
                message = "must be one of career, exam, college, degree, job_role, company, sector, certification")
        String type,

        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE)
        String slug,

        /** "YYYY-MM", or null for no date. */
        @Pattern(regexp = "^\\d{4}-(0[1-9]|1[0-2])$", message = "must be a month like 2027-03")
        String targetMonth
) {
}
