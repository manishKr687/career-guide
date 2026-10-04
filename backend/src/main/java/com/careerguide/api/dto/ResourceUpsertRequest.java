package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/resources}. {@code slug} is
 * ignored on update (the path variable wins) but required on create.
 * {@code resourceType} is a free-text field rather than a fixed enum --
 * unlike Career's "demand" or Course's "level", the site has no seeded
 * resources yet and so no established set of types to lock the admin into.
 */
public record ResourceUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 300) String title,
        @NotBlank @Size(max = 32) String resourceType,
        String description,
        @Size(max = 500) String contentUrl,
        @Size(max = 160) String author,
        LocalDate publishedAt,
        List<String> relatedCareerSlugs,
        List<String> relatedExamSlugs,
        List<String> relatedSkillSlugs
) {
}
