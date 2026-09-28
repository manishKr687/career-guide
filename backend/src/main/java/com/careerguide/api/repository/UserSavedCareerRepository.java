package com.careerguide.api.repository;

import com.careerguide.api.entity.UserSavedCareer;
import com.careerguide.api.entity.UserSlugId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserSavedCareerRepository extends JpaRepository<UserSavedCareer, UserSlugId> {

    List<UserSavedCareer> findAllByIdUserId(Long userId);
}
