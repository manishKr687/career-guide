package com.careerguide.api.repository;

import com.careerguide.api.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** Added in V53 (College MVP). */
public interface CityRepository extends JpaRepository<City, String> {

    List<City> findAllByOrderByNameAsc();

    List<City> findAllByStateSlugOrderByNameAsc(String stateSlug);
}
