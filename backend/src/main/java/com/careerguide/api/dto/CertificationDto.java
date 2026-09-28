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
