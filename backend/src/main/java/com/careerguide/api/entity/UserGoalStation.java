package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * One station on a user's line (V148). Built from the catalogue when the goal
 * is set, then the user's own: ticked off, removed, or added ({@code custom}).
 */
@Entity
@Table(name = "user_goal_stations")
public class UserGoalStation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

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

    @Column(nullable = false)
    private boolean done;

    @Column(nullable = false)
    private boolean custom;

    protected UserGoalStation() {
        // JPA
    }

    public UserGoalStation(Long userId, int position, String name, String kind, String detail, String nextStep, boolean custom) {
        this.userId = userId;
        this.position = (short) position;
        this.name = name;
        this.kind = kind;
        this.detail = detail == null ? "" : detail;
        this.nextStep = nextStep;
        this.custom = custom;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = (short) position;
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

    public boolean isDone() {
        return done;
    }

    public void setDone(boolean done) {
        this.done = done;
    }

    public boolean isCustom() {
        return custom;
    }
}
