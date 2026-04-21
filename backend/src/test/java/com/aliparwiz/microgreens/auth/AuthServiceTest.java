package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import com.aliparwiz.microgreens.auth.dto.AuthResponse;
import com.aliparwiz.microgreens.auth.dto.LoginRequest;
import com.aliparwiz.microgreens.auth.dto.RegisterRequest;
import com.aliparwiz.microgreens.exception.ValidationException;
import com.aliparwiz.microgreens.mail.EmailService;
import com.aliparwiz.microgreens.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Objects;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
@EnableTestLifecycleLogging
class AuthServiceTest {

    @Mock
    private AuthRepository authRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private AuthService authService;

    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setEmail("new@example.com");
        registerRequest.setPassword("password123");
        registerRequest.setName("New User");

        loginRequest = new LoginRequest();
        loginRequest.setEmail("user@example.com");
        loginRequest.setPassword("password123");
    }

    @Test
    @DisplayName("Register creates pending-verification user and sends verification email")
    void registerShouldCreatePendingVerificationUser() {
        when(authRepository.existsByEmail("new@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("encoded-password");
        // Simulate DB-generated primary key after save.
        when(authRepository.save(any())).thenAnswer(invocation -> {
            User saved = Objects.requireNonNull(invocation.getArgument(0, User.class));
            saved.setId(10L);
            return saved;
        });

        AuthResponse response = authService.register(registerRequest);

        assertEquals("new@example.com", response.getEmail());
        assertEquals(AccountStatus.PENDING_VERIFICATION.name(), response.getAccountStatus());
        assertTrue(Boolean.FALSE.equals(response.getEmailVerified()));
        verify(emailService).sendVerificationEmail(eq("new@example.com"), any(String.class));
    }

    @Test
    @DisplayName("Register rejects duplicate email")
    void registerShouldRejectDuplicateEmail() {
        when(authRepository.existsByEmail("new@example.com")).thenReturn(true);

        ValidationException exception = assertThrows(
                ValidationException.class,
                () -> authService.register(registerRequest)
        );

        assertEquals("Email already registered", exception.getMessage());
        verify(authRepository, never()).save(any());
    }

    @Test
    @DisplayName("Login returns JWT for active account with valid password")
    void loginShouldReturnTokenForActiveUser() {
        User user = new User();
        user.setId(22L);
        user.setEmail("user@example.com");
        user.setPassword("hashed");
        user.setRole(Role.USER);
        user.setAccountStatus(AccountStatus.ACTIVE);

        when(authRepository.findByEmail("user@example.com"))
                .thenReturn(Optional.of(Objects.requireNonNull(user)));
        when(passwordEncoder.matches("password123", "hashed")).thenReturn(true);
        when(jwtTokenProvider.generateToken(22L, "user@example.com", "USER")).thenReturn("jwt-token");
        when(jwtTokenProvider.getJwtExpirationMs()).thenReturn(86400000L);

        AuthResponse response = authService.login(loginRequest);

        assertNotNull(response);
        assertEquals("jwt-token", response.getToken());
        assertEquals("jwt-token", response.getAccessToken());
        assertEquals(AccountStatus.ACTIVE.name(), response.getAccountStatus());
        assertTrue(Boolean.TRUE.equals(response.getEmailVerified()));
    }
}
