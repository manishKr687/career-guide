package com.careerguide.api.dto;

import java.util.List;

/** Added in V27 -- see Certification.java and the Data Model Roadmap doc. */
public record CertificationDto(
        String slug,
        String name,
        String description,
        String provider,
        String level,
        String duration,
        String officialUrl,
        List<String> relatedCareerSlugs,
        List<String> relatedSkillSlugs
) {
}
