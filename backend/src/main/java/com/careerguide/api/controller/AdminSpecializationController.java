package com.careerguide.api.controller;

import com.careerguide.api.dto.SpecializationDto;
import com.careerguide.api.dto.SpecializationUpsertRequest;
import com.careerguide.api.service.SpecializationService;
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
 * Write endpoints for specializations. Reads still go through the public
 * {@link SpecializationController} ({@code GET /api/specializations}), same
 * convention as {@link AdminSkillController}.
 */
@RestController
@RequestMapping("/api/admin/specializations")
public class AdminSpecializationController {

    private final SpecializationService specializationService;

    public AdminSpecializationController(SpecializationService specializationService) {
        this.specializationService = specializationService;
    }

    @PostMapping
    public ResponseEntity<SpecializationDto> create(@Valid @RequestBody SpecializationUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(specializationService.create(request));
    }

    @PutMapping("/{slug}")
    public SpecializationDto update(@PathVariable String slug, @Valid @RequestBody SpecializationUpsertRequest request) {
        return specializationService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        specializationService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
