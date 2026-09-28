package com.careerguide.api.service;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.College;
import com.careerguide.api.entity.Exam;
import com.careerguide.api.entity.User;
import com.careerguide.api.entity.UserSavedCareer;
import com.careerguide.api.entity.UserSavedCollege;
import com.careerguide.api.entity.UserSavedExam;
import com.careerguide.api.entity.UserSlugId;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CollegeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.UserRepository;
import com.careerguide.api.repository.UserSavedCareerRepository;
import com.careerguide.api.repository.UserSavedCollegeRepository;
import com.careerguide.api.repository.UserSavedExamRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Server-backed saved careers/colleges/exams (V31) -- the eventual
 * replacement for the frontend's browser-localStorage {@code savedItems.ts},
 * which today only covers colleges and doesn't survive a cleared browser or
 * a new device. Wiring the frontend onto these endpoints is a separate
 * follow-up; this service and its controller just make the endpoints exist.
 */
@Service
@Transactional
public class SavedItemsService {

    private final UserRepository userRepository;
    private final CareerRepository careerRepository;
    private final CollegeRepository collegeRepository;
    private final ExamRepository examRepository;
    private final UserSavedCareerRepository savedCareerRepository;
    private final UserSavedCollegeRepository savedCollegeRepository;
    private final UserSavedExamRepository savedExamRepository;

    public SavedItemsService(
            UserRepository userRepository,
            CareerRepository careerRepository,
            CollegeRepository collegeRepository,
            ExamRepository examRepository,
            UserSavedCareerRepository savedCareerRepository,
            UserSavedCollegeRepository savedCollegeRepository,
            UserSavedExamRepository savedExamRepository
    ) {
        this.userRepository = userRepository;
        this.careerRepository = careerRepository;
        this.collegeRepository = collegeRepository;
        this.examRepository = examRepository;
        this.savedCareerRepository = savedCareerRepository;
        this.savedCollegeRepository = savedCollegeRepository;
        this.savedExamRepository = savedExamRepository;
    }

    @Transactional(readOnly = true)
    public List<CareerDto> getSavedCareers(Long userId) {
        return savedCareerRepository.findAllByIdUserId(userId).stream()
                .map(UserSavedCareer::getCareer).map(DtoMapper::toDto).toList();
    }

    public void saveCareer(Long userId, String careerSlug) {
        UserSlugId id = new UserSlugId(userId, careerSlug);
        if (savedCareerRepository.existsById(id)) {
            return;
        }
        User user = requireUser(userId);
        Career career = careerRepository.findById(careerSlug)
                .orElseThrow(() -> NotFoundException.forSlug("Career", careerSlug));
        savedCareerRepository.save(new UserSavedCareer(user, career));
    }

    public void unsaveCareer(Long userId, String careerSlug) {
        savedCareerRepository.deleteById(new UserSlugId(userId, careerSlug));
    }

    @Transactional(readOnly = true)
    public List<CollegeDto> getSavedColleges(Long userId) {
        return savedCollegeRepository.findAllByIdUserId(userId).stream()
                .map(UserSavedCollege::getCollege).map(DtoMapper::toDto).toList();
    }

    public void saveCollege(Long userId, String collegeSlug) {
        UserSlugId id = new UserSlugId(userId, collegeSlug);
        if (savedCollegeRepository.existsById(id)) {
            return;
        }
        User user = requireUser(userId);
        College college = collegeRepository.findById(collegeSlug)
                .orElseThrow(() -> NotFoundException.forSlug("College", collegeSlug));
        savedCollegeRepository.save(new UserSavedCollege(user, college));
    }

    public void unsaveCollege(Long userId, String collegeSlug) {
        savedCollegeRepository.deleteById(new UserSlugId(userId, collegeSlug));
    }

    @Transactional(readOnly = true)
    public List<ExamDto> getSavedExams(Long userId) {
        return savedExamRepository.findAllByIdUserId(userId).stream()
                .map(UserSavedExam::getExam).map(DtoMapper::toDto).toList();
    }

    public void saveExam(Long userId, String examSlug) {
        UserSlugId id = new UserSlugId(userId, examSlug);
        if (savedExamRepository.existsById(id)) {
            return;
        }
        User user = requireUser(userId);
        Exam exam = examRepository.findById(examSlug)
                .orElseThrow(() -> NotFoundException.forSlug("Exam", examSlug));
        savedExamRepository.save(new UserSavedExam(user, exam));
    }

    public void unsaveExam(Long userId, String examSlug) {
        savedExamRepository.deleteById(new UserSlugId(userId, examSlug));
    }

    private User requireUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> NotFoundException.forSlug("User", String.valueOf(userId)));
    }
}
