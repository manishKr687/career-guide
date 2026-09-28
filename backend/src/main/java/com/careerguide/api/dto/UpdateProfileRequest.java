package com.careerguide.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

/**
 * Full-replace update, same convention as the rest of this API's admin
 * write endpoints -- any field left null clears that column (e.g. a user
 * un-picking their stream) rather than being treated as "leave unchanged".
 *
 * <p>{@code educationStageSlug}/{@code streamSlug} aren't validated for
 * format here because {@link com.careerguide.api.service.UserService}
 * already resolves each against its repository and throws
 * {@link com.careerguide.api.web.NotFoundException} for an unknown slug --
 * the same de facto FK check the admin upsert endpoints do inline.
 */
public record UpdateProfileRequest(
        String educationStageSlug,
        String streamSlug,
        @Size(max = 64) String educationLevel,
        @Min(1950) @Max(2100) Integer graduationYear,
        @Min(0) @Max(60) Integer experienceYears,
        @Size(max = 160) String location
) {
}
