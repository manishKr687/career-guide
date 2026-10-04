package com.careerguide.api.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/** Request body for {@code POST/PUT /api/admin/exams}. */
public record ExamUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 160) String name,
        @NotBlank @Size(max = 255) String fullName,
        @NotBlank @Size(max = 64) String category,
        @NotBlank @Size(max = 255) String conductedBy,
        @NotBlank @Size(max = 128) String frequency,
        @NotBlank String description,
        @NotBlank @Size(max = 32) String icon,
        List<String> relatedCareerSlugs,
        @Size(max = 32) String mode,
        String eligibilityMinQualification,
        @Size(max = 255) String officialWebsite,
        String syllabusOverview,
        @Valid List<ExamCareerDegreeDto> careerDegreeOfferings,
        @NotBlank @Size(max = 32) String examType,
        List<String> jobRoleSlugs,

        // V112. Null category means the exam spans every field (CUET, NTSE).
        @Size(max = 64) String categorySlug,
        @NotBlank @Size(max = 24) String level,
        @NotBlank @Size(max = 24) String frequencyType
) {
}
