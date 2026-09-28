package com.careerguide.api.config;

import com.careerguide.api.service.AdminTokenService;
import com.careerguide.api.web.UnauthorizedException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Guards every {@code /api/admin/**} write endpoint (registered in
 * {@link AdminWebConfig}, which excludes {@code /api/admin/login} itself).
 * Requires {@code Authorization: Bearer <token>} with a token previously
 * issued by {@code AdminAuthService}.
 */
@Component
public class AdminAuthInterceptor implements HandlerInterceptor {

    private static final String BEARER_PREFIX = "Bearer ";

    private final AdminTokenService tokenService;

    public AdminAuthInterceptor(AdminTokenService tokenService) {
        this.tokenService = tokenService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // CORS preflight requests never carry the Authorization header (that
        // would defeat the point of a preflight) -- let them through so the
        // browser's actual OPTIONS check succeeds, same as the public API.
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String header = request.getHeader("Authorization");
        String token = (header != null && header.startsWith(BEARER_PREFIX))
                ? header.substring(BEARER_PREFIX.length())
                : null;
        if (!tokenService.isValid(token)) {
            throw new UnauthorizedException("Missing or expired admin session -- please log in again");
        }
        return true;
    }
}
