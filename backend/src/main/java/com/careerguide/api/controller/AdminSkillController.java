package com.careerguide.api.controller;

import com.careerguide.api.dto.SkillDto;
import com.careerguide.api.dto.SkillUpsertRequest;
import com.careerguide.api.service.SkillService;
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
 * Write endpoints for skills -- the first admin write path this table has
 * had since V24; until now a skill could only be added or edited by hand
 * via a Flyway migration (see SkillService's javadoc). Reads still go
 * through the public {@link SkillController} ({@code GET /api/skills}),
 * same convention as {@link AdminCareerController}. Every endpoint here
 * requires a valid admin session token; see {@code AdminAuthInterceptor}.
 */
@RestController
@RequestMapping("/api/admin/skills")
public class AdminSkillController {

    private final SkillService skillService;

    public AdminSkillController(SkillService skillService) {
        this.skillService = skillService;
    }

    @PostMapping
    public ResponseEntity<SkillDto> create(@Valid @RequestBody SkillUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(skillService.create(request));
    }

    @PutMapping("/{slug}")
    public SkillDto update(@PathVariable String slug, @Valid @RequestBody SkillUpsertRequest request) {
        return skillService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        skillService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
