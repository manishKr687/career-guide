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

// Added in V31 -- server-backed replacement for the frontend's
// localStorage-only saved colleges (savedItems.ts).
@Entity
@Table(name = "user_saved_colleges")
public class UserSavedCollege {

    @EmbeddedId
    private UserSlugId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("slug")
    @JoinColumn(name = "college_slug")
    private College college;

    @Column(name = "saved_at", nullable = false)
    private Instant savedAt = Instant.now();

    protected UserSavedCollege() {
        // JPA
    }

    public UserSavedCollege(User user, College college) {
        this.id = new UserSlugId(user.getId(), college.getSlug());
        this.user = user;
        this.college = college;
    }

    public UserSlugId getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public College getCollege() {
        return college;
    }

    public Instant getSavedAt() {
        return savedAt;
    }
}
