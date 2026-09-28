package com.careerguide.api.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/colleges}.
 *
 * <p>{@code universitySlug} and {@code citySlug} are optional (most
 * colleges have neither a separate parent university nor a catalog city
 * yet -- see V53's migration comment); {@code stateSlug} is required, same
 * as every other new V53 field. {@code disciplineSlugs} is deliberately
 * NOT here -- see CollegeDto's javadoc on why that relation is read-only
 * from this side.
 *
 * <p>{@code careerOfferings} (added alongside the admin write path for
 * {@code college_career_degrees}) is independent of {@code degreeSlugs}
 * and {@code disciplineSlugs} -- editing one does not touch the others,
 * see CollegeService.syncCareerOfferings.
 */
public record CollegeUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 200) String name,
        @NotBlank @Size(max = 200) String location,
        @NotBlank @Size(max = 32) String type,
        @NotNull Integer established,
        List<String> tags,
        @NotBlank String description,
        List<String> examSlugs,
        @NotBlank @Size(max = 32) String ownershipType,
        String universitySlug,
        @NotBlank String stateSlug,
        String citySlug,
        @Size(max = 255) String website,
        @NotBlank @Size(max = 16) String status,
        // V103 -- (degree, subject) pairs rather than bare degree slugs, so a
        // college can award M.Tech in several branches. `title` is ignored on
        // write; it is derived on read.
        @Valid List<EducationDto> degreeOfferings,
        List<String> specializationSlugs,
        @Valid List<CollegeCareerOfferingDto> careerOfferings,

        // V113. Supply all three or none -- a rank with no table and no year
        // cannot be rendered honestly, and the DB CHECK rejects the pair.
        @Min(1) Integer nirfRank,
        @Size(max = 32) String nirfCategory,
        @Min(2016) Short nirfYear
) {
}
