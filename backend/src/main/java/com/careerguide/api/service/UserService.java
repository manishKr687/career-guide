package com.careerguide.api.service;

import com.careerguide.api.dto.AddUserSkillRequest;
import com.careerguide.api.dto.UpdateProfileRequest;
import com.careerguide.api.dto.UserDto;
import com.careerguide.api.dto.UserProfileDto;
import com.careerguide.api.dto.UserSkillDto;
import com.careerguide.api.entity.Skill;
import com.careerguide.api.entity.Stage;
import com.careerguide.api.entity.Stream;
import com.careerguide.api.entity.User;
import com.careerguide.api.entity.UserProfile;
import com.careerguide.api.entity.UserSkill;
import com.careerguide.api.entity.UserSlugId;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.StageRepository;
import com.careerguide.api.repository.StreamRepository;
import com.careerguide.api.repository.UserProfileRepository;
import com.careerguide.api.repository.UserRepository;
import com.careerguide.api.repository.UserSkillRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * The logged-in user's own profile: {@code GET/PUT /api/me/*} in
 * {@code MeController}. Everything here is scoped to a single user id
 * resolved from the session token by {@code UserAuthInterceptor} --
 * there's no admin-style "look up any user" path in this service.
 */
@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final StageRepository stageRepository;
    private final StreamRepository streamRepository;
    private final UserSkillRepository userSkillRepository;
    private final SkillRepository skillRepository;

    public UserService(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            StageRepository stageRepository,
            StreamRepository streamRepository,
            UserSkillRepository userSkillRepository,
            SkillRepository skillRepository
    ) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.stageRepository = stageRepository;
        this.streamRepository = streamRepository;
        this.userSkillRepository = userSkillRepository;
        this.skillRepository = skillRepository;
    }

    @Transactional(readOnly = true)
    public UserDto getUser(Long userId) {
        return DtoMapper.toDto(requireUser(userId));
    }

    @Transactional(readOnly = true)
    public UserProfileDto getProfile(Long userId) {
        return userProfileRepository.findById(userId)
                .map(DtoMapper::toDto)
                .orElseGet(() -> new UserProfileDto(null, null, null, null, null, null));
    }

    public UserProfileDto updateProfile(Long userId, UpdateProfileRequest request) {
        User user = requireUser(userId);
        UserProfile profile = userProfileRepository.findById(userId).orElseGet(() -> new UserProfile(user));

        profile.setEducationStage(request.educationStageSlug() == null
                ? null
                : findStage(request.educationStageSlug()));
        profile.setStream(request.streamSlug() == null
                ? null
                : findStream(request.streamSlug()));
        profile.setEducationLevel(request.educationLevel());
        profile.setGraduationYear(request.graduationYear());
        profile.setExperienceYears(request.experienceYears());
        profile.setLocation(request.location());

        return DtoMapper.toDto(userProfileRepository.save(profile));
    }

    public UserDto updateInterests(Long userId, Set<String> interests) {
        User user = requireUser(userId);
        user.setInterests(interests == null ? new HashSet<>() : new HashSet<>(interests));
        return DtoMapper.toDto(user);
    }

    @Transactional(readOnly = true)
    public List<UserSkillDto> getSkills(Long userId) {
        return userSkillRepository.findAllByIdUserId(userId).stream().map(DtoMapper::toDto).toList();
    }

    public UserSkillDto addOrUpdateSkill(Long userId, AddUserSkillRequest request) {
        User user = requireUser(userId);
        Skill skill = skillRepository.findById(request.skillSlug())
                .orElseThrow(() -> NotFoundException.forSlug("Skill", request.skillSlug()));
        UserSkill userSkill = userSkillRepository.findById(new UserSlugId(userId, request.skillSlug()))
                .orElseGet(() -> new UserSkill(user, skill, null, null));
        userSkill.setProficiencyLevel(request.proficiencyLevel());
        userSkill.setYearsOfExperience(request.yearsOfExperience());
        return DtoMapper.toDto(userSkillRepository.save(userSkill));
    }

    public void removeSkill(Long userId, String skillSlug) {
        userSkillRepository.deleteById(new UserSlugId(userId, skillSlug));
    }

    private Stage findStage(String slug) {
        return stageRepository.findById(slug).orElseThrow(() -> NotFoundException.forSlug("Stage", slug));
    }

    private Stream findStream(String slug) {
        return streamRepository.findById(slug).orElseThrow(() -> NotFoundException.forSlug("Stream", slug));
    }

    private User requireUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> NotFoundException.forSlug("User", String.valueOf(userId)));
    }
}
