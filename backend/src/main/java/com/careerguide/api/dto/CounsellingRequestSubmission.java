package com.careerguide.api.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
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
        String message,

        /**
         * Consent to being contacted about this enquiry (V133).
         *
         * BOTH annotations are required, and the reason is a trap worth naming:
         * Bean Validation's {@code @AssertTrue} passes when the value is NULL --
         * it only fails on {@code false}. With {@code @AssertTrue} alone, sending
         * {@code "consent": false} was correctly rejected while OMITTING the
         * field entirely was accepted, which is precisely the bypass this exists
         * to close. {@code @NotNull} makes absence a failure too.
         *
         * The requirement lives on the server because the endpoint is public and
         * takes a plain POST; a checkbox in the browser stops nobody.
         */
        @NotNull(message = "Consent is required before we can contact you about this enquiry.")
        @AssertTrue(message = "Consent is required before we can contact you about this enquiry.")
        Boolean consent
) {
}
