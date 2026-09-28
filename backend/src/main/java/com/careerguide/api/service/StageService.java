package com.careerguide.api.service;

import com.careerguide.api.dto.StageDto;
import com.careerguide.api.entity.Stage;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.StageRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class StageService {

    private final StageRepository stageRepository;

    public StageService(StageRepository stageRepository) {
        this.stageRepository = stageRepository;
    }

    public List<StageDto> findAll() {
        return stageRepository.findAllByOrderBySortOrderAsc().stream().map(DtoMapper::toDto).toList();
    }

    public StageDto findBySlug(String slug) {
        Stage stage = stageRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Stage", slug));
        return DtoMapper.toDto(stage);
    }
}
