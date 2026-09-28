package com.careerguide.api.controller;

import com.careerguide.api.config.AdminAuthInterceptor;
import com.careerguide.api.config.AdminWebConfig;
import com.careerguide.api.config.AuthRateLimitInterceptor;
import com.careerguide.api.config.AuthRateLimitWebConfig;
import com.careerguide.api.config.UserAuthInterceptor;
import com.careerguide.api.config.UserWebConfig;
import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CareerUpsertRequest;
import com.careerguide.api.service.CareerService;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slices out {@link AdminCareerController} the same way
 * {@link CareerControllerTest} slices out {@link CareerController} -- see
 * that class's javadoc for why the three {@code WebMvcConfigurer}s AND the
 * three {@code HandlerInterceptor} beans they register are excluded (in
 * particular, this means {@code AdminAuthInterceptor} does NOT run here;
 * these tests are about the controller's request handling, validation
 * wiring, and status-code mapping, not the admin-token guard, which has no
 * logic of its own worth a slice test beyond what {@code AdminTokenService}
 * already covers by inspection).
 */
@WebMvcTest(
        controllers = AdminCareerController.class,
        excludeFilters = @ComponentScan.Filter(
                type = FilterType.ASSIGNABLE_TYPE,
                classes = {
                        AdminWebConfig.class, UserWebConfig.class, AuthRateLimitWebConfig.class,
                        AdminAuthInterceptor.class, UserAuthInterceptor.class, AuthRateLimitInterceptor.class
                }
        )
)
class AdminCareerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private CareerService careerService;

    @Test
    void createReturns201WithCreatedBody() throws Exception {
        CareerUpsertRequest request = validRequest("data-scientist");
        when(careerService.create(any(CareerUpsertRequest.class))).thenReturn(sampleDto("data-scientist"));

        mockMvc.perform(post("/api/admin/careers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.slug").value("data-scientist"));
    }

    @Test
    void createDuplicateSlugReturns409() throws Exception {
        CareerUpsertRequest request = validRequest("software-engineer");
        when(careerService.create(any(CareerUpsertRequest.class)))
                .thenThrow(new ConflictException("Career already exists: software-engineer"));

        mockMvc.perform(post("/api/admin/careers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409));
    }

    @Test
    void createWithBlankTitleReturns400AndNeverCallsService() throws Exception {
        CareerUpsertRequest invalid = new CareerUpsertRequest(
                "data-scientist", "", "engineering-technology", "Tagline", "High",
                "Typical work", new BigDecimal("5"), new BigDecimal("10"), null, null, null, "icon", "Description", null,
                null, null, null, null, null, null,
                null, null, null, null, null, null, null);

        mockMvc.perform(post("/api/admin/careers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalid)))
                .andExpect(status().isBadRequest());

        verify(careerService, never()).create(any());
    }

    @Test
    void updateReturns200WithUpdatedBody() throws Exception {
        CareerUpsertRequest request = validRequest("software-engineer");
        when(careerService.update(eq("software-engineer"), any(CareerUpsertRequest.class)))
                .thenReturn(sampleDto("software-engineer"));

        mockMvc.perform(put("/api/admin/careers/software-engineer")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.slug").value("software-engineer"));
    }

    @Test
    void updateUnknownSlugReturns404() throws Exception {
        CareerUpsertRequest request = validRequest("does-not-exist");
        when(careerService.update(eq("does-not-exist"), any(CareerUpsertRequest.class)))
                .thenThrow(NotFoundException.forSlug("Career", "does-not-exist"));

        mockMvc.perform(put("/api/admin/careers/does-not-exist")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound());
    }

    @Test
    void deleteReturns204() throws Exception {
        mockMvc.perform(delete("/api/admin/careers/software-engineer"))
                .andExpect(status().isNoContent());

        verify(careerService).delete("software-engineer");
    }

    @Test
    void deleteUnknownSlugReturns404() throws Exception {
        org.mockito.Mockito.doThrow(NotFoundException.forSlug("Career", "does-not-exist"))
                .when(careerService).delete("does-not-exist");

        mockMvc.perform(delete("/api/admin/careers/does-not-exist"))
                .andExpect(status().isNotFound());
    }

    private static CareerUpsertRequest validRequest(String slug) {
        return new CareerUpsertRequest(
                slug, "Data Scientist", "engineering-technology", "Tagline", "High",
                "Typical work", new BigDecimal("5"), new BigDecimal("10"), List.of("Junior"), null, null,
                "icon", "Description", null,
                null, null, null, null, null, null,
                null, null, null, null, null, null, null);
    }

    private static CareerDto sampleDto(String slug) {
        return new CareerDto(
                slug, "Data Scientist", "engineering-technology", "Tagline", "High",
                List.of(), "Typical work", "5-10 LPA", new BigDecimal("5"), new BigDecimal("10"), List.of("Junior"),
                List.of(), List.of(), "icon", "Description",
                List.of(), List.of(), List.of(), List.of(), List.of(), null,
                List.of(), List.of(), List.of(), List.of(), null, null, null);
    }
}
