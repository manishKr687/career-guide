package com.careerguide.api.dto;

import java.time.LocalDate;

/** One scored log entry, for the mock-score chart. */
public record MockScoreDto(LocalDate loggedOn, int score, int scoreMax) {
}
