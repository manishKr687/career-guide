package com.careerguide.api.service;

import com.careerguide.api.dto.AddGoalFocusRequest;
import com.careerguide.api.dto.AddGoalStationRequest;
import com.careerguide.api.dto.AddLearningLogRequest;
import com.careerguide.api.dto.GoalDto;
import com.careerguide.api.dto.GoalFocusDto;
import com.careerguide.api.dto.GoalStationDto;
import com.careerguide.api.dto.JourneyDto;
import com.careerguide.api.dto.LearningLogEntryDto;
import com.careerguide.api.dto.MockScoreDto;
import com.careerguide.api.dto.SetGoalRequest;
import com.careerguide.api.entity.UserGoal;
import com.careerguide.api.entity.UserGoalFocus;
import com.careerguide.api.entity.UserGoalStation;
import com.careerguide.api.entity.UserLearningLogEntry;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.UserGoalFocusRepository;
import com.careerguide.api.repository.UserGoalRepository;
import com.careerguide.api.repository.UserGoalStationRepository;
import com.careerguide.api.repository.UserLearningLogRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * My Career: a user's goal, its line of stations, their focus items and the
 * learning log, with the rules each of them keeps.
 *
 * <p>Every method takes the user id the auth interceptor resolved, and every
 * lookup of a station, focus item or log entry is scoped by it, so an id from
 * someone else's data is "not found" rather than reachable.
 *
 * <p>Every write returns the whole journey, so the page re-renders from one
 * response instead of patching its own copy and drifting from the server.
 */
@Service
public class GoalService {

    static final int MAX_FOCUS = 6;
    static final int MAX_STATIONS = 12;
    static final int MIN_STATIONS = 2;
    static final int DAYS = 84;
    private static final int RECENT = 8;
    private static final int MOCKS = 6;

    private final UserGoalRepository goals;
    private final UserGoalStationRepository stations;
    private final UserGoalFocusRepository focus;
    private final UserLearningLogRepository log;
    private final SkillRepository skills;
    private final GoalCatalog catalog;
    private final Clock clock;

    public GoalService(UserGoalRepository goals, UserGoalStationRepository stations, UserGoalFocusRepository focus,
                       UserLearningLogRepository log, SkillRepository skills, GoalCatalog catalog, Clock clock) {
        this.goals = goals;
        this.stations = stations;
        this.focus = focus;
        this.log = log;
        this.skills = skills;
        this.catalog = catalog;
        this.clock = clock;
    }

    // ------------------------------------------------------------------ read

    @Transactional(readOnly = true)
    public JourneyDto journey(Long userId) {
        LocalDate today = LocalDate.now(clock);

        int[] perDay = new int[DAYS];
        for (UserLearningLogEntry e : log.findAllByUserIdAndLoggedOnGreaterThanEqual(userId, today.minusDays(DAYS - 1L))) {
            long ago = ChronoUnit.DAYS.between(e.getLoggedOn(), today);
            if (ago >= 0 && ago < DAYS) perDay[(int) ago] += e.getMinutes();
        }
        // Counted from yesterday when nothing is logged yet today, so a streak
        // does not read 0 every morning before the first entry of the day.
        int streak = 0;
        for (int d = perDay[0] > 0 ? 0 : 1; d < DAYS && perDay[d] > 0; d++) streak++;
        int week = 0;
        for (int d = 0; d < 7; d++) week += perDay[d];
        List<Integer> minutesByDay = new ArrayList<>(DAYS);
        for (int m : perDay) minutesByDay.add(m);

        List<LearningLogEntryDto> recent = log.findAllByUserIdOrderByLoggedOnDescIdDesc(userId, PageRequest.of(0, RECENT))
                .stream().map(GoalService::toDto).toList();

        UserGoal goal = goals.findById(userId).orElse(null);
        if (goal == null) {
            return new JourneyDto(null, List.of(), List.of(), recent, minutesByDay, streak, week, 0, List.of());
        }

        GoalDto goalDto = goalDto(goal);
        Map<String, Long> minutesByTarget = log.sumMinutesByTarget(userId).stream()
                .collect(Collectors.toMap(t -> t.getTarget().toLowerCase(Locale.ROOT), t -> t.getMinutes() == null ? 0L : t.getMinutes(), Long::sum));
        List<UserGoalStation> line = stations.findAllByUserIdOrderByPositionAscIdAsc(userId);
        List<UserGoalFocus> items = focus.findAllByUserIdOrderByIdAsc(userId);

        List<GoalStationDto> stationDtos = line.stream()
                .map(s -> new GoalStationDto(s.getId(), s.getName(), s.getKind(), s.getDetail(), s.getNextStep(), s.isDone(), s.isCustom()))
                .toList();
        List<GoalFocusDto> focusDtos = items.stream()
                .map(f -> new GoalFocusDto(f.getId(), f.getName(), f.getSkillSlug(), f.getLevel(),
                        minutesByTarget.getOrDefault(f.getName().toLowerCase(Locale.ROOT), 0L).intValue()))
                .toList();

        List<MockScoreDto> mocks = List.of();
        if (goalDto.mockMax() != null) {
            List<MockScoreDto> scored = log.findAllByUserIdAndScoreIsNotNullOrderByLoggedOnAscIdAsc(userId).stream()
                    // Only scores on this goal's scale, so a 142/300 never sits beside an 80%.
                    .filter(e -> goalDto.mockMax().equals(e.getScoreMax()))
                    .map(e -> new MockScoreDto(e.getLoggedOn(), e.getScore(), e.getScoreMax()))
                    .toList();
            mocks = scored.subList(Math.max(0, scored.size() - MOCKS), scored.size());
        }

        return new JourneyDto(goalDto, stationDtos, focusDtos, recent, minutesByDay, streak, week,
                readiness(line, items), mocks);
    }

    /**
     * Half from stations passed, half from focus levels -- the same split the
     * page explains under the ring.
     */
    static int readiness(List<UserGoalStation> line, List<UserGoalFocus> items) {
        double stationPart = line.isEmpty() ? 0 : line.stream().filter(UserGoalStation::isDone).count() / (double) line.size();
        double focusPart = items.isEmpty() ? 0 : items.stream().mapToInt(UserGoalFocus::getLevel).sum() / (items.size() * 3.0);
        return (int) Math.round((stationPart * 0.5 + focusPart * 0.5) * 100);
    }

    private GoalDto goalDto(UserGoal g) {
        String month = g.getTargetMonth() == null ? null : YearMonth.from(g.getTargetMonth()).toString();
        GoalCatalog.Blueprint b;
        try {
            b = catalog.resolve(g.getGoalType(), g.getTargetSlug());
        } catch (NotFoundException gone) {
            // The catalogue item was removed after the goal was set. The goal
            // still reads, from its saved name; there is just nothing new to
            // suggest from it.
            return new GoalDto(g.getGoalType(), g.getTargetSlug(), g.getTargetName(), List.of(), month,
                    GoalCatalog.FOCUS_OWN, List.of(), List.of(), null, null);
        }
        return new GoalDto(g.getGoalType(), g.getTargetSlug(), b.name(), b.facts(), month, b.focusMode(),
                b.suggestedSkills(), b.logTargets(), b.mockTarget(), b.mockMax());
    }

    // ------------------------------------------------------------------ goal

    /**
     * Sets the goal. A different type or item rebuilds the line and focus list
     * from the catalogue; the same one only changes the date. The learning log
     * is never touched.
     */
    @Transactional
    public JourneyDto setGoal(Long userId, SetGoalRequest request) {
        GoalCatalog.Blueprint b = catalog.resolve(request.type(), request.slug());
        UserGoal goal = goals.findById(userId).orElse(null);
        boolean changed = goal == null || !goal.getGoalType().equals(request.type()) || !goal.getTargetSlug().equals(request.slug());
        if (goal == null) goal = new UserGoal(userId);
        goal.setGoalType(request.type());
        goal.setTargetSlug(request.slug());
        goal.setTargetName(b.name().length() > 160 ? b.name().substring(0, 160) : b.name());
        goal.setTargetMonth(request.targetMonth() == null ? null : YearMonth.parse(request.targetMonth()).atDay(1));
        goals.saveAndFlush(goal);

        if (changed) {
            stations.deleteAllForUser(userId);
            focus.deleteAllForUser(userId);
            int position = 0;
            for (GoalCatalog.StationSeed s : b.stations()) {
                stations.save(new UserGoalStation(userId, position++, s.name(), s.kind(), s.detail(), s.nextStep(), false));
            }
            b.seedFocus().stream().limit(MAX_FOCUS)
                    .forEach(sk -> focus.save(new UserGoalFocus(userId, sk.name(), sk.slug())));
        }
        return journey(userId);
    }

    // -------------------------------------------------------------- stations

    /** Adds the user's own station just before the goal station, which always stays last. */
    @Transactional
    public JourneyDto addStation(Long userId, AddGoalStationRequest request) {
        requireGoal(userId);
        List<UserGoalStation> line = stations.findAllByUserIdOrderByPositionAscIdAsc(userId);
        if (line.size() >= MAX_STATIONS) {
            throw new IllegalArgumentException("A line can have at most " + MAX_STATIONS + " stations");
        }
        int position = 0;
        if (!line.isEmpty()) {
            UserGoalStation last = line.get(line.size() - 1);
            position = last.getPosition();
            last.setPosition(position + 1);
        }
        stations.save(new UserGoalStation(userId, position, request.name().trim(), "Your station", "Added by you", null, true));
        return journey(userId);
    }

    @Transactional
    public JourneyDto updateStation(Long userId, Long stationId, boolean done) {
        UserGoalStation s = stations.findByIdAndUserId(stationId, userId)
                .orElseThrow(() -> new NotFoundException("Station not found: " + stationId));
        s.setDone(done);
        return journey(userId);
    }

    /** Any station but the goal itself can go, as long as two remain. */
    @Transactional
    public JourneyDto removeStation(Long userId, Long stationId) {
        UserGoalStation s = stations.findByIdAndUserId(stationId, userId)
                .orElseThrow(() -> new NotFoundException("Station not found: " + stationId));
        List<UserGoalStation> line = stations.findAllByUserIdOrderByPositionAscIdAsc(userId);
        if (line.get(line.size() - 1).getId().equals(s.getId())) {
            throw new IllegalArgumentException("The goal station is the end of the line and cannot be removed");
        }
        if (line.size() <= MIN_STATIONS) {
            throw new IllegalArgumentException("A line needs at least " + MIN_STATIONS + " stations");
        }
        stations.delete(s);
        return journey(userId);
    }

    // ----------------------------------------------------------------- focus

    @Transactional
    public JourneyDto addFocus(Long userId, AddGoalFocusRequest request) {
        requireGoal(userId);
        List<UserGoalFocus> items = focus.findAllByUserIdOrderByIdAsc(userId);
        if (items.size() >= MAX_FOCUS) {
            throw new IllegalArgumentException("You can focus on " + MAX_FOCUS + " things at a time; remove one first");
        }
        String name = request.name().trim();
        if (items.stream().anyMatch(f -> f.getName().equalsIgnoreCase(name))) {
            throw new ConflictException("Already in your focus list: " + name);
        }
        String skillSlug = request.skillSlug();
        if (skillSlug != null && !skills.existsById(skillSlug)) {
            throw NotFoundException.forSlug("Skill", skillSlug);
        }
        focus.save(new UserGoalFocus(userId, name, skillSlug));
        return journey(userId);
    }

    @Transactional
    public JourneyDto updateFocus(Long userId, Long focusId, int level) {
        UserGoalFocus f = focus.findByIdAndUserId(focusId, userId)
                .orElseThrow(() -> new NotFoundException("Focus item not found: " + focusId));
        f.setLevel(level);
        return journey(userId);
    }

    @Transactional
    public JourneyDto removeFocus(Long userId, Long focusId) {
        UserGoalFocus f = focus.findByIdAndUserId(focusId, userId)
                .orElseThrow(() -> new NotFoundException("Focus item not found: " + focusId));
        focus.delete(f);
        return journey(userId);
    }

    // ------------------------------------------------------------------- log

    /** Dated today in India time; a score must come with its maximum, and not exceed it. */
    @Transactional
    public JourneyDto addLog(Long userId, AddLearningLogRequest request) {
        Integer score = request.score();
        Integer max = request.scoreMax();
        if ((score == null) != (max == null)) {
            throw new IllegalArgumentException("A score needs its maximum, and a maximum needs a score");
        }
        if (score != null && score > max) {
            throw new IllegalArgumentException("Score " + score + " is more than the maximum of " + max);
        }
        log.save(new UserLearningLogEntry(userId, LocalDate.now(clock), request.note().trim(), request.target().trim(),
                request.minutes(), score, max));
        return journey(userId);
    }

    @Transactional
    public JourneyDto removeLog(Long userId, Long entryId) {
        UserLearningLogEntry e = log.findByIdAndUserId(entryId, userId)
                .orElseThrow(() -> new NotFoundException("Log entry not found: " + entryId));
        log.delete(e);
        return journey(userId);
    }

    // --------------------------------------------------------------- helpers

    private void requireGoal(Long userId) {
        if (!goals.existsById(userId)) {
            throw new NotFoundException("Set a goal first");
        }
    }

    private static LearningLogEntryDto toDto(UserLearningLogEntry e) {
        return new LearningLogEntryDto(e.getId(), e.getLoggedOn(), e.getNote(), e.getTarget(), e.getMinutes(), e.getScore(), e.getScoreMax());
    }
}
