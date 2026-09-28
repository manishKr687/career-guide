package com.careerguide.api.dto;

import jakarta.validation.constraints.NotBlank;

/** Body for {@code PUT /api/admin/counselling-requests/{id}/status}. Value must be one of PENDING/CONTACTED/COMPLETED (see CounsellingRequest's constants). */
public record CounsellingStatusUpdateRequest(
        @NotBlank String status
) {
}
