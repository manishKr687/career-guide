package com.careerguide.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Applies {@link AuthRateLimitInterceptor} to exactly the four unauthenticated
 * endpoints that need it -- deliberately narrow path patterns rather than
 * {@code AdminWebConfig}'s/{@code UserWebConfig}'s {@code /**}-style ones,
 * since this isn't a blanket guard.
 *
 * <p>Three are credential-checking. The fourth,
 * {@code POST /api/counselling-requests}, is not: it is the only
 * unauthenticated endpoint in this API that <em>persists</em> anything, and
 * what it persists is a name, email address, phone number and free text from
 * students who are often minors.
 *
 * <p>It was unprotected until this was written, and measurably so: thirty
 * submissions fired back to back all returned 201, and a 2 MB message was
 * accepted and stored. Nothing about that needed a credential or a browser.
 * The consent column added in V133 made the table lawful to hold; it did
 * nothing to stop a stranger filling it with other people's contact details.
 *
 * <p>It gets its own, tighter budget -- see {@link AuthRateLimitInterceptor}.
 */
@Configuration
public class AuthRateLimitWebConfig implements WebMvcConfigurer {

    private final AuthRateLimitInterceptor authRateLimitInterceptor;

    public AuthRateLimitWebConfig(AuthRateLimitInterceptor authRateLimitInterceptor) {
        this.authRateLimitInterceptor = authRateLimitInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authRateLimitInterceptor)
                .addPathPatterns(
                        "/api/auth/login",
                        "/api/auth/register",
                        "/api/admin/login",
                        "/api/counselling-requests");
    }
}
