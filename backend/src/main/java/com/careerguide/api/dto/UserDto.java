package com.careerguide.api.dto;

import java.time.Instant;
import java.util.List;

public record UserDto(
        Long id,
        String email,
        String name,
        Instant createdAt,
        List<String> interests
) {
}
