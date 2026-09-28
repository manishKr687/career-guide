package com.careerguide.api.repository;

import com.careerguide.api.entity.Stage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StageRepository extends JpaRepository<Stage, String> {

    List<Stage> findAllByOrderBySortOrderAsc();
}
