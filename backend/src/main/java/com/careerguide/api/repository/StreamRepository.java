package com.careerguide.api.repository;

import com.careerguide.api.entity.Stream;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StreamRepository extends JpaRepository<Stream, String> {

    List<Stream> findAllByOrderByNameAsc();
}
