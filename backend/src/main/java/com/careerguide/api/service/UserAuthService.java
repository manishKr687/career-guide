package com.careerguide.api.service;

import com.careerguide.api.dto.AuthResponse;
import com.careerguide.api.entity.User;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.UserRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.UnauthorizedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Registration and login for consumer accounts -- the {@code users} table
 * added in V30. Mirrors {@link AdminAuthService}'s constant-time-comparison
 * discipline (via {@link UserPasswordService}, which uses PBKDF2 rather
 * than a raw digest since these are user-chosen passwords, not one shared
 * admin secret) but additionally has to look an account up, hence its own
 * service rather than reusing AdminAuthService directly.
 */
@Service
@Transactional
public class UserAuthService {

    private final UserRepository userRepository;
    private final UserPasswordService passwordService;
    private final UserTokenService tokenService;

    public UserAuthService(UserRepository userRepository, UserPasswordService passwordService, UserTokenService tokenService) {
        this.userRepository = userRepository;
        this.passwordService = passwordService;
        this.tokenService = tokenService;
    }

    /**
     * @throws ConflictException if the email is already registered.
     */
    public AuthResponse register(String email, String rawPassword, String name) {
        String normalizedEmail = normalize(email);
        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new ConflictException("An account with this email already exists");
        }
        User user = new User(normalizedEmail, passwordService.hash(rawPassword), name.trim());
        user = userRepository.save(user);
        return issueAuthResponse(user);
    }

    /**
     * @throws UnauthorizedException if the email isn't registered or the
     * password doesn't match -- deliberately the same message either way, so
     * a failed login can't be used to enumerate which emails have accounts.
     */
    public AuthResponse login(String email, String rawPassword) {
        User user = userRepository.findByEmail(normalize(email))
                .orElseThrow(() -> new UnauthorizedException("Incorrect email or password"));
        if (!passwordService.matches(rawPassword == null ? "" : rawPassword, user.getPasswordHash())) {
            throw new UnauthorizedException("Incorrect email or password");
        }
        return issueAuthResponse(user);
    }

    private AuthResponse issueAuthResponse(User user) {
        String token = tokenService.issueToken(user.getId());
        return new AuthResponse(token, DtoMapper.toDto(user));
    }

    private String normalize(String email) {
        return (email == null ? "" : email).trim().toLowerCase();
    }
}
