package com.example.SpringBoot_BE.Repository;

import com.example.SpringBoot_BE.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findBySocialProviderAndSocialId(String provider, String socialId);
}
