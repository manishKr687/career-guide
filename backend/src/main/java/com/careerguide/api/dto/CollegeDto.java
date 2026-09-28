package com.careerguide.api.dto;

import java.util.List;

/**
 * Mirrors the frontend's {@code College} TypeScript interface (src/lib/types.ts).
 *
 * <p>{@code ownershipType}, {@code universitySlug}, {@code stateSlug},
 * {@code citySlug}, {@code website}, {@code status}, {@code degreeSlugs},
 * {@code specializationSlugs} and {@code disciplineSlugs} were added in V53
 * (College MVP). {@code disciplineSlugs} is read-only here -- it's the
 * inverse side of {@code Career.relatedCollegeSlugs} (same underlying
 * career_colleges table), written only through the Career admin form's
 * "Related Colleges" field, same as before V53. {@code universitySlug} and
 * {@code citySlug} are nullable; every other new field is required.
 *
 * <p>{@code careerOfferings} was added in V55 and is also read-only -- it
 * has no admin write path yet (the generic admin form framework has no
 * "list of pairs" field type), so new rows need a follow-up migration
 * against {@code college_career_degrees} until that lands.
 */
public record CollegeDto(
        String slug,
        String name,
        String location,
        String type,
        Integer established,
        List<String> tags,
        String description,
        List<String> examSlugs,
        String ownershipType,
        String universitySlug,
        String stateSlug,
        String citySlug,
        String website,
        String status,
        // V103 -- (degree, subject) pairs with a composed title, replacing
        // the flat slug list. 54 colleges award a PhD in Engineering, which
        // a bare degree slug could not express once the product row went.
        List<EducationDto> degreeOfferings,
        List<String> specializationSlugs,
        List<String> disciplineSlugs,
        List<CollegeCareerOfferingDto> careerOfferings,

        // --- V113. All three move together: a rank without the table it came
        // from is ambiguous, since NIRF publishes a dozen each year. Null for
        // all 90 today -- see the entity and V113's header.

        Integer nirfRank,
        String nirfCategory,
        Short nirfYear,

        /** Composed server-side: "NIRF 2024 · Engineering", or null. */
        String nirfLabel
) {
}
