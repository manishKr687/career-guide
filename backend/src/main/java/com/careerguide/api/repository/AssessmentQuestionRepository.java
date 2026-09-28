package com.careerguide.api.repository;

import com.careerguide.api.entity.AssessmentQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AssessmentQuestionRepository extends JpaRepository<AssessmentQuestion, String> {

    List<AssessmentQuestion> findAllByOrderBySortOrderAsc();
}
