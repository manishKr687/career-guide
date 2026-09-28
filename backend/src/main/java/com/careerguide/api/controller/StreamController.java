package com.careerguide.api.controller;

import com.careerguide.api.dto.StreamDto;
import com.careerguide.api.service.StreamService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/streams")
public class StreamController {

    private final StreamService streamService;

    public StreamController(StreamService streamService) {
        this.streamService = streamService;
    }

    @GetMapping
    public List<StreamDto> findAll() {
        return streamService.findAll();
    }

    @GetMapping("/{slug}")
    public StreamDto findBySlug(@PathVariable String slug) {
        return streamService.findBySlug(slug);
    }
}
