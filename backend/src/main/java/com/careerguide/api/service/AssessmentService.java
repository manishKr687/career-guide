package com.careerguide.api.service;

import com.careerguide.api.dto.AssessmentQuestionDto;
import com.careerguide.api.dto.AssessmentResultDto;
import com.careerguide.api.dto.AssessmentSubmissionRequest;
import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CategoryDto;
import com.careerguide.api.entity.AssessmentOption;
import com.careerguide.api.entity.AssessmentQuestion;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.Category;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.AssessmentQuestionRepository;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Server-side port of the frontend's src/lib/assessment.ts:
 * computeCategoryScores / getTopCategories / getRecommendedCareers. Kept
 * behaviourally identical (including its default counts of 4 top categories
 * for display and 5 top categories when picking recommended careers) so
 * results match what the client currently computes locally.
 */
@Service
@Transactional(readOnly = true)
public class AssessmentService {

    private static final int DEFAULT_TOP_CATEGORY_COUNT = 4;
    private static final int RECOMMENDATION_CATEGORY_POOL = 5;
    private static final int DEFAULT_RECOMMENDED_CAREER_COUNT = 6;

    private final AssessmentQuestionRepository questionRepository;
    private final CategoryRepository categoryRepository;
    private final CareerRepository careerRepository;

    public AssessmentService(
            AssessmentQuestionRepository questionRepository,
            CategoryRepository categoryRepository,
            CareerRepository careerRepository
    ) {
        this.questionRepository = questionRepository;
        this.categoryRepository = categoryRepository;
        this.careerRepository = careerRepository;
    }

    public List<AssessmentQuestionDto> findQuestions() {
        return questionRepository.findAllByOrderBySortOrderAsc().stream().map(DtoMapper::toDto).toList();
    }

    public AssessmentResultDto submit(AssessmentSubmissionRequest request) {
        List<AssessmentQuestion> questions = questionRepository.findAllByOrderBySortOrderAsc();
        Map<String, Integer> scores = computeCategoryScores(request.answers(), questions);

        List<Category> topCategories = getTopCategories(scores, DEFAULT_TOP_CATEGORY_COUNT);
        List<Career> recommendedCareers = getRecommendedCareers(scores, DEFAULT_RECOMMENDED_CAREER_COUNT);

        return new AssessmentResultDto(
                scores,
                topCategories.stream().map(DtoMapper::toDto).toList(),
                recommendedCareers.stream().map(DtoMapper::toDto).toList()
        );
    }

    private Map<String, Integer> computeCategoryScores(Map<String, String> answers, List<AssessmentQuestion> questions) {
        Map<String, Integer> scores = new LinkedHashMap<>();
        if (answers == null) {
            return scores;
        }
        for (AssessmentQuestion question : questions) {
            String chosenOptionKey = answers.get(question.getId());
            if (chosenOptionKey == null) {
                continue;
            }
            AssessmentOption option = question.getOptions().stream()
                    .filter(o -> o.getOptionKey().equals(chosenOptionKey))
                    .findFirst()
                    .orElse(null);
            if (option == null) {
                continue;
            }
            for (Map.Entry<String, Integer> weight : option.getWeights().entrySet()) {
                scores.merge(weight.getKey(), weight.getValue() == null ? 0 : weight.getValue(), Integer::sum);
            }
        }
        return scores;
    }

    private List<Category> getTopCategories(Map<String, Integer> scores, int count) {
        return scores.entrySet().stream()
                // Integer.compare rather than b - a: subtraction in a comparator
                // overflows once the operands are far enough apart, and an
                // overflowed difference flips sign, which makes the comparator
                // inconsistent and can throw "Comparison method violates its
                // general contract". Assessment scores are small enough that it
                // could not happen here, but the correct form costs nothing.
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .limit(count)
                .map(e -> categoryRepository.findById(e.getKey()).orElse(null))
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    private List<Career> getRecommendedCareers(Map<String, Integer> scores, int count) {
        List<Category> topCategories = getTopCategories(scores, RECOMMENDATION_CATEGORY_POOL);
        List<Career> picked = new ArrayList<>();
        for (Category category : topCategories) {
            List<Career> inCategory = careerRepository.findAllByCategorySlugOrderBySortOrderAsc(category.getSlug());
            for (Career career : inCategory) {
                if (picked.size() >= count) {
                    break;
                }
                boolean alreadyPicked = picked.stream().anyMatch(p -> p.getSlug().equals(career.getSlug()));
                if (!alreadyPicked) {
                    picked.add(career);
                }
            }
            if (picked.size() >= count) {
                break;
            }
        }
        return picked.size() > count ? picked.subList(0, count) : picked;
    }
}
