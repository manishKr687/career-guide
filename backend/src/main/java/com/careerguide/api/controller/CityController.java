package com.careerguide.api.controller;

import com.careerguide.api.dto.CityDto;
import com.careerguide.api.service.CityService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Added in V53 (College MVP). Small, unpaged reference data -- same shape as CategoryController. */
@RestController
@RequestMapping("/api/cities")
public class CityController {

    private final CityService cityService;

    public CityController(CityService cityService) {
        this.cityService = cityService;
    }

    @GetMapping
    public List<CityDto> findAll() {
        return cityService.findAll();
    }

    @GetMapping("/{slug}")
    public CityDto findBySlug(@PathVariable String slug) {
        return cityService.findBySlug(slug);
    }
}
