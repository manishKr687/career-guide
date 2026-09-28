package com.careerguide.api.controller;

import com.careerguide.api.dto.SkillDto;
import com.careerguide.api.service.SkillService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
public class SkillController {

    private final SkillService skillService;

    public SkillController(SkillService skillService) {
        this.skillService = skillService;
    }

    @GetMapping
    public List<SkillDto> findAll() {
        return skillService.findAll();
    }

    @GetMapping("/{slug}")
    public SkillDto findBySlug(@PathVariable String slug) {
        return skillService.findBySlug(slug);
    }
}
