package com.careerguide.api.entity;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.Table;

import java.util.LinkedHashMap;
import java.util.Map;

@Entity
@Table(name = "assessment_options")
public class AssessmentOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private AssessmentQuestion question;

    @Column(name = "option_key", nullable = false, length = 8)
    private String optionKey;

    @Column(nullable = false, columnDefinition = "text")
    private String label;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    // categorySlug -> weight, mirrors AssessmentOption.weights in the frontend.
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "assessment_option_weights", joinColumns = @JoinColumn(name = "option_id"))
    @MapKeyColumn(name = "category_slug")
    @Column(name = "weight", nullable = false)
    private Map<String, Integer> weights = new LinkedHashMap<>();

    protected AssessmentOption() {
        // JPA
    }

    public Long getId() {
        return id;
    }

    public AssessmentQuestion getQuestion() {
        return question;
    }

    public String getOptionKey() {
        return optionKey;
    }

    public String getLabel() {
        return label;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public Map<String, Integer> getWeights() {
        return weights;
    }
}
