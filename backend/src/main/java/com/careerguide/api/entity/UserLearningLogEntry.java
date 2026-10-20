package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDate;

/**
 * One line of a user's learning log (V148). Owned by the user rather than the
 * goal, so changing goal keeps the history. A score is stored with its own
 * maximum, so a 142/300 mock and an 80% practice test are never mixed up.
 */
@Entity
@Table(name = "user_learning_log")
public class UserLearningLogEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "logged_on", nullable = false)
    private LocalDate loggedOn;

    @Column(nullable = false, length = 280)
    private String note;

    @Column(nullable = false, length = 80)
    private String target;

    @Column(nullable = false)
    private Short minutes;

    private Short score;

    @Column(name = "score_max")
    private Short scoreMax;

    protected UserLearningLogEntry() {
        // JPA
    }

    public UserLearningLogEntry(Long userId, LocalDate loggedOn, String note, String target, int minutes, Integer score, Integer scoreMax) {
        this.userId = userId;
        this.loggedOn = loggedOn;
        this.note = note;
        this.target = target;
        this.minutes = (short) minutes;
        this.score = score == null ? null : score.shortValue();
        this.scoreMax = scoreMax == null ? null : scoreMax.shortValue();
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public LocalDate getLoggedOn() {
        return loggedOn;
    }

    public String getNote() {
        return note;
    }

    public String getTarget() {
        return target;
    }

    public int getMinutes() {
        return minutes;
    }

    public Integer getScore() {
        return score == null ? null : score.intValue();
    }

    public Integer getScoreMax() {
        return scoreMax == null ? null : scoreMax.intValue();
    }
}
