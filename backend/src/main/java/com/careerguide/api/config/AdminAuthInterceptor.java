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

    /**
     * Always returns {@code true}, and rejects by throwing instead.
     *
     * <p>SonarQube reports this as {@code java:S3516} ("refactor this method to
     * not always return the same value") at BLOCKER severity, in all three
     * interceptors. It is wrong here, and returning {@code false} to satisfy it
     * would be a regression: {@code false} halts the handler chain without
     * writing anything, so the caller receives an empty 200 and no explanation.
     * Throwing {@link UnauthorizedException} lets
     * {@link com.careerguide.api.web.GlobalExceptionHandler} answer with a 401
     * carrying the same {@code ApiError} shape as every other error from this
     * API. The boolean is Spring's "continue" signal, not a result.
     */
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
