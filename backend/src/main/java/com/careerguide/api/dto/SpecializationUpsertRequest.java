package com.careerguide.api.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/specializations}. {@code slug}
 * is ignored on update (the path variable wins) but required on create --
 * same convention as every other upsert DTO in this package. The salary
 * fields are optional (null for a specialization with no salary breakdown),
 * Salary fields were dropped in V107 -- see Specialization.java.
 */
public record SpecializationUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 160) String name,
        @NotBlank String description,
        @NotBlank @Size(max = 32) String icon,
        List<String> relatedExamSlugs,
        List<String> careerSlugs,
        /**
         * Which of {@code careerSlugs} is the canonical parent (V117). Optional
         * in the request: when omitted, the service keeps the existing primary
         * if it is still among the requested careers, otherwise it takes the
         * first. Must be one of {@code careerSlugs} when given.
         */
        String primaryCareerSlug,
        List<String> relatedJobRoleSlugs,
        List<String> relatedHardSkillSlugs,
        List<String> relatedSoftSkillSlugs,
        List<String> responsibilities,
        @Size(max = 16) String demand,
        List<String> certificationSlugs,
        List<String> industrySlugs,

        // --- V108.

        // "What you will learn" -- what the field covers. Null or blank leaves
        // it unset rather than storing an empty string, so "not written yet"
        // stays distinguishable from "deliberately blank".
        String overview,

        // Short claims about the field. Null/empty clears the list.
        List<String> highlights,

        // The education routes into this specialization, in display order.
        // Each is a (degree, subject) pair; subjectSlug may be null for a
        // qualification that names its own field. Null/empty clears the list.
        // The `title` field of EducationDto is ignored on write -- it is
        // derived on read.
        @Valid List<EducationDto> education,

        // Reading material. Null/empty clears the list.
        List<String> resourceSlugs,

        // V110. Null leaves the specialization without its own figure, and
        // the page then shows the parent career's range, labelled as such.
        @DecimalMin("0.1") java.math.BigDecimal salaryMinLpa,
        @DecimalMin("0.1") java.math.BigDecimal salaryMaxLpa

        // collegeSlugs is deliberately absent: college_specializations is
        // owned by College, exactly as career_specializations is owned by
        // Career. It is read-only on this DTO and edited from the college.
) {
}
