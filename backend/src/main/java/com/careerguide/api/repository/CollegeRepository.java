package com.careerguide.api.repository;

import com.careerguide.api.entity.College;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CollegeRepository extends JpaRepository<College, String> {

    List<College> findAllByTypeOrderByNameAsc(String type);

    // See CareerRepository.search for why this takes a Pageable and how
    // Pageable.unpaged() is handled (PaginationSupport resolves it).
    //
    // degree/discipline/state added in V53 (College MVP) -- matches the
    // Since V103 c.degrees is a CollegeDegree join entity rather than a
    // direct Degree collection, so the filter walks deg.degree.slug -- the
    // extra hop is the subject-bearing row in between. Filtering by subject
    // would be `deg.subject.slug` and is not exposed yet.
    //
    // spec's own filter example, GET /api/colleges?degree=btech&discipline=
    // cse&state=delhi. `distinct` is needed because the two `left join`s
    // fan the row count out per matching degree/discipline when a college
    // has more than one -- harmless when the corresponding filter is null
    // (every row still matches its own "is null" branch) but would
    // otherwise return duplicate rows once a filter narrows the join.
    @Query(
            value = """
                    select distinct c from College c
                    left join c.degrees deg
                    left join c.disciplines dis
                    where (:type is null or c.type = :type)
                      and (:state is null or c.state.slug = :state)
                      and (:degree is null or deg.degree.slug = :degree)
                      and (:discipline is null or dis.slug = :discipline)
                      and (
                        :q is null
                        or lower(c.name) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.location) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    order by c.name asc
                    """,
            countQuery = """
                    select count(distinct c) from College c
                    left join c.degrees deg
                    left join c.disciplines dis
                    where (:type is null or c.type = :type)
                      and (:state is null or c.state.slug = :state)
                      and (:degree is null or deg.degree.slug = :degree)
                      and (:discipline is null or dis.slug = :discipline)
                      and (
                        :q is null
                        or lower(c.name) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.location) like lower(concat('%', cast(:q as string), '%'))
                        or lower(c.description) like lower(concat('%', cast(:q as string), '%'))
                      )
                    """
    )
    Page<College> search(
            @Param("type") String type,
            @Param("q") String query,
            @Param("degree") String degree,
            @Param("discipline") String discipline,
            @Param("state") String state,
            Pageable pageable
    );
}
