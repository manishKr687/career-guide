package com.careerguide.api.controller;

import com.careerguide.api.dto.StageDto;
import com.careerguide.api.service.StageService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/stages")
public class StageController {

    private final StageService stageService;

    public StageController(StageService stageService) {
        this.stageService = stageService;
    }

    @GetMapping
    public List<StageDto> findAll() {
        return stageService.findAll();
    }

    @GetMapping("/{slug}")
    public StageDto findBySlug(@PathVariable String slug) {
        return stageService.findBySlug(slug);
    }
}
