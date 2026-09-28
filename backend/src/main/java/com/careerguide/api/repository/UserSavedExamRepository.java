package com.careerguide.api.repository;

import com.careerguide.api.entity.UserSavedExam;
import com.careerguide.api.entity.UserSlugId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserSavedExamRepository extends JpaRepository<UserSavedExam, UserSlugId> {

    List<UserSavedExam> findAllByIdUserId(Long userId);
}
