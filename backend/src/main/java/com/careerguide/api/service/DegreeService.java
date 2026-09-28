package com.careerguide.api.service;

import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.dto.DegreeUpsertRequest;
import com.careerguide.api.entity.Category;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.ResourceRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.SubjectRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class DegreeService {

    private final DegreeRepository degreeRepository;
    private final ExamRepository examRepository;
    private final SkillRepository skillRepository;
    private final ResourceRepository resourceRepository;
    private final CategoryRepository categoryRepository;
    private final SubjectRepository subjectRepository;

    public DegreeService(
            DegreeRepository degreeRepository,
            ExamRepository examRepository,
            SkillRepository skillRepository,
            ResourceRepository resourceRepository,
            CategoryRepository categoryRepository,
            SubjectRepository subjectRepository
    ) {
        this.degreeRepository = degreeRepository;
        this.examRepository = examRepository;
        this.skillRepository = skillRepository;
        this.resourceRepository = resourceRepository;
        this.categoryRepository = categoryRepository;
        this.subjectRepository = subjectRepository;
    }

    public List<DegreeDto> findAll() {
        return degreeRepository.findAllByOrderByTitleAsc().stream().map(DtoMapper::toDto).toList();
    }

    public DegreeDto findBySlug(String slug) {
        Degree degree = degreeRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Degree", slug));
        return DtoMapper.toDto(degree);
    }

    @Transactional
    public DegreeDto create(DegreeUpsertRequest request) {
        if (degreeRepository.existsById(request.slug())) {
            throw new ConflictException("Degree already exists: " + request.slug());
        }
        Degree degree = new Degree();
        degree.setSlug(request.slug());
        applyRequest(degree, request);
        degreeRepository.save(degree);
        return DtoMapper.toDto(degree);
    }

    @Transactional
    public DegreeDto update(String slug, DegreeUpsertRequest request) {
        Degree degree = degreeRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Degree", slug));
        applyRequest(degree, request);
        return DtoMapper.toDto(degree);
    }

    @Transactional
    public void delete(String slug) {
        if (!degreeRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Degree", slug);
        }
        degreeRepository.deleteById(slug);
    }

    private void applyRequest(Degree degree, DegreeUpsertRequest request) {
        degree.setTitle(request.title());
        degree.setDescription(request.description());
        degree.setIcon(request.icon());
        degree.setPreparationStrategy(request.preparationStrategy());
        degree.setLevel(request.level());
        degree.setCategory(resolveCategory(request.categorySlug()));
        degree.setFullTitle(request.fullTitle() == null || request.fullTitle().isBlank()
                ? null : request.fullTitle());
        degree.setDurationMinYears(request.durationMinYears());
        degree.setDurationMaxYears(request.durationMaxYears());
        degree.setRequiresSubject(request.requiresSubject());
        degree.setRelatedExams(resolveEach(request.entranceExamSlugs(), examRepository::findById, "exam"));
        degree.setRelatedSkills(resolveEach(request.skillSlugs(), skillRepository::findById, "skill"));
        degree.setRelatedResources(resolveEach(request.resourceSlugs(), resourceRepository::findById, "resource"));
        degree.setSubjects(resolveEach(request.subjectSlugs(), subjectRepository::findById, "subject"));
    }

    private Category resolveCategory(String categorySlug) {
        if (categorySlug == null || categorySlug.isBlank()) {
            return null;
        }
        return categoryRepository.findById(categorySlug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown category slug: " + categorySlug));
    }

    private <T> List<T> resolveEach(List<String> slugs, Function<String, Optional<T>> lookup, String entityName) {
        if (slugs == null) {
            return new ArrayList<>();
        }
        List<T> result = new ArrayList<>();
        for (String slug : slugs) {
            result.add(lookup.apply(slug)
                    .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug)));
        }
        return result;
    }
}
