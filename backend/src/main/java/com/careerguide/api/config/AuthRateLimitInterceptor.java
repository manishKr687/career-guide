package com.careerguide.api.config;

import com.careerguide.api.web.RateLimitExceededException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Set;

/**
 * Basic per-IP throttle on the endpoints an attacker can hit without ever
 * holding a valid credential.
 *
 * <p>Two groups, with different budgets because they are different problems:
 *
 * <ul>
 *   <li><b>Credential endpoints</b> -- {@code POST /api/auth/login},
 *       {@code /api/auth/register} and {@code /api/admin/login}. Brute-forcing
 *       a password or spamming account creation. Budget:
 *       {@code careerguide.rate-limit.auth.max-attempts}, default 10.</li>
 *   <li><b>Public submissions</b> -- {@code POST /api/counselling-requests}.
 *       Not credential guessing: it is an unauthenticated endpoint that writes
 *       a row of personal data, so the risk is unbounded table growth and an
 *       unusable admin inbox. Budget:
 *       {@code careerguide.rate-limit.submission.max-attempts}, default 3,
 *       because nobody books a counselling call four times in a quarter of an
 *       hour and anyone who does can wait.</li>
 * </ul>
 *
 * Registered on exactly those paths in {@link AuthRateLimitWebConfig}. Every
 * other endpoint is either behind a bearer token or a public read with no
 * attempt-limited resource behind it.
 */
@Component
public class AuthRateLimitInterceptor implements HandlerInterceptor {

    /**
     * Paths treated as public submissions rather than credential attempts.
     * Matched exactly, not by prefix: a future {@code /api/counselling-requests/
     * something} should not inherit this budget by accident.
     */
    private static final Set<String> SUBMISSION_PATHS = Set.of("/api/counselling-requests");

    private final AuthRateLimiter rateLimiter;
    private final int submissionMaxAttempts;

    public AuthRateLimitInterceptor(
            AuthRateLimiter rateLimiter,
            @Value("${careerguide.rate-limit.submission.max-attempts:3}") int submissionMaxAttempts) {
        this.rateLimiter = rateLimiter;
        this.submissionMaxAttempts = submissionMaxAttempts;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // Same reasoning as AdminAuthInterceptor/UserAuthInterceptor: let CORS
        // preflight through untouched, it never carries the real request.
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String path = request.getRequestURI();
        String key = clientIp(request) + ":" + path;
        boolean allowed = SUBMISSION_PATHS.contains(path)
                ? rateLimiter.tryAcquire(key, submissionMaxAttempts)
                : rateLimiter.tryAcquire(key);
        if (!allowed) {
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
