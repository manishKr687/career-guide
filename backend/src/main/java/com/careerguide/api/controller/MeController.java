package com.careerguide.api.controller;

import com.careerguide.api.config.UserAuthInterceptor;
import com.careerguide.api.dto.AddUserSkillRequest;
import com.careerguide.api.dto.UpdateInterestsRequest;
import com.careerguide.api.dto.UpdateProfileRequest;
import com.careerguide.api.dto.UserDto;
import com.careerguide.api.dto.UserProfileDto;
import com.careerguide.api.dto.UserSkillDto;
import com.careerguide.api.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Guarded end-to-end by {@code UserAuthInterceptor} ({@code UserWebConfig}
 * matches {@code /api/me/**}); the user id is read back out of the request
 * attribute the interceptor stashed, never taken from a path/query param, so
 * one user can never act on another's data by editing a URL.
 */
@RestController
@RequestMapping("/api/me")
public class MeController {

    private final UserService userService;

    public MeController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public UserDto me(HttpServletRequest request) {
        return userService.getUser(currentUserId(request));
    }

    @GetMapping("/profile")
    public UserProfileDto profile(HttpServletRequest request) {
        return userService.getProfile(currentUserId(request));
    }

    @PutMapping("/profile")
    public UserProfileDto updateProfile(HttpServletRequest request, @Valid @RequestBody UpdateProfileRequest body) {
        return userService.updateProfile(currentUserId(request), body);
    }

    @PutMapping("/interests")
    public UserDto updateInterests(HttpServletRequest request, @RequestBody UpdateInterestsRequest body) {
        return userService.updateInterests(currentUserId(request), body.interests());
    }

    @GetMapping("/skills")
    public List<UserSkillDto> skills(HttpServletRequest request) {
        return userService.getSkills(currentUserId(request));
    }

    @PutMapping("/skills")
    public UserSkillDto upsertSkill(HttpServletRequest request, @Valid @RequestBody AddUserSkillRequest body) {
        return userService.addOrUpdateSkill(currentUserId(request), body);
    }

    @DeleteMapping("/skills/{skillSlug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeSkill(HttpServletRequest request, @PathVariable String skillSlug) {
        userService.removeSkill(currentUserId(request), skillSlug);
    }

    private Long currentUserId(HttpServletRequest request) {
        return (Long) request.getAttribute(UserAuthInterceptor.USER_ID_ATTRIBUTE);
    }
}
