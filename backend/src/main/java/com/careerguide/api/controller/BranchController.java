package com.careerguide.api.controller;

import com.careerguide.api.dto.BranchDto;
import com.careerguide.api.service.BranchService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/branches")
public class BranchController {

    private final BranchService branchService;

    public BranchController(BranchService branchService) {
        this.branchService = branchService;
    }

    @GetMapping
    public List<BranchDto> findAll(@RequestParam(required = false) String category) {
        return branchService.findAll(category);
    }

    @GetMapping("/{slug}")
    public BranchDto findBySlug(@PathVariable String slug) {
        return branchService.findBySlug(slug);
    }
}
