package com.careerguide.api.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/degrees}. {@code slug} is
 * ignored on update (the path variable wins) but required on create --
 * same convention as every other upsert DTO in this package.
 * preparationStrategy is optional free text; a degree with no guidance
 * written yet just gets null. categorySlug is optional too (V71) -- a few
 * generic degrees (Certificate, Diploma, PhD) have no confident category.
 */
public record DegreeUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 160) String title,
        @NotBlank String description,
        @NotBlank @Size(max = 32) String icon,
        String preparationStrategy,
        @NotBlank @Pattern(regexp = "^(Undergraduate|Postgraduate|Diploma|Doctoral|Certificate)$", message = "must be one of Undergraduate, Postgraduate, Diploma, Doctoral, Certificate") String level,
        String categorySlug,
        // V88. Primitive boolean, so an omitted field defaults to false --
        // the safe direction: a degree wrongly marked as needing no subject
        // just doesn't offer the picker, whereas the reverse would demand a
        // subject for MBBS.
        boolean requiresSubject,
        List<String> entranceExamSlugs,
        List<String> skillSlugs,
        List<String> resourceSlugs,
        // V101. Only meaningful when requiresSubject is true.
        List<String> subjectSlugs,

        // V111. Null full title means `title` is already the full name.
        @Size(max = 200) String fullTitle,
        // Both or neither: null on both means the qualification is not a
        // taught programme, which the page renders as no duration at all.
        @DecimalMin("0.1") java.math.BigDecimal durationMinYears,
        @DecimalMin("0.1") java.math.BigDecimal durationMaxYears
) {
}
