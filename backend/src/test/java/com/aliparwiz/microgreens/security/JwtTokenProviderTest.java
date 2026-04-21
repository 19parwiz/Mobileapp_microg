package com.aliparwiz.microgreens.security;

import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@EnableTestLifecycleLogging
class JwtTokenProviderTest {

    private JwtTokenProvider jwtTokenProvider;

    @BeforeEach
    void setUp() {
        jwtTokenProvider = new JwtTokenProvider();
        // Test-only config so token behavior is deterministic and easy to debug.
        Object target = jwtTokenProvider;
        ReflectionTestUtils.setField(
                target,
                "jwtSecret",
                "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI="
        );
        ReflectionTestUtils.setField(target, "jwtExpirationMs", 60_000L);
    }

    @Test
    @DisplayName("JWT should be generated and decoded with expected claims")
    void generateAndParseTokenShouldReturnExpectedClaims() {
        String token = jwtTokenProvider.generateToken(123L, "test@example.com", "USER");

        assertTrue(jwtTokenProvider.validateToken(token));
        assertEquals(123L, jwtTokenProvider.getUserIdFromToken(token));
        assertEquals("test@example.com", jwtTokenProvider.getEmailFromToken(token));
        assertEquals("USER", jwtTokenProvider.getRoleFromToken(token));
    }

    @Test
    @DisplayName("Invalid JWT must fail validation")
    void invalidTokenShouldFailValidation() {
        assertFalse(jwtTokenProvider.validateToken("invalid.token.value"));
    }
}
