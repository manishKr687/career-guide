package com.careerguide.api.controller;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.service.CareerService;
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

/**
 * Serves the specific-role entity (title, tagline, salary bands, day-to-day work, etc).
 *
 * <p>Exposed at {@code /api/careers}. Phase 4 (see backend/README.md) temporarily also
 * exposed this at {@code /api/job-roles} as a routing-only stand-in for a real Job Role
 * entity; that alias is now retired in favour of the actual {@link JobRoleController},
 * once the "Spec v1.0 Match" / "ER Data Model Match" analysis showed that data belongs
 * at a finer grain than this entity (see {@code job_roles}, added in V26) rather than
 * being this entity under a second name.
 */
@RestController
@RequestMapping("/api/careers")
public class CareerController {

    private final CareerService careerService;

    public CareerController(CareerService careerService) {
        this.careerService = careerService;
    }

    /**
     * @param category optional category slug filter (e.g. "engineering-technology")
     * @param q        optional free-text search across title/tagline/description
     * @param slugs      optional comma-separated slugs. When given, returns exactly
     *                   those records and ignores every filter and the paging
     *                   parameters above: the caller has named the set it wants,
     *                   so narrowing it further would silently return less than
     *                   was asked for. Exists so a page resolving relations makes
     *                   one request instead of one per slug -- see SlugList.
     * @param page     optional, 0-based -- omit together with {@code size} to get every
     *                 matching career in one response (the default, and today's only
     *                 behavior for existing callers). Providing either opts into real
     *                 paging; the total matching row count is returned in the
     *                 {@code X-Total-Count} response header rather than the body, so
     *                 the body stays a plain array whether or not paging was requested.
     * @param size     optional page size (1-200, default 20 when {@code page} is given
     *                 but {@code size} isn't)
     */
    @GetMapping
    public ResponseEntity<List<CareerDto>> findAll(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String slugs,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size
    ) {
        if (slugs != null) {
            return ResponseEntity.ok(careerService.findBySlugs(slugs));
        }
        Pageable pageable = PaginationSupport.resolve(page, size);
        Page<CareerDto> result = careerService.findAll(category, q, pageable);
        return ResponseEntity.ok()
                .header("X-Total-Count", String.valueOf(result.getTotalElements()))
                .body(result.getContent());
    }

    @GetMapping("/{slug}")
    public CareerDto findBySlug(@PathVariable String slug) {
        return careerService.findBySlug(slug);
    }
}
