package com.careerguide.api.controller;

import com.careerguide.api.dto.CategoryDto;
import com.careerguide.api.service.CategoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Serves the top-level classification (slug/name/icon/color), which every career has
 * always had 100% coverage under (unlike {@link BranchController}'s branches, which
 * only cover the 13 Engineering &amp; Technology careers so far).
 *
 * <p>Phase 4 (see backend/README.md) temporarily also exposed this at
 * {@code /api/career-directions}, on the theory that Category was standing in for the
 * spec's "Career" (broad professional direction). The "Spec v1.0 Match" / "ER Data
 * Model Match" analysis superseded that: the uploaded specs' own {@code careers}
 * examples (Software Engineering, Data Science, Medicine, ...) are far narrower than
 * a Category (Engineering &amp; Technology) -- the existing {@code careers} table
 * already sits at that grain. So Category maps to the spec's {@code career_categories}
 * (a taxonomy layer above Career), not to Career itself, and that alias is retired.
 */
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public List<CategoryDto> findAll() {
        return categoryService.findAll();
    }

    @GetMapping("/{slug}")
    public CategoryDto findBySlug(@PathVariable String slug) {
        return categoryService.findBySlug(slug);
    }
}
