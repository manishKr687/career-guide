package com.careerguide.api.dto;

/**
 * A focus item: a catalogue skill ({@code skillSlug} set) or the user's own
 * subject or topic. {@code level}: 0 not started, 1 learning, 2 comfortable,
 * 3 confident. {@code minutesLogged} counts log entries made for it.
 */
public record GoalFocusDto(
        Long id,
        String name,
        String skillSlug,
        int level,
        int minutesLogged
) {
}
