package com.careerguide.api.controller;

import com.careerguide.api.dto.SubjectDto;
import com.careerguide.api.service.SubjectService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/subjects")
public class SubjectController {

    private final SubjectService subjectService;

    public SubjectController(SubjectService subjectService) {
        this.subjectService = subjectService;
    }

    /**
     * The optional {@code category} filter exists for the admin form: once a
     * category is chosen, the Subject picker narrows to subjects in it,
     * matching the cascading-filter behaviour the listing pages already use.
     */
    @GetMapping
    public List<SubjectDto> findAll(@RequestParam(required = false) String category) {
        return category == null || category.isBlank()
                ? subjectService.findAll()
                : subjectService.findByCategory(category);
    }

    @GetMapping("/{slug}")
    public SubjectDto findBySlug(@PathVariable String slug) {
        return subjectService.findBySlug(slug);
    }
}
