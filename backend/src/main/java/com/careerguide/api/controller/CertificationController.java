package com.careerguide.api.controller;

import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.service.CertificationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/certifications")
public class CertificationController {

    private final CertificationService certificationService;

    public CertificationController(CertificationService certificationService) {
        this.certificationService = certificationService;
    }

    /**
     * The full list, or just the records named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     */
    @GetMapping
    public List<CertificationDto> findAll(@RequestParam(required = false) String slugs) {
        return slugs == null
                ? certificationService.findAll()
                : certificationService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public CertificationDto findBySlug(@PathVariable String slug) {
        return certificationService.findBySlug(slug);
    }
}
