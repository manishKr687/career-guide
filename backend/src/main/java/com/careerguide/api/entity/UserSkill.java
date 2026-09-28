package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

// Added in V30 -- a user's self-reported skills with an optional
// proficiency level and years of experience, distinct from Career's
// relatedSkills (which describe a career, not a person).
@Entity
@Table(name = "user_skills")
public class UserSkill {

    @EmbeddedId
    private UserSlugId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("slug")
    @JoinColumn(name = "skill_slug")
    private Skill skill;

    @Column(name = "proficiency_level", length = 32)
    private String proficiencyLevel;

    @Column(name = "years_of_experience")
    private Integer yearsOfExperience;

    protected UserSkill() {
        // JPA
    }

    public UserSkill(User user, Skill skill, String proficiencyLevel, Integer yearsOfExperience) {
        this.id = new UserSlugId(user.getId(), skill.getSlug());
        this.user = user;
        this.skill = skill;
        this.proficiencyLevel = proficiencyLevel;
        this.yearsOfExperience = yearsOfExperience;
    }

    public UserSlugId getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public Skill getSkill() {
        return skill;
    }

    public String getProficiencyLevel() {
        return proficiencyLevel;
    }

    public void setProficiencyLevel(String proficiencyLevel) {
        this.proficiencyLevel = proficiencyLevel;
    }

    public Integer getYearsOfExperience() {
        return yearsOfExperience;
    }

    public void setYearsOfExperience(Integer yearsOfExperience) {
        this.yearsOfExperience = yearsOfExperience;
    }
}
