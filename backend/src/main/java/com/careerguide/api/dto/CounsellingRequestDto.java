package com.careerguide.api.dto;

import java.time.Instant;
import java.time.LocalDate;

/** Admin-facing view of a submitted counselling request (GET /api/admin/counselling-requests). */
public record CounsellingRequestDto(
        Long id,
        String name,
        String email,
        String phone,
        LocalDate preferredDate,
        String preferredTime,
        String stageSlug,
        String careerSlug,
        String message,
        String status,
        Instant createdAt
) {
}
