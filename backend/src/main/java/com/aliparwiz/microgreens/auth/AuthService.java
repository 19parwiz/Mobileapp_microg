package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.auth.dto.AuthResponse;
import com.aliparwiz.microgreens.auth.dto.LoginRequest;
import com.aliparwiz.microgreens.auth.dto.RegisterRequest;
import com.aliparwiz.microgreens.auth.dto.ResendVerificationRequest;
import com.aliparwiz.microgreens.auth.dto.ResetPasswordRequest;
import com.aliparwiz.microgreens.auth.dto.UpdateProfileRequest;
import com.aliparwiz.microgreens.auth.dto.UserProfileResponse;
import com.aliparwiz.microgreens.exception.AccountSuspendedException;
import com.aliparwiz.microgreens.exception.EmailNotVerifiedException;
import com.aliparwiz.microgreens.exception.ResourceNotFoundException;
import com.aliparwiz.microgreens.exception.ValidationException;
import com.aliparwiz.microgreens.mail.EmailService;
import com.aliparwiz.microgreens.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Authentication Service
 * Handles user registration, login, token management, email verification, and password reset.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String MSG_REGISTER_CHECK_EMAIL =
        "Registration successful. Please check your email to verify your account before signing in.";
    private static final String MSG_EMAIL_NOT_VERIFIED = "Please verify your email first";
    private static final String MSG_ACCOUNT_SUSPENDED = "This account has been suspended";
    private static final String MSG_FORGOT_GENERIC =
        "If an account exists for that email, password reset instructions have been sent.";
    private static final String MSG_RESEND_GENERIC =
        "If an account exists and is awaiting verification, a new verification email has been sent.";

    private final AuthRepository authRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;

    private static AccountStatus effectiveStatus(User user) {
        if (user.getAccountStatus() == null) {
            return AccountStatus.ACTIVE;
        }
        return user.getAccountStatus();
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();
        String name = request.getName();

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

        String verificationToken = UUID.randomUUID().toString();

        User user = new User();
        user.setEmail(email.trim());
        user.setPassword(passwordEncoder.encode(password));
        user.setName(name.trim());
        user.setRole(Role.USER);
        user.setAccountStatus(AccountStatus.PENDING_VERIFICATION);
        user.setVerificationToken(verificationToken);

        User savedUser = authRepository.save(user);
        log.info("[AUTH] Registered user (pending verification): {}", savedUser.getEmail());

        emailService.sendVerificationEmail(savedUser.getEmail(), verificationToken);

        return buildPendingVerificationResponse(savedUser);
    }

    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();

        User user = authRepository.findByEmail(email)
            .orElseThrow(() -> new ValidationException("Invalid email or password"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.warn("[AUTH] Login failed for user: {}", email);
            throw new ValidationException("Invalid email or password");
        }

        AccountStatus status = effectiveStatus(user);
        if (status == AccountStatus.PENDING_VERIFICATION) {
            throw new EmailNotVerifiedException(MSG_EMAIL_NOT_VERIFIED);
        }
        if (status == AccountStatus.SUSPENDED) {
            throw new AccountSuspendedException(MSG_ACCOUNT_SUSPENDED);
        }

        log.info("[AUTH] User logged in: {}", email);

        String token = jwtTokenProvider.generateToken(
            user.getId(),
            user.getEmail(),
            user.getRole().name()
        );

        return buildAuthResponseWithToken(user, token);
    }

    public Map<String, String> logout(String email) {
        log.info("[AUTH] User logged out: {}", email);
        return Map.of("message", "Logged out successfully");
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getCurrentProfile(Long userId) {
        User user = authRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return toUserProfileResponse(user);
    }

    @Transactional
    public UserProfileResponse updateCurrentProfile(Long userId, UpdateProfileRequest request) {
        User user = authRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        String newEmail = request.getEmail().trim();
        if (!newEmail.equalsIgnoreCase(user.getEmail()) && authRepository.existsByEmail(newEmail)) {
            throw new ValidationException("Email already in use");
        }

        user.setName(request.getName().trim());
        user.setEmail(newEmail);
        user.setUpdatedAt(LocalDateTime.now());
        authRepository.save(user);
        log.info("[AUTH] Profile updated for user id={}", userId);
        return toUserProfileResponse(user);
    }

    private UserProfileResponse toUserProfileResponse(User user) {
        AccountStatus status = effectiveStatus(user);
        return UserProfileResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .name(user.getName())
            .role(user.getRole().name())
            .accountStatus(status.name())
            .createdAt(user.getCreatedAt())
            .updatedAt(user.getUpdatedAt())
            .build();
    }

    @Transactional
    public Map<String, String> verifyEmail(String token) {
        if (token == null || token.isBlank()) {
            throw new ValidationException("Verification token is required");
        }
        User user = authRepository.findByVerificationToken(token.trim())
            .orElseThrow(() -> new ValidationException("Invalid or expired verification link"));

        user.setAccountStatus(AccountStatus.ACTIVE);
        user.setVerificationToken(null);
        user.setUpdatedAt(LocalDateTime.now());
        authRepository.save(user);
        log.info("[AUTH] Email verified for user id={}", user.getId());

        return Map.of(
            "message", "Email verified successfully. You can sign in now.",
            "email", user.getEmail()
        );
    }

    @Transactional
    public Map<String, String> forgotPassword(String emailRaw) {
        String email = emailRaw == null ? "" : emailRaw.trim();
        if (email.isEmpty()) {
            return Map.of("message", MSG_FORGOT_GENERIC);
        }

        authRepository.findByEmail(email).ifPresent(user -> {
            if (effectiveStatus(user) != AccountStatus.ACTIVE) {
                return;
            }
            String token = UUID.randomUUID().toString();
            user.setResetPasswordToken(token);
            user.setResetPasswordExpiry(LocalDateTime.now().plusMinutes(15));
            user.setUpdatedAt(LocalDateTime.now());
            authRepository.save(user);
            emailService.sendPasswordResetEmail(user.getEmail(), token);
            log.info("[AUTH] Password reset email queued for user id={}", user.getId());
        });

        return Map.of("message", MSG_FORGOT_GENERIC);
    }

    @Transactional
    public Map<String, String> resetPassword(ResetPasswordRequest request) {
        String token = request.getToken();
        if (token == null || token.isBlank()) {
            throw new ValidationException("Reset token is required");
        }

        User user = authRepository.findByResetPasswordToken(token.trim())
            .orElseThrow(() -> new ValidationException("Invalid or expired reset token"));

        if (user.getResetPasswordExpiry() == null
            || user.getResetPasswordExpiry().isBefore(LocalDateTime.now())) {
            throw new ValidationException("Invalid or expired reset token");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setResetPasswordToken(null);
        user.setResetPasswordExpiry(null);
        user.setUpdatedAt(LocalDateTime.now());
        authRepository.save(user);
        log.info("[AUTH] Password reset completed for user id={}", user.getId());

        return Map.of("message", "Password has been reset. You can sign in with your new password.");
    }

    @Transactional
    public Map<String, String> resendVerification(ResendVerificationRequest request) {
        String email = request.getEmail() == null ? "" : request.getEmail().trim();
        if (email.isEmpty()) {
            return Map.of("message", MSG_RESEND_GENERIC);
        }

        authRepository.findByEmail(email).ifPresent(user -> {
            if (effectiveStatus(user) != AccountStatus.PENDING_VERIFICATION) {
                return;
            }
            if (user.getVerificationToken() == null || user.getVerificationToken().isBlank()) {
                user.setVerificationToken(UUID.randomUUID().toString());
            }
            user.setUpdatedAt(LocalDateTime.now());
            authRepository.save(user);
            emailService.sendVerificationEmail(user.getEmail(), user.getVerificationToken());
            log.info("[AUTH] Verification email resent for user id={}", user.getId());
        });

        return Map.of("message", MSG_RESEND_GENERIC);
    }

    private AuthResponse buildPendingVerificationResponse(User user) {
        return AuthResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .name(user.getName())
            .role(user.getRole().name())
            .token(null)
            .accessToken(null)
            .expiresIn(null)
            .message(MSG_REGISTER_CHECK_EMAIL)
            .accountStatus(AccountStatus.PENDING_VERIFICATION.name())
            .emailVerified(false)
            .build();
    }

    private AuthResponse buildAuthResponseWithToken(User user, String token) {
        return AuthResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .name(user.getName())
            .role(user.getRole().name())
            .token(token)
            .accessToken(token)
            .expiresIn(jwtTokenProvider.getJwtExpirationMs())
            .accountStatus(effectiveStatus(user).name())
            .emailVerified(true)
            .build();
    }
}
