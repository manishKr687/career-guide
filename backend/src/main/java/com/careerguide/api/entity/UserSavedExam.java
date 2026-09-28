package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

import java.time.Instant;

// Added in V31 -- saved exams have no localStorage precedent at all (the
// old frontend savedItems.ts only ever covered courses and colleges); this
// is a wholly new capability, per the ER doc's user_saved_exams.
@Entity
@Table(name = "user_saved_exams")
public class UserSavedExam {

    @EmbeddedId
    private UserSlugId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("slug")
    @JoinColumn(name = "exam_slug")
    private Exam exam;

    @Column(name = "saved_at", nullable = false)
    private Instant savedAt = Instant.now();

    protected UserSavedExam() {
        // JPA
    }

    public UserSavedExam(User user, Exam exam) {
        this.id = new UserSlugId(user.getId(), exam.getSlug());
        this.user = user;
        this.exam = exam;
    }

    public UserSlugId getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public Exam getExam() {
        return exam;
    }

    public Instant getSavedAt() {
        return savedAt;
    }
}
