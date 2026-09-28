package com.careerguide.api.dto;

import java.util.List;

/**
 * Mirrors the frontend's {@code Career} TypeScript interface (src/lib/types.ts).
 *
 * <p>Note: {@code entranceExams} is always returned as an empty list. It was
 * never migrated into the database because it is dead data in the frontend
 * itself — no page or component reads it, and it is redundant with
 * {@code relatedExamSlugs} in nearly every existing record. The field is kept
 * here only so this DTO stays a drop-in match for the frontend type.
 *
 * <p>{@code topRecruiters} and {@code salaryEntryLevel}/{@code salaryMidLevel}/
 * {@code salarySeniorLevel} (added in V13) were removed in V41: {@code
 * topRecruiters} had no admin write path since {@code relatedIndustrySlugs}
 * (V25) was added -- every career it ever covered was already backfilled
 * there -- and the salary breakdown was only ever populated for the 8
 * engineering careers added in V12, made redundant once Specialization got
 * its own, more precise, per-specialization breakdown (V40). Callers that
 * showed "Top Recruiters" now read {@code relatedIndustrySlugs} instead.
 *
 * <p>{@code relatedCollegeSlugs} was added in V13 and is only populated for
 * the same 8 engineering careers -- every other career returns an empty list.
 *
 * <p>{@code relatedSpecializationSlugs} was added in V16 and is only
 * populated for Aerospace Engineer -- every other career returns an empty
 * list.
 *
 * <p>{@code branchSlug} was added in V23 and is only populated for the 13
 * careers currently in Engineering & Technology -- every other career
 * returns null. {@code relatedSkillSlugs} (V24) and {@code relatedIndustrySlugs}
 * (V25) are populated for every career backfilled from its {@code skills} /
 * former {@code topRecruiters} arrays, but unlike every other {@code relatedXSlugs}
 * field above, their order is not meaningful (no {@code @OrderColumn} backs
 * them -- see the backend README).
 *
 * <p>{@code relatedJobRoleSlugs} was added in V26 and is only populated for
 * software-engineer (7 job roles) -- every other career returns an empty
 * list, since no source data exists yet for the other 55.
 *
 * <p>{@code education} started in V47 as a single nullable
 * {@code degreeSlug}, replaced in V51 with a real many-to-many relation
 * (career_degrees) -- see Career.education's javadoc and V51's
 * migration comment. Empty for any discipline where no degree in this
 * catalog is a clean, direct entry path.
 */
public record CareerDto(
        String slug,
        String title,
        String categorySlug,
        String tagline,
        String demand,
        List<String> entranceExams,
        String typicalWork,
        // Derived from the two numbers below (V107); not stored as the
        // source of truth. Null when either bound is unrecorded.
        String salaryRange,
        java.math.BigDecimal salaryMinLpa,
        java.math.BigDecimal salaryMaxLpa,
        List<String> growthPath,
        List<String> relatedExamSlugs,
        List<String> stageSlugs,
        String icon,
        String description,
        List<String> relatedCollegeSlugs,
        List<String> relatedSpecializationSlugs,
        String branchSlug,
        List<String> relatedSkillSlugs,
        List<String> relatedIndustrySlugs,
        List<String> relatedJobRoleSlugs,
        // V103 -- each entry is a (degree, subject) pair plus its composed
        // title. Replaces the flat slug list, which could say "B.A." but
        // never "B.A. (Psychology)". See EducationDto.
        List<EducationDto> education,

        // --- V110. The career page's own structure. A career is the parent
        // of its specializations, so this is the broad view -- progression,
        // pay by level, where the work happens -- while the specialization
        // page covers one focused area within it.

        /**
         * The progression ladder with experience attached. Supersedes
         * {@code growthPath} above, which stays only until nothing reads it.
         */
        List<GrowthStageDto> growthStages,

        /** Pay by experience level. Empty for all 42 -- see SalaryBandDto. */
        List<SalaryBandDto> salaryBands,

        /** Short claims about the career; empty where unwritten. */
        List<String> highlights,

        /** Work settings -- Product Companies, Research Labs, Remote. */
        List<String> workEnvironments,

        /** Typical years in the field. Null where unresearched. */
        Short experienceMinYears,
        Short experienceMaxYears,

        /** Open roles. Null where unresearched -- never a guessed figure. */
        Integer jobOpenings
) {
}
