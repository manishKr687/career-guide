package com.careerguide.api.service;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CertificationDto;
import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.DegreeDto;
import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.dto.GoalSkillDto;
import com.careerguide.api.dto.IndustryDto;
import com.careerguide.api.dto.JobRoleDto;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Turns one catalogue item into the starting point of a goal: its name, a few
 * real facts, the stations of its line, and what can be focused on.
 *
 * <p>Every value comes from the item or what the catalogue links to it. Where
 * the catalogue has nothing -- 20 of 31 exams have no eligibility or mode, no
 * exam records its subjects, no certification lists skills -- the station
 * says so ("Check the official notice") or the user supplies their own
 * subjects, rather than this inventing a plausible value.
 */
@Component
public class GoalCatalog {

    /** A station before it belongs to anyone. */
    public record StationSeed(String name, String kind, String detail, String nextStep) {
    }

    public record Blueprint(
            String name,
            List<String> facts,
            List<StationSeed> stations,
            List<GoalSkillDto> suggestedSkills,
            List<GoalSkillDto> seedFocus,
            String focusMode,
            List<String> logTargets,
            String mockTarget,
            Integer mockMax
    ) {
    }

    static final String FOCUS_SKILLS = "skills";
    static final String FOCUS_OWN = "own";
    private static final String MOCK = "Mock test";
    /** The one exam whose mock tests have a known, fixed maximum in this catalogue. */
    private static final String JEE_MAIN = "jee-main";

    private final CareerService careerService;
    private final ExamService examService;
    private final CollegeService collegeService;
    private final DegreeService degreeService;
    private final JobRoleService jobRoleService;
    private final IndustryService industryService;
    private final CertificationService certificationService;
    private final CareerRepository careerRepository;
    private final ExamRepository examRepository;
    private final SkillRepository skillRepository;

    public GoalCatalog(CareerService careerService, ExamService examService, CollegeService collegeService,
                       DegreeService degreeService, JobRoleService jobRoleService, IndustryService industryService,
                       CertificationService certificationService, CareerRepository careerRepository,
                       ExamRepository examRepository, SkillRepository skillRepository) {
        this.careerService = careerService;
        this.examService = examService;
        this.collegeService = collegeService;
        this.degreeService = degreeService;
        this.jobRoleService = jobRoleService;
        this.industryService = industryService;
        this.certificationService = certificationService;
        this.careerRepository = careerRepository;
        this.examRepository = examRepository;
        this.skillRepository = skillRepository;
    }

    /** Throws NotFoundException (404) when the slug is not a {@code type} in the catalogue. */
    @Transactional(readOnly = true)
    public Blueprint resolve(String type, String slug) {
        return switch (type) {
            case "career" -> career(careerService.findBySlug(slug));
            case "exam" -> exam(examService.findBySlug(slug));
            case "college" -> college(collegeService.findBySlug(slug));
            case "degree" -> degree(degreeService.findBySlug(slug));
            case "job_role" -> jobRole(jobRoleService.findBySlug(slug));
            case "company" -> employer(industry(slug, false), true);
            case "sector" -> employer(industry(slug, true), false);
            case "certification" -> certification(certificationService.findBySlug(slug));
            default -> throw new IllegalArgumentException("Unknown goal type: " + type);
        };
    }

    private Blueprint career(CareerDto c) {
        List<String> exams = undergraduateExams(c.relatedExamSlugs());
        String degree = c.education() == null || c.education().isEmpty() ? null : c.education().get(0).title();
        String firstRole = c.growthStages() == null || c.growthStages().isEmpty() ? null : c.growthStages().get(0).title();
        List<StationSeed> line = new ArrayList<>();
        line.add(seed("Where you are now", "Start", "Your current stage", "Note where you are today, then mark this station passed."));
        exams.forEach(n -> line.add(seed(n, "Entrance exam", "Linked to this career", n + ": take one full timed mock this week and log the score.")));
        if (degree != null) {
            line.add(seed(degree, "Degree", "For " + c.title(), degree + ": shortlist colleges that offer it."));
        }
        line.add(seed(firstRole != null ? firstRole : "First role in " + c.title(), "First role", "Entry level",
                "Look for internships and entry-level openings."));
        List<String> facts = new ArrayList<>();
        if (degree != null) facts.add(degree + " route");
        if (c.salaryMinLpa() != null && c.salaryMaxLpa() != null) {
            facts.add("₹" + plain(c.salaryMinLpa()) + "–" + plain(c.salaryMaxLpa()) + " LPA");
        }
        int roles = c.relatedJobRoleSlugs() == null ? 0 : c.relatedJobRoleSlugs().size();
        if (roles > 0) facts.add(roles + " job roles");
        List<String> targets = new ArrayList<>(exams);
        return new Blueprint(c.title(), facts, line, skills(c.relatedSkillSlugs()), List.of(), FOCUS_SKILLS,
                targets, exams.isEmpty() ? null : MOCK, exams.isEmpty() ? null : 100);
    }

    private Blueprint exam(ExamDto e) {
        int colleges = e.collegeSlugs() == null ? 0 : e.collegeSlugs().size();
        List<StationSeed> line = List.of(
                seed("Check eligibility", "Eligibility", firstSentence(e.eligibilityMinQualification(), "Check the official notice"),
                        "Check you meet the eligibility rule before registering."),
                seed("Register", "Registration", "With " + e.conductedBy(), "Register before the window closes."),
                seed("Cover the syllabus", "Preparation", "Your subjects", "Syllabus: one chapter per subject this week, logged."),
                seed("Full mock tests", "Practice", e.mode() != null ? "Timed · " + e.mode() : "Timed practice",
                        "Mocks: one full timed mock this week, with the score logged."),
                seed("Exam day", "Exam", firstNonNull(e.mode(), e.frequency(), "As notified"), "Exam day: plan travel and documents."),
                seed("Result & counselling", "Admission", colleges > 0 ? colleges + " colleges accept " + e.name() : "What the result leads to",
                        "Shortlist where your result can take you."));
        List<String> facts = new ArrayList<>();
        facts.add(e.conductedBy());
        if (e.mode() != null) facts.add(e.mode());
        if (e.frequency() != null) facts.add(e.frequency());
        if (colleges > 0) facts.add("Accepted by " + colleges + " colleges");
        return new Blueprint(e.name(), facts, line, List.of(), List.of(), FOCUS_OWN,
                List.of(MOCK), MOCK, JEE_MAIN.equals(e.slug()) ? 300 : 100);
    }

    private Blueprint college(CollegeDto c) {
        String degree = c.degreeOfferings() == null || c.degreeOfferings().isEmpty() ? null : c.degreeOfferings().get(0).title();
        boolean postgraduate = degree != null && degree.matches("(?i)^(M\\.|MBA|MD|MS\\b|PhD|Ph\\.D|PGDM|MCA|LLM|MA\\b).*");
        List<String> exams = examNames(c.examSlugs()).stream().limit(2).toList();
        List<StationSeed> line = new ArrayList<>();
        line.add(seed(postgraduate ? "Graduation" : "Class 12", "Eligibility",
                postgraduate ? "A bachelor's degree first" : "Your current stage", null));
        exams.forEach(n -> line.add(seed(n, "Entrance exam", "How " + c.name() + " admits",
                n + ": one full timed mock this week, then log the score.")));
        line.add(seed("Counselling", "Admission", "After results", "Counselling: list your preferences in order."));
        line.add(seed((degree != null ? degree + " at " : "") + c.name(), "College", Objects.toString(c.location(), ""),
                "Prepare documents for reporting."));
        List<String> facts = new ArrayList<>();
        if (c.nirfRank() != null) facts.add("#" + c.nirfRank() + " " + c.nirfLabel());
        if (c.location() != null) facts.add(c.location());
        if (!exams.isEmpty()) facts.add("Admission via " + String.join(" / ", exams));
        return new Blueprint(c.name(), facts, line, List.of(), List.of(), FOCUS_OWN, List.of(MOCK), MOCK, 100);
    }

    private Blueprint degree(DegreeDto d) {
        boolean postgraduate = "Postgraduate".equals(d.level()) || "Doctoral".equals(d.level());
        List<String> allExams = examNames(d.entranceExamSlugs());
        List<String> exams = allExams.stream().limit(2).toList();
        List<StationSeed> line = new ArrayList<>();
        line.add(seed(postgraduate ? "Graduation" : "Undergraduate".equals(d.level()) ? "Class 12" : "Where you are now", "Eligibility",
                postgraduate ? "A bachelor's degree first" : "Your current stage", null));
        if (exams.isEmpty()) {
            line.add(seed("Shortlist colleges", "Research", "Colleges that offer " + d.title(),
                    "Shortlist five colleges that offer " + d.title() + "."));
        } else {
            exams.forEach(n -> line.add(seed(n, "Entrance exam", "Used for " + d.title() + " admission",
                    n + ": one full timed mock this week, with the score logged.")));
        }
        line.add(seed("Admission", "Admission", exams.isEmpty() ? "Apply to your shortlist" : "Counselling after results",
                "Keep your documents and marksheets ready."));
        line.add(seed(d.title(), "Degree", Objects.toString(d.durationLabel(), ""), "Settle in and set your next goal."));
        List<String> facts = new ArrayList<>();
        if (d.level() != null) facts.add(d.level());
        if (d.durationLabel() != null) facts.add(d.durationLabel());
        facts.add(allExams.isEmpty() ? "No entrance exam listed" : "Entrance: " + String.join(" / ", allExams));
        List<String> targets = new ArrayList<>(exams);
        targets.add("College applications");
        return new Blueprint(d.title(), facts, line, List.of(), List.of(), FOCUS_OWN, targets,
                exams.isEmpty() ? null : MOCK, exams.isEmpty() ? null : 100);
    }

    private Blueprint jobRole(JobRoleDto r) {
        List<GoalSkillDto> skills = skills(r.relatedSkillSlugs());
        List<StationSeed> line = List.of(
                seed("Your current role", "Now", "Where you are today", "Note what you already do that this new role needs."),
                seed("Close the skill gap", "Skills", skillsLine(skills, "This role's skills"),
                        "Skill gap: an hour on your weakest skill, three times this week."),
                seed("Build proof", "Portfolio", "Projects that show the skills", "Portfolio: start one project that uses this role's skills."),
                seed("Apply & interview", "Job search", r.name() + " openings", "Apply to five openings and log what each interview asked."),
                seed(r.name(), "New role", Objects.toString(r.experienceLevel(), ""), "Settle in and set your next goal."));
        List<String> facts = new ArrayList<>();
        if (r.salaryRange() != null) facts.add(r.salaryRange());
        if (r.experienceLevel() != null) facts.add(r.experienceLevel());
        facts.add("Career change");
        // A role's own skills are the gap, so they start as the focus list.
        return new Blueprint(r.name(), facts, line, skills, skills.stream().limit(GoalService.MAX_FOCUS).toList(),
                FOCUS_SKILLS, List.of("Portfolio project", "Interview prep"), null, null);
    }

    private Blueprint employer(IndustryDto ind, boolean company) {
        String slug = ind.slug();
        List<CareerDto> careers = careerRepository.findAll().stream().map(DtoMapper::toDto)
                .filter(c -> c.relatedIndustrySlugs() != null && c.relatedIndustrySlugs().contains(slug)).toList();
        List<JobRoleDto> roles = jobRoleService.findAll(null).stream()
                .filter(r -> r.relatedIndustrySlugs() != null && r.relatedIndustrySlugs().contains(slug)).toList();
        List<String> paths = !roles.isEmpty() ? roles.stream().map(JobRoleDto::name).toList() : careers.stream().map(CareerDto::title).toList();
        LinkedHashSet<String> skillSlugs = new LinkedHashSet<>();
        (roles.isEmpty() ? careers.stream().map(CareerDto::relatedSkillSlugs) : roles.stream().map(JobRoleDto::relatedSkillSlugs))
                .filter(Objects::nonNull).forEach(skillSlugs::addAll);
        List<GoalSkillDto> skills = skills(new ArrayList<>(skillSlugs));
        String where = (company ? "at " : "in ") + ind.name();
        List<StationSeed> line = List.of(
                seed("Your current role", "Now", "Where you are today", "Note what you already do that " + ind.name() + " would value."),
                seed(company ? "Pick your role there" : "Choose a role in " + ind.name(), "Target role",
                        paths.isEmpty() ? "The role you want " + where : String.join(" · ", paths.subList(0, Math.min(2, paths.size())))
                                + (paths.size() > 2 ? " and more" : ""),
                        "Pick the one role you want " + where + "."),
                seed("Close the skill gap", "Skills", skillsLine(skills, "Skills for that role"),
                        "Skill gap: an hour on your weakest skill, three times this week."),
                seed("Build proof", "Portfolio", "Projects that show the skills", "Portfolio: one project that uses the skills of your target role."),
                seed(company ? "Apply to " + ind.name() : "Apply in " + ind.name(), "Job search",
                        company ? "Openings and referrals" : "Openings across the sector",
                        company ? "Find two people who work there and ask how they got in." : "Apply to five openings in the sector and log each interview."),
                seed(company ? "Join " + ind.name() : "Working in " + ind.name(), "New role", "", "Settle in and set your next goal."));
        List<String> facts = new ArrayList<>();
        facts.add(company ? "Employer" : "Sector");
        if (company && !careers.isEmpty()) facts.add("Linked to " + careers.size() + " careers");
        if (!company && !roles.isEmpty()) facts.add(roles.size() + " job roles");
        if (!company && !careers.isEmpty()) facts.add(careers.size() + " careers");
        facts.add("Career change");
        return new Blueprint(ind.name(), facts, line, skills, List.of(), skills.isEmpty() ? FOCUS_OWN : FOCUS_SKILLS,
                List.of("Portfolio project", "Interview prep"), null, null);
    }

    private Blueprint certification(CertificationDto c) {
        String by = c.provider() != null ? c.provider() : "the provider";
        List<StationSeed> line = List.of(
                seed("Check prerequisites", "Eligibility", "From " + by, "Read what " + by + " expects before you start."),
                seed("Learn the topics", "Preparation", "Your own topic list", "Topics: one topic this week, logged."),
                seed("Practice tests", "Practice", "Timed, like the real exam", "Take one timed practice test and log the score."),
                seed("Book the exam", "Booking", "With " + by, "Book a date once practice scores are steady."),
                seed(c.name(), "Certified", Objects.toString(c.provider(), ""), "Add it to your CV and set your next goal."));
        List<String> facts = new ArrayList<>();
        if (c.provider() != null) facts.add(c.provider());
        if (c.duration() != null) facts.add(c.duration());
        facts.add("Upskilling");
        return new Blueprint(c.name(), facts, line, List.of(), List.of(), FOCUS_OWN, List.of("Practice test"), "Practice test", 100);
    }

    // --- helpers

    private IndustryDto industry(String slug, boolean sector) {
        IndustryDto ind = industryService.findBySlug(slug);
        if (ind.isSector() != sector) {
            throw NotFoundException.forSlug(sector ? "Sector" : "Company", slug);
        }
        return ind;
    }

    /** Exam names in the order the slugs were given; unknown slugs dropped. */
    private List<String> examNames(List<String> slugs) {
        return exams(slugs).stream().map(ExamDto::name).toList();
    }

    private List<String> undergraduateExams(List<String> slugs) {
        return exams(slugs).stream().filter(e -> "Undergraduate".equals(e.level())).map(ExamDto::name).limit(2).toList();
    }

    private List<ExamDto> exams(List<String> slugs) {
        if (slugs == null || slugs.isEmpty()) return List.of();
        Map<String, ExamDto> bySlug = examRepository.findAllById(slugs).stream().map(DtoMapper::toDto)
                .collect(Collectors.toMap(ExamDto::slug, Function.identity()));
        return slugs.stream().map(bySlug::get).filter(Objects::nonNull).toList();
    }

    /** Skill references in the order given; unknown slugs dropped. */
    private List<GoalSkillDto> skills(List<String> slugs) {
        if (slugs == null || slugs.isEmpty()) return List.of();
        Map<String, String> names = skillRepository.findAllById(slugs).stream().map(DtoMapper::toDto)
                .collect(Collectors.toMap(s -> s.slug(), s -> s.name()));
        return slugs.stream().filter(names::containsKey).map(s -> new GoalSkillDto(s, names.get(s))).toList();
    }

    private static String skillsLine(List<GoalSkillDto> skills, String fallback) {
        return skills.isEmpty() ? fallback : skills.stream().limit(3).map(GoalSkillDto::name).collect(Collectors.joining(" · "));
    }

    private static StationSeed seed(String name, String kind, String detail, String nextStep) {
        return new StationSeed(cut(name, 80), kind, cut(Objects.toString(detail, ""), 200), nextStep == null ? null : cut(nextStep, 200));
    }

    private static String firstSentence(String text, String fallback) {
        if (text == null || text.isBlank()) return fallback;
        String s = text.split("(?<=\\.)\\s", 2)[0];
        return s.length() > 90 ? s.substring(0, 87).stripTrailing() + "…" : s;
    }

    private static String firstNonNull(String... values) {
        for (String v : values) if (v != null && !v.isBlank()) return v;
        return "";
    }

    private static String plain(BigDecimal v) {
        return v.stripTrailingZeros().toPlainString();
    }

    private static String cut(String s, int max) {
        return s.length() <= max ? s : s.substring(0, max - 1).stripTrailing() + "…";
    }
}
