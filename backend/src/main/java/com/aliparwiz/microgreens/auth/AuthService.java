package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.auth.dto.AuthResponse;
import com.aliparwiz.microgreens.auth.dto.LoginRequest;
import com.aliparwiz.microgreens.auth.dto.RegisterRequest;
import com.aliparwiz.microgreens.exception.ValidationException;
import com.aliparwiz.microgreens.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

/**
 * Authentication Service
 * Handles user registration, login, and token management
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final AuthRepository authRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    
    /**
     * Register a new user
     * @param request User registration request
     * @return Response containing user info and JWT token
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();
        String name = request.getName();

        // Validate input
        if (email == null || email.trim().isEmpty()) {
            throw new ValidationException("Email cannot be empty");
        }
        if (password == null || password.length() < 6) {
            throw new ValidationException("Password must be at least 6 characters");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new ValidationException("Name cannot be empty");
        }
        
        if (authRepository.existsByEmail(email)) {
            throw new ValidationException("Email already registered");
        }
        
        User user = new User();
        user.setEmail(email.trim());
        user.setPassword(passwordEncoder.encode(password));
        user.setName(name.trim());
        user.setRole(Role.USER);
        
        User savedUser = authRepository.save(user);
        log.info("[AUTH] Registered user: {}", savedUser.getEmail());
        
        // Generate JWT token
        String token = jwtTokenProvider.generateToken(
            savedUser.getId(), 
            savedUser.getEmail(), 
            savedUser.getRole().name()
        );

        return buildAuthResponse(savedUser, token);
    }
    
    /**
     * Login user with email and password
     * @param request User login request
     * @return Response containing user info and JWT token
     */
    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();

        User user = authRepository.findByEmail(email)
            .orElseThrow(() -> new ValidationException("Invalid email or password"));
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.warn("[AUTH] Login failed for user: {}", email);
            throw new ValidationException("Invalid email or password");
        }
        
        log.info("[AUTH] User logged in: {}", email);
        
        // Generate JWT token
        String token = jwtTokenProvider.generateToken(
            user.getId(), 
            user.getEmail(), 
            user.getRole().name()
        );

        return buildAuthResponse(user, token);
    }
    
    /**
     * Logout user (token invalidation handled on client side)
     * @return Logout confirmation message
     */
    public Map<String, String> logout(String email) {
        log.info("[AUTH] User logged out: {}", email);
        return Map.of("message", "Logged out successfully");
    }

    private AuthResponse buildAuthResponse(User user, String token) {
        return AuthResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .name(user.getName())
            .role(user.getRole().name())
            .token(token)
            .accessToken(token)
            .expiresIn(jwtTokenProvider.getJwtExpirationMs())
            .build();
    }
}

