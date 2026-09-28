package com.careerguide.api.dto;

/** Added in V24 -- see Skill.java and the Data Model Roadmap doc's Phase 2. */
public record SkillDto(
        String slug,
        String name,
        String skillType,

        // --- V114.

        /** Soft / Programming / Tools / Analytical / Domain. Derived by rule
         *  from the name, unlike `skillType`, which is free text an editor
         *  typed and which is null for 93% of the catalog. */
        String category,

        /** Null for every skill today -- see Skill.java. */
        String description
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
