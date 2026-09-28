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
// localStorage-only saved careers (savedItems.ts never covered careers).
@Entity
@Table(name = "user_saved_careers")
public class UserSavedCareer {

    @EmbeddedId
    private UserSlugId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("slug")
    @JoinColumn(name = "career_slug")
    private Career career;

    @Column(name = "saved_at", nullable = false)
    private Instant savedAt = Instant.now();

    protected UserSavedCareer() {
        // JPA
    }

    public UserSavedCareer(User user, Career career) {
        this.id = new UserSlugId(user.getId(), career.getSlug());
        this.user = user;
        this.career = career;
    }

    public UserSlugId getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public Career getCareer() {
        return career;
    }

    public Instant getSavedAt() {
        return savedAt;
    }
}
