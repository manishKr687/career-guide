package com.careerguide.api.service;

import com.careerguide.api.dto.CityDto;
import com.careerguide.api.dto.CityUpsertRequest;
import com.careerguide.api.entity.City;
import com.careerguide.api.entity.State;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CityRepository;
import com.careerguide.api.repository.StateRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** Added in V53 (College MVP). */
@Service
@Transactional(readOnly = true)
public class CityService {

    private final CityRepository cityRepository;
    private final StateRepository stateRepository;

    public CityService(CityRepository cityRepository, StateRepository stateRepository) {
        this.cityRepository = cityRepository;
        this.stateRepository = stateRepository;
    }

    public List<CityDto> findAll() {
        return cityRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    public CityDto findBySlug(String slug) {
        City city = cityRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("City", slug));
        return DtoMapper.toDto(city);
    }

    @Transactional
    public CityDto create(CityUpsertRequest request) {
        if (cityRepository.existsById(request.slug())) {
            throw new ConflictException("City already exists: " + request.slug());
        }
        City city = new City();
        city.setSlug(request.slug());
        applyRequest(city, request);
        cityRepository.save(city);
        return DtoMapper.toDto(city);
    }

    @Transactional
    public CityDto update(String slug, CityUpsertRequest request) {
        City city = cityRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("City", slug));
        applyRequest(city, request);
        return DtoMapper.toDto(city);
    }

    @Transactional
    public void delete(String slug) {
        if (!cityRepository.existsById(slug)) {
            throw NotFoundException.forSlug("City", slug);
        }
        cityRepository.deleteById(slug);
    }

    private void applyRequest(City city, CityUpsertRequest request) {
        city.setName(request.name());
        State state = stateRepository.findById(request.stateSlug())
                .orElseThrow(() -> new IllegalArgumentException("Unknown state slug: " + request.stateSlug()));
        city.setState(state);
    }
}
