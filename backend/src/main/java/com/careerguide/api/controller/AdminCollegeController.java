package com.careerguide.api.controller;

import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.CollegeUpsertRequest;
import com.careerguide.api.service.CollegeService;
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

/** Write endpoints for colleges. See {@link AdminCareerController}'s javadoc for the general shape. */
@RestController
@RequestMapping("/api/admin/colleges")
public class AdminCollegeController {

    private final CollegeService collegeService;

    public AdminCollegeController(CollegeService collegeService) {
        this.collegeService = collegeService;
    }

    @PostMapping
    public ResponseEntity<CollegeDto> create(@Valid @RequestBody CollegeUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(collegeService.create(request));
    }

    @PutMapping("/{slug}")
    public CollegeDto update(@PathVariable String slug, @Valid @RequestBody CollegeUpsertRequest request) {
        return collegeService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        collegeService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
