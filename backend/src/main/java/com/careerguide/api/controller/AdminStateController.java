package com.careerguide.api.controller;

import com.careerguide.api.dto.StateDto;
import com.careerguide.api.dto.StateUpsertRequest;
import com.careerguide.api.service.StateService;
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

/** Write endpoints for states. Added in V53 (College MVP). See {@link AdminCareerController}'s javadoc for the general shape. */
@RestController
@RequestMapping("/api/admin/states")
public class AdminStateController {

    private final StateService stateService;

    public AdminStateController(StateService stateService) {
        this.stateService = stateService;
    }

    @PostMapping
    public ResponseEntity<StateDto> create(@Valid @RequestBody StateUpsertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(stateService.create(request));
    }

    @PutMapping("/{slug}")
    public StateDto update(@PathVariable String slug, @Valid @RequestBody StateUpsertRequest request) {
        return stateService.update(slug, request);
    }

    @DeleteMapping("/{slug}")
    public ResponseEntity<Void> delete(@PathVariable String slug) {
        stateService.delete(slug);
        return ResponseEntity.noContent().build();
    }
}
