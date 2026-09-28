package com.careerguide.api.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "assessment_questions")
public class AssessmentQuestion {

    @Id
    @Column(name = "id", length = 64)
    private String id;

    @Column(nullable = false, columnDefinition = "text")
    private String question;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    @OneToMany(mappedBy = "question", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<AssessmentOption> options = new ArrayList<>();

    protected AssessmentQuestion() {
        // JPA
    }

    public String getId() {
        return id;
    }

    public String getQuestion() {
        return question;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public List<AssessmentOption> getOptions() {
        return options;
    }
}
