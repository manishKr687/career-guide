package com.careerguide.api.service;

import com.careerguide.api.dto.UniversityDto;
import com.careerguide.api.dto.UniversityUpsertRequest;
import com.careerguide.api.entity.City;
import com.careerguide.api.entity.State;
import com.careerguide.api.entity.University;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CityRepository;
import com.careerguide.api.repository.StateRepository;
import com.careerguide.api.repository.UniversityRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/** Added in V53 (College MVP). */
@Service
@Transactional(readOnly = true)
public class UniversityService {

    private final UniversityRepository universityRepository;
    private final StateRepository stateRepository;
    private final CityRepository cityRepository;

    public UniversityService(UniversityRepository universityRepository, StateRepository stateRepository, CityRepository cityRepository) {
        this.universityRepository = universityRepository;
        this.stateRepository = stateRepository;
        this.cityRepository = cityRepository;
    }

    public List<UniversityDto> findAll() {
        return universityRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    public UniversityDto findBySlug(String slug) {
        University university = universityRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("University", slug));
        return DtoMapper.toDto(university);
    }

    @Transactional
    public UniversityDto create(UniversityUpsertRequest request) {
        if (universityRepository.existsById(request.slug())) {
            throw new ConflictException("University already exists: " + request.slug());
        }
        University university = new University();
        university.setSlug(request.slug());
        applyRequest(university, request);
        universityRepository.save(university);
        return DtoMapper.toDto(university);
    }

    @Transactional
    public UniversityDto update(String slug, UniversityUpsertRequest request) {
        University university = universityRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("University", slug));
        applyRequest(university, request);
        return DtoMapper.toDto(university);
    }

    @Transactional
    public void delete(String slug) {
        if (!universityRepository.existsById(slug)) {
            throw NotFoundException.forSlug("University", slug);
        }
        // Colleges referencing this university have ON DELETE SET NULL
        // (V53) -- deleting a university just un-links its colleges rather
        // than failing or cascading.
        universityRepository.deleteById(slug);
    }

    private void applyRequest(University university, UniversityUpsertRequest request) {
        university.setName(request.name());
        university.setUniversityType(request.universityType());
        university.setOwnershipType(request.ownershipType());
        university.setState(resolveState(request.stateSlug()));
        university.setCity(resolveCity(request.citySlug()));
        university.setWebsite(request.website());
        university.setStatus(request.status());
    }

    private State resolveState(String stateSlug) {
        if (!StringUtils.hasText(stateSlug)) {
            return null;
        }
        return stateRepository.findById(stateSlug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown state slug: " + stateSlug));
    }

    private City resolveCity(String citySlug) {
        if (!StringUtils.hasText(citySlug)) {
            return null;
        }
        return cityRepository.findById(citySlug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown city slug: " + citySlug));
    }
}
