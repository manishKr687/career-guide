package com.careerguide.api.service;

import com.careerguide.api.dto.SkillDto;
import com.careerguide.api.dto.SkillUpsertRequest;
import com.careerguide.api.entity.Skill;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.SlugList;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class SkillService {

    private final SkillRepository skillRepository;

    public SkillService(SkillRepository skillRepository) {
        this.skillRepository = skillRepository;
    }

    public List<SkillDto> findAll() {
        return skillRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    /**
     * The records for {@code slugs}, in one query instead of one request each.
     * See {@link com.careerguide.api.web.SlugList} for why this exists.
     *
     * <p>Order is the repository's, not the caller's, and unknown slugs are
     * simply absent -- the same contract the per-slug lookups had, where a 404
     * was dropped. The client restores its own ordering.
     */
    public List<SkillDto> findBySlugs(String slugs) {
        return skillRepository.findAllById(SlugList.parse(slugs)).stream()
                .map(DtoMapper::toDto)
                .toList();
    }

    public SkillDto findBySlug(String slug) {
        Skill skill = skillRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Skill", slug));
        return DtoMapper.toDto(skill);
    }

    @Transactional
    public SkillDto create(SkillUpsertRequest request) {
        if (skillRepository.existsById(request.slug())) {
            throw new ConflictException("Skill already exists: " + request.slug());
        }
        Skill skill = new Skill();
        skill.setSlug(request.slug());
        applyRequest(skill, request);
        skillRepository.save(skill);
        return DtoMapper.toDto(skill);
    }

    @Transactional
    public SkillDto update(String slug, SkillUpsertRequest request) {
        Skill skill = skillRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Skill", slug));
        applyRequest(skill, request);
        return DtoMapper.toDto(skill);
    }

    @Transactional
    public void delete(String slug) {
        if (!skillRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Skill", slug);
        }
        // Every join table referencing skills.slug (career_skills,
        // job_role_skills, certification_skills, resource_skills,
        // user_skills) has ON DELETE CASCADE -- see V24/V26/V27/V28/V30 --
        // so this cleans up every reference automatically, same convention
        // as CareerService.delete().
        skillRepository.deleteById(slug);
    }

    private void applyRequest(Skill skill, SkillUpsertRequest request) {
        skill.setName(request.name());
        skill.setSkillType(request.skillType());
        skill.setCategory(request.category());
        skill.setDescription(
                request.description() == null || request.description().isBlank()
                        ? null : request.description());
    }
}
