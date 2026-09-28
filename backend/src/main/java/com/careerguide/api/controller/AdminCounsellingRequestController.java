package com.careerguide.api.controller;

import com.careerguide.api.dto.CounsellingRequestDto;
import com.careerguide.api.dto.CounsellingStatusUpdateRequest;
import com.careerguide.api.service.CounsellingRequestService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Admin inbox for the counselling requests visitors submit through the
 * public form. Guarded by {@code AdminAuthInterceptor} like every other
 * {@code /api/admin/**} endpoint -- no separate wiring needed here.
 */
@RestController
@RequestMapping("/api/admin/counselling-requests")
public class AdminCounsellingRequestController {

    private final CounsellingRequestService counsellingRequestService;

    public AdminCounsellingRequestController(CounsellingRequestService counsellingRequestService) {
        this.counsellingRequestService = counsellingRequestService;
    }

    @GetMapping
    public List<CounsellingRequestDto> findAll() {
        return counsellingRequestService.findAll();
    }

    @PutMapping("/{id}/status")
    public CounsellingRequestDto updateStatus(@PathVariable Long id, @Valid @RequestBody CounsellingStatusUpdateRequest request) {
        return counsellingRequestService.updateStatus(id, request.status());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        counsellingRequestService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
