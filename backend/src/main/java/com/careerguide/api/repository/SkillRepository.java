package com.careerguide.api.repository;

import com.careerguide.api.entity.Skill;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SkillRepository extends JpaRepository<Skill, String> {

    List<Skill> findAllByOrderByNameAsc();
}
