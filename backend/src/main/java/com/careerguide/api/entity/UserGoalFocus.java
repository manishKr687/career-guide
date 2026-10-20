package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Something a user is working on for their goal (V148): a catalogue skill
 * ({@code skillSlug} set) or their own subject or topic ({@code skillSlug}
 * null). {@code level} runs 0 not started, 1 learning, 2 comfortable,
 * 3 confident.
 */
@Entity
@Table(name = "user_goal_focus")
public class UserGoalFocus {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(nullable = false, length = 60)
    private String name;

    @Column(name = "skill_slug", length = 64)
    private String skillSlug;

    @Column(nullable = false)
    private Short level;

    protected UserGoalFocus() {
        // JPA
    }

    public UserGoalFocus(Long userId, String name, String skillSlug) {
        this.userId = userId;
        this.name = name;
        this.skillSlug = skillSlug;
        this.level = 0;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public String getSkillSlug() {
        return skillSlug;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = (short) level;
    }
}
