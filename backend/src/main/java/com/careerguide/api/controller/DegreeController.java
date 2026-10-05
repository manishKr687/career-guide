package com.careerguide.api.controller;

import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.service.DegreeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/degrees")
public class DegreeController {

    private final DegreeService degreeService;

    public DegreeController(DegreeService degreeService) {
        this.degreeService = degreeService;
    }

    /**
     * The full list, or just the records named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     */
    @GetMapping
    public List<DegreeDto> findAll(@RequestParam(required = false) String slugs) {
        return slugs == null
                ? degreeService.findAll()
                : degreeService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public DegreeDto findBySlug(@PathVariable String slug) {
        return degreeService.findBySlug(slug);
    }
}
