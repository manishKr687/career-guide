package com.careerguide.api.config;

import com.careerguide.api.web.RateLimitExceededException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Basic per-IP throttle on the handful of endpoints an attacker can hit
 * without ever holding a valid credential -- {@code POST /api/auth/login}
 * and {@code POST /api/auth/register} (brute-forcing a password / spamming
 * account creation) and {@code POST /api/admin/login} (brute-forcing the
 * single shared admin password). Registered only on those exact paths in
 * {@link AuthRateLimitWebConfig}; every other endpoint is either already
 * behind a bearer token (so hammering it isn't a credential-guessing
 * concern) or a public read with no attempt-limited resource behind it.
 */
@Component
public class AuthRateLimitInterceptor implements HandlerInterceptor {

    private final AuthRateLimiter rateLimiter;

    public AuthRateLimitInterceptor(AuthRateLimiter rateLimiter) {
        this.rateLimiter = rateLimiter;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // Same reasoning as AdminAuthInterceptor/UserAuthInterceptor: let CORS
        // preflight through untouched, it never carries the real request.
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String key = clientIp(request) + ":" + request.getRequestURI();
        if (!rateLimiter.tryAcquire(key)) {
            long retryAfterSeconds = rateLimiter.retryAfterSeconds(key);
            response.setHeader("Retry-After", String.valueOf(retryAfterSeconds));
            throw new RateLimitExceededException("Too many attempts -- please wait before trying again");
        }
        return true;
    }

    /**
     * {@code X-Forwarded-For}'s first entry when present (this API is meant
     * to sit behind a reverse proxy in production -- see {@code CorsConfig}),
     * falling back to the direct socket address for local/dev requests where
     * there's no proxy in front to set it. This app has no configured set of
     * trusted proxies, so a caller could in principle forge this header to
     * spread attempts across fake keys; that's an acceptable gap for a
     * basic, best-effort throttle rather than perimeter security, and no
     * worse than the attacker simply rotating source IPs directly.
     */
    private String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
