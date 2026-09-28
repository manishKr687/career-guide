package com.careerguide.api.controller;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CareerUpsertRequest;
import com.careerguide.api.service.CareerService;
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
 * Write endpoints for careers. Reads still go through the public
 * {@link CareerController} ({@code GET /api/careers}) -- the admin frontend
 * lists/edits using the same DTOs it already fetches for the public site.
 * Every endpoint here requires a valid admin session token; see
 * {@code AdminAuthInterceptor}.
 */
@RestController
@RequestMapping("/api/admin/careers")
public class AdminCareerController {

    private final CareerService careerService;

    public AdminCareerController(CareerService careerService) {
        this.careerService = careerService;
    }

    @PostMapping
    public ResponseEntity<CareerDto> create(@Valid @RequestBody CareerUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(careerService.create(request));
    }

    @PutMapping("/{slug}")
    public CareerDto update(@PathVariable String slug, @Valid @RequestBody CareerUpsertRequest request) {
        return careerService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        careerService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
