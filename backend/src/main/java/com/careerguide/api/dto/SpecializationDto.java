package com.careerguide.api.dto;

import java.util.List;

/** Mirrors the frontend's {@code Specialization} TypeScript interface (src/lib/types.ts). */
public record SpecializationDto(
        String slug,
        String name,
        String description,
        String icon,
        List<String> relatedExamSlugs,
        List<String> careerSlugs,

        /**
         * The canonical parent among {@code careerSlugs} (V117). A
         * specialization may legitimately sit under more than one career --
         * Cloud Computing under both CSE and IT -- so consumers that need
         * exactly one parent (the breadcrumb, the borrowed-data fallback) read
         * this instead of taking {@code careerSlugs[0]}, which was whichever
         * career happened to come back first. Guaranteed non-null and
         * guaranteed present in {@code careerSlugs}.
         */
        String primaryCareerSlug,
        List<String> relatedJobRoleSlugs,
        List<String> relatedHardSkillSlugs,
        List<String> relatedSoftSkillSlugs,
        List<String> responsibilities,
        String demand,
        List<String> certificationSlugs,
        List<String> industrySlugs,

        // --- V108. Everything below describes the FIELD, so the same page can
        // render any specialization without knowing which one it is.

        /** What the field covers ("what you will learn"); null where unwritten. */
        String overview,

        /** Short claims about the field; empty where unwritten. */
        List<String> highlights,

        /** Education routes in -- a degree plus the subject it is taken in. */
        List<EducationDto> education,

        /**
         * Colleges that teach this specialization. The read-only reverse of
         * College.specializations -- writes go through the college, not here.
         */
        List<String> collegeSlugs,

        /** Reading material for this field. */
        List<String> resourceSlugs,

        // --- V110.

        /**
         * What this specialization pays, where anyone has researched it.
         * Null for all 263 today; the page falls back to the parent career's
         * range under a label naming whose range it is, rather than passing
         * the career's figure off as the specialization's.
         */
        java.math.BigDecimal salaryMinLpa,
        java.math.BigDecimal salaryMaxLpa,

        /** Derived from the two numbers above; null when they are. */
        String salaryRange
) {
}
