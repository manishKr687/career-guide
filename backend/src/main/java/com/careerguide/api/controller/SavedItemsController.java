package com.careerguide.api.controller;

import com.careerguide.api.config.UserAuthInterceptor;
import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CollegeDto;
import com.careerguide.api.dto.ExamDto;
import com.careerguide.api.service.SavedItemsService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Server-backed saved careers/colleges/exams (V31) -- covered by
 * {@code UserAuthInterceptor} because it sits under {@code /api/me/**}
 * ({@code UserWebConfig}). Returns full DTOs (not just slugs) so a client
 * can render a saved-items list without a second round trip per item.
 */
@RestController
@RequestMapping("/api/me/saved")
public class SavedItemsController {

    private final SavedItemsService savedItemsService;

    public SavedItemsController(SavedItemsService savedItemsService) {
        this.savedItemsService = savedItemsService;
    }

    @GetMapping("/careers")
    public List<CareerDto> savedCareers(HttpServletRequest request) {
        return savedItemsService.getSavedCareers(currentUserId(request));
    }

    @PostMapping("/careers/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void saveCareer(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.saveCareer(currentUserId(request), slug);
    }

    @DeleteMapping("/careers/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unsaveCareer(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.unsaveCareer(currentUserId(request), slug);
    }

    @GetMapping("/colleges")
    public List<CollegeDto> savedColleges(HttpServletRequest request) {
        return savedItemsService.getSavedColleges(currentUserId(request));
    }

    @PostMapping("/colleges/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void saveCollege(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.saveCollege(currentUserId(request), slug);
    }

    @DeleteMapping("/colleges/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unsaveCollege(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.unsaveCollege(currentUserId(request), slug);
    }

    @GetMapping("/exams")
    public List<ExamDto> savedExams(HttpServletRequest request) {
        return savedItemsService.getSavedExams(currentUserId(request));
    }

    @PostMapping("/exams/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void saveExam(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.saveExam(currentUserId(request), slug);
    }

    @DeleteMapping("/exams/{slug}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unsaveExam(HttpServletRequest request, @PathVariable String slug) {
        savedItemsService.unsaveExam(currentUserId(request), slug);
    }

    private Long currentUserId(HttpServletRequest request) {
        return (Long) request.getAttribute(UserAuthInterceptor.USER_ID_ATTRIBUTE);
    }
}
