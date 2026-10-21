package com.careerguide.api.repository;

import com.careerguide.api.entity.UserGoal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserGoalRepository extends JpaRepository<UserGoal, Long> {

    /** How many people a change to this item's line reaches -- shown to the admin before they save. */
    long countByGoalTypeAndTargetSlug(String goalType, String targetSlug);
}
