package com.careerguide.api.dto;

import java.time.LocalDate;

/** One learning-log line. {@code score} and {@code scoreMax} are both set or both null. */
public record LearningLogEntryDto(
        Long id,
        LocalDate loggedOn,
        String note,
        String target,
        int minutes,
        Integer score,
        Integer scoreMax
) {
}
