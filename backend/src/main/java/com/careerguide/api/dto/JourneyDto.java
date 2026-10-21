package com.careerguide.api.dto;

import java.util.List;

/**
 * Everything the My Career page shows, in one response, so the page loads in
 * a single request.
 *
 * @param goal         null until the user sets one
 * @param minutesByDay minutes logged per day for the last 84 days, index 0 = today (IST)
 * @param streak       consecutive days with something logged, ending today -- or
 *                     yesterday, so the streak does not read 0 every morning
 * @param readiness    0-100: half from stations passed, half from focus levels
 * @param lineUpdated  the goal's line has changed since this user's copy was made
 *                     (an admin edited it, or reset it to the automatic one)
 */
public record JourneyDto(
        GoalDto goal,
        List<GoalStationDto> stations,
        List<GoalFocusDto> focus,
        List<LearningLogEntryDto> recent,
        List<Integer> minutesByDay,
        int streak,
        int weekMinutes,
        int readiness,
        List<MockScoreDto> mocks,
        boolean lineUpdated
) {
}
