package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

// Added in V30 -- one row per user, created lazily the first time they save
// profile details (UserService.updateProfile), not at registration time.
@Entity
@Table(name = "user_profiles")
public class UserProfile {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "education_stage_slug")
    private Stage educationStage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stream_slug")
    private Stream stream;

    @Column(name = "education_level", length = 64)
    private String educationLevel;

    @Column(name = "graduation_year")
    private Integer graduationYear;

    @Column(name = "experience_years")
    private Integer experienceYears;

    @Column(length = 160)
    private String location;

    protected UserProfile() {
        // JPA
    }

    public UserProfile(User user) {
        this.user = user;
        this.userId = user.getId();
    }

    public Long getUserId() {
        return userId;
    }

    public User getUser() {
        return user;
    }

    public Stage getEducationStage() {
        return educationStage;
    }

    public void setEducationStage(Stage educationStage) {
        this.educationStage = educationStage;
    }

    public Stream getStream() {
        return stream;
    }

    public void setStream(Stream stream) {
        this.stream = stream;
    }

    public String getEducationLevel() {
        return educationLevel;
    }

    public void setEducationLevel(String educationLevel) {
        this.educationLevel = educationLevel;
    }

    public Integer getGraduationYear() {
        return graduationYear;
    }

    public void setGraduationYear(Integer graduationYear) {
        this.graduationYear = graduationYear;
    }

    public Integer getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(Integer experienceYears) {
        this.experienceYears = experienceYears;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}
