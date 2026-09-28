package com.careerguide.api.dto;

import java.util.List;

/**
 * Mirrors the frontend's {@code Exam} TypeScript interface (src/lib/types.ts).
 *
 * <p>{@code mode}, {@code eligibilityMinQualification}, {@code officialWebsite}
 * and {@code syllabusOverview} were added in V66 and are all nullable (not
 * backfilled for the pre-existing catalog). {@code careerDegreeOfferings}
 * was added alongside them -- see {@code ExamCareerDegree}'s javadoc.
 *
 * <p>{@code examType} (V68) is orthogonal to {@code category} -- see
 * that migration's comment. {@code jobRoleSlugs} is the Recruitment-side
 * counterpart to {@code careerDegreeOfferings}'s Admission-side pairing;
 * see {@code Exam.relatedJobRoles}'s javadoc.
 */
public record ExamDto(
        String slug,
        String name,
        String fullName,
        String category,
        String conductedBy,
        String frequency,
        String description,
        List<String> careerSlugs,
        String icon,
        List<String> collegeSlugs,
        String mode,
        String eligibilityMinQualification,
        String officialWebsite,
        String syllabusOverview,
        List<ExamCareerDegreeDto> careerDegreeOfferings,
        String examType,
        List<String> jobRoleSlugs,

        // --- V112.

        /**
         * The FIELD this exam belongs to, as a slug from the shared
         * `categories` taxonomy. Distinct from `category`, which is free
         * text holding the stage axis ("After 12th"). Null for CUET and
         * NTSE, which genuinely span every field.
         */
        String categorySlug,

        /** What the exam gets you: Undergraduate, Recruitment, Research... */
        String level,

        /** `frequency` normalised to a filterable bucket. */
        String frequencyType
) {
}
