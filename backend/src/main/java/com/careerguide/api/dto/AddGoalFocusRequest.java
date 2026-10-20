package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Adds a focus item: a catalogue skill (send its {@code skillSlug}) or the
 * user's own subject or topic ({@code skillSlug} null). Six at most.
 */
public record AddGoalFocusRequest(
        @NotBlank @Size(max = 60) String name,
        @Size(max = 64) @Pattern(regexp = Slugs.PATTERN, message = Slugs.MESSAGE) String skillSlug
) {
}
