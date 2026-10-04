package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Request body for {@code POST/PUT /api/admin/universities}. Added in V53 (College MVP). */
public record UniversityUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 200) String name,
        @NotBlank @Size(max = 32) String universityType,
        @NotBlank @Size(max = 32) String ownershipType,
        String stateSlug,
        String citySlug,
        @Size(max = 255) String website,
        @NotBlank @Size(max = 16) String status
) {
}
