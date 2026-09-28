package com.careerguide.api.controller;

import com.careerguide.api.dto.SpecializationDto;
import com.careerguide.api.service.SpecializationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/specializations")
public class SpecializationController {

    private final SpecializationService specializationService;

    public SpecializationController(SpecializationService specializationService) {
        this.specializationService = specializationService;
    }

    @GetMapping
    public List<SpecializationDto> findAll() {
        return specializationService.findAll();
    }

    @GetMapping("/{slug}")
    public SpecializationDto findBySlug(@PathVariable String slug) {
        return specializationService.findBySlug(slug);
    }
}
