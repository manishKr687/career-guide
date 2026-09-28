package com.careerguide.api.controller;

import com.careerguide.api.dto.JobRoleDto;
import com.careerguide.api.dto.JobRoleUpsertRequest;
import com.careerguide.api.service.JobRoleService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Write endpoints for job roles. Reads still go through the public
 * {@link JobRoleController} ({@code GET /api/job-roles}), same convention
 * as {@link AdminSkillController}.
 */
@RestController
@RequestMapping("/api/admin/job-roles")
public class AdminJobRoleController {

    private final JobRoleService jobRoleService;

    public AdminJobRoleController(JobRoleService jobRoleService) {
        this.jobRoleService = jobRoleService;
    }

    @PostMapping
    public ResponseEntity<JobRoleDto> create(@Valid @RequestBody JobRoleUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(jobRoleService.create(request));
    }

    @PutMapping("/{slug}")
    public JobRoleDto update(@PathVariable String slug, @Valid @RequestBody JobRoleUpsertRequest request) {
        return jobRoleService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        jobRoleService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
