package com.careerguide.api.service;

import com.careerguide.api.web.UnauthorizedException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@Service
public class AdminAuthService {

    private final byte[] configuredPasswordBytes;
    private final AdminTokenService tokenService;

    public AdminAuthService(
            @Value("${careerguide.admin.password}") String configuredPassword,
            AdminTokenService tokenService
    ) {
        this.configuredPasswordBytes = configuredPassword.getBytes(StandardCharsets.UTF_8);
        this.tokenService = tokenService;
    }

    /**
     * @return a fresh session token if {@code suppliedPassword} matches the
     * configured admin password.
     * @throws UnauthorizedException if it doesn't.
     */
    public String login(String suppliedPassword) {
        byte[] supplied = (suppliedPassword == null ? "" : suppliedPassword).getBytes(StandardCharsets.UTF_8);
        // Constant-time comparison so a wrong guess can't be narrowed down
        // character-by-character via response timing.
        if (!MessageDigest.isEqual(supplied, configuredPasswordBytes)) {
            throw new UnauthorizedException("Incorrect admin password");
        }
        return tokenService.issueToken();
    }
}
