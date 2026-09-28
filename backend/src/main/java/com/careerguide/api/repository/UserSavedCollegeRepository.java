package com.careerguide.api.repository;

import com.careerguide.api.entity.UserSavedCollege;
import com.careerguide.api.entity.UserSlugId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserSavedCollegeRepository extends JpaRepository<UserSavedCollege, UserSlugId> {

    List<UserSavedCollege> findAllByIdUserId(Long userId);
}
