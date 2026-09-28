package com.careerguide.api.dto;

/**
 * Mirrors the frontend's {@code Subject} TypeScript interface
 * (src/lib/types.ts). Added in V87 -- see Subject.java for why field of study
 * is modelled separately from {@link DegreeDto}.
 *
 * <p>Flatter than DegreeDto on purpose: a subject owns no relations. What it
 * connects to is decided by the link that pairs it with a degree, not by the
 * subject itself.
 */
public record SubjectDto(
        String slug,
        String title,
        String description,
        String icon,
        String categorySlug
) {
}
