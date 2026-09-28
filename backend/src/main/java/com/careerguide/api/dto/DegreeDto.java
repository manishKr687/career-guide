package com.careerguide.api.dto;

import java.util.List;

/** Mirrors the frontend's {@code Degree} TypeScript interface (src/lib/types.ts). */
public record DegreeDto(
        String slug,
        String title,
        String description,
        String icon,
        String preparationStrategy,
        String level,
        String categorySlug,
        // V88 -- whether a Subject must be chosen alongside this degree.
        // The admin form reads this to decide whether to show the picker.
        boolean requiresSubject,
        List<String> entranceExamSlugs,
        List<String> skillSlugs,
        List<String> resourceSlugs,
        // V101 -- the fields of study this qualification is offered in.
        // Empty for fused qualifications (MBBS) and for product rows not yet
        // converted; callers compose "B.Sc (Computer Science)" from the two
        // parts rather than reading a stored title.
        List<String> subjectSlugs,

        // --- V111.

        /** What the abbreviation stands for; null where `title` already is it. */
        String fullTitle,

        /**
         * Programme length in years, both bounds set and equal where fixed.
         * Null means the qualification is not a taught programme (the higher
         * doctorates), which is different from unknown.
         */
        java.math.BigDecimal durationMinYears,
        java.math.BigDecimal durationMaxYears,

        /** Composed server-side: "4 years", "3-5 years", or null. */
        String durationLabel
,

        /**
         * When this record last changed, or null for a row seeded before V115
         * added the column. Maintained by a database trigger, so it is accurate
         * whichever service did the writing. Read-only: the upsert requests do
         * not accept it.
         */
        java.time.Instant updatedAt
) {
}
