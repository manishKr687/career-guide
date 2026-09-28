package com.careerguide.api.repository;

import com.careerguide.api.entity.University;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** Added in V53 (College MVP). */
public interface UniversityRepository extends JpaRepository<University, String> {

    List<University> findAllByOrderByNameAsc();
}
