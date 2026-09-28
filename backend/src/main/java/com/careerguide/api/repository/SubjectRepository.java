package com.careerguide.api.repository;

import com.careerguide.api.entity.Subject;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SubjectRepository extends JpaRepository<Subject, String> {

    List<Subject> findAllByOrderByTitleAsc();

    // Explicit underscore: Subject has no `categorySlug` property, so the
    // traversal into category.slug is spelled out rather than left to Spring
    // Data's property-splitting fallback.
    List<Subject> findAllByCategory_SlugOrderByTitleAsc(String categorySlug);
}
