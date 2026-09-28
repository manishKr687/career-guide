package com.careerguide.api.service;

import com.careerguide.api.dto.JobRoleDto;
import com.careerguide.api.dto.JobRoleUpsertRequest;
import com.careerguide.api.entity.JobRole;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CertificationRepository;
import com.careerguide.api.repository.IndustryRepository;
import com.careerguide.api.repository.JobRoleRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class JobRoleService {

    private final JobRoleRepository jobRoleRepository;
    private final CareerRepository careerRepository;
    private final SkillRepository skillRepository;
    private final IndustryRepository industryRepository;
    private final CertificationRepository certificationRepository;

    public JobRoleService(
            JobRoleRepository jobRoleRepository,
            CareerRepository careerRepository,
            SkillRepository skillRepository,
            IndustryRepository industryRepository,
            CertificationRepository certificationRepository
    ) {
        this.jobRoleRepository = jobRoleRepository;
        this.careerRepository = careerRepository;
        this.skillRepository = skillRepository;
        this.industryRepository = industryRepository;
        this.certificationRepository = certificationRepository;
    }

    /**
     * @param careerSlug optional career slug filter (e.g. "software-engineer")
     */
    public List<JobRoleDto> findAll(String careerSlug) {
        List<JobRole> jobRoles = (careerSlug == null || careerSlug.isBlank())
                ? jobRoleRepository.findAllByOrderByNameAsc()
                : jobRoleRepository.findAllByCareers_SlugOrderByNameAsc(careerSlug);
        return jobRoles.stream().map(DtoMapper::toDto).toList();
    }

    public JobRoleDto findBySlug(String slug) {
        JobRole jobRole = jobRoleRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Job role", slug));
        return DtoMapper.toDto(jobRole);
    }

    @Transactional
    public JobRoleDto create(JobRoleUpsertRequest request) {
        if (jobRoleRepository.existsById(request.slug())) {
            throw new ConflictException("Job role already exists: " + request.slug());
        }
        JobRole jobRole = new JobRole();
        jobRole.setSlug(request.slug());
        applyRequest(jobRole, request);
        jobRoleRepository.save(jobRole);
        return DtoMapper.toDto(jobRole);
    }

    @Transactional
    public JobRoleDto update(String slug, JobRoleUpsertRequest request) {
        JobRole jobRole = jobRoleRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Job role", slug));
        applyRequest(jobRole, request);
        return DtoMapper.toDto(jobRole);
    }

    @Transactional
    public void delete(String slug) {
        if (!jobRoleRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Job role", slug);
        }
        // career_job_roles, job_role_skills, job_role_industries (V26) and
        // job_role_certifications (V72) all cascade on job_roles.slug, so
        // this cleans up every reference automatically, same convention as
        // CareerService.delete().
        jobRoleRepository.deleteById(slug);
    }

    // JobRole is the OWNING side of career_job_roles (see its javadoc), so
    // setCareers() here is all persistence needs -- no separate reverse
    // join table to keep in sync, unlike Career's own relatedCourses/
    // relatedExams (see CareerService's syncRelatedCourses/syncRelatedExams).
    private void applyRequest(JobRole jobRole, JobRoleUpsertRequest request) {
        jobRole.setName(request.name());
        jobRole.setDescription(request.description());
        jobRole.setExperienceLevel(request.experienceLevel());
        jobRole.setSalaryMin(request.salaryMin());
        jobRole.setSalaryMax(request.salaryMax());
        jobRole.setCareers(new HashSet<>(resolveEach(request.careerSlugs(), careerRepository::findById, "career")));
        jobRole.setRelatedSkills(new HashSet<>(resolveEach(request.relatedSkillSlugs(), skillRepository::findById, "skill")));
        jobRole.setRelatedIndustries(new HashSet<>(resolveEach(request.relatedIndustrySlugs(), industryRepository::findById, "industry")));
        jobRole.setRelatedCertifications(new HashSet<>(resolveEach(request.relatedCertificationSlugs(), certificationRepository::findById, "certification")));
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
