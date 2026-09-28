package com.careerguide.api.controller;

import com.careerguide.api.dto.UniversityDto;
import com.careerguide.api.dto.UniversityUpsertRequest;
import com.careerguide.api.service.UniversityService;
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

/** Write endpoints for universities. Added in V53 (College MVP). See {@link AdminCareerController}'s javadoc for the general shape. */
@RestController
@RequestMapping("/api/admin/universities")
public class AdminUniversityController {

    private final UniversityService universityService;

    public AdminUniversityController(UniversityService universityService) {
        this.universityService = universityService;
    }

    @PostMapping
    public ResponseEntity<UniversityDto> create(@Valid @RequestBody UniversityUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(universityService.create(request));
    }

    @PutMapping("/{slug}")
    public UniversityDto update(@PathVariable String slug, @Valid @RequestBody UniversityUpsertRequest request) {
        return universityService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        universityService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
