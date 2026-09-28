package com.careerguide.api.controller;

import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.dto.DegreeUpsertRequest;
import com.careerguide.api.service.DegreeService;
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
 * Write endpoints for degrees. Reads still go through the public
 * {@link DegreeController} ({@code GET /api/degrees}), same convention as
 * {@link AdminSpecializationController}.
 */
@RestController
@RequestMapping("/api/admin/degrees")
public class AdminDegreeController {

    private final DegreeService degreeService;

    public AdminDegreeController(DegreeService degreeService) {
        this.degreeService = degreeService;
    }

    @PostMapping
    public ResponseEntity<DegreeDto> create(@Valid @RequestBody DegreeUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(degreeService.create(request));
    }

    @PutMapping("/{slug}")
    public DegreeDto update(@PathVariable String slug, @Valid @RequestBody DegreeUpsertRequest request) {
        return degreeService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        degreeService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
