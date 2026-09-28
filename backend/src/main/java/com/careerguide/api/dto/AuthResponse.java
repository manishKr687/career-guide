package com.careerguide.api.dto;

public record AuthResponse(
        String token,
        UserDto user
) {
}
