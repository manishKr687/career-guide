package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;

/**
 * A visitor-submitted request to book a counselling call. Unlike the
 * content entities (Career, Course, ...), this has a surrogate numeric id
 * rather than a slug -- these are transient submissions, not admin-authored
 * catalog content.
 */
@Entity
@Table(name = "counselling_requests")
public class CounsellingRequest {

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_CONTACTED = "CONTACTED";
    public static final String STATUS_COMPLETED = "COMPLETED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false, length = 255)
    private String email;

    @Column(nullable = false, length = 32)
    private String phone;

    @Column(name = "preferred_date")
    private LocalDate preferredDate;

    @Column(name = "preferred_time", length = 64)
    private String preferredTime;

    @Column(name = "stage_slug", length = 64)
    private String stageSlug;

    @Column(name = "career_slug", length = 64)
    private String careerSlug;

    @Column(columnDefinition = "text")
    private String message;

    @Column(nullable = false, length = 16)
    private String status = STATUS_PENDING;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    // Public, not protected: JPA only needs a no-arg constructor (Hibernate
    // uses reflection regardless of visibility), and CounsellingRequestService
    // calls `new CounsellingRequest()` directly from a different package. A
    // previous entity in this codebase had this as `protected` and it broke
    // the build the moment a service tried to construct one -- see Career.java.
    public CounsellingRequest() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public LocalDate getPreferredDate() {
        return preferredDate;
    }

    public void setPreferredDate(LocalDate preferredDate) {
        this.preferredDate = preferredDate;
    }

    public String getPreferredTime() {
        return preferredTime;
    }

    public void setPreferredTime(String preferredTime) {
        this.preferredTime = preferredTime;
    }

    public String getStageSlug() {
        return stageSlug;
    }

    public void setStageSlug(String stageSlug) {
        this.stageSlug = stageSlug;
    }

    public String getCareerSlug() {
        return careerSlug;
    }

    public void setCareerSlug(String careerSlug) {
        this.careerSlug = careerSlug;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
