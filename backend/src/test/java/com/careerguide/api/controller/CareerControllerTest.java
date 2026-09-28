package com.careerguide.api.controller;

import com.careerguide.api.config.AdminAuthInterceptor;
import com.careerguide.api.config.AdminWebConfig;
import com.careerguide.api.config.AuthRateLimitInterceptor;
import com.careerguide.api.config.AuthRateLimitWebConfig;
import com.careerguide.api.config.UserAuthInterceptor;
import com.careerguide.api.config.UserWebConfig;
import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.service.CareerService;
import com.careerguide.api.web.NotFoundException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slices out just {@link CareerController} + Spring MVC infra, mocking
 * {@link CareerService} entirely -- no database, no other beans.
 *
 * <p>Both the three {@code WebMvcConfigurer} classes AND the three
 * {@code HandlerInterceptor} beans they register are excluded. Excluding
 * only the {@code WebMvcConfigurer}s isn't enough: {@code @WebMvcTest}'s
 * default component filters auto-detect {@code HandlerInterceptor} beans
 * directly (regardless of whether anything registers them), so
 * {@code AdminAuthInterceptor}/{@code UserAuthInterceptor}/
 * {@code AuthRateLimitInterceptor} would otherwise still get instantiated
 * here and fail to construct -- their {@code AdminTokenService}/
 * {@code UserTokenService}/{@code AuthRateLimiter} dependencies are real
 * {@code @Service}/{@code @Component} beans this slice never scans. That
 * changes nothing about what's under test here: none of the three apply to
 * {@code /api/careers} anyway (they're scoped to {@code /api/admin/**},
 * {@code /api/me/**}, and the three unauthenticated auth endpoints
 * respectively).
 */
@WebMvcTest(
        controllers = CareerController.class,
        excludeFilters = @ComponentScan.Filter(
                type = FilterType.ASSIGNABLE_TYPE,
                classes = {
                        AdminWebConfig.class, UserWebConfig.class, AuthRateLimitWebConfig.class,
                        AdminAuthInterceptor.class, UserAuthInterceptor.class, AuthRateLimitInterceptor.class
                }
        )
)
class CareerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private CareerService careerService;

    @Test
    void findAllReturnsBareArrayWithTotalCountHeader() throws Exception {
        when(careerService.findAll(isNull(), isNull(), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(sampleDto("software-engineer"))));

        mockMvc.perform(get("/api/careers"))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Total-Count", "1"))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].slug").value("software-engineer"));
    }

    @Test
    void findAllPassesCategoryAndQueryThrough() throws Exception {
        when(careerService.findAll(eq("engineering-technology"), eq("soft"), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of()));

        mockMvc.perform(get("/api/careers")
                        .param("category", "engineering-technology")
                        .param("q", "soft"))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Total-Count", "0"))
                .andExpect(jsonPath("$", hasSize(0)));

        verify(careerService).findAll(eq("engineering-technology"), eq("soft"), any(Pageable.class));
    }

    @Test
    void findBySlugReturnsDto() throws Exception {
        when(careerService.findBySlug("software-engineer")).thenReturn(sampleDto("software-engineer"));

        mockMvc.perform(get("/api/careers/software-engineer"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.slug").value("software-engineer"))
                .andExpect(jsonPath("$.title").value("Software Engineer"));
    }

    @Test
    void findBySlugReturns404WhenUnknown() throws Exception {
        when(careerService.findBySlug("does-not-exist"))
                .thenThrow(NotFoundException.forSlug("Career", "does-not-exist"));

        mockMvc.perform(get("/api/careers/does-not-exist"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.path").value("/api/careers/does-not-exist"));
    }

    private static CareerDto sampleDto(String slug) {
        return new CareerDto(
                slug,
                "Software Engineer",
                "engineering-technology",
                "Build software that runs the world",
                "High",
                List.of(),
                "Writes and maintains code",
                "6-20 LPA",
                new BigDecimal("6"), new BigDecimal("20"),
                List.of("Junior", "Senior"),
                List.of(),
                List.of(),
                "code",
                "A software engineer designs and builds applications.",
                List.of(),
                List.of(),
                null,
                List.of(),
                List.of(),
                List.of(),
                null,
                List.of(),
                List.of(),
                List.of(),
                List.of(),
                null,
                null,
                null
        );
    }
}
