package com.careerguide.api.controller;

import com.careerguide.api.dto.StateDto;
import com.careerguide.api.service.StateService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Added in V53 (College MVP). Small, unpaged reference data -- same shape as CategoryController. */
@RestController
@RequestMapping("/api/states")
public class StateController {

    private final StateService stateService;

    public StateController(StateService stateService) {
        this.stateService = stateService;
    }

    @GetMapping
    public List<StateDto> findAll() {
        return stateService.findAll();
    }

    @GetMapping("/{slug}")
    public StateDto findBySlug(@PathVariable String slug) {
        return stateService.findBySlug(slug);
    }
}
