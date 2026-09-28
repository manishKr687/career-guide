package com.careerguide.api.controller;

import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.service.CertificationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/certifications")
public class CertificationController {

    private final CertificationService certificationService;

    public CertificationController(CertificationService certificationService) {
        this.certificationService = certificationService;
    }

    @GetMapping
    public List<CertificationDto> findAll() {
        return certificationService.findAll();
    }

    @GetMapping("/{slug}")
    public CertificationDto findBySlug(@PathVariable String slug) {
        return certificationService.findBySlug(slug);
    }
}
