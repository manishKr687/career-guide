package com.careerguide.api.service;

import com.careerguide.api.dto.CollegeCareerOfferingDto;
import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.CollegeUpsertRequest;
import com.careerguide.api.dto.EducationDto;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.City;
import com.careerguide.api.entity.College;
import com.careerguide.api.entity.CollegeDegree;
import com.careerguide.api.entity.CollegeCareerDegree;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.entity.Subject;
import com.careerguide.api.entity.State;
import com.careerguide.api.entity.University;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CityRepository;
import com.careerguide.api.repository.CollegeRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.SpecializationRepository;
import com.careerguide.api.repository.StateRepository;
import com.careerguide.api.repository.SubjectRepository;
import com.careerguide.api.repository.UniversityRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import com.careerguide.api.web.SlugList;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

@Service
@Transactional(readOnly = true)
public class CollegeService {

    private final CollegeRepository collegeRepository;
    private final ExamRepository examRepository;
    private final StateRepository stateRepository;
    private final CityRepository cityRepository;
    private final UniversityRepository universityRepository;
    private final DegreeRepository degreeRepository;
    private final SubjectRepository subjectRepository;
    private final SpecializationRepository specializationRepository;
    private final CareerRepository careerRepository;

    public CollegeService(
            CollegeRepository collegeRepository,
            ExamRepository examRepository,
            StateRepository stateRepository,
            CityRepository cityRepository,
            UniversityRepository universityRepository,
            DegreeRepository degreeRepository,
            SpecializationRepository specializationRepository,
            CareerRepository careerRepository,
            SubjectRepository subjectRepository
    ) {
        this.collegeRepository = collegeRepository;
        this.examRepository = examRepository;
        this.stateRepository = stateRepository;
        this.cityRepository = cityRepository;
        this.universityRepository = universityRepository;
        this.degreeRepository = degreeRepository;
        this.specializationRepository = specializationRepository;
        this.careerRepository = careerRepository;
        this.subjectRepository = subjectRepository;
    }

    // degree/discipline/state added in V53 (College MVP) -- see
    // CollegeRepository.search's javadoc.
    public Page<CollegeDto> findAll(String type, String q, String degree, String discipline, String state, Pageable pageable) {
        String normalizedType = StringUtils.hasText(type) ? type : null;
        String normalizedQuery = StringUtils.hasText(q) ? q.trim() : null;
        String normalizedDegree = StringUtils.hasText(degree) ? degree : null;
        String normalizedDiscipline = StringUtils.hasText(discipline) ? discipline : null;
        String normalizedState = StringUtils.hasText(state) ? state : null;
        return collegeRepository.search(normalizedType, normalizedQuery, normalizedDegree, normalizedDiscipline, normalizedState, pageable)
                .map(DtoMapper::toDto);
    }

    /**
     * The records for `slugs`, in one query instead of one request each.
     * See SlugList for why this exists.
     *
     * <p>Unpaged by design: the caller has named a bounded, explicit set, and
     * SlugList.MAX is what bounds it.
     */
    public List<CollegeDto> findBySlugs(String slugs) {
        return collegeRepository.findAllById(SlugList.parse(slugs)).stream()
                .map(DtoMapper::toDto)
                .toList();
    }

    public CollegeDto findBySlug(String slug) {
        College college = collegeRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("College", slug));
        return DtoMapper.toDto(college);
    }

    @Transactional
    public CollegeDto create(CollegeUpsertRequest request) {
        if (collegeRepository.existsById(request.slug())) {
            throw new ConflictException("College already exists: " + request.slug());
        }
        College college = new College();
        college.setSlug(request.slug());
        applyRequest(college, request);
        collegeRepository.save(college);
        return DtoMapper.toDto(college);
    }

    @Transactional
    public CollegeDto update(String slug, CollegeUpsertRequest request) {
        College college = collegeRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("College", slug));
        applyRequest(college, request);
        return DtoMapper.toDto(college);
    }

    @Transactional
    public void delete(String slug) {
        if (!collegeRepository.existsById(slug)) {
            throw NotFoundException.forSlug("College", slug);
        }
        // See the equivalent note in CareerService.delete: every join table
        // referencing colleges.slug cascades on delete (V1__schema.sql,
        // V53__college_mvp_architecture.sql).
        collegeRepository.deleteById(slug);
    }

    private void applyRequest(College college, CollegeUpsertRequest request) {
        college.setName(request.name());
        college.setLocation(request.location());
        college.setType(request.type());
        college.setEstablished(request.established());
        college.setTags(request.tags() == null ? new ArrayList<>() : new ArrayList<>(request.tags()));
        college.setDescription(request.description());
        college.setExams(resolveEach(request.examSlugs(), examRepository::findById, "exam"));
        college.setOwnershipType(request.ownershipType());
        college.setUniversity(resolveOptional(request.universitySlug(), universityRepository::findById, "university"));
        college.setState(resolveRequired(request.stateSlug(), stateRepository::findById, "state"));
        college.setCity(resolveOptional(request.citySlug(), cityRepository::findById, "city"));
        college.setWebsite(request.website());
        // Blank category clears the whole ranking rather than half-setting
        // it; the DB CHECK would reject a rank with no table anyway, and a
        // 400 is a worse answer than "you left it empty".
        college.setNirfRank(request.nirfRank());
        college.setNirfCategory(
                request.nirfCategory() == null || request.nirfCategory().isBlank()
                        ? null : request.nirfCategory());
        college.setNirfYear(request.nirfYear());
        college.setStatus(request.status());
        syncDegrees(college, request.degreeOfferings());
        college.setSpecializations(resolveEach(request.specializationSlugs(), specializationRepository::findById, "specialization"));
        syncCareerOfferings(college, request.careerOfferings());
    }

    // Same diff-in-place pattern as syncCareerOfferings below, for the
    // college's own qualifications. Matching is on the (degree, subject)
    // pair: a college awarding M.Tech in two branches is two rows, and
    // matching on degree alone would collapse them.
    private void syncDegrees(College college, List<EducationDto> requested) {
        List<EducationDto> wanted = requested == null ? List.of() : requested;

        college.getDegrees().removeIf(existing -> wanted.stream().noneMatch(e -> matchesDegree(existing, e)));

        int sortOrder = 0;
        for (EducationDto e : wanted) {
            CollegeDegree existing = college.getDegrees().stream()
                    .filter(cd -> matchesDegree(cd, e))
                    .findFirst()
                    .orElse(null);
            if (existing != null) {
                existing.setSortOrder(sortOrder);
            } else {
                Degree degree = resolveRequired(e.degreeSlug(), degreeRepository::findById, "degree");
                Subject subject = e.subjectSlug() == null || e.subjectSlug().isBlank()
                        ? null
                        : resolveRequired(e.subjectSlug(), subjectRepository::findById, "subject");
                college.getDegrees().add(new CollegeDegree(college, degree, subject, sortOrder));
            }
            sortOrder++;
        }
    }

    private static boolean matchesDegree(CollegeDegree existing, EducationDto requested) {
        if (!existing.getDegree().getSlug().equals(requested.degreeSlug())) {
            return false;
        }
        String have = existing.getSubject() == null ? null : existing.getSubject().getSlug();
        String want = requested.subjectSlug() == null || requested.subjectSlug().isBlank()
                ? null : requested.subjectSlug();
        return java.util.Objects.equals(have, want);
    }

    // Diffs college.getCareerOfferings() against the requested (career,
    // degree) pairs: rows no longer requested are removed (orphanRemoval
    // on College.careerOfferings deletes them), rows already present are
    // just reordered, and new pairs get a new CollegeCareerDegree. Kept
    // independent of degreeSlugs/disciplineSlugs by design -- see
    // CollegeUpsertRequest's javadoc.
    private void syncCareerOfferings(College college, List<CollegeCareerOfferingDto> requested) {
        List<CollegeCareerOfferingDto> offerings = requested == null ? List.of() : requested;

        college.getCareerOfferings().removeIf(existing -> offerings.stream().noneMatch(o ->
                o.careerSlug().equals(existing.getCareer().getSlug()) && o.degreeSlug().equals(existing.getDegree().getSlug())));

        int sortOrder = 0;
        for (CollegeCareerOfferingDto offering : offerings) {
            CollegeCareerDegree existing = college.getCareerOfferings().stream()
                    .filter(o -> o.getCareer().getSlug().equals(offering.careerSlug()) && o.getDegree().getSlug().equals(offering.degreeSlug()))
                    .findFirst()
                    .orElse(null);
            if (existing != null) {
                existing.setSortOrder(sortOrder);
            } else {
                Career career = resolveRequired(offering.careerSlug(), careerRepository::findById, "career");
                Degree degree = resolveRequired(offering.degreeSlug(), degreeRepository::findById, "degree");
                college.getCareerOfferings().add(new CollegeCareerDegree(college, career, degree, sortOrder));
            }
            sortOrder++;
        }
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

    private <T> T resolveRequired(String slug, Function<String, Optional<T>> lookup, String entityName) {
        return lookup.apply(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug));
    }

    private <T> T resolveOptional(String slug, Function<String, Optional<T>> lookup, String entityName) {
        if (!StringUtils.hasText(slug)) {
            return null;
        }
        return lookup.apply(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown " + entityName + " slug: " + slug));
    }
}
