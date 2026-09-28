package com.careerguide.api.controller;

import com.careerguide.api.dto.AdminDashboardDto;
import com.careerguide.api.service.AdminDashboardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Read-only aggregate view for the admin dashboard. Sits under
 * {@code /api/admin} so AdminAuthInterceptor guards it like every other admin
 * endpoint -- the counts are harmless but the gaps describe where the catalog
 * is weak, which is not something to publish.
 */
@RestController
@RequestMapping("/api/admin/dashboard")
public class AdminDashboardController {

    private final AdminDashboardService dashboardService;

    public AdminDashboardController(AdminDashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping
    public AdminDashboardDto get() {
        return dashboardService.build();
    }
}
