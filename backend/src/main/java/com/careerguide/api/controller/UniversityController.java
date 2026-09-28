package com.careerguide.api.controller;

import com.careerguide.api.dto.UniversityDto;
import com.careerguide.api.service.UniversityService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Added in V53 (College MVP). Small, unpaged reference data -- same shape as CategoryController. */
@RestController
@RequestMapping("/api/universities")
public class UniversityController {

    private final UniversityService universityService;

    public UniversityController(UniversityService universityService) {
        this.universityService = universityService;
    }

    @GetMapping
    public List<UniversityDto> findAll() {
        return universityService.findAll();
    }

    @GetMapping("/{slug}")
    public UniversityDto findBySlug(@PathVariable String slug) {
        return universityService.findBySlug(slug);
    }
}
