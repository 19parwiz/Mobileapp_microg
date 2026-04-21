package com.aliparwiz.microgreens.api;

import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@EnableTestLifecycleLogging
class HealthControllerWebMvcTest {

    private HealthController healthController;

    @BeforeEach
    void setUp() {
        healthController = new HealthController();
        // Keep values explicit so assertions read like a real endpoint response contract.
        Object target = healthController;
        ReflectionTestUtils.setField(target, "appName", "Microgreens Test");
        ReflectionTestUtils.setField(target, "appVersion", "1.0.0-test");
        ReflectionTestUtils.setField(target, "appDescription", "Test description");
    }

    @Test
    @DisplayName("Health endpoint returns UP and app name")
    void healthEndpointReturnsUpStatus() {
        ResponseEntity<Map<String, Object>> response = healthController.getHealth();
        Map<String, Object> body = response.getBody();

        assertEquals(200, response.getStatusCode().value());
        assertNotNull(body);
        assertEquals("UP", body.get("status"));
        assertEquals("Microgreens Test", body.get("application"));
    }

    @Test
    @DisplayName("Info endpoint returns app metadata")
    void infoEndpointReturnsVersionMetadata() {
        ResponseEntity<Map<String, String>> response = healthController.getInfo();
        Map<String, String> body = response.getBody();

        assertEquals(200, response.getStatusCode().value());
        assertNotNull(body);
        assertEquals("Microgreens Test", body.get("name"));
        assertEquals("1.0.0-test", body.get("version"));
        assertEquals("Test description", body.get("description"));
    }
}
