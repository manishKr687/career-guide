package com.careerguide.api.controller;

import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.dto.IndustryUpsertRequest;
import com.careerguide.api.service.IndustryService;
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
 * Write endpoints for industries. Reads still go through the public
 * {@link IndustryController} ({@code GET /api/industries}), same convention
 * as {@link AdminSkillController}.
 */
@RestController
@RequestMapping("/api/admin/industries")
public class AdminIndustryController {

    private final IndustryService industryService;

    public AdminIndustryController(IndustryService industryService) {
        this.industryService = industryService;
    }

    @PostMapping
    public ResponseEntity<IndustryDto> create(@Valid @RequestBody IndustryUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(industryService.create(request));
    }

    @PutMapping("/{slug}")
    public IndustryDto update(@PathVariable String slug, @Valid @RequestBody IndustryUpsertRequest request) {
        return industryService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        industryService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
