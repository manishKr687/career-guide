package com.careerguide.api.dto;

import java.time.Instant;
import java.util.List;

/**
 * One item's line as the admin page shows it.
 *
 * @param custom    true when an admin line replaces the automatic one
 * @param version   the admin line's version; null while automatic
 * @param users     how many people have this item as their goal now
 * @param stations  the line users get today (the admin's, or the automatic one)
 * @param automatic the line the catalogue would build, for "Reset to automatic" and as a starting point
 */
public record AdminGoalLineDto(
        String type,
        String slug,
        String name,
        boolean custom,
        Integer version,
        Instant updatedAt,
        long users,
        List<GoalLineStationDto> stations,
        List<GoalLineStationDto> automatic
) {
}
