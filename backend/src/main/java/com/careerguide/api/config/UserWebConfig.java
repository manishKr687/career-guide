package com.careerguide.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Registers {@link UserAuthInterceptor} on every {@code /api/me/**} route
 * (which includes {@code /api/me/saved/**} -- see {@code SavedItemsController}).
 * {@code /api/auth/**} (register/login) is intentionally never added here,
 * the same way {@code /api/admin/login} is excluded in {@code AdminWebConfig}.
 */
@Configuration
public class UserWebConfig implements WebMvcConfigurer {

    private final UserAuthInterceptor userAuthInterceptor;

    public UserWebConfig(UserAuthInterceptor userAuthInterceptor) {
        this.userAuthInterceptor = userAuthInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(userAuthInterceptor)
                .addPathPatterns("/api/me/**");
    }
}
