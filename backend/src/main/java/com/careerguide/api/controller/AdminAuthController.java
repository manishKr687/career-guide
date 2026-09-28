package com.careerguide.api.controller;

import com.careerguide.api.dto.AdminLoginRequest;
import com.careerguide.api.dto.AdminLoginResponse;
import com.careerguide.api.service.AdminAuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Not guarded by {@code AdminAuthInterceptor} (explicitly excluded in
 * {@code AdminWebConfig}) -- this is the one admin endpoint you're allowed to
 * call without already having a token, since it's how you get one.
 */
@RestController
@RequestMapping("/api/admin")
public class AdminAuthController {

    private final AdminAuthService adminAuthService;

    public AdminAuthController(AdminAuthService adminAuthService) {
        this.adminAuthService = adminAuthService;
    }

    @PostMapping("/login")
    public AdminLoginResponse login(@Valid @RequestBody AdminLoginRequest request) {
        String token = adminAuthService.login(request.password());
        return new AdminLoginResponse(token);
    }
}
