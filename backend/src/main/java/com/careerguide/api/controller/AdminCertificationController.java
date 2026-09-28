package com.careerguide.api.controller;

import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.dto.CertificationUpsertRequest;
import com.careerguide.api.service.CertificationService;
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
 * Write endpoints for certifications. Reads still go through the public
 * {@link CertificationController} ({@code GET /api/certifications}), same
 * convention as {@link AdminSkillController}.
 */
@RestController
@RequestMapping("/api/admin/certifications")
public class AdminCertificationController {

    private final CertificationService certificationService;

    public AdminCertificationController(CertificationService certificationService) {
        this.certificationService = certificationService;
    }

    @PostMapping
    public ResponseEntity<CertificationDto> create(@Valid @RequestBody CertificationUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(certificationService.create(request));
    }

    @PutMapping("/{slug}")
    public CertificationDto update(@PathVariable String slug, @Valid @RequestBody CertificationUpsertRequest request) {
        return certificationService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        certificationService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
