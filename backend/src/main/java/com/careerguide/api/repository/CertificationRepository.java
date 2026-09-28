package com.careerguide.api.repository;

import com.careerguide.api.entity.Certification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CertificationRepository extends JpaRepository<Certification, String> {

    List<Certification> findAllByOrderByNameAsc();
}
