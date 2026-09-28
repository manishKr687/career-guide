package com.careerguide.api.repository;

import com.careerguide.api.entity.Resource;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ResourceRepository extends JpaRepository<Resource, String> {

    List<Resource> findAllByOrderByPublishedAtDesc();
}
