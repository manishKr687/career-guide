package com.careerguide.api.controller;

import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.service.DegreeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/degrees")
public class DegreeController {

    private final DegreeService degreeService;

    public DegreeController(DegreeService degreeService) {
        this.degreeService = degreeService;
    }

    @GetMapping
    public List<DegreeDto> findAll() {
        return degreeService.findAll();
    }

    @GetMapping("/{slug}")
    public DegreeDto findBySlug(@PathVariable String slug) {
        return degreeService.findBySlug(slug);
    }
}
