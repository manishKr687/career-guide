package com.careerguide.api.repository;

import com.careerguide.api.entity.Career;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CareerRepository extends JpaRepository<Career, String> {

    List<Career> findAllByCategorySlugOrderBySortOrderAsc(String categorySlug);

    // Reverse of Career.relatedSpecializations (career_specializations is
    // owned entirely by Career -- see Specialization.java) -- used to show
    // which career(s) a specialization belongs to, and by SpecializationService
    // to sync that link from the Specialization admin form.
    List<Career> findAllByRelatedSpecializations_SlugOrderByTitleAsc(String specializationSlug);

    // Pageable is honored when concrete (LIMIT/OFFSET applied and an
    // accurate totalElements computed via countQuery); Pageable.unpaged()
    // returns every matching row in one Page, with totalElements still
    // correct -- see PaginationSupport for why callers get that choice.
    @Query(
            value = """
                    select c from Career c
                    where (:category is null or c.category.slug = :category)
                      and (
                        :q is null
                        or lower(c.title) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.tagline) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    order by c.title asc
                    """,
            countQuery = """
                    select count(c) from Career c
                    where (:category is null or c.category.slug = :category)
                      and (
                        :q is null
                        or lower(c.title) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.tagline) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    """
    )
    Page<Career> search(@Param("category") String category, @Param("q") String query, Pageable pageable);
}
