package com.careerguide.api.repository;

import com.careerguide.api.entity.Industry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IndustryRepository extends JpaRepository<Industry, String> {

    List<Industry> findAllByOrderByNameAsc();
}
