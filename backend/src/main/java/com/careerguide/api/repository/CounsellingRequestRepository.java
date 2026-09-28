package com.careerguide.api.repository;

import com.careerguide.api.entity.CounsellingRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CounsellingRequestRepository extends JpaRepository<CounsellingRequest, Long> {

    List<CounsellingRequest> findAllByOrderByCreatedAtDesc();
}
