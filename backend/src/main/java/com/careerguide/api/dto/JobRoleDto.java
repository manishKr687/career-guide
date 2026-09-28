package com.careerguide.api.dto;

import java.util.List;

/** Added in V26 -- see JobRole.java and the Data Model Roadmap doc. */
public record JobRoleDto(
        String slug,
        String name,
        String description,
        String experienceLevel,
        String salaryMin,
        String salaryMax,
        List<String> careerSlugs,
        List<String> relatedSkillSlugs,
        List<String> relatedIndustrySlugs,
        List<String> relatedCertificationSlugs,
        // Read-only, same convention as CollegeDto.disciplineSlugs -- Exam
        // owns this relation (Exam.relatedJobRoles), edited only from the
        // Exam admin form's jobRoleSlugs field.
        List<String> relatedExamSlugs,

        // --- V107's numbers, finally exposed.
        //
        // The migration converted job_roles' salary to NUMERIC and backfilled
        // 247 of 255 rows, but this DTO was never updated -- so the API kept
        // returning only the "5 LPA" / "25 LPA" strings and nothing could
        // sort or filter on pay. The strings stay for now (they are what the
        // admin form still edits); these are the ones to read.

        java.math.BigDecimal salaryMinLpa,
        java.math.BigDecimal salaryMaxLpa,

        /** Composed by SalaryRange, exactly as CareerDto does it, so a career
         *  and a job role can never write the same figure two ways. */
        String salaryRange
) {
}
