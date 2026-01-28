package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.exception.ValidationException;
import com.aliparwiz.microgreens.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
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
     * @param email User email
     * @param password User password
     * @param name User name
     * @return Response containing user info and JWT token
     */
    @Transactional
    public Map<String, Object> register(String email, String password, String name) {
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
        log.info("New user registered: {}", savedUser.getEmail());
        
        // Generate JWT token
        String token = jwtTokenProvider.generateToken(
            savedUser.getId(), 
            savedUser.getEmail(), 
            savedUser.getRole().name()
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", savedUser.getId());
        response.put("email", savedUser.getEmail());
        response.put("name", savedUser.getName());
        response.put("role", savedUser.getRole().name());
        response.put("token", token);
        response.put("accessToken", token);
        response.put("expiresIn", jwtTokenProvider.getJwtExpirationMs());
        
        return response;
    }
    
    /**
     * Login user with email and password
     * @param email User email
     * @param password User password
     * @return Response containing user info and JWT token
     */
    public Map<String, Object> login(String email, String password) {
        User user = authRepository.findByEmail(email)
            .orElseThrow(() -> new ValidationException("Invalid email or password"));
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.warn("Failed login attempt for user: {}", email);
            throw new ValidationException("Invalid email or password");
        }
        
        log.info("User logged in: {}", email);
        
        // Generate JWT token
        String token = jwtTokenProvider.generateToken(
            user.getId(), 
            user.getEmail(), 
            user.getRole().name()
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("email", user.getEmail());
        response.put("name", user.getName());
        response.put("role", user.getRole().name());
        response.put("token", token);
        response.put("accessToken", token);
        response.put("expiresIn", jwtTokenProvider.getJwtExpirationMs());
        
        return response;
    }
    
    /**
     * Logout user (token invalidation handled on client side)
     * @return Logout confirmation message
     */
    public Map<String, String> logout(String email) {
        log.info("User logged out: {}", email);
        return Map.of("message", "Logged out successfully");
    }
}

