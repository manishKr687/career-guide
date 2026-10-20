package com.careerguide.api.repository;

import com.careerguide.api.entity.UserGoalStation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserGoalStationRepository extends JpaRepository<UserGoalStation, Long> {

    List<UserGoalStation> findAllByUserIdOrderByPositionAscIdAsc(Long userId);

    /** Scoped by user so a station id from someone else's line is simply not found. */
    Optional<UserGoalStation> findByIdAndUserId(Long id, Long userId);

    @Modifying
    @Query("delete from UserGoalStation s where s.userId = :userId")
    void deleteAllForUser(@Param("userId") Long userId);
}
