package com.careerguide.api.controller;

import com.careerguide.api.config.UserAuthInterceptor;
import com.careerguide.api.dto.AddGoalFocusRequest;
import com.careerguide.api.dto.AddGoalStationRequest;
import com.careerguide.api.dto.AddLearningLogRequest;
import com.careerguide.api.dto.JourneyDto;
import com.careerguide.api.dto.SetGoalRequest;
import com.careerguide.api.dto.UpdateGoalFocusRequest;
import com.careerguide.api.dto.UpdateGoalStationRequest;
import com.careerguide.api.service.GoalService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * My Career: goal, line, focus items and learning log.
 *
 * <p>Under {@code /api/me}, so {@code UserAuthInterceptor} guards every route
 * and the user id comes from the session token, never from the URL. Every
 * route returns the whole journey, so the page re-renders from one response.
 */
@RestController
@RequestMapping("/api/me")
public class GoalController {

    private final GoalService goalService;

    public GoalController(GoalService goalService) {
        this.goalService = goalService;
    }

    @GetMapping("/journey")
    public JourneyDto journey(HttpServletRequest request) {
        return goalService.journey(userId(request));
    }

    @PutMapping("/goal")
    public JourneyDto setGoal(HttpServletRequest request, @Valid @RequestBody SetGoalRequest body) {
        return goalService.setGoal(userId(request), body);
    }

    @PostMapping("/goal/stations")
    public JourneyDto addStation(HttpServletRequest request, @Valid @RequestBody AddGoalStationRequest body) {
        return goalService.addStation(userId(request), body);
    }

    @PatchMapping("/goal/stations/{id}")
    public JourneyDto updateStation(HttpServletRequest request, @PathVariable Long id, @Valid @RequestBody UpdateGoalStationRequest body) {
        return goalService.updateStation(userId(request), id, body.done());
    }

    @DeleteMapping("/goal/stations/{id}")
    public JourneyDto removeStation(HttpServletRequest request, @PathVariable Long id) {
        return goalService.removeStation(userId(request), id);
    }

    @PostMapping("/goal/focus")
    public JourneyDto addFocus(HttpServletRequest request, @Valid @RequestBody AddGoalFocusRequest body) {
        return goalService.addFocus(userId(request), body);
    }

    @PatchMapping("/goal/focus/{id}")
    public JourneyDto updateFocus(HttpServletRequest request, @PathVariable Long id, @Valid @RequestBody UpdateGoalFocusRequest body) {
        return goalService.updateFocus(userId(request), id, body.level());
    }

    @DeleteMapping("/goal/focus/{id}")
    public JourneyDto removeFocus(HttpServletRequest request, @PathVariable Long id) {
        return goalService.removeFocus(userId(request), id);
    }

    @PostMapping("/learning-log")
    public JourneyDto addLog(HttpServletRequest request, @Valid @RequestBody AddLearningLogRequest body) {
        return goalService.addLog(userId(request), body);
    }

    @DeleteMapping("/learning-log/{id}")
    public JourneyDto removeLog(HttpServletRequest request, @PathVariable Long id) {
        return goalService.removeLog(userId(request), id);
    }

    private static Long userId(HttpServletRequest request) {
        return (Long) request.getAttribute(UserAuthInterceptor.USER_ID_ATTRIBUTE);
    }
}
