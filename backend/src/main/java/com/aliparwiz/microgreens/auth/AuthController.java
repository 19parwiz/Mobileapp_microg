package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.auth.dto.AuthResponse;
import com.aliparwiz.microgreens.auth.dto.LoginRequest;
import com.aliparwiz.microgreens.auth.dto.RegisterRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Authentication Controller
 * Handles user registration, login, and logout endpoints
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final AuthService authService;
    
    /**
     * Register a new user
     * @param request DTO containing email, password, and name
     * @return User info and JWT token
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }
    
    /**
     * Login with email and password
     * @param request DTO containing email and password
     * @return User info and JWT token
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
    
    /**
     * Logout user
     * @return Logout confirmation
     */
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            String email = extractEmailFromToken(authHeader);
            return ResponseEntity.ok(authService.logout(email));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
        }
    }
    
    /**
     * Extract email from JWT token (for logging purposes)
     */
    private String extractEmailFromToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return "user"; // In real scenario, parse token to get email
        }
        return "unknown";
    }
    
}

