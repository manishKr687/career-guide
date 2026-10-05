package com.careerguide.api.controller;

import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.service.IndustryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/industries")
public class IndustryController {

    private final IndustryService industryService;

    public IndustryController(IndustryService industryService) {
        this.industryService = industryService;
    }

    /**
     * The full list, or just the records named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     */
    @GetMapping
    public List<IndustryDto> findAll(@RequestParam(required = false) String slugs) {
        return slugs == null
                ? industryService.findAll()
                : industryService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public IndustryDto findBySlug(@PathVariable String slug) {
        return industryService.findBySlug(slug);
    }
}
