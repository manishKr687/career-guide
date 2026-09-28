package com.careerguide.api.controller;

import com.careerguide.api.dto.CityDto;
import com.careerguide.api.dto.CityUpsertRequest;
import com.careerguide.api.service.CityService;
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

/** Write endpoints for cities. Added in V53 (College MVP). See {@link AdminCareerController}'s javadoc for the general shape. */
@RestController
@RequestMapping("/api/admin/cities")
public class AdminCityController {

    private final CityService cityService;

    public AdminCityController(CityService cityService) {
        this.cityService = cityService;
    }

    @PostMapping
    public ResponseEntity<CityDto> create(@Valid @RequestBody CityUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(cityService.create(request));
    }

    @PutMapping("/{slug}")
    public CityDto update(@PathVariable String slug, @Valid @RequestBody CityUpsertRequest request) {
        return cityService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        cityService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
