package com.careerguide.api.service;

import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.dto.CertificationUpsertRequest;
import com.careerguide.api.entity.Certification;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CertificationRepository;
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
public class CertificationService {

    private final CertificationRepository certificationRepository;
    private final CareerRepository careerRepository;
    private final SkillRepository skillRepository;

    public CertificationService(
            CertificationRepository certificationRepository,
            CareerRepository careerRepository,
            SkillRepository skillRepository
    ) {
        this.certificationRepository = certificationRepository;
        this.careerRepository = careerRepository;
        this.skillRepository = skillRepository;
    }

    public List<CertificationDto> findAll() {
        return certificationRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    /**
     * The records for {slugs}, in one query instead of one request each.
     * See {@link com.careerguide.api.web.SlugList} for why this exists.
     */
    public List<CertificationDto> findBySlugs(String slugs) {
        return certificationRepository.findAllById(SlugList.parse(slugs)).stream()
                .map(DtoMapper::toDto)
                .toList();
    }

    public CertificationDto findBySlug(String slug) {
        Certification certification = certificationRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Certification", slug));
        return DtoMapper.toDto(certification);
    }

    @Transactional
    public CertificationDto create(CertificationUpsertRequest request) {
        if (certificationRepository.existsById(request.slug())) {
            throw new ConflictException("Certification already exists: " + request.slug());
        }
        Certification certification = new Certification();
        certification.setSlug(request.slug());
        applyRequest(certification, request);
        certificationRepository.save(certification);
        return DtoMapper.toDto(certification);
    }

    @Transactional
    public CertificationDto update(String slug, CertificationUpsertRequest request) {
        Certification certification = certificationRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Certification", slug));
        applyRequest(certification, request);
        return DtoMapper.toDto(certification);
    }

    @Transactional
    public void delete(String slug) {
        if (!certificationRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Certification", slug);
        }
        // certification_careers and certification_skills both cascade on
        // certifications.slug -- see V27 -- so this cleans up every
        // reference automatically, same convention as SkillService.delete().
        certificationRepository.deleteById(slug);
    }

    // Certification owns both certification_careers and certification_skills
    // outright (see the entity's javadoc) -- neither Career nor Skill has an
    // inverse field for these, so there's no second join table to keep in
    // sync, unlike Career's own relatedCourses/relatedExams.
    private void applyRequest(Certification certification, CertificationUpsertRequest request) {
        certification.setName(request.name());
        certification.setDescription(request.description());
        certification.setProvider(request.provider());
        certification.setLevel(request.level());
        certification.setDuration(request.duration());
        certification.setOfficialUrl(request.officialUrl());
        certification.setRelatedCareers(new HashSet<>(resolveEach(request.relatedCareerSlugs(), careerRepository::findById, "career")));
        certification.setRelatedSkills(new HashSet<>(resolveEach(request.relatedSkillSlugs(), skillRepository::findById, "skill")));
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
