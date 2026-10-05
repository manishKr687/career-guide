package com.careerguide.api.service;

import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.dto.IndustryUpsertRequest;
import com.careerguide.api.entity.Industry;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.IndustryRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import com.careerguide.api.web.SlugList;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class IndustryService {

    private final IndustryRepository industryRepository;

    public IndustryService(IndustryRepository industryRepository) {
        this.industryRepository = industryRepository;
    }

    public List<IndustryDto> findAll() {
        return industryRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    /**
     * The records for {slugs}, in one query instead of one request each.
     * See {@link com.careerguide.api.web.SlugList} for why this exists.
     */
    public List<IndustryDto> findBySlugs(String slugs) {
        return industryRepository.findAllById(SlugList.parse(slugs)).stream()
                .map(DtoMapper::toDto)
                .toList();
    }

    public IndustryDto findBySlug(String slug) {
        Industry industry = industryRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Industry", slug));
        return DtoMapper.toDto(industry);
    }

    @Transactional
    public IndustryDto create(IndustryUpsertRequest request) {
        if (industryRepository.existsById(request.slug())) {
            throw new ConflictException("Industry already exists: " + request.slug());
        }
        Industry industry = new Industry();
        industry.setSlug(request.slug());
        applyRequest(industry, request);
        industryRepository.save(industry);
        return DtoMapper.toDto(industry);
    }

    @Transactional
    public IndustryDto update(String slug, IndustryUpsertRequest request) {
        Industry industry = industryRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Industry", slug));
        applyRequest(industry, request);
        return DtoMapper.toDto(industry);
    }

    @Transactional
    public void delete(String slug) {
        if (!industryRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Industry", slug);
        }
        // career_industries and job_role_industries both cascade on
        // industries.slug -- see V25/V26 -- so this cleans up every
        // reference automatically, same convention as SkillService.delete().
        industryRepository.deleteById(slug);
    }

    private void applyRequest(Industry industry, IndustryUpsertRequest request) {
        industry.setName(request.name());
        industry.setSector(request.isSector());
    }
}
