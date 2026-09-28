package com.careerguide.api.web;

/**
 * Thrown when an admin request is missing a valid session token, or the
 * login endpoint receives the wrong password. Mapped to HTTP 401 by
 * {@link GlobalExceptionHandler}.
 */
public class UnauthorizedException extends RuntimeException {

    public UnauthorizedException(String message) {
        super(message);
    }
}
