package com.careerguide.api.controller;

import com.careerguide.api.dto.AdminGoalLineDto;
import com.careerguide.api.dto.GoalLineSummaryDto;
import com.careerguide.api.dto.SaveGoalLineRequest;
import com.careerguide.api.service.GoalLineAdminService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * The lines My Career goals start from, per item -- {@code /exams/jee-main},
 * {@code /colleges/iit-madras}. Guarded by {@code AdminAuthInterceptor} like
 * every other {@code /api/admin/**} endpoint.
 */
@RestController
@RequestMapping("/api/admin/goal-lines")
public class AdminGoalLineController {

    private final GoalLineAdminService service;

    public AdminGoalLineController(GoalLineAdminService service) {
        this.service = service;
    }

    /** Only the items with a custom line; everything else is automatic. */
    @GetMapping
    public List<GoalLineSummaryDto> list() {
        return service.list();
    }

    @GetMapping("/{type}/{slug}")
    public AdminGoalLineDto get(@PathVariable String type, @PathVariable String slug) {
        return service.get(type, slug);
    }

    /** Saved and then read back in a fresh transaction, so the response carries the stored version and time. */
    @PutMapping("/{type}/{slug}")
    public AdminGoalLineDto save(@PathVariable String type, @PathVariable String slug,
                                 @Valid @RequestBody SaveGoalLineRequest body) {
        service.save(type, slug, body);
        return service.get(type, slug);
    }

    @DeleteMapping("/{type}/{slug}")
    public AdminGoalLineDto reset(@PathVariable String type, @PathVariable String slug) {
        service.reset(type, slug);
        return service.get(type, slug);
    }
}
