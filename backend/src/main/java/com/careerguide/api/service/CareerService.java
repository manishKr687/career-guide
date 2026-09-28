package com.careerguide.api.service;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CareerUpsertRequest;
import com.careerguide.api.dto.EducationDto;
import com.careerguide.api.entity.CareerSalaryBand;
import com.careerguide.api.entity.CareerGrowthStage;
import com.careerguide.api.dto.SalaryBandDto;
import com.careerguide.api.dto.GrowthStageDto;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.CareerDegree;
import com.careerguide.api.entity.Category;
import com.careerguide.api.entity.College;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.entity.Exam;
import com.careerguide.api.entity.Industry;
import com.careerguide.api.entity.JobRole;
import com.careerguide.api.entity.Skill;
import com.careerguide.api.entity.Specialization;
import com.careerguide.api.entity.Subject;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.repository.CollegeRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.IndustryRepository;
import com.careerguide.api.repository.JobRoleRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.SpecializationRepository;
import com.careerguide.api.repository.StageRepository;
import com.careerguide.api.repository.SubjectRepository;
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
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class CareerService {

    private final CareerRepository careerRepository;
    private final CategoryRepository categoryRepository;
    private final ExamRepository examRepository;
    private final StageRepository stageRepository;
    private final SkillRepository skillRepository;
    private final IndustryRepository industryRepository;
    private final CollegeRepository collegeRepository;
    private final SpecializationRepository specializationRepository;
    private final JobRoleRepository jobRoleRepository;
    private final DegreeRepository degreeRepository;
    private final SubjectRepository subjectRepository;

    public CareerService(
            CareerRepository careerRepository,
            CategoryRepository categoryRepository,
            ExamRepository examRepository,
            StageRepository stageRepository,
            SkillRepository skillRepository,
            IndustryRepository industryRepository,
            CollegeRepository collegeRepository,
            SpecializationRepository specializationRepository,
            JobRoleRepository jobRoleRepository,
            DegreeRepository degreeRepository,
            SubjectRepository subjectRepository
    ) {
        this.careerRepository = careerRepository;
        this.categoryRepository = categoryRepository;
        this.examRepository = examRepository;
        this.stageRepository = stageRepository;
        this.skillRepository = skillRepository;
        this.industryRepository = industryRepository;
        this.collegeRepository = collegeRepository;
        this.specializationRepository = specializationRepository;
        this.jobRoleRepository = jobRoleRepository;
        this.degreeRepository = degreeRepository;
        this.subjectRepository = subjectRepository;
    }

    public Page<CareerDto> findAll(String category, String q, Pageable pageable) {
        String normalizedCategory = StringUtils.hasText(category) ? category : null;
        String normalizedQuery = StringUtils.hasText(q) ? q.trim() : null;
        return careerRepository.search(normalizedCategory, normalizedQuery, pageable).map(DtoMapper::toDto);
    }

    public CareerDto findBySlug(String slug) {
        Career career = careerRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Career", slug));
        return DtoMapper.toDto(career);
    }

    @Transactional
    public CareerDto create(CareerUpsertRequest request) {
        if (careerRepository.existsById(request.slug())) {
            throw new ConflictException("Career already exists: " + request.slug());
        }
        Career career = new Career();
        career.setSlug(request.slug());
        applyRequest(career, request);
        careerRepository.save(career);
        syncRelatedExams(career, List.of(), career.getRelatedExams());
        syncJobRoles(career, Set.of(), career.getJobRoles());
        return DtoMapper.toDto(career);
    }

    @Transactional
    public CareerDto update(String slug, CareerUpsertRequest request) {
        Career career = careerRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Career", slug));
        List<Exam> oldExams = new ArrayList<>(career.getRelatedExams());
        Set<JobRole> oldJobRoles = new HashSet<>(career.getJobRoles());
        applyRequest(career, request);
        syncRelatedExams(career, oldExams, career.getRelatedExams());
        syncJobRoles(career, oldJobRoles, career.getJobRoles());
        return DtoMapper.toDto(career);
    }

    // Same reasoning as syncRelatedCourses, for career_exams / exam_careers
    // (Exam.relatedCareers), kept in sync with ExamService's own mirror.
    private void syncRelatedExams(Career career, List<Exam> oldExams, List<Exam> newExams) {
        for (Exam removed : oldExams) {
            if (!newExams.contains(removed)) {
                removed.getRelatedCareers().remove(career);
            }
        }
        for (Exam added : newExams) {
            if (!oldExams.contains(added) && !added.getRelatedCareers().contains(career)) {
                added.getRelatedCareers().add(career);
            }
        }
    }

    // career_job_roles is owned by JobRole (JobRole.careers), the reverse of
    // every relation above -- Career.jobRoles is declared `mappedBy` on the
    // Career side, so persisting a change here means mutating each affected
    // JobRole's own `careers` collection, not career.getJobRoles() itself
    // (applyRequest already set that directly via career.setJobRoles(...)
    // purely so this request's own returned DTO is correct immediately,
    // without depending on a lazy-reload picking up the pending change).
    private void syncJobRoles(Career career, Set<JobRole> oldJobRoles, Set<JobRole> newJobRoles) {
        for (JobRole removed : oldJobRoles) {
            if (!newJobRoles.contains(removed)) {
                removed.getCareers().remove(career);
            }
        }
        for (JobRole added : newJobRoles) {
            if (!oldJobRoles.contains(added)) {
                added.getCareers().add(career);
            }
        }
    }

    @Transactional
    public void delete(String slug) {
        if (!careerRepository.existsById(slug)) {
            throw NotFoundException.forSlug("Career", slug);
        }
        // Every join table referencing careers.slug (career_exams,
        // exam_careers, career_stages, stage_careers) has ON DELETE CASCADE,
        // so this cleans up all of a career's relations on every side
        // automatically -- see V1__schema.sql.
        careerRepository.deleteById(slug);
    }

    private void applyRequest(Career career, CareerUpsertRequest request) {
        Category category = categoryRepository.findById(request.categorySlug())
                .orElseThrow(() -> new IllegalArgumentException("Unknown category slug: " + request.categorySlug()));

        career.setTitle(request.title());
        career.setCategory(category);
        career.setTagline(request.tagline());
        career.setDemand(request.demand());
        career.setTypicalWork(request.typicalWork());
        career.setSalaryMinLpa(request.salaryMinLpa());
        career.setSalaryMaxLpa(request.salaryMaxLpa());
        // salary_range is NOT NULL in the schema and is still read by older
        // queries, so it is written here from the numbers rather than left to
        // drift. It is a cache of SalaryRange.compose, not an input: the
        // admin form no longer offers it.
        career.setSalaryRange(
                java.util.Objects.requireNonNullElse(
                        com.careerguide.api.entity.SalaryRange.compose(
                                request.salaryMinLpa(), request.salaryMaxLpa()),
                        ""));
        career.setGrowthPath(nonNullCopy(request.growthPath()));
        career.setHighlights(nonNullCopy(request.highlights()));
        career.setWorkEnvironments(nonNullCopy(request.workEnvironments()));
        career.setExperienceMinYears(request.experienceMinYears());
        career.setExperienceMaxYears(request.experienceMaxYears());
        career.setJobOpenings(request.jobOpenings());
        syncGrowthStages(career, request.growthStages());
        syncSalaryBands(career, request.salaryBands());
        career.setIcon(request.icon());
        career.setDescription(request.description());
        career.setSortOrder(request.sortOrder() != null ? request.sortOrder() : nextSortOrder(category.getSlug()));
        career.setRelatedExams(resolveEach(request.relatedExamSlugs(), examRepository::findById, "exam"));
        career.setStages(resolveEach(request.stageSlugs(), stageRepository::findById, "stage"));
        career.setRelatedSkills(resolveEach(request.relatedSkillSlugs(), skillRepository::findById, "skill"));
        career.setRelatedIndustries(new HashSet<>(resolveEach(request.relatedIndustrySlugs(), industryRepository::findById, "industry")));
        career.setRelatedColleges(resolveEach(request.relatedCollegeSlugs(), collegeRepository::findById, "college"));
        career.setRelatedSpecializations(resolveEach(request.relatedSpecializationSlugs(), specializationRepository::findById, "specialization"));
        career.setJobRoles(new HashSet<>(resolveEach(request.relatedJobRoleSlugs(), jobRoleRepository::findById, "job role")));
        syncEducation(career, request.education());
    }

    // Diffs career.getEducation() against the requested (degree, subject)
    // pairs: rows no longer requested are removed (orphanRemoval deletes
    // them), rows already present keep their identity and are just reordered,
    // and new pairs get a new CareerDegree.
    //
    // Matching is on the PAIR, not the degree alone -- a career can list the
    // same degree in two subjects ("B.Sc in Computer Science" and "B.Sc in
    // Statistics"), and treating those as one row would silently drop one.
    //
    // Mutates the list in place rather than replacing it: Career.education is
    // orphanRemoval=true, so assigning a new List instance detaches the
    // managed collection and Hibernate throws.
    /**
     * Rewrites the progression ladder in place. Unlike syncEducation there is
     * no natural key to diff on -- two rungs can share a title, and a rung's
     * title is itself editable -- so the list is matched POSITIONALLY: rung i
     * of the request updates rung i that exists, extra rungs are added and
     * surplus ones removed. The list instance is never replaced, because
     * orphanRemoval=true would then detach the old rows instead of deleting
     * them.
     */
    private void syncGrowthStages(Career career, List<GrowthStageDto> requested) {
        List<GrowthStageDto> wanted = requested == null ? List.of() : requested;
        List<CareerGrowthStage> current = career.getGrowthStages();

        while (current.size() > wanted.size()) {
            current.remove(current.size() - 1);
        }
        for (int i = 0; i < wanted.size(); i++) {
            GrowthStageDto g = wanted.get(i);
            if (i < current.size()) {
                CareerGrowthStage stage = current.get(i);
                stage.setTitle(g.title());
                stage.setMinYears(g.minYears());
                stage.setMaxYears(g.maxYears());
                stage.setSortOrder(i);
            } else {
                current.add(new CareerGrowthStage(career, g.title(), g.minYears(), g.maxYears(), i));
            }
        }
    }

    /** Positional, for the same reasons as syncGrowthStages. */
    private void syncSalaryBands(Career career, List<SalaryBandDto> requested) {
        List<SalaryBandDto> wanted = requested == null ? List.of() : requested;
        List<CareerSalaryBand> current = career.getSalaryBands();

        while (current.size() > wanted.size()) {
            current.remove(current.size() - 1);
        }
        for (int i = 0; i < wanted.size(); i++) {
            SalaryBandDto b = wanted.get(i);
            if (i < current.size()) {
                CareerSalaryBand band = current.get(i);
                band.setBand(b.band());
                band.setMinLpa(b.minLpa());
                band.setMaxLpa(b.maxLpa());
                band.setSortOrder(i);
            } else {
                current.add(new CareerSalaryBand(career, b.band(), b.minLpa(), b.maxLpa(), i));
            }
        }
    }

    private void syncEducation(Career career, List<EducationDto> requested) {
        List<EducationDto> wanted = requested == null ? List.of() : requested;

        career.getEducation().removeIf(existing -> wanted.stream().noneMatch(e -> matches(existing, e)));

        int sortOrder = 0;
        for (EducationDto e : wanted) {
            CareerDegree existing = career.getEducation().stream()
                    .filter(cd -> matches(cd, e))
                    .findFirst()
                    .orElse(null);
            if (existing != null) {
                existing.setSortOrder(sortOrder);
            } else {
                Degree degree = resolveRequired(e.degreeSlug(), degreeRepository::findById, "degree");
                Subject subject = blankToNull(e.subjectSlug()) == null
                        ? null
                        : resolveRequired(e.subjectSlug(), subjectRepository::findById, "subject");
                career.getEducation().add(new CareerDegree(career, degree, subject, sortOrder));
            }
            sortOrder++;
        }
    }

    private static boolean matches(CareerDegree existing, EducationDto requested) {
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

    private int nextSortOrder(String categorySlug) {
        return careerRepository.findAllByCategorySlugOrderBySortOrderAsc(categorySlug).stream()
                .mapToInt(Career::getSortOrder)
                .max()
                .orElse(-1) + 1;
    }

    private static List<String> nonNullCopy(List<String> values) {
        return values == null ? new ArrayList<>() : new ArrayList<>(values);
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
