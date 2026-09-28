package com.careerguide.api.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Request body for {@code POST/PUT /api/admin/careers}. {@code slug} is
 * ignored on update (the path variable wins) but required on create, since
 * it's the primary key. {@code sortOrder} is optional -- when omitted, the
 * service assigns "one after the current highest in this category" so
 * newly-added careers still sort sensibly without the admin having to know
 * the existing values.
 *
 * <p>{@code relatedSkillSlugs}/{@code relatedIndustrySlugs}/
 * {@code relatedCollegeSlugs}/{@code relatedSpecializationSlugs}/
 * {@code relatedJobRoleSlugs}/{@code relatedDegreeSlugs} were added so the
 * admin career form can edit the relationships CareerDto already returns
 * on read (see its javadoc) -- until now there was no write path for any
 * of them at all, even though the Career entity has had live setters for
 * every one of these since they were first added (V16/V24/V25/V26/V51).
 */
public record CareerUpsertRequest(
        @NotBlank @Size(max = 64) @Pattern(regexp = "^[a-z0-9]+(-[a-z0-9]+)*$", message = "must be lowercase letters, numbers and hyphens only") String slug,
        @NotBlank @Size(max = 160) String title,
        @NotBlank String categorySlug,
        @NotBlank @Size(max = 255) String tagline,
        @NotBlank @Size(max = 32) String demand,
        @NotBlank String typicalWork,
        // Salary is entered as NUMBERS since V107; the display string is
        // composed by the server. Accepting the string here would make it
        // possible to save a range whose text and numbers disagree.
        @jakarta.validation.constraints.DecimalMin("0.1") java.math.BigDecimal salaryMinLpa,
        @jakarta.validation.constraints.DecimalMin("0.1") java.math.BigDecimal salaryMaxLpa,
        List<String> growthPath,
        List<String> relatedExamSlugs,
        List<String> stageSlugs,
        @NotBlank @Size(max = 32) String icon,
        @NotBlank String description,
        Integer sortOrder,
        List<String> relatedSkillSlugs,
        List<String> relatedIndustrySlugs,
        List<String> relatedCollegeSlugs,
        List<String> relatedSpecializationSlugs,
        List<String> relatedJobRoleSlugs,
        // The education routes into this career, in display order. Each is a
        // (degree, subject) pair; subjectSlug may be null for a fused
        // qualification. Null/empty clears the list. The `title` field of
        // EducationDto is ignored on write -- it is derived on read.
        @Valid List<EducationDto> education,

        // --- V110. Null/empty clears each list, same as every other
        // collection on this request.

        // The progression ladder. Supersedes growthPath above; both are
        // accepted while growthPath still exists.
        @Valid List<GrowthStageDto> growthStages,

        // Pay by experience level. The `label` on each DTO is ignored on
        // write -- it is derived on read.
        @Valid List<SalaryBandDto> salaryBands,

        List<String> highlights,
        List<String> workEnvironments,

        // Null means unresearched, which is different from zero and is how
        // all 42 careers ship. The page omits the metric rather than
        // rendering a placeholder.
        @Min(0) Short experienceMinYears,
        @Min(0) Short experienceMaxYears,
        @Min(1) Integer jobOpenings
) {
}
