package com.careerguide.api.service;

import com.careerguide.api.dto.ResourceDto;
import com.careerguide.api.dto.ResourceUpsertRequest;
import com.careerguide.api.entity.Resource;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.ResourceRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import com.careerguide.api.web.SlugList;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class ResourceService {

    private final ResourceRepository resourceRepository;
    private final CareerRepository careerRepository;
    private final ExamRepository examRepository;
    private final SkillRepository skillRepository;

    public ResourceService(
            ResourceRepository resourceRepository,
            CareerRepository careerRepository,
            ExamRepository examRepository,
            SkillRepository skillRepository
    ) {
        this.resourceRepository = resourceRepository;
        this.careerRepository = careerRepository;
        this.examRepository = examRepository;
        this.skillRepository = skillRepository;
    }

    public List<ResourceDto> findAll() {
        return resourceRepository.findAllByOrderByPublishedAtDesc().stream().map(DtoMapper::toDto).toList();
    }

    /**
     * The records for {slugs}, in one query instead of one request each.
     * See {@link com.careerguide.api.web.SlugList} for why this exists.
     */
    public List<ResourceDto> findBySlugs(String slugs) {
        return resourceRepository.findAllById(SlugList.parse(slugs)).stream()
                .map(DtoMapper::toDto)
                .toList();
    }

    public ResourceDto findBySlug(String slug) {
        Resource resource = resourceRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Resource", slug));
        return DtoMapper.toDto(resource);
    }

    @Transactional
    public ResourceDto create(ResourceUpsertRequest request) {
        if (resourceRepository.existsById(request.slug())) {
            throw new ConflictException("Resource already exists: " + request.slug());
        }
        Resource resource = new Resource();
        resource.setSlug(request.slug());
        applyRequest(resource, request);
        resourceRepository.save(resource);
        return DtoMapper.toDto(resource);
    }

    @Transactional
    public ResourceDto update(String slug, ResourceUpsertRequest request) {
        Resource resource = resourceRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Resource", slug));
        applyRequest(resource, request);
        return DtoMapper.toDto(resource);
    }

    @Transactional
    public void delete(String slug) {
        if (!resourceRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Resource", slug);
        }
        // resource_careers, resource_exams and resource_skills all cascade
        // on resources.slug -- see V28 -- so
        // this cleans up every reference automatically, same convention as
        // SkillService.delete().
        resourceRepository.deleteById(slug);
    }

    // Resource owns all its join tables outright (see the entity's
    // javadoc) -- none of Career/Exam/Skill has an inverse field for
    // these, so there's no second join table to keep in sync, unlike
    // Career's own relatedExams.
    private void applyRequest(Resource resource, ResourceUpsertRequest request) {
        resource.setTitle(request.title());
        resource.setResourceType(request.resourceType());
        resource.setDescription(request.description());
        resource.setContentUrl(request.contentUrl());
        resource.setAuthor(request.author());
        resource.setPublishedAt(request.publishedAt());
        resource.setRelatedCareers(new HashSet<>(resolveEach(request.relatedCareerSlugs(), careerRepository::findById, "career")));
        resource.setRelatedExams(new HashSet<>(resolveEach(request.relatedExamSlugs(), examRepository::findById, "exam")));
        resource.setRelatedSkills(new HashSet<>(resolveEach(request.relatedSkillSlugs(), skillRepository::findById, "skill")));
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
