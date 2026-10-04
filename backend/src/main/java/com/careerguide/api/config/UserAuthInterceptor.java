package com.careerguide.api.config;

import com.careerguide.api.service.UserTokenService;
import com.careerguide.api.web.UnauthorizedException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Guards every {@code /api/me/**} endpoint (registered in
 * {@link UserWebConfig}), mirroring {@code AdminAuthInterceptor}. Requires
 * {@code Authorization: Bearer <token>} with a token previously issued by
 * {@code UserAuthService} (via {@link UserTokenService}), and -- unlike the
 * admin interceptor, which guards a single shared account -- stashes the
 * resolved user id as a request attribute so controllers know *which* user
 * is making the request.
 */
@Component
public class UserAuthInterceptor implements HandlerInterceptor {

    public static final String USER_ID_ATTRIBUTE = "careerguide.userId";

    private static final String BEARER_PREFIX = "Bearer ";

    private final UserTokenService tokenService;

    public UserAuthInterceptor(UserTokenService tokenService) {
        this.tokenService = tokenService;
    }

    /**
     * Always returns {@code true} and rejects by throwing -- see
     * {@link AdminAuthInterceptor#preHandle} for why Sonar's java:S3516 on this
     * method is wrong and returning {@code false} would be a regression.
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // Same reasoning as AdminAuthInterceptor: let CORS preflight through
        // unauthenticated, since the browser never sends Authorization on it.
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String header = request.getHeader("Authorization");
        String token = (header != null && header.startsWith(BEARER_PREFIX))
                ? header.substring(BEARER_PREFIX.length())
                : null;
        Long userId = tokenService.resolveUserId(token).orElse(null);
        if (userId == null) {
            throw new UnauthorizedException("Missing or expired session -- please log in again");
        }
        request.setAttribute(USER_ID_ATTRIBUTE, userId);
        return true;
    }
}
