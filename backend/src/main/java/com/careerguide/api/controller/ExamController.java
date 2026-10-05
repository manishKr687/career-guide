package com.careerguide.api.controller;

import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.service.ExamService;
import com.careerguide.api.web.PaginationSupport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/exams")
public class ExamController {

    private final ExamService examService;

    public ExamController(ExamService examService) {
        this.examService = examService;
    }

    /**
     * @param category optional category filter (e.g. "Government", "Banking")
     * @param q        optional free-text search across name/fullName/description
     * @param slugs      optional comma-separated slugs. When given, returns exactly
     *                   those records and ignores every filter and the paging
     *                   parameters above: the caller has named the set it wants,
     *                   so narrowing it further would silently return less than
     *                   was asked for. Exists so a page resolving relations makes
     *                   one request instead of one per slug -- see SlugList.
     * @param page     optional, 0-based -- see CareerController.findAll for the
     *                 backward-compatible unpaged-by-default contract this follows.
     * @param size     optional page size (1-200, default 20 when {@code page} is given)
     */
    @GetMapping
    public ResponseEntity<List<ExamDto>> findAll(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String slugs,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size
    ) {
        if (slugs != null) {
            return ResponseEntity.ok(examService.findBySlugs(slugs));
        }
        Pageable pageable = PaginationSupport.resolve(page, size);
        Page<ExamDto> result = examService.findAll(category, q, pageable);
        return ResponseEntity.ok()
                .header("X-Total-Count", String.valueOf(result.getTotalElements()))
                .body(result.getContent());
    }

    @GetMapping("/{slug}")
    public ExamDto findBySlug(@PathVariable String slug) {
        return examService.findBySlug(slug);
    }
}
