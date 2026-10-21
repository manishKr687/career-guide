package com.careerguide.api.repository;

import com.careerguide.api.entity.GoalLineStation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GoalLineStationRepository extends JpaRepository<GoalLineStation, Long> {

    List<GoalLineStation> findAllByLineIdOrderByPositionAsc(Long lineId);

    /** A bulk delete, run at once -- so re-inserting the same positions never meets the unique constraint. */
    @Modifying
    @Query("delete from GoalLineStation s where s.lineId = :lineId")
    void deleteAllForLine(@Param("lineId") Long lineId);
}
