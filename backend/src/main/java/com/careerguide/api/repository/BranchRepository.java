package com.careerguide.api.repository;

import com.careerguide.api.entity.Branch;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BranchRepository extends JpaRepository<Branch, String> {

    List<Branch> findAllByOrderBySortOrderAsc();

    List<Branch> findAllByCategorySlugOrderBySortOrderAsc(String categorySlug);
}
