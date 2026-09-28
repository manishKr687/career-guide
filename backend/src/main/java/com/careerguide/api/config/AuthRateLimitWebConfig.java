package com.careerguide.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Applies {@link AuthRateLimitInterceptor} to exactly the three
 * unauthenticated, credential-checking endpoints it's meant to protect --
 * deliberately narrow path patterns rather than {@code AdminWebConfig}'s/
 * {@code UserWebConfig}'s {@code /**}-style ones, since this isn't a
 * blanket guard.
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
                .addPathPatterns("/api/auth/login", "/api/auth/register", "/api/admin/login");
    }
}
