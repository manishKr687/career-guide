package com.careerguide.api.web;

/**
 * Thrown when an admin create request reuses a slug that already exists.
 * Mapped to HTTP 409 by {@link GlobalExceptionHandler}.
 */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
