package com.careerguide.api.mapper;

import com.careerguide.api.dto.AssessmentOptionDto;
import com.careerguide.api.dto.AssessmentQuestionDto;
import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CategoryDto;
import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.dto.CityDto;
import com.careerguide.api.dto.CollegeCareerOfferingDto;
import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.dto.EducationDto;
import com.careerguide.api.dto.ExamCareerDegreeDto;
import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.dto.JobRoleDto;
import com.careerguide.api.dto.ResourceDto;
import com.careerguide.api.dto.SkillDto;
import com.careerguide.api.dto.GrowthStageDto;
import com.careerguide.api.dto.SalaryBandDto;
import com.careerguide.api.dto.SpecializationDto;
import com.careerguide.api.dto.StageDto;
import com.careerguide.api.dto.StateDto;
import com.careerguide.api.dto.StreamDto;
import com.careerguide.api.dto.StreamCombinationDto;
import com.careerguide.api.dto.SubjectDto;
import com.careerguide.api.dto.UniversityDto;
import com.careerguide.api.dto.UserDto;
import com.careerguide.api.dto.UserProfileDto;
import com.careerguide.api.dto.UserSkillDto;
import com.careerguide.api.entity.AssessmentOption;
import com.careerguide.api.entity.AssessmentQuestion;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.CareerSalaryBand;
import com.careerguide.api.entity.CareerGrowthStage;
import com.careerguide.api.entity.CareerDegree;
import com.careerguide.api.entity.Category;
import com.careerguide.api.entity.Certification;
import com.careerguide.api.entity.City;
import com.careerguide.api.dto.CounsellingRequestDto;
import com.careerguide.api.entity.College;
import com.careerguide.api.entity.CollegeDegree;
import com.careerguide.api.entity.Degree;
import com.careerguide.api.entity.QualificationTitle;
import com.careerguide.api.entity.CounsellingRequest;
import com.careerguide.api.entity.Exam;
import com.careerguide.api.entity.Industry;
import com.careerguide.api.entity.JobRole;
import com.careerguide.api.entity.Resource;
import com.careerguide.api.entity.SalaryRange;
import com.careerguide.api.entity.Skill;
import com.careerguide.api.entity.Specialization;
import com.careerguide.api.entity.SpecializationDegree;
import com.careerguide.api.entity.Stage;
import com.careerguide.api.entity.State;
import com.careerguide.api.entity.Stream;
import com.careerguide.api.entity.StreamCombination;
import com.careerguide.api.entity.Subject;
import com.careerguide.api.entity.University;
import com.careerguide.api.entity.User;
import com.careerguide.api.entity.UserProfile;
import com.careerguide.api.entity.UserSkill;

import java.util.Collections;
import java.util.Collection;
import java.util.List;

/**
 * Maps JPA entities to the API's response DTOs. DTO shapes deliberately mirror
 * the frontend's TypeScript interfaces (src/lib/types.ts) field-for-field, so
 * a future frontend rewiring onto this API is a drop-in swap.
 *
 * <p>Callers must invoke these from within a transaction (e.g. a
 * {@code @Transactional(readOnly = true)} service method), since lazily
 * loaded associations are read here.
 */
public final class DtoMapper {

    private DtoMapper() {
    }

    public static CategoryDto toDto(Category c) {
        return new CategoryDto(c.getSlug(), c.getName(), c.getIcon(), c.getColor());
    }

    public static StageDto toDto(Stage s) {
        return new StageDto(
                s.getSlug(),
                s.getName(),
                s.getTagline(),
                s.getDescription(),
                s.getBadgeSoft(),
                s.getBadgeSolid(),
                s.getIcon(),
                s.getHighlights(),
                slugs(s.getRelatedCareers(), Career::getSlug),
                slugs(s.getRelatedExams(), Exam::getSlug)
        );
    }

    public static CareerDto toDto(Career c) {
        return new CareerDto(
                c.getSlug(),
                c.getTitle(),
                c.getCategory().getSlug(),
                c.getTagline(),
                c.getDemand(),
                Collections.emptyList(), // entranceExams: deliberately not migrated, see CareerDto javadoc
                c.getTypicalWork(),
                SalaryRange.compose(c.getSalaryMinLpa(), c.getSalaryMaxLpa()),
                c.getSalaryMinLpa(),
                c.getSalaryMaxLpa(),
                c.getGrowthPath(),
                slugs(c.getRelatedExams(), Exam::getSlug),
                slugs(c.getStages(), Stage::getSlug),
                c.getIcon(),
                c.getDescription(),
                slugs(c.getRelatedColleges(), College::getSlug),
                slugs(c.getRelatedSpecializations(), Specialization::getSlug),
                slugs(c.getRelatedSkills(), Skill::getSlug),
                slugs(c.getRelatedIndustries(), Industry::getSlug),
                slugs(c.getJobRoles(), JobRole::getSlug),
                c.getEducation().stream().map(DtoMapper::toDto).toList(),
                c.getGrowthStages().stream().map(DtoMapper::toDto).toList(),
                c.getSalaryBands().stream().map(DtoMapper::toDto).toList(),
                c.getHighlights(),
                c.getWorkEnvironments(),
                c.getExperienceMinYears(),
                c.getExperienceMaxYears(),
                c.getJobOpenings()
        );
    }

    /**
     * Added in V103. `title` is composed here rather than by each caller --
     * the rule is level-dependent ("B.A. (Psychology)" but "PhD in
     * Psychology") and four pages inventing it separately is how they drift.
     */
    public static EducationDto toDto(CareerDegree cd) {
        return new EducationDto(
                cd.getDegree().getSlug(),
                cd.getSubject() == null ? null : cd.getSubject().getSlug(),
                QualificationTitle.compose(cd.getDegree(), cd.getSubject())
        );
    }

    public static EducationDto toDto(CollegeDegree cd) {
        return new EducationDto(
                cd.getDegree().getSlug(),
                cd.getSubject() == null ? null : cd.getSubject().getSlug(),
                QualificationTitle.compose(cd.getDegree(), cd.getSubject())
        );
    }

    /**
     * "4 years" / "3-5 years" / "6 months". Composed here rather than per page
     * for the same reason as EducationDto.title and GrowthStageDto.label: one
     * rule, one place. Sub-year lengths read as months because "0.5 years" is
     * not how anyone says it.
     */
    private static String durationLabel(Degree d) {
        java.math.BigDecimal lo = d.getDurationMinYears();
        java.math.BigDecimal hi = d.getDurationMaxYears();
        if (lo == null || hi == null) {
            return null;
        }
        if (lo.compareTo(hi) != 0) {
            return plainYears(lo) + "-" + plainYears(hi) + " years";
        }
        if (lo.compareTo(java.math.BigDecimal.ONE) < 0) {
            return lo.multiply(java.math.BigDecimal.valueOf(12)).stripTrailingZeros()
                    .toPlainString() + " months";
        }
        return plainYears(lo) + (lo.compareTo(java.math.BigDecimal.ONE) == 0 ? " year" : " years");
    }

    private static String plainYears(java.math.BigDecimal v) {
        return v.stripTrailingZeros().toPlainString();
    }

    public static ExamDto toDto(Exam e) {
        return new ExamDto(
                e.getSlug(),
                e.getName(),
                e.getFullName(),
                e.getCategory(),
                e.getConductedBy(),
                e.getFrequency(),
                e.getDescription(),
                slugs(e.getRelatedCareers(), Career::getSlug),
                e.getIcon(),
                slugs(e.getRelatedColleges(), College::getSlug),
                e.getMode(),
                e.getEligibilityMinQualification(),
                e.getOfficialWebsite(),
                e.getSyllabusOverview(),
                e.getCareerDegreeOfferings().stream()
                        .map(o -> new ExamCareerDegreeDto(o.getCareer().getSlug(), o.getDegree().getSlug()))
                        .toList(),
                e.getExamType(),
                slugs(e.getRelatedJobRoles(), JobRole::getSlug),
                e.getFieldCategory() == null ? null : e.getFieldCategory().getSlug(),
                e.getLevel(),
                e.getFrequencyType()
        );
    }

    public static DegreeDto toDto(Degree d) {
        return new DegreeDto(
                d.getSlug(),
                d.getTitle(),
                d.getDescription(),
                d.getIcon(),
                d.getPreparationStrategy(),
                d.getLevel(),
                d.getCategory() == null ? null : d.getCategory().getSlug(),
                d.isRequiresSubject(),
                slugs(d.getRelatedExams(), Exam::getSlug),
                slugs(d.getRelatedSkills(), Skill::getSlug),
                slugs(d.getRelatedResources(), Resource::getSlug),
                slugs(d.getSubjects(), Subject::getSlug),
                d.getFullTitle(),
                d.getDurationMinYears(),
                d.getDurationMaxYears(),
                durationLabel(d)
        );
    }

    /**
     * Added in V87. No relation lists: a subject owns nothing -- what it
     * connects to is decided by the link that pairs it with a degree.
     */
    public static SubjectDto toDto(Subject s) {
        return new SubjectDto(
                s.getSlug(),
                s.getTitle(),
                s.getDescription(),
                s.getIcon(),
                s.getCategory().getSlug()
        );
    }

    public static StateDto toDto(State s) {
        return new StateDto(s.getSlug(), s.getName(), s.getCode());
    }

    public static CityDto toDto(City c) {
        return new CityDto(c.getSlug(), c.getName(), c.getState().getSlug());
    }

    public static UniversityDto toDto(University u) {
        return new UniversityDto(
                u.getSlug(),
                u.getName(),
                u.getUniversityType(),
                u.getOwnershipType(),
                u.getState() == null ? null : u.getState().getSlug(),
                u.getCity() == null ? null : u.getCity().getSlug(),
                u.getWebsite(),
                u.getStatus()
        );
    }

    public static CollegeDto toDto(College c) {
        return new CollegeDto(
                c.getSlug(),
                c.getName(),
                c.getLocation(),
                c.getType(),
                c.getEstablished(),
                c.getTags(),
                c.getDescription(),
                slugs(c.getExams(), Exam::getSlug),
                c.getOwnershipType(),
                c.getUniversity() == null ? null : c.getUniversity().getSlug(),
                c.getState().getSlug(),
                c.getCity() == null ? null : c.getCity().getSlug(),
                c.getWebsite(),
                c.getStatus(),
                c.getDegrees().stream().map(DtoMapper::toDto).toList(),
                slugs(c.getSpecializations(), Specialization::getSlug),
                slugs(c.getDisciplines(), Career::getSlug),
                c.getCareerOfferings().stream()
                        .map(o -> new CollegeCareerOfferingDto(o.getCareer().getSlug(), o.getDegree().getSlug()))
                        .toList(),
                c.getNirfRank(),
                c.getNirfCategory(),
                c.getNirfYear(),
                c.getNirfRank() == null ? null : "NIRF " + c.getNirfYear() + " \u00b7 " + c.getNirfCategory()
        );
    }

    public static SpecializationDto toDto(Specialization s) {
        return new SpecializationDto(
                s.getSlug(),
                s.getName(),
                s.getDescription(),
                s.getIcon(),
                slugs(s.getRelatedExams(), Exam::getSlug),
                slugs(s.getCareers(), Career::getSlug),
                s.getPrimaryCareerSlug(),
                slugs(s.getRelatedJobRoles(), JobRole::getSlug),
                slugs(s.getRelatedHardSkills(), Skill::getSlug),
                slugs(s.getRelatedSoftSkills(), Skill::getSlug),
                s.getResponsibilities(),
                s.getDemand(),
                slugs(s.getRelatedCertifications(), Certification::getSlug),
                slugs(s.getRelatedIndustries(), Industry::getSlug),
                s.getOverview(),
                s.getHighlights(),
                s.getEducation().stream().map(DtoMapper::toDto).toList(),
                slugs(s.getColleges(), College::getSlug),
                slugs(s.getRelatedResources(), Resource::getSlug),
                s.getSalaryMinLpa(),
                s.getSalaryMaxLpa(),
                SalaryRange.compose(s.getSalaryMinLpa(), s.getSalaryMaxLpa())
        );
    }

    /**
     * The specialization twin of {@link #toDto(CareerDegree)}. Both compose
     * their title through {@link QualificationTitle} for the same reason: the
     * rule is level-dependent, and two callers inventing it separately is how
     * a career and a specialization end up spelling the same qualification
     * two different ways.
     */
    public static EducationDto toDto(SpecializationDegree sd) {
        return new EducationDto(
                sd.getDegree().getSlug(),
                sd.getSubject() == null ? null : sd.getSubject().getSlug(),
                QualificationTitle.compose(sd.getDegree(), sd.getSubject())
        );
    }

    /**
     * `label` is composed here, not per page: "0-2 yrs" and an open-ended
     * "12+ yrs" are one rule, and two callers inventing it separately is how
     * the ladder ends up written two ways on the same site.
     */
    public static GrowthStageDto toDto(CareerGrowthStage g) {
        String label = g.getMaxYears() == null
                ? g.getMinYears() + "+ yrs"
                : g.getMinYears() + "-" + g.getMaxYears() + " yrs";
        return new GrowthStageDto(g.getTitle(), g.getMinYears(), g.getMaxYears(), label);
    }

    public static SalaryBandDto toDto(CareerSalaryBand b) {
        return new SalaryBandDto(
                b.getBand(),
                b.getMinLpa(),
                b.getMaxLpa(),
                SalaryRange.composeOpenEnded(b.getMinLpa(), b.getMaxLpa())
        );
    }

    public static AssessmentQuestionDto toDto(AssessmentQuestion q) {
        return new AssessmentQuestionDto(
                q.getId(),
                q.getQuestion(),
                q.getOptions().stream().map(DtoMapper::toDto).toList()
        );
    }

    public static CounsellingRequestDto toDto(CounsellingRequest r) {
        return new CounsellingRequestDto(
                r.getId(),
                r.getName(),
                r.getEmail(),
                r.getPhone(),
                r.getPreferredDate(),
                r.getPreferredTime(),
                r.getStageSlug(),
                r.getCareerSlug(),
                r.getMessage(),
                r.getStatus(),
                r.getCreatedAt()
        );
    }

    public static AssessmentOptionDto toDto(AssessmentOption o) {
        return new AssessmentOptionDto(o.getOptionKey(), o.getLabel(), o.getWeights());
    }

    private static <T> List<String> slugs(Collection<T> entities, java.util.function.Function<T, String> slugFn) {
        return entities.stream().map(slugFn).toList();
    }

    public static SkillDto toDto(Skill s) {
        return new SkillDto(s.getSlug(), s.getName(), s.getSkillType(), s.getCategory(), s.getDescription());
    }

    public static IndustryDto toDto(Industry i) {
        return new IndustryDto(i.getSlug(), i.getName(), i.isSector());
    }

    public static StreamDto toDto(Stream s) {
        return new StreamDto(
                s.getSlug(),
                s.getName(),
                s.getDescription(),
                slugs(s.getStages(), Stage::getSlug),
                slugs(s.getCareers(), Career::getSlug),
                s.getCombinations().stream().map(DtoMapper::toDto).toList()
        );
    }

    /**
     * Added in V97. Only Science has combinations, so most streams map this
     * to an empty list -- that is the normal case, not missing data.
     */
    public static StreamCombinationDto toDto(StreamCombination sc) {
        return new StreamCombinationDto(
                sc.getSlug(),
                sc.getStream().getSlug(),
                sc.getName(),
                sc.getShortName(),
                sc.getDescription(),
                slugs(sc.getCareers(), Career::getSlug)
        );
    }

    public static JobRoleDto toDto(JobRole j) {
        return new JobRoleDto(
                j.getSlug(),
                j.getName(),
                j.getDescription(),
                j.getExperienceLevel(),
                j.getSalaryMin(),
                j.getSalaryMax(),
                slugs(j.getCareers(), Career::getSlug),
                slugs(j.getRelatedSkills(), Skill::getSlug),
                slugs(j.getRelatedIndustries(), Industry::getSlug),
                slugs(j.getRelatedCertifications(), Certification::getSlug),
                slugs(j.getRelatedExams(), Exam::getSlug),
                j.getSalaryMinLpa(),
                j.getSalaryMaxLpa(),
                SalaryRange.compose(j.getSalaryMinLpa(), j.getSalaryMaxLpa())
        );
    }

    public static CertificationDto toDto(Certification c) {
        return new CertificationDto(
                c.getSlug(),
                c.getName(),
                c.getDescription(),
                c.getProvider(),
                c.getLevel(),
                c.getDuration(),
                c.getOfficialUrl(),
                slugs(c.getRelatedCareers(), Career::getSlug),
                slugs(c.getRelatedSkills(), Skill::getSlug)
        );
    }

    public static ResourceDto toDto(Resource r) {
        return new ResourceDto(
                r.getSlug(),
                r.getTitle(),
                r.getResourceType(),
                r.getDescription(),
                r.getContentUrl(),
                r.getAuthor(),
                r.getPublishedAt(),
                slugs(r.getRelatedCareers(), Career::getSlug),
                slugs(r.getRelatedExams(), Exam::getSlug),
                slugs(r.getRelatedSkills(), Skill::getSlug)
        );
    }

    public static UserDto toDto(User u) {
        return new UserDto(
                u.getId(),
                u.getEmail(),
                u.getName(),
                u.getCreatedAt(),
                u.getInterests().stream().sorted().toList()
        );
    }

    public static UserProfileDto toDto(UserProfile p) {
        return new UserProfileDto(
                p.getEducationStage() == null ? null : p.getEducationStage().getSlug(),
                p.getStream() == null ? null : p.getStream().getSlug(),
                p.getEducationLevel(),
                p.getGraduationYear(),
                p.getExperienceYears(),
                p.getLocation()
        );
    }

    public static UserSkillDto toDto(UserSkill s) {
        return new UserSkillDto(
                s.getSkill().getSlug(),
                s.getSkill().getName(),
                s.getProficiencyLevel(),
                s.getYearsOfExperience()
        );
    }
}
