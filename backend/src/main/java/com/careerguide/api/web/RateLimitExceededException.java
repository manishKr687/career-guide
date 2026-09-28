package com.careerguide.api.web;

/**
 * Thrown when a caller has made too many attempts against a throttled
 * endpoint (currently the auth/register/admin-login endpoints -- see
 * {@code com.careerguide.api.config.AuthRateLimitInterceptor}) within the
 * configured window. Mapped to HTTP 429 by {@link GlobalExceptionHandler}.
 */
public class RateLimitExceededException extends RuntimeException {

    public RateLimitExceededException(String message) {
        super(message);
    }
}
