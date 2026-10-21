package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** One station of an admin-set line (V149); the last one is the goal. */
@Entity
@Table(name = "goal_line_stations")
public class GoalLineStation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "line_id", nullable = false)
    private Long lineId;

    @Column(nullable = false)
    private Short position;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(nullable = false, length = 32)
    private String kind;

    @Column(nullable = false, length = 200)
    private String detail;

    @Column(name = "next_step", length = 200)
    private String nextStep;

    protected GoalLineStation() {
        // JPA
    }

    public GoalLineStation(Long lineId, int position, String name, String kind, String detail, String nextStep) {
        this.lineId = lineId;
        this.position = (short) position;
        this.name = name;
        this.kind = kind;
        this.detail = detail;
        this.nextStep = nextStep;
    }

    public Long getId() {
        return id;
    }

    public Long getLineId() {
        return lineId;
    }

    public int getPosition() {
        return position;
    }

    public String getName() {
        return name;
    }

    public String getKind() {
        return kind;
    }

    public String getDetail() {
        return detail;
    }

    public String getNextStep() {
        return nextStep;
    }
}
