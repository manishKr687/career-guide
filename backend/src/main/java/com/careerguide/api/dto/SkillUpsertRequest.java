package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Request body for {@code POST/PUT /api/admin/skills}. {@code slug} is
 * ignored on update (the path variable wins) but required on create, since
 * it's the primary key -- same convention as {@link CareerUpsertRequest}.
 * {@code skillType} is optional: many pre-existing skills were seeded
 * without one (see Skill.java's javadoc) and there's nothing wrong with
 * leaving a new one uncategorized either.
 *
 * <p>Before this DTO existed, {@code skills} rows could only be created or
 * edited via a Flyway migration (e.g. V24/V34) -- there was no admin write
 * path for Skill Management at all, even though skills are referenced from
 * careers, job roles, certifications, resources and user profiles.
 */
public record SkillUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 160) String name,
        @Size(max = 50) String skillType,

        // V114. Required, unlike skillType: the listing filters on it, and a
        // skill with no category would be unreachable by browsing.
        @NotBlank @Size(max = 24) String category,
        String description
) {
}
