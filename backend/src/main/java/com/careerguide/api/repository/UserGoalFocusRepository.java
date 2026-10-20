package com.careerguide.api.repository;

import com.careerguide.api.entity.UserGoalFocus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserGoalFocusRepository extends JpaRepository<UserGoalFocus, Long> {

    List<UserGoalFocus> findAllByUserIdOrderByIdAsc(Long userId);

    /** Scoped by user so a focus id from someone else's goal is simply not found. */
    Optional<UserGoalFocus> findByIdAndUserId(Long id, Long userId);

    long countByUserId(Long userId);

    @Modifying
    @Query("delete from UserGoalFocus f where f.userId = :userId")
    void deleteAllForUser(@Param("userId") Long userId);
}
