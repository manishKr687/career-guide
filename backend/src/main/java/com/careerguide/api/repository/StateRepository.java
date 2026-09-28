package com.careerguide.api.repository;

import com.careerguide.api.entity.State;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** Added in V53 (College MVP). */
public interface StateRepository extends JpaRepository<State, String> {

    List<State> findAllByOrderByNameAsc();
}
