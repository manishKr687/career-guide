package com.careerguide.api.controller;

import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.service.CollegeService;
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
@RequestMapping("/api/colleges")
public class CollegeController {

    private final CollegeService collegeService;

    public CollegeController(CollegeService collegeService) {
        this.collegeService = collegeService;
    }

    /**
     * @param type       optional type filter (e.g. "IIT", "NIT", "Polytechnic")
     * @param q          optional free-text search across name/location/description
     * @param degree     optional degree slug filter (V53) -- matches the spec's
     *                   {@code GET /api/colleges?degree=btech&discipline=cse&state=delhi} example
     * @param discipline optional discipline (career) slug filter (V53)
     * @param state      optional state slug filter (V53)
     * @param slugs      optional comma-separated slugs. When given, returns exactly
     *                   those records and ignores every filter and the paging
     *                   parameters above: the caller has named the set it wants,
     *                   so narrowing it further would silently return less than
     *                   was asked for. Exists so a page resolving relations makes
     *                   one request instead of one per slug -- see SlugList.
     * @param page       optional, 0-based -- see CareerController.findAll for the
     *                   backward-compatible unpaged-by-default contract this follows.
     * @param size       optional page size (1-200, default 20 when {@code page} is given)
     */
    @GetMapping
    public ResponseEntity<List<CollegeDto>> findAll(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String degree,
            @RequestParam(required = false) String discipline,
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String slugs,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size
    ) {
        if (slugs != null) {
            return ResponseEntity.ok(collegeService.findBySlugs(slugs));
        }
        Pageable pageable = PaginationSupport.resolve(page, size);
        Page<CollegeDto> result = collegeService.findAll(type, q, degree, discipline, state, pageable);
        return ResponseEntity.ok()
                .header("X-Total-Count", String.valueOf(result.getTotalElements()))
                .body(result.getContent());
    }

    @GetMapping("/{slug}")
    public CollegeDto findBySlug(@PathVariable String slug) {
        return collegeService.findBySlug(slug);
    }
}
