package com.careerguide.api.dto;

import java.time.LocalDate;
import java.util.List;

/** Added in V28 -- see Resource.java and the Data Model Roadmap doc. */
public record ResourceDto(
        String slug,
        String title,
        String resourceType,
        String description,
        String contentUrl,
        String author,
        LocalDate publishedAt,
        List<String> relatedCareerSlugs,
        List<String> relatedExamSlugs,
        List<String> relatedSkillSlugs
) {
}
