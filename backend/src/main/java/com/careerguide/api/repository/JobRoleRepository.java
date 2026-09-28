package com.careerguide.api.repository;

import com.careerguide.api.entity.JobRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JobRoleRepository extends JpaRepository<JobRole, String> {

    List<JobRole> findAllByOrderByNameAsc();

    List<JobRole> findAllByCareers_SlugOrderByNameAsc(String careerSlug);
}
