package com.careerguide.api.repository;

import com.careerguide.api.entity.UserLearningLogEntry;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface UserLearningLogRepository extends JpaRepository<UserLearningLogEntry, Long> {

    /** Everything since a date, for the activity grid, streak and minutes per item. */
    List<UserLearningLogEntry> findAllByUserIdAndLoggedOnGreaterThanEqual(Long userId, LocalDate from);

    /** The newest entries, for the log list. */
    List<UserLearningLogEntry> findAllByUserIdOrderByLoggedOnDescIdDesc(Long userId, Pageable page);

    /** Scored entries, oldest first, for the mock-score chart. */
    List<UserLearningLogEntry> findAllByUserIdAndScoreIsNotNullOrderByLoggedOnAscIdAsc(Long userId);

    /** Minutes logged per target, all time, for each focus item's total. */
    @Query("select e.target as target, sum(e.minutes) as minutes from UserLearningLogEntry e where e.userId = :userId group by e.target")
    List<TargetMinutes> sumMinutesByTarget(@Param("userId") Long userId);

    interface TargetMinutes {
        String getTarget();

        Long getMinutes();
    }

    /** Scoped by user so an entry id from someone else's log is simply not found. */
    Optional<UserLearningLogEntry> findByIdAndUserId(Long id, Long userId);
}
