package com.careerguide.api.controller;

import com.careerguide.api.dto.SpecializationDto;
import com.careerguide.api.service.SpecializationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/specializations")
public class SpecializationController {

    private final SpecializationService specializationService;

    public SpecializationController(SpecializationService specializationService) {
        this.specializationService = specializationService;
    }

    /**
     * The full list, or just the records named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     */
    @GetMapping
    public List<SpecializationDto> findAll(@RequestParam(required = false) String slugs) {
        return slugs == null
                ? specializationService.findAll()
                : specializationService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public SpecializationDto findBySlug(@PathVariable String slug) {
        return specializationService.findBySlug(slug);
    }
}
