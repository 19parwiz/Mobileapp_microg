package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.exception.ErrorResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Authentication Controller
 * Handles user registration, login, and logout endpoints
 */
@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final AuthService authService;
    
    /**
     * Register a new user
     * @param request Map containing email, password, and name
     * @return User info and JWT token
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String password = request.get("password");
            String name = request.get("name");
            
            Map<String, Object> response = authService.register(email, password, name);
            log.info("User registration successful: {}", email);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Registration failed: {}", e.getMessage());
            return buildErrorResponse(e, HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * Login with email and password
     * @param request Map containing email and password
     * @return User info and JWT token
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String password = request.get("password");
            
            Map<String, Object> response = authService.login(email, password);
            log.info("User login successful: {}", email);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Login failed: {}", e.getMessage());
            return buildErrorResponse(e, HttpStatus.UNAUTHORIZED);
        }
    }
    
    /**
     * Logout user
     * @return Logout confirmation
     */
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            String email = extractEmailFromToken(authHeader);
            Map<String, String> response = authService.logout(email);
            log.info("User logout successful: {}", email);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Logout failed: {}", e.getMessage());
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
    
    /**
     * Build standardized error response
     */
    private ResponseEntity<ErrorResponse> buildErrorResponse(Exception e, HttpStatus status) {
        ErrorResponse errorResponse = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(status.value())
                .error(status.getReasonPhrase())
                .message(e.getMessage())
                .build();
        return new ResponseEntity<>(errorResponse, status);
    }
}

