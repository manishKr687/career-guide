package com.careerguide.api.service;

import com.careerguide.api.dto.StreamDto;
import com.careerguide.api.entity.Stream;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.StreamRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class StreamService {

    private final StreamRepository streamRepository;

    public StreamService(StreamRepository streamRepository) {
        this.streamRepository = streamRepository;
    }

    public List<StreamDto> findAll() {
        return streamRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    public StreamDto findBySlug(String slug) {
        Stream stream = streamRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Stream", slug));
        return DtoMapper.toDto(stream);
    }
}
