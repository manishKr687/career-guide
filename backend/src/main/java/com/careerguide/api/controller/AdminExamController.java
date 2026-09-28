package com.careerguide.api.controller;

import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.dto.ExamUpsertRequest;
import com.careerguide.api.service.ExamService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Write endpoints for exams. See {@link AdminCareerController}'s javadoc for the general shape. */
@RestController
@RequestMapping("/api/admin/exams")
public class AdminExamController {

    private final ExamService examService;

    public AdminExamController(ExamService examService) {
        this.examService = examService;
    }

    @PostMapping
    public ResponseEntity<ExamDto> create(@Valid @RequestBody ExamUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(examService.create(request));
    }

    @PutMapping("/{slug}")
    public ExamDto update(@PathVariable String slug, @Valid @RequestBody ExamUpsertRequest request) {
        return examService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        examService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
