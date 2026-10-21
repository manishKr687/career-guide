package com.careerguide.api.dto;

import java.time.Instant;

/** A row in the admin's list of customised lines. {@code name} reads "(removed)" when the item has left the catalogue. */
public record GoalLineSummaryDto(
        String type,
        String slug,
        String name,
        int stations,
        int version,
        Instant updatedAt,
        long users
) {
}
