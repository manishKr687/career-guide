package com.careerguide.api.service;

import com.careerguide.api.dto.ExamCareerDegreeDto;
import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.dto.ExamUpsertRequest;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.entity.Exam;
import com.careerguide.api.entity.ExamCareerDegree;
import com.careerguide.api.entity.JobRole;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.JobRoleRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class ExamService {

    private final ExamRepository examRepository;
    private final CareerRepository careerRepository;
    private final DegreeRepository degreeRepository;
    private final JobRoleRepository jobRoleRepository;
    private final CategoryRepository categoryRepository;

    public ExamService(
            ExamRepository examRepository,
            CareerRepository careerRepository,
            DegreeRepository degreeRepository,
            JobRoleRepository jobRoleRepository,
            CategoryRepository categoryRepository
    ) {
        this.examRepository = examRepository;
        this.careerRepository = careerRepository;
        this.degreeRepository = degreeRepository;
        this.jobRoleRepository = jobRoleRepository;
        this.categoryRepository = categoryRepository;
    }

    public Page<ExamDto> findAll(String category, String q, Pageable pageable) {
        String normalizedCategory = StringUtils.hasText(category) ? category : null;
        String normalizedQuery = StringUtils.hasText(q) ? q.trim() : null;
        return examRepository.search(normalizedCategory, normalizedQuery, pageable).map(DtoMapper::toDto);
    }

    public ExamDto findBySlug(String slug) {
        Exam exam = examRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Exam", slug));
        return DtoMapper.toDto(exam);
    }

    @Transactional
    public ExamDto create(ExamUpsertRequest request) {
        if (examRepository.existsById(request.slug())) {
            throw new ConflictException("Exam already exists: " + request.slug());
        }
        Exam exam = new Exam();
        exam.setSlug(request.slug());
        applyRequest(exam, request);
        examRepository.save(exam);
        syncRelatedCareers(exam, List.of(), exam.getRelatedCareers());
        syncRelatedJobRoles(exam, Set.of(), exam.getRelatedJobRoles());
        return DtoMapper.toDto(exam);
    }

    @Transactional
    public ExamDto update(String slug, ExamUpsertRequest request) {
        Exam exam = examRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Exam", slug));
        List<Career> oldCareers = new ArrayList<>(exam.getRelatedCareers());
        Set<JobRole> oldJobRoles = new HashSet<>(exam.getRelatedJobRoles());
        applyRequest(exam, request);
        syncRelatedCareers(exam, oldCareers, exam.getRelatedCareers());
        syncRelatedJobRoles(exam, oldJobRoles, exam.getRelatedJobRoles());
        return DtoMapper.toDto(exam);
    }

    // exam_careers (this entity's relatedCareers) and career_exams
    // (Career.relatedExams) are two independently-writable directions of the
    // same relationship -- mirrors CareerService.syncRelatedExams, see the
    // backend README's "Keeping bidirectional relationships in sync"
    // section. Career entities touched here are already managed by this
    // transaction's persistence context, so reference equality via
    // List.contains/remove/add correctly identifies "the same row".
    private void syncRelatedCareers(Exam exam, List<Career> oldCareers, List<Career> newCareers) {
        for (Career removed : oldCareers) {
            if (!newCareers.contains(removed)) {
                removed.getRelatedExams().remove(exam);
            }
        }
        for (Career added : newCareers) {
            if (!oldCareers.contains(added) && !added.getRelatedExams().contains(exam)) {
                added.getRelatedExams().add(exam);
            }
        }
    }

    // exam_job_roles (this entity's relatedJobRoles) and JobRole.relatedExams
    // are two independently-writable directions of the same relationship --
    // same bidirectional-sync convention as syncRelatedCareers above, just
    // over a Set instead of an ordered List since neither side of this
    // relation has a sort_order (see Exam.relatedJobRoles's javadoc).
    private void syncRelatedJobRoles(Exam exam, Set<JobRole> oldJobRoles, Set<JobRole> newJobRoles) {
        for (JobRole removed : oldJobRoles) {
            if (!newJobRoles.contains(removed)) {
                removed.getRelatedExams().remove(exam);
            }
        }
        for (JobRole added : newJobRoles) {
            if (!oldJobRoles.contains(added)) {
                added.getRelatedExams().add(exam);
            }
        }
    }

    @Transactional
    public void delete(String slug) {
        if (!examRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Exam", slug);
        }
        // See the equivalent note in CareerService.delete: every join table
        // referencing exams.slug cascades on delete (V1__schema.sql).
        examRepository.deleteById(slug);
    }

    private void applyRequest(Exam exam, ExamUpsertRequest request) {
        exam.setName(request.name());
        exam.setFullName(request.fullName());
        exam.setCategory(request.category());
        exam.setConductedBy(request.conductedBy());
        exam.setFrequency(request.frequency());
        exam.setDescription(request.description());
        exam.setIcon(request.icon());
        exam.setRelatedCareers(resolveEach(request.relatedCareerSlugs(), careerRepository::findById, "career"));
        exam.setMode(request.mode());
        exam.setEligibilityMinQualification(request.eligibilityMinQualification());
        exam.setOfficialWebsite(request.officialWebsite());
        exam.setSyllabusOverview(request.syllabusOverview());
        exam.setExamType(request.examType());
        // Null category is legitimate -- CUET and NTSE span every field --
        // so a blank slug clears the link rather than failing validation.
        exam.setFieldCategory(
                request.categorySlug() == null || request.categorySlug().isBlank()
                        ? null
                        : categoryRepository.findById(request.categorySlug()).orElseThrow(
                                () -> new IllegalArgumentException(
                                        "Unknown category slug: " + request.categorySlug())));
        exam.setLevel(request.level());
        exam.setFrequencyType(request.frequencyType());
        exam.setRelatedJobRoles(new HashSet<>(resolveEach(request.jobRoleSlugs(), jobRoleRepository::findById, "job role")));
        syncCareerDegreeOfferings(exam, request.careerDegreeOfferings());
    }

    // Same diff-and-reorder approach as CollegeService.syncCareerOfferings:
    // rows no longer requested are removed (orphanRemoval on
    // Exam.careerDegreeOfferings deletes them), rows already present are
    // just reordered, and new pairs get a new ExamCareerDegree.
    private void syncCareerDegreeOfferings(Exam exam, List<ExamCareerDegreeDto> requested) {
        List<ExamCareerDegreeDto> offerings = requested == null ? List.of() : requested;

        exam.getCareerDegreeOfferings().removeIf(existing -> offerings.stream().noneMatch(o ->
                o.careerSlug().equals(existing.getCareer().getSlug()) && o.degreeSlug().equals(existing.getDegree().getSlug())));

        int sortOrder = 0;
        for (ExamCareerDegreeDto offering : offerings) {
            ExamCareerDegree existing = exam.getCareerDegreeOfferings().stream()
                    .filter(o -> o.getCareer().getSlug().equals(offering.careerSlug()) && o.getDegree().getSlug().equals(offering.degreeSlug()))
                    .findFirst()
                    .orElse(null);
            if (existing != null) {
                existing.setSortOrder(sortOrder);
            } else {
                Career career = resolveRequired(offering.careerSlug(), careerRepository::findById, "career");
                Degree degree = resolveRequired(offering.degreeSlug(), degreeRepository::findById, "degree");
                exam.getCareerDegreeOfferings().add(new ExamCareerDegree(exam, career, degree, sortOrder));
            }
            sortOrder++;
        }
    }

    private <T> T resolveRequired(String slug, Function<String, Optional<T>> lookup, String entityName) {
        return lookup.apply(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug));
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
