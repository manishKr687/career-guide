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
        resolvePrimaryCareer(specialization, request);
        return DtoMapper.toDto(specialization);
    }

    @Transactional
    public SpecializationDto update(String slug, SpecializationUpsertRequest request) {
        Specialization specialization = specializationRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Specialization", slug));
        applyRequest(specialization, request);
        syncCareerLinks(specialization, request.careerSlugs());
        resolvePrimaryCareer(specialization, request);
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
                unlink(career, specialization);
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

    /**
     * Settles which career is this specialization's canonical parent, after
     * {@link #syncCareerLinks} has established what the parents are.
     *
     * <p>Runs second on purpose: the primary has to be one of the links, and the
     * database enforces that with a composite foreign key into
     * career_specializations (see V117). That constraint is DEFERRABLE, so a
     * violation would otherwise surface as an opaque error at commit rather than
     * as a message naming the field -- hence the explicit check here.
     *
     * <p>An omitted {@code primaryCareerSlug} is not an error. It keeps whatever
     * was primary if that career is still linked, and otherwise falls to the
     * first requested career, so an editor who only wanted to add a second
     * parent does not have to restate the first.
     */
    private void resolvePrimaryCareer(Specialization specialization, SpecializationUpsertRequest request) {
        List<String> linked = specialization.getCareers().stream().map(Career::getSlug).toList();
        if (linked.isEmpty()) {
            throw new IllegalArgumentException(
                    "A specialization needs at least one career: it is the parent its page is reached "
                            + "through and the source of the data it falls back to.");
        }

        String requested = request.primaryCareerSlug();
        if (requested != null && !requested.isBlank()) {
            if (!linked.contains(requested)) {
                throw new IllegalArgumentException(
                        "primaryCareerSlug '" + requested + "' is not one of this specialization's careers "
                                + linked + ". The canonical parent has to be an actual parent.");
            }
            specialization.setPrimaryCareerSlug(requested);
            return;
        }

        String current = specialization.getPrimaryCareerSlug();
        specialization.setPrimaryCareerSlug(
                current != null && linked.contains(current) ? current : linked.get(0));
    }

    /**
     * Removes one specialization from a career's ordered list.
     *
     * <p>Not a plain {@code removeIf}, which was silently broken. The relation
     * carries {@code @OrderColumn(name = "sort_order")} while the join table's
     * primary key is (career_slug, specialization_slug), so Hibernate maintains
     * the list index by UPDATEing the row <em>at each position</em>:
     *
     * <pre>update career_specializations set specialization_slug = ? where career_slug = ? and sort_order = ?</pre>
     *
     * <p>Removing from anywhere but the end therefore shifts every later element
     * down one slot, and the first such UPDATE rewrites a row into a
     * (career, specialization) pair that already exists further down the list --
     * a duplicate key on the primary key, even though the final state would have
     * been perfectly valid. Removing Cloud Computing from Information Technology
     * failed this way, colliding with Network Administration.
     *
     * <p>So the list is rebuilt rather than patched: clear it, flush so the
     * DELETEs land, then re-add what remains. Hibernate assigns sort_order 0..n-1
     * on the way back in, which is what {@code @OrderColumn} wants anyway. Two
     * extra statements per edit, on lists of at most a couple of dozen rows.
     *
     * <p>The same mapping shape exists on other relations in this schema, so the
     * same latent bug is likely reachable through them; this fixes the one path
     * that is demonstrably hit.
     */
    private void unlink(Career career, Specialization specialization) {
        List<Specialization> remaining = career.getRelatedSpecializations().stream()
                .filter(s -> !s.getSlug().equals(specialization.getSlug()))
                .toList();
        career.getRelatedSpecializations().clear();
        careerRepository.saveAndFlush(career);
        career.getRelatedSpecializations().addAll(remaining);
        careerRepository.saveAndFlush(career);
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
