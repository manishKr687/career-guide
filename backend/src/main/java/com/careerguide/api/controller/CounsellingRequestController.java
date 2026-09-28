package com.careerguide.api.controller;

import com.careerguide.api.dto.CounsellingRequestDto;
import com.careerguide.api.dto.CounsellingRequestSubmission;
import com.careerguide.api.service.CounsellingRequestService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Public endpoint -- the "Book a counselling call" form on the site posts
 * here directly, no login required. Reviewing/actioning submissions is an
 * admin-only concern; see {@link AdminCounsellingRequestController}.
 */
@RestController
@RequestMapping("/api/counselling-requests")
public class CounsellingRequestController {

    private final CounsellingRequestService counsellingRequestService;

    public CounsellingRequestController(CounsellingRequestService counsellingRequestService) {
        this.counsellingRequestService = counsellingRequestService;
    }

    @PostMapping
    public ResponseEntity<CounsellingRequestDto> submit(@Valid @RequestBody CounsellingRequestSubmission submission) {
        return ResponseEntity.status(HttpStatus.CREATED).body(counsellingRequestService.submit(submission));
    }
}
