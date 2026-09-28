package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Request body for {@code POST/PUT /api/admin/industries}. {@code slug} is
 * ignored on update (the path variable wins) but required on create --
 * same convention as every other upsert DTO in this package.
 */
public record IndustryUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 160) String name,
        boolean isSector
) {
}
