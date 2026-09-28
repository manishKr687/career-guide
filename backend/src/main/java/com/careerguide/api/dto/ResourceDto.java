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
,

        /**
         * When this record last changed, or null for a row seeded before V115
         * added the column. Maintained by a database trigger, so it is accurate
         * whichever service did the writing. Read-only: the upsert requests do
         * not accept it.
         */
        java.time.Instant updatedAt
) {
}
