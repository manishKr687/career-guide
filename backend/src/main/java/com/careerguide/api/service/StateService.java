package com.careerguide.api.service;

import com.careerguide.api.dto.StateDto;
import com.careerguide.api.dto.StateUpsertRequest;
import com.careerguide.api.entity.State;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.StateRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** Added in V53 (College MVP). No relations to resolve -- the simplest possible CRUD shape, same as CategoryService but with a write path. */
@Service
@Transactional(readOnly = true)
public class StateService {

    private final StateRepository stateRepository;

    public StateService(StateRepository stateRepository) {
        this.stateRepository = stateRepository;
    }

    public List<StateDto> findAll() {
        return stateRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    public StateDto findBySlug(String slug) {
        State state = stateRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("State", slug));
        return DtoMapper.toDto(state);
    }

    @Transactional
    public StateDto create(StateUpsertRequest request) {
        if (stateRepository.existsById(request.slug())) {
            throw new ConflictException("State already exists: " + request.slug());
        }
        State state = new State();
        state.setSlug(request.slug());
        applyRequest(state, request);
        stateRepository.save(state);
        return DtoMapper.toDto(state);
    }

    @Transactional
    public StateDto update(String slug, StateUpsertRequest request) {
        State state = stateRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("State", slug));
        applyRequest(state, request);
        return DtoMapper.toDto(state);
    }

    @Transactional
    public void delete(String slug) {
        if (!stateRepository.existsById(slug)) {
            throw NotFoundException.forSlug("State", slug);
        }
        // Cities/universities/colleges referencing this state have no
        // ON DELETE CASCADE (see V53's migration comment) -- deleting a
        // state still in use fails at the DB constraint level, which is
        // the desired behavior (states are effectively permanent reference
        // data, not something to prune casually).
        stateRepository.deleteById(slug);
    }

    private void applyRequest(State state, StateUpsertRequest request) {
        state.setName(request.name());
        state.setCode(request.code());
    }
}
