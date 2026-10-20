package com.careerguide.api.repository;

import com.careerguide.api.entity.UserGoal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserGoalRepository extends JpaRepository<UserGoal, Long> {
}
