package com.careerguide.api.repository;

import com.careerguide.api.entity.GoalLine;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GoalLineRepository extends JpaRepository<GoalLine, Long> {

    Optional<GoalLine> findByGoalTypeAndTargetSlug(String goalType, String targetSlug);

    List<GoalLine> findAllByOrderByUpdatedAtDesc();
}
