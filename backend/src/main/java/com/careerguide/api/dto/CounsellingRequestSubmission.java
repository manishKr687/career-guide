package com.careerguide.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * Body for the public {@code POST /api/counselling-requests} -- what a site
 * visitor submits from the booking form. Preferred date/time, stage and
 * career context are all optional; only enough to reach the person back is
 * required.
 */
public record CounsellingRequestSubmission(
        @NotBlank @Size(max = 200) String name,
        @NotBlank @Email @Size(max = 255) String email,
        @NotBlank @Size(max = 32) String phone,
        LocalDate preferredDate,
        @Size(max = 64) String preferredTime,
        @Size(max = 64) String stageSlug,
        @Size(max = 64) String careerSlug,
        String message
) {
}
