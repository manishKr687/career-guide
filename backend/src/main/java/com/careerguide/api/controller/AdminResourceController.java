package com.careerguide.api.controller;

import com.careerguide.api.dto.ResourceDto;
import com.careerguide.api.dto.ResourceUpsertRequest;
import com.careerguide.api.service.ResourceService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Write endpoints for resources. Reads still go through the public
 * {@link ResourceController} ({@code GET /api/resources}), same convention
 * as {@link AdminSkillController}. Named {@code AdminResourceController}
 * for the {@code Resource} content entity -- unrelated to the generic REST
 * notion of "a resource".
 */
@RestController
@RequestMapping("/api/admin/resources")
public class AdminResourceController {

    private final ResourceService resourceService;

    public AdminResourceController(ResourceService resourceService) {
        this.resourceService = resourceService;
    }

    @PostMapping
    public ResponseEntity<ResourceDto> create(@Valid @RequestBody ResourceUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(resourceService.create(request));
    }

    @PutMapping("/{slug}")
    public ResourceDto update(@PathVariable String slug, @Valid @RequestBody ResourceUpsertRequest request) {
        return resourceService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        resourceService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
