package com.careerguide.api.repository;

import com.careerguide.api.entity.UserSkill;
import com.careerguide.api.entity.UserSlugId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserSkillRepository extends JpaRepository<UserSkill, UserSlugId> {

    List<UserSkill> findAllByIdUserId(Long userId);
}
