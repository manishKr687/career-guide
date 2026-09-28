package com.careerguide.api.controller;

import com.careerguide.api.dto.AssessmentQuestionDto;
import com.careerguide.api.dto.AssessmentResultDto;
import com.careerguide.api.dto.AssessmentSubmissionRequest;
import com.careerguide.api.service.AssessmentService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/assessment")
public class AssessmentController {

    private final AssessmentService assessmentService;

    public AssessmentController(AssessmentService assessmentService) {
        this.assessmentService = assessmentService;
    }

    @GetMapping("/questions")
    public List<AssessmentQuestionDto> findQuestions() {
        return assessmentService.findQuestions();
    }

    /** Scores a completed assessment server-side and returns top categories + recommended careers. */
    @PostMapping("/submit")
    public AssessmentResultDto submit(@Valid @RequestBody AssessmentSubmissionRequest request) {
        return assessmentService.submit(request);
    }
}
