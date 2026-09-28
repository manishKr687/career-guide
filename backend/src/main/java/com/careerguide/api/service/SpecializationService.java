package com.careerguide.api.service;

import com.careerguide.api.dto.EducationDto;
import com.careerguide.api.dto.SpecializationDto;
import com.careerguide.api.dto.SpecializationUpsertRequest;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.entity.Specialization;
import com.careerguide.api.entity.SpecializationDegree;
import com.careerguide.api.entity.Subject;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CertificationRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.IndustryRepository;
import com.careerguide.api.repository.JobRoleRepository;
import com.careerguide.api.repository.ResourceRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.SpecializationRepository;
import com.careerguide.api.repository.SubjectRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class SpecializationService {

    private final SpecializationRepository specializationRepository;
    private final ExamRepository examRepository;
    private final CareerRepository careerRepository;
    private final JobRoleRepository jobRoleRepository;
    private final SkillRepository skillRepository;
    private final CertificationRepository certificationRepository;
    private final IndustryRepository industryRepository;
    private final DegreeRepository degreeRepository;
    private final SubjectRepository subjectRepository;
    private final ResourceRepository resourceRepository;

    public SpecializationService(
            SpecializationRepository specializationRepository,
            ExamRepository examRepository,
            CareerRepository careerRepository,
            JobRoleRepository jobRoleRepository,
            SkillRepository skillRepository,
            CertificationRepository certificationRepository,
            IndustryRepository industryRepository,
            DegreeRepository degreeRepository,
            SubjectRepository subjectRepository,
            ResourceRepository resourceRepository
    ) {
        this.specializationRepository = specializationRepository;
        this.examRepository = examRepository;
        this.careerRepository = careerRepository;
        this.jobRoleRepository = jobRoleRepository;
        this.skillRepository = skillRepository;
        this.certificationRepository = certificationRepository;
        this.industryRepository = industryRepository;
        this.degreeRepository = degreeRepository;
        this.subjectRepository = subjectRepository;
        this.resourceRepository = resourceRepository;
    }

    public List<SpecializationDto> findAll() {
        return specializationRepository.findAllByOrderByNameAsc().stream().map(DtoMapper::toDto).toList();
    }

    public SpecializationDto findBySlug(String slug) {
        Specialization specialization = specializationRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Specialization", slug));
        return DtoMapper.toDto(specialization);
    }

    @Transactional
    public SpecializationDto create(SpecializationUpsertRequest request) {
        if (specializationRepository.existsById(request.slug())) {
            throw new ConflictException("Specialization already exists: " + request.slug());
        }
        Specialization specialization = new Specialization();
        specialization.setSlug(request.slug());
        applyRequest(specialization, request);
        specializationRepository.save(specialization);
        syncCareerLinks(specialization, request.careerSlugs());
        return DtoMapper.toDto(specialization);
    }

    @Transactional
    public SpecializationDto update(String slug, SpecializationUpsertRequest request) {
        Specialization specialization = specializationRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Specialization", slug));
        applyRequest(specialization, request);
        syncCareerLinks(specialization, request.careerSlugs());
        return DtoMapper.toDto(specialization);
    }

    @Transactional
    public void delete(String slug) {
        if (!specializationRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Specialization", slug);
        }
        specializationRepository.deleteById(slug);
    }

    private void applyRequest(Specialization specialization, SpecializationUpsertRequest request) {
        specialization.setName(request.name());
        specialization.setDescription(request.description());
        specialization.setIcon(request.icon());
        specialization.setRelatedExams(resolveEach(request.relatedExamSlugs(), examRepository::findById, "exam"));
        specialization.setRelatedJobRoles(resolveEach(request.relatedJobRoleSlugs(), jobRoleRepository::findById, "job role"));
        specialization.setRelatedHardSkills(resolveEach(request.relatedHardSkillSlugs(), skillRepository::findById, "skill"));
        specialization.setRelatedSoftSkills(resolveEach(request.relatedSoftSkillSlugs(), skillRepository::findById, "skill"));
        specialization.setResponsibilities(request.responsibilities() == null ? new ArrayList<>() : request.responsibilities());
        specialization.setDemand(request.demand());
        specialization.setRelatedCertifications(resolveEach(request.certificationSlugs(), certificationRepository::findById, "certification"));
        specialization.setRelatedIndustries(resolveEach(request.industrySlugs(), industryRepository::findById, "industry"));
        specialization.setOverview(blankToNull(request.overview()));
        specialization.setHighlights(request.highlights() == null ? new ArrayList<>() : request.highlights());
        specialization.setRelatedResources(resolveEach(request.resourceSlugs(), resourceRepository::findById, "resource"));
        specialization.setSalaryMinLpa(request.salaryMinLpa());
        specialization.setSalaryMaxLpa(request.salaryMaxLpa());
        syncEducation(specialization, request.education());
    }

    /**
     * Diffs the education list in place. The list cannot be replaced wholesale
     * -- orphanRemoval=true means a new instance detaches the old rows rather
     * than deleting them -- and rows are matched on the (degree, subject) PAIR
     * rather than the degree alone, since the same degree may legitimately
     * appear twice in two subjects.
     *
     * <p>Identical to CareerService.syncEducation; the two are kept separate
     * because the entity types differ, not because the rule does.
     */
    private void syncEducation(Specialization specialization, List<EducationDto> requested) {
        List<EducationDto> wanted = requested == null ? List.of() : requested;

        specialization.getEducation().removeIf(existing -> wanted.stream().noneMatch(e -> matches(existing, e)));

        int sortOrder = 0;
        for (EducationDto e : wanted) {
            SpecializationDegree existing = specialization.getEducation().stream()
                    .filter(sd -> matches(sd, e))
                    .findFirst()
                    .orElse(null);
            if (existing != null) {
                existing.setSortOrder(sortOrder);
            } else {
                Degree degree = resolveRequired(e.degreeSlug(), degreeRepository::findById, "degree");
                Subject subject = blankToNull(e.subjectSlug()) == null
                        ? null
                        : resolveRequired(e.subjectSlug(), subjectRepository::findById, "subject");
                specialization.getEducation().add(new SpecializationDegree(specialization, degree, subject, sortOrder));
            }
            sortOrder++;
        }
    }

    private static boolean matches(SpecializationDegree existing, EducationDto requested) {
        if (!existing.getDegree().getSlug().equals(requested.degreeSlug())) {
            return false;
        }
        String have = existing.getSubject() == null ? null : existing.getSubject().getSlug();
        return Objects.equals(have, blankToNull(requested.subjectSlug()));
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s;
    }

    private <T> T resolveRequired(String slug, Function<String, Optional<T>> lookup, String entityName) {
        return lookup.apply(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug));
    }

    private void syncCareerLinks(Specialization specialization, List<String> careerSlugs) {
        List<Career> requested = resolveEach(careerSlugs, careerRepository::findById, "career");
        List<Career> current = careerRepository.findAllByRelatedSpecializations_SlugOrderByTitleAsc(specialization.getSlug());

        for (Career career : current) {
            boolean stillRequested = requested.stream().anyMatch(c -> c.getSlug().equals(career.getSlug()));
            if (!stillRequested) {
                career.getRelatedSpecializations().removeIf(s -> s.getSlug().equals(specialization.getSlug()));
                careerRepository.save(career);
                specialization.getCareers().removeIf(c -> c.getSlug().equals(career.getSlug()));
            }
        }
        for (Career career : requested) {
            boolean alreadyLinked = current.stream().anyMatch(c -> c.getSlug().equals(career.getSlug()));
            if (!alreadyLinked) {
                career.getRelatedSpecializations().add(specialization);
                careerRepository.save(career);
                specialization.getCareers().add(career);
            }
        }
    }

    private <T> List<T> resolveEach(List<String> slugs, Function<String, Optional<T>> lookup, String entityName) {
        if (slugs == null) return new ArrayList<>();
        List<T> result = new ArrayList<>();
        for (String slug : slugs) {
            result.add(lookup.apply(slug)
                    .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug)));
        }
        return result;
    }
}
