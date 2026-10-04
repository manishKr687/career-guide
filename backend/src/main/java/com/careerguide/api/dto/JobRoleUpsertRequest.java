package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/job-roles}. {@code slug} is
 * ignored on update (the path variable wins) but required on create.
 * {@code description}/{@code experienceLevel}/{@code salaryMin}/
 * {@code salaryMax} are optional, matching JobRole.java's nullable columns.
 */
public record JobRoleUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 160) String name,
        String description,
        @Size(max = 32) String experienceLevel,
        @Size(max = 64) String salaryMin,
        @Size(max = 64) String salaryMax,
        List<String> careerSlugs,
        List<String> relatedSkillSlugs,
        List<String> relatedIndustrySlugs,
        List<String> relatedCertificationSlugs
) {
}
