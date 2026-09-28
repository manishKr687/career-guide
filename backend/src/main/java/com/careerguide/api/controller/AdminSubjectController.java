package com.careerguide.api.controller;

import com.careerguide.api.dto.SubjectDto;
import com.careerguide.api.dto.SubjectUpsertRequest;
import com.careerguide.api.service.SubjectService;
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
 * Write endpoints for subjects. Reads still go through the public
 * {@link SubjectController} ({@code GET /api/subjects}), same convention as
 * {@link AdminIndustryController}.
 */
@RestController
@RequestMapping("/api/admin/subjects")
public class AdminSubjectController {

    private final SubjectService subjectService;

    public AdminSubjectController(SubjectService subjectService) {
        this.subjectService = subjectService;
    }

    @PostMapping
    public ResponseEntity<SubjectDto> create(@Valid @RequestBody SubjectUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(subjectService.create(request));
    }

    @PutMapping("/{slug}")
    public SubjectDto update(@PathVariable String slug, @Valid @RequestBody SubjectUpsertRequest request) {
        return subjectService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        subjectService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
