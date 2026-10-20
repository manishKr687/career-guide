package com.careerguide.api.service;

import com.careerguide.api.dto.AddGoalFocusRequest;
import com.careerguide.api.dto.AddGoalStationRequest;
import com.careerguide.api.dto.AddLearningLogRequest;
import com.careerguide.api.dto.JourneyDto;
import com.careerguide.api.dto.SetGoalRequest;
import com.careerguide.api.entity.UserGoal;
import com.careerguide.api.entity.UserGoalFocus;
import com.careerguide.api.entity.UserGoalStation;
import com.careerguide.api.entity.UserLearningLogEntry;
import com.careerguide.api.dto.GoalSkillDto;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.UserGoalFocusRepository;
import com.careerguide.api.repository.UserGoalRepository;
import com.careerguide.api.repository.UserGoalStationRepository;
import com.careerguide.api.repository.UserLearningLogRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GoalServiceTest {

    private static final long USER = 7L;
    // 20:00 UTC on 20 Oct is 01:30 IST on 21 Oct: "today" must be the 21st.
    private static final Clock CLOCK = Clock.fixed(Instant.parse("2026-10-20T20:00:00Z"), ZoneId.of("Asia/Kolkata"));
    private static final LocalDate TODAY = LocalDate.of(2026, 10, 21);

    @Mock private UserGoalRepository goals;
    @Mock private UserGoalStationRepository stations;
    @Mock private UserGoalFocusRepository focus;
    @Mock private UserLearningLogRepository log;
    @Mock private SkillRepository skills;
    @Mock private GoalCatalog catalog;

    private GoalService service;

    @BeforeEach
    void setUp() {
        service = new GoalService(goals, stations, focus, log, skills, catalog, CLOCK);
        // journey() runs after every write; by default the user has no log.
        lenient().when(log.findAllByUserIdAndLoggedOnGreaterThanEqual(anyLong(), any())).thenReturn(List.of());
        lenient().when(log.findAllByUserIdOrderByLoggedOnDescIdDesc(anyLong(), any())).thenReturn(List.of());
        lenient().when(log.sumMinutesByTarget(anyLong())).thenReturn(List.of());
    }

    // ---------------------------------------------------------------- journey

    @Test
    void withNoGoalTheJourneyStillCarriesTheLog() {
        when(goals.findById(USER)).thenReturn(Optional.empty());

        JourneyDto j = service.journey(USER);

        assertThat(j.goal()).isNull();
        assertThat(j.minutesByDay()).hasSize(84).containsOnly(0);
        assertThat(j.readiness()).isZero();
    }

    @Test
    void streakCountsFromYesterdayWhenNothingIsLoggedYetToday() {
        when(goals.findById(USER)).thenReturn(Optional.empty());
        when(log.findAllByUserIdAndLoggedOnGreaterThanEqual(USER, TODAY.minusDays(83))).thenReturn(List.of(
                entry(TODAY.minusDays(1), 30), entry(TODAY.minusDays(2), 45), entry(TODAY.minusDays(4), 20)));

        JourneyDto j = service.journey(USER);

        // Yesterday and the day before; the gap on day 3 ends it.
        assertThat(j.streak()).isEqualTo(2);
        assertThat(j.minutesByDay().subList(0, 5)).containsExactly(0, 30, 45, 0, 20);
        assertThat(j.weekMinutes()).isEqualTo(95);
    }

    @Test
    void streakIncludesTodayOnceSomethingIsLogged() {
        when(goals.findById(USER)).thenReturn(Optional.empty());
        when(log.findAllByUserIdAndLoggedOnGreaterThanEqual(USER, TODAY.minusDays(83))).thenReturn(List.of(
                entry(TODAY, 15), entry(TODAY, 15), entry(TODAY.minusDays(1), 30)));

        JourneyDto j = service.journey(USER);

        assertThat(j.streak()).isEqualTo(2);
        assertThat(j.minutesByDay().get(0)).isEqualTo(30);
    }

    @Test
    void readinessIsHalfStationsHalfFocusLevels() {
        List<UserGoalStation> line = List.of(station(1, 0, true), station(2, 1, false), station(3, 2, false), station(4, 3, false));
        UserGoalFocus a = new UserGoalFocus(USER, "Physics", null);
        a.setLevel(3);
        UserGoalFocus b = new UserGoalFocus(USER, "Chemistry", null);
        b.setLevel(0);

        // 1 of 4 stations = 25% -> 12.5; levels 3 of 6 = 50% -> 25; total 37.5 -> 38.
        assertThat(GoalService.readiness(line, List.of(a, b))).isEqualTo(38);
        assertThat(GoalService.readiness(List.of(), List.of())).isZero();
    }

    // ------------------------------------------------------------------- goal

    @Test
    void settingANewGoalBuildsTheLineAndSeedsFocusFromTheCatalogue() {
        when(catalog.resolve("job_role", "data-analyst")).thenReturn(blueprint(3,
                List.of(new GoalSkillDto("sql", "SQL"), new GoalSkillDto("statistics", "Statistics"))));
        when(goals.findById(USER)).thenReturn(Optional.empty());

        service.setGoal(USER, new SetGoalRequest("job_role", "data-analyst", "2027-03"));

        ArgumentCaptor<UserGoal> saved = ArgumentCaptor.forClass(UserGoal.class);
        verify(goals).saveAndFlush(saved.capture());
        assertThat(saved.getValue().getTargetMonth()).isEqualTo(LocalDate.of(2027, 3, 1));
        verify(stations).deleteAllForUser(USER);
        ArgumentCaptor<UserGoalStation> line = ArgumentCaptor.forClass(UserGoalStation.class);
        verify(stations, times(3)).save(line.capture());
        assertThat(line.getAllValues()).extracting(UserGoalStation::getPosition).containsExactly(0, 1, 2);
        verify(focus, times(2)).save(any(UserGoalFocus.class));
    }

    @Test
    void theSameGoalOnlyChangesTheDateAndKeepsProgress() {
        UserGoal existing = new UserGoal(USER);
        existing.setGoalType("exam");
        existing.setTargetSlug("jee-main");
        when(goals.findById(USER)).thenReturn(Optional.of(existing));
        when(catalog.resolve("exam", "jee-main")).thenReturn(blueprint(6, List.of()));

        service.setGoal(USER, new SetGoalRequest("exam", "jee-main", null));

        verify(stations, never()).deleteAllForUser(anyLong());
        verify(focus, never()).deleteAllForUser(anyLong());
        assertThat(existing.getTargetMonth()).isNull();
    }

    // --------------------------------------------------------------- stations

    @Test
    void anAddedStationGoesJustBeforeTheGoalStation() {
        when(goals.existsById(USER)).thenReturn(true);
        UserGoalStation goalStation = station(30, 4, false);
        when(stations.findAllByUserIdOrderByPositionAscIdAsc(USER))
                .thenReturn(List.of(station(10, 0, true), station(20, 2, false), goalStation));

        service.addStation(USER, new AddGoalStationRequest("  Coaching classes "));

        ArgumentCaptor<UserGoalStation> added = ArgumentCaptor.forClass(UserGoalStation.class);
        verify(stations).save(added.capture());
        assertThat(added.getValue().getName()).isEqualTo("Coaching classes");
        assertThat(added.getValue().isCustom()).isTrue();
        assertThat(added.getValue().getPosition()).isEqualTo(4);
        assertThat(goalStation.getPosition()).isEqualTo(5);
    }

    @Test
    void aLineStopsAtTwelveStations() {
        when(goals.existsById(USER)).thenReturn(true);
        List<UserGoalStation> line = new ArrayList<>();
        for (int i = 0; i < 12; i++) line.add(station(i + 1, i, false));
        when(stations.findAllByUserIdOrderByPositionAscIdAsc(USER)).thenReturn(line);

        assertThatThrownBy(() -> service.addStation(USER, new AddGoalStationRequest("One more")))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void theGoalStationCannotBeRemoved() {
        UserGoalStation last = station(3, 2, false);
        when(stations.findByIdAndUserId(3L, USER)).thenReturn(Optional.of(last));
        when(stations.findAllByUserIdOrderByPositionAscIdAsc(USER)).thenReturn(List.of(station(1, 0, true), station(2, 1, false), last));

        assertThatThrownBy(() -> service.removeStation(USER, 3L))
                .isInstanceOf(IllegalArgumentException.class).hasMessageContaining("goal station");
    }

    @Test
    void aLineKeepsAtLeastTwoStations() {
        UserGoalStation first = station(1, 0, false);
        when(stations.findByIdAndUserId(1L, USER)).thenReturn(Optional.of(first));
        when(stations.findAllByUserIdOrderByPositionAscIdAsc(USER)).thenReturn(List.of(first, station(2, 1, false)));

        assertThatThrownBy(() -> service.removeStation(USER, 1L)).isInstanceOf(IllegalArgumentException.class);
        verify(stations, never()).delete(any());
    }

    @Test
    void someoneElsesStationIsNotFound() {
        when(stations.findByIdAndUserId(99L, USER)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.updateStation(USER, 99L, true)).isInstanceOf(NotFoundException.class);
    }

    // ------------------------------------------------------------------ focus

    @Test
    void focusStopsAtSix() {
        when(goals.existsById(USER)).thenReturn(true);
        List<UserGoalFocus> six = new ArrayList<>();
        for (int i = 0; i < 6; i++) six.add(new UserGoalFocus(USER, "Item " + i, null));
        when(focus.findAllByUserIdOrderByIdAsc(USER)).thenReturn(six);

        assertThatThrownBy(() -> service.addFocus(USER, new AddGoalFocusRequest("Seventh", null)))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void aFocusItemCannotBeAddedTwiceWhateverItsCase() {
        when(goals.existsById(USER)).thenReturn(true);
        when(focus.findAllByUserIdOrderByIdAsc(USER)).thenReturn(List.of(new UserGoalFocus(USER, "Physics", null)));

        assertThatThrownBy(() -> service.addFocus(USER, new AddGoalFocusRequest(" physics ", null)))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void aFocusSkillMustExistInTheCatalogue() {
        when(goals.existsById(USER)).thenReturn(true);
        when(focus.findAllByUserIdOrderByIdAsc(USER)).thenReturn(List.of());
        when(skills.existsById("no-such-skill")).thenReturn(false);

        assertThatThrownBy(() -> service.addFocus(USER, new AddGoalFocusRequest("Made up", "no-such-skill")))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    void focusNeedsAGoalFirst() {
        when(goals.existsById(USER)).thenReturn(false);

        assertThatThrownBy(() -> service.addFocus(USER, new AddGoalFocusRequest("Physics", null)))
                .isInstanceOf(NotFoundException.class);
    }

    // -------------------------------------------------------------------- log

    @Test
    void aLogEntryIsDatedTodayInIndiaTime() {
        when(goals.findById(USER)).thenReturn(Optional.empty());

        service.addLog(USER, new AddLearningLogRequest(" Rotational motion ", "Physics", 45, null, null));

        ArgumentCaptor<UserLearningLogEntry> saved = ArgumentCaptor.forClass(UserLearningLogEntry.class);
        verify(log).save(saved.capture());
        assertThat(saved.getValue().getLoggedOn()).isEqualTo(TODAY);
        assertThat(saved.getValue().getNote()).isEqualTo("Rotational motion");
    }

    @Test
    void aScoreNeedsItsMaximumAndMustNotExceedIt() {
        assertThatThrownBy(() -> service.addLog(USER, new AddLearningLogRequest("Mock 4", "Mock test", 180, 142, null)))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> service.addLog(USER, new AddLearningLogRequest("Mock 4", "Mock test", 180, null, 300)))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> service.addLog(USER, new AddLearningLogRequest("Mock 4", "Mock test", 180, 301, 300)))
                .isInstanceOf(IllegalArgumentException.class);
        verify(log, never()).save(any());
    }

    @Test
    void someoneElsesLogEntryIsNotFound() {
        when(log.findByIdAndUserId(5L, USER)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.removeLog(USER, 5L)).isInstanceOf(NotFoundException.class);
    }

    // ---------------------------------------------------------------- helpers

    private static UserLearningLogEntry entry(LocalDate on, int minutes) {
        return new UserLearningLogEntry(USER, on, "note", "Physics", minutes, null, null);
    }

    private static UserGoalStation station(long id, int position, boolean done) {
        UserGoalStation s = new UserGoalStation(USER, position, "Station " + id, "Kind", "", null, false);
        s.setDone(done);
        ReflectionTestUtils.setField(s, "id", id);
        return s;
    }

    private static GoalCatalog.Blueprint blueprint(int stationCount, List<GoalSkillDto> seedFocus) {
        List<GoalCatalog.StationSeed> line = new ArrayList<>();
        for (int i = 0; i < stationCount; i++) line.add(new GoalCatalog.StationSeed("S" + i, "Kind", "", null));
        return new GoalCatalog.Blueprint("Goal", List.of(), line, seedFocus, seedFocus, "skills", List.of(), null, null);
    }
}
