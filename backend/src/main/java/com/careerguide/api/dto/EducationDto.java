package com.careerguide.api.dto;

/**
 * One education route: a degree, and the subject it is taken in. Added in
 * V103.
 *
 * <p>Replaces the flat {@code relatedDegreeSlugs} list on {@link CareerDto}.
 * A list of degree slugs could say "B.A." but never "B.A. (Psychology)", and
 * could not hold two rows for the same degree in different subjects.
 *
 * <p>{@code subjectSlug} is null for a fused qualification that takes none
 * (MBBS, GNM -- see {@code DegreeDto.requiresSubject}), or where one applies
 * but has not been filled in yet.
 *
 * <p>{@code title} is the composed display string, supplied by the server so
 * every caller renders it identically. The rule is level-dependent --
 * parentheses for bachelor's and master's, "in" for doctorates -- and
 * duplicating it per page is how four callers end up disagreeing. It is
 * derived, never stored; {@code degreeSlug} and {@code subjectSlug} remain
 * the source of truth.
 */
public record EducationDto(
        String degreeSlug,
        String subjectSlug,
        String title
) {
}
