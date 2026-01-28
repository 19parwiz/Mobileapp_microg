package com.aliparwiz.microgreens.api;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Health Check and Info Controller
 * Provides endpoints for monitoring application health and version information
 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class HealthController {

    @Value("${app.name:Microgreens Management System}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    @Value("${app.description:Spring Boot backend for microgreens management}")
    private String appDescription;

    /**
     * Health check endpoint
     * Returns application status and availability
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> getHealth() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", LocalDateTime.now());
        health.put("application", appName);
        health.put("message", "Application is running successfully");

        return ResponseEntity.ok(health);
    }

    /**
     * Application info endpoint
     * Returns application metadata and version information
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, String>> getInfo() {
        Map<String, String> info = new HashMap<>();
        info.put("name", appName);
        info.put("version", appVersion);
        info.put("description", appDescription);
        info.put("timestamp", LocalDateTime.now().toString());

        return ResponseEntity.ok(info);
    }
}
