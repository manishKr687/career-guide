package com.careerguide.api.dto;

/** Added in V25 -- see Industry.java and the Data Model Roadmap doc's Phase 2. */
public record IndustryDto(
        String slug,
        String name,
        boolean isSector
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
