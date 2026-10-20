package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;

/**
 * A user's one active goal (V148): what kind of thing it is, and which one.
 *
 * <p>Keyed by the user, not by its own id, because a user has exactly one. Its
 * stations and focus items are separate rows keyed by the same user id and
 * read through their own repositories rather than mapped collections -- they
 * are always loaded by user, and this keeps the ordering bugs that
 * {@code @OrderColumn} collections caused elsewhere in this codebase out of it.
 */
@Entity
@Table(name = "user_goals")
public class UserGoal {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "goal_type", nullable = false, length = 16)
    private String goalType;

    @Column(name = "target_slug", nullable = false, length = 64)
    private String targetSlug;

    @Column(name = "target_name", nullable = false, length = 160)
    private String targetName;

    @Column(name = "target_month")
    private LocalDate targetMonth;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    protected UserGoal() {
        // JPA
    }

    public UserGoal(Long userId) {
        this.userId = userId;
    }

    public Long getUserId() {
        return userId;
    }

    public String getGoalType() {
        return goalType;
    }

    public void setGoalType(String goalType) {
        this.goalType = goalType;
    }

    public String getTargetSlug() {
        return targetSlug;
    }

    public void setTargetSlug(String targetSlug) {
        this.targetSlug = targetSlug;
    }

    public String getTargetName() {
        return targetName;
    }

    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }

    public LocalDate getTargetMonth() {
        return targetMonth;
    }

    public void setTargetMonth(LocalDate targetMonth) {
        this.targetMonth = targetMonth;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
