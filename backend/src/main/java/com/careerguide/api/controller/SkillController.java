package com.careerguide.api.controller;

import com.careerguide.api.dto.SkillDto;
import com.careerguide.api.service.SkillService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
public class SkillController {

    private final SkillService skillService;

    public SkillController(SkillService skillService) {
        this.skillService = skillService;
    }

    /**
     * The full list, or just the records named by {@code ?slugs=a,b,c}.
     *
     * <p>The slugs form exists so a page resolving relations makes one request
     * instead of one per slug -- see {@link com.careerguide.api.web.SlugList}.
     * It ignores nothing else here because this endpoint has no other filters.
     */
    @GetMapping
    public List<SkillDto> findAll(@RequestParam(required = false) String slugs) {
        return slugs == null
                ? skillService.findAll()
                : skillService.findBySlugs(slugs);
    }

    @GetMapping("/{slug}")
    public SkillDto findBySlug(@PathVariable String slug) {
        return skillService.findBySlug(slug);
    }
}
