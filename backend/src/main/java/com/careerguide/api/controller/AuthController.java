package com.careerguide.api.controller;

import com.careerguide.api.dto.AuthResponse;
import com.careerguide.api.dto.LoginRequest;
import com.careerguide.api.dto.RegisterRequest;
import com.careerguide.api.service.UserAuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Not guarded by {@code UserAuthInterceptor} ({@code UserWebConfig} only
 * registers it on {@code /api/me/**}) -- these are the two consumer
 * endpoints you're allowed to call without already having a token, since
 * they're how you get one.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserAuthService userAuthService;

    public AuthController(UserAuthService userAuthService) {
        this.userAuthService = userAuthService;
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return userAuthService.register(request.email(), request.password(), request.name());
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return userAuthService.login(request.email(), request.password());
    }
}
