package com.careerguide.api.controller;

import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.service.IndustryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/industries")
public class IndustryController {

    private final IndustryService industryService;

    public IndustryController(IndustryService industryService) {
        this.industryService = industryService;
    }

    @GetMapping
    public List<IndustryDto> findAll() {
        return industryService.findAll();
    }

    @GetMapping("/{slug}")
    public IndustryDto findBySlug(@PathVariable String slug) {
        return industryService.findBySlug(slug);
    }
}
