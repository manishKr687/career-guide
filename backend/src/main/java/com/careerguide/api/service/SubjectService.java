package com.careerguide.api.service;

import com.careerguide.api.dto.SubjectDto;
import com.careerguide.api.dto.SubjectUpsertRequest;
import com.careerguide.api.entity.Category;
import com.careerguide.api.entity.Subject;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.repository.SubjectRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class SubjectService {

    private final SubjectRepository subjectRepository;
    private final CategoryRepository categoryRepository;

    public SubjectService(SubjectRepository subjectRepository, CategoryRepository categoryRepository) {
        this.subjectRepository = subjectRepository;
        this.categoryRepository = categoryRepository;
    }

    public List<SubjectDto> findAll() {
        return subjectRepository.findAllByOrderByTitleAsc().stream().map(DtoMapper::toDto).toList();
    }

    public List<SubjectDto> findByCategory(String categorySlug) {
        return subjectRepository.findAllByCategory_SlugOrderByTitleAsc(categorySlug)
                .stream().map(DtoMapper::toDto).toList();
    }

    public SubjectDto findBySlug(String slug) {
        Subject subject = subjectRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Subject", slug));
        return DtoMapper.toDto(subject);
    }

    @Transactional
    public SubjectDto create(SubjectUpsertRequest request) {
        if (subjectRepository.existsById(request.slug())) {
            throw new ConflictException("Subject already exists: " + request.slug());
        }
        Subject subject = new Subject();
        subject.setSlug(request.slug());
        applyRequest(subject, request);
        subjectRepository.save(subject);
        return DtoMapper.toDto(subject);
    }

    @Transactional
    public SubjectDto update(String slug, SubjectUpsertRequest request) {
        Subject subject = subjectRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Subject", slug));
        applyRequest(subject, request);
        return DtoMapper.toDto(subject);
    }

    @Transactional
    public void delete(String slug) {
        if (!subjectRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Subject", slug);
        }
        // Deliberately NOT a cascade, unlike SkillService/IndustryService: the
        // subject FKs on the qualification link tables are ON DELETE RESTRICT
        // (V89), so deleting a subject that is still paired with a degree
        // fails at the database rather than silently removing those pairings.
        // The cascade convention exists for pure tag-like relations; a subject
        // carries the meaning of the row it sits in, so losing it silently
        // would turn "M.Sc (Physics)" into a bare "M.Sc" with no trace.
        subjectRepository.deleteById(slug);
    }

    private void applyRequest(Subject subject, SubjectUpsertRequest request) {
        subject.setTitle(request.title());
        subject.setDescription(request.description());
        subject.setIcon(request.icon());
        subject.setCategory(resolveCategory(request.categorySlug()));
    }

    private Category resolveCategory(String categorySlug) {
        return categoryRepository.findById(categorySlug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown category slug: " + categorySlug));
    }
}
