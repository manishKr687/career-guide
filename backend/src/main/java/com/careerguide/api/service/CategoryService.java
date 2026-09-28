package com.careerguide.api.service;

import com.careerguide.api.dto.CategoryDto;
import com.careerguide.api.entity.Category;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<CategoryDto> findAll() {
        return categoryRepository.findAll().stream().map(DtoMapper::toDto).toList();
    }

    public CategoryDto findBySlug(String slug) {
        Category category = categoryRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Category", slug));
        return DtoMapper.toDto(category);
    }
}
