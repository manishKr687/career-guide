package com.careerguide.api.controller;

import com.careerguide.api.dto.ResourceDto;
import com.careerguide.api.service.ResourceService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/resources")
public class ResourceController {

    private final ResourceService resourceService;

    public ResourceController(ResourceService resourceService) {
        this.resourceService = resourceService;
    }

    @GetMapping
    public List<ResourceDto> findAll() {
        return resourceService.findAll();
    }

    @GetMapping("/{slug}")
    public ResourceDto findBySlug(@PathVariable String slug) {
        return resourceService.findBySlug(slug);
    }
}
