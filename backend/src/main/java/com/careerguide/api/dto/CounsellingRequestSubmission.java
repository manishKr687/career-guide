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

        /**
         * The only field on this record that had no length limit, which on a
         * public unauthenticated endpoint made it the cheapest way to fill the
         * database: a 2 MB message was accepted and stored, and nothing capped
         * how many times. The column is {@code text}, so Postgres imposed no
         * bound either.
         *
         * <p>2000 characters is roughly 400 words -- more than anyone needs to
         * describe what they want to talk about, and short enough that even a
         * caller exhausting the rate limit every window cannot grow the table
         * meaningfully.
         *
         * <p>This rejects the value after Jackson has parsed it. The body is
         * refused before parsing by {@link
         * com.careerguide.api.config.RequestSizeLimitFilter}, which is the
         * layer that protects memory rather than the table.
         */
        @Size(max = 2000, message = "Message must be 2000 characters or fewer.") String message,

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
