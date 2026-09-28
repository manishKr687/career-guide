package com.careerguide.api.repository;

import com.careerguide.api.entity.Exam;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ExamRepository extends JpaRepository<Exam, String> {

    List<Exam> findAllByCategoryOrderByNameAsc(String category);

    // See CareerRepository.search for why this takes a Pageable and how
    // Pageable.unpaged() is handled (PaginationSupport resolves it).
    @Query(
            value = """
                    select e from Exam e
                    where (:category is null or e.category = :category)
                      and (
                        :q is null
                        or lower(e.name) like lower(concat('%', cast(:q as string), '%'))
                        or lower(e.fullName) like lower(concat('%', cast(:q as string), '%'))
                        or lower(e.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    order by e.name asc
                    """,
            countQuery = """
                    select count(e) from Exam e
                    where (:category is null or e.category = :category)
                      and (
                        :q is null
                        or lower(e.name) like lower(concat('%', cast(:q as string), '%'))
                        or lower(e.fullName) like lower(concat('%', cast(:q as string), '%'))
                        or lower(e.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    """
    )
    Page<Exam> search(@Param("category") String category, @Param("q") String query, Pageable pageable);
}
