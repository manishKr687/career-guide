package com.careerguide.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Allows the Next.js frontend (dev server on localhost:3000/3311, or
 * whatever origin is configured) to call this API from the browser. The
 * career-guide frontend's {@code src/lib/api.ts} is a live consumer of
 * this API.
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Value("${careerguide.cors.allowed-origins:http://localhost:3000,http://localhost:3311}")
    private String[] allowedOrigins;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(allowedOrigins)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
