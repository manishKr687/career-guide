package com.careerguide.api.dto;

import java.util.Set;

public record UpdateInterestsRequest(
        Set<String> interests
) {
}
