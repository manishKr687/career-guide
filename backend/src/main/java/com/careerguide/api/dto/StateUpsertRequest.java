package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Request body for {@code POST/PUT /api/admin/states}. Added in V53 (College MVP). */
public record StateUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String slug,
        @NotBlank @Size(max = 128) String name,
        @NotBlank @Size(max = 8) String code
) {
}
