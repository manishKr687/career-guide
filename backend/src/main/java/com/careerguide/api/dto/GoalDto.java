package com.careerguide.api.dto;

import java.util.List;

/**
 * A user's goal and what the catalogue says about it.
 *
 * @param type            career, exam, college, degree, job_role, company, sector or certification
 * @param facts           short real facts for the chips ("NTA", "4 years", "₹4–30 LPA")
 * @param targetMonth     "YYYY-MM", or null when no date is set
 * @param focusMode       "skills" when the catalogue lists skills to pick from,
 *                        "own" when the user types their own subjects or topics
 * @param suggestedSkills the catalogue skills to pick focus items from (empty in "own" mode)
 * @param logTargets      what a log entry can be for besides a focus item -- the
 *                        goal's exams, "Mock test", "Portfolio project"
 * @param mockTarget      the log target that carries a score, or null
 * @param mockMax         that score's maximum: 300 for a JEE Main mock, 100 otherwise
 */
public record GoalDto(
        String type,
        String slug,
        String name,
        List<String> facts,
        String targetMonth,
        String focusMode,
        List<GoalSkillDto> suggestedSkills,
        List<String> logTargets,
        String mockTarget,
        Integer mockMax
) {
}
