package com.careerguide.api.repository;

import com.careerguide.api.entity.Specialization;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SpecializationRepository extends JpaRepository<Specialization, String> {

    List<Specialization> findAllByOrderByNameAsc();
}
