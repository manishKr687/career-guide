package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "stages")
public class Stage {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 128)
    private String name;

    @Column(nullable = false, length = 255)
    private String tagline;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(name = "badge_soft", nullable = false, length = 128)
    private String badgeSoft;

    @Column(name = "badge_solid", nullable = false, length = 128)
    private String badgeSolid;

    @Column(nullable = false, length = 32)
    private String icon;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(nullable = false, columnDefinition = "text[]")
    private List<String> highlights = new ArrayList<>();

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    // Mirrors stage.relatedCareerSlugs from the frontend data model.
    //
    // Inverse side of Career.stages (career_stages) as of V76. This used to
    // own a SECOND table, stage_careers, holding the same relationship in
    // the opposite direction -- and nothing ever wrote it: Stage is
    // read-only (no setters, absent from the admin's RESOURCE_CONFIGS),
    // while the Career admin form writes career_stages. So assigning stages
    // to a career could never show up on that stage's page. Reading both
    // directions from one table makes that divergence impossible rather
    // than merely discouraged.
    //
    // Ordered by title, not a per-stage @OrderColumn: an inverse side cannot
    // own the join table's order column, and there is no second ordering
    // left to keep dense (see V58 for what a broken @OrderColumn costs).
    // Deliberately NOT Career.sortOrder -- that column is 0 for all 41
    // careers, so ordering by it would leave the sequence up to whatever
    // order the database happened to return.
    @ManyToMany(mappedBy = "stages", fetch = FetchType.LAZY)
    @OrderBy("title ASC")
    private List<Career> relatedCareers = new ArrayList<>();

    // Mirrors stage.relatedExamSlugs from the frontend data model.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "stage_exams",
            joinColumns = @JoinColumn(name = "stage_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Exam> relatedExams = new ArrayList<>();

    protected Stage() {
        // JPA
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getTagline() {
        return tagline;
    }

    public String getDescription() {
        return description;
    }

    public String getBadgeSoft() {
        return badgeSoft;
    }

    public String getBadgeSolid() {
        return badgeSolid;
    }

    public String getIcon() {
        return icon;
    }

    public List<String> getHighlights() {
        return highlights;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public List<Career> getRelatedCareers() {
        return relatedCareers;
    }

    public List<Exam> getRelatedExams() {
        return relatedExams;
    }
}
