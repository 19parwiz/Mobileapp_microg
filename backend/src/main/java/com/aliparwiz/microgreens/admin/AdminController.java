package com.aliparwiz.microgreens.admin;

import com.aliparwiz.microgreens.admin.dto.UserResponseDto;
import com.aliparwiz.microgreens.admin.dto.DeviceResponseDto;
import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.Role;
import com.aliparwiz.microgreens.auth.User;
import com.aliparwiz.microgreens.device.DeviceRepository;
import com.aliparwiz.microgreens.device.Device;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Admin Controller
 * Endpoints for admin-only operations (user and device management)
 * All endpoints require ADMIN role
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AuthRepository authRepository;
    private final DeviceRepository deviceRepository;

    /**
     * Get all users in the system (admin only)
     * Returns user data without passwords
     */
    @GetMapping("/users")
    public ResponseEntity<List<UserResponseDto>> getAllUsers() {
        List<User> users = authRepository.findAll();
        List<UserResponseDto> userDtos = users.stream()
            .map(UserResponseDto::fromUser)
            .toList();
        return ResponseEntity.ok(userDtos);
    }

    /**
     * Get all devices in the system (admin only)
     * Returns device data with owner information
     */
    @GetMapping("/devices")
    public ResponseEntity<List<DeviceResponseDto>> getAllDevices() {
        List<Device> devices = deviceRepository.findAll();
        List<DeviceResponseDto> deviceDtos = devices.stream()
            .map(DeviceResponseDto::fromDevice)
            .toList();
        return ResponseEntity.ok(deviceDtos);
    }

    /**
     * Update user role (ADMIN <-> USER)
     */
    @PutMapping("/users/{id}/role")
    public ResponseEntity<?> updateUserRole(
            @PathVariable Long id,
            @RequestParam String role) {
        try {
            Role newRole = Role.valueOf(role.toUpperCase());
            User user = authRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

            user.setRole(newRole);
            user.setUpdatedAt(LocalDateTime.now());
            authRepository.save(user);

            return ResponseEntity.ok(Map.of(
                "message", "User role updated successfully",
                "userId", user.getId(),
                "role", user.getRole().name()
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid role. Use USER or ADMIN"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}
