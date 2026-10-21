package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

/**
 * An admin-set line for one goal item (V149). Its stations are separate rows
 * read through {@code GoalLineStationRepository}, the same way a user's
 * stations are.
 */
@Entity
@Table(name = "goal_lines")
public class GoalLine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "goal_type", nullable = false, length = 16)
    private String goalType;

    @Column(name = "target_slug", nullable = false, length = 64)
    private String targetSlug;

    @Column(nullable = false)
    private int version = 1;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    protected GoalLine() {
        // JPA
    }

    public GoalLine(String goalType, String targetSlug) {
        this.goalType = goalType;
        this.targetSlug = targetSlug;
    }

    public Long getId() {
        return id;
    }

    public String getGoalType() {
        return goalType;
    }

    public String getTargetSlug() {
        return targetSlug;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    /** What a user's goal records when its stations come from this line. */
    public String source() {
        return "admin:" + version;
    }
}
