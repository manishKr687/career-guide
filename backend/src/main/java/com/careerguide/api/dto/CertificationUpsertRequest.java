package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/certifications}. {@code slug}
 * is ignored on update (the path variable wins) but required on create.
 * {@code description}/{@code provider}/{@code level}/{@code duration}/
 * {@code officialUrl} are optional, matching Certification.java's nullable
 * columns.
 */
public record CertificationUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 200) String name,
        String description,
        @Size(max = 160) String provider,
        @Size(max = 32) String level,
        @Size(max = 64) String duration,
        @Size(max = 500) String officialUrl,
        List<String> relatedCareerSlugs,
        List<String> relatedSkillSlugs
) {
}
