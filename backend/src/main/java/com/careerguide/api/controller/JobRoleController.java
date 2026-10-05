package com.careerguide.api.controller;

import com.careerguide.api.dto.JobRoleDto;
import com.careerguide.api.service.JobRoleService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * The real Job Role entity (V26) -- see the Data Model Roadmap doc's
 * "Spec v1.0 Match" / "ER Data Model Match" tabs. Now owns {@code /api/job-roles}
 * outright: {@link CareerController}'s Phase 4 alias at that same path (which
 * re-served Career data under this name) has been retired in favour of this.
 *
 * @param career optional career slug filter (e.g. "software-engineer")
 */
@RestController
@RequestMapping("/api/job-roles")
public class JobRoleController {

    private final JobRoleService jobRoleService;

    public JobRoleController(JobRoleService jobRoleService) {
        this.jobRoleService = jobRoleService;
    }

    /**
     * The full list, optionally filtered by {@code career}, or just the records
     * named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     *
     * <p>{@code slugs} takes precedence over {@code career} and ignores it: the
     * caller has named the exact records it wants, so narrowing them further
     * would silently return fewer than asked for. Sending both is a caller
     * mistake rather than a meaningful query, and answering the explicit part is
     * the less surprising of the two readings.
     */
    @GetMapping
    public List<JobRoleDto> findAll(
            @RequestParam(required = false) String career,
            @RequestParam(required = false) String slugs) {
        return slugs == null
                ? jobRoleService.findAll(career)
                : jobRoleService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public JobRoleDto findBySlug(@PathVariable String slug) {
        return jobRoleService.findBySlug(slug);
    }
}
