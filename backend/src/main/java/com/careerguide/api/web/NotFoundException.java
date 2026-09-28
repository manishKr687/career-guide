package com.careerguide.api.web;

/** Thrown when a requested slug does not exist. Mapped to HTTP 404 by {@link GlobalExceptionHandler}. */
public class NotFoundException extends RuntimeException {

    public NotFoundException(String message) {
        super(message);
    }

    public static NotFoundException forSlug(String entity, String slug) {
        return new NotFoundException(entity + " not found: " + slug);
    }
}
