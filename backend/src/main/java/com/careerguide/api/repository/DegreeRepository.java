package com.careerguide.api.repository;

import com.careerguide.api.entity.Degree;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DegreeRepository extends JpaRepository<Degree, String> {

    List<Degree> findAllByOrderByTitleAsc();
}
