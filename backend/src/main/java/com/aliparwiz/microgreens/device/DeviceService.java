package com.aliparwiz.microgreens.device;

import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.User;
import com.aliparwiz.microgreens.device.dto.DeviceRequest;
import com.aliparwiz.microgreens.device.dto.DeviceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceService {
    
    private final DeviceRepository deviceRepository;
    private final AuthRepository authRepository;
    
    public List<DeviceResponse> getAllDevices() {
        if (isCurrentUserAdmin()) {
            return deviceRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
        }

        Long userId = getCurrentUserId();
        if (userId == null) {
            return List.of();
        }
        return deviceRepository.findByOwnerId(userId).stream()
            .map(this::toResponse)
            .toList();
    }
    
    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return null;
        }
        String email = auth.getName();
        return authRepository.findByEmail(email)
            .map(User::getId)
            .orElse(null);
    }

    private boolean isCurrentUserAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        return auth.getAuthorities().stream()
            .anyMatch(authority -> "ROLE_ADMIN".equals(authority.getAuthority()));
    }
    
    public DeviceResponse getDeviceById(Long id) {
        return toResponse(getDeviceEntityById(id));
    }

    private Device getDeviceEntityById(Long id) {
        Device device = deviceRepository.findById(Objects.requireNonNull(id, "Device id is required"))
            .orElseThrow(() -> new RuntimeException("Device not found"));

        if (isCurrentUserAdmin()) {
            return device;
        }

        Long userId = getCurrentUserId();
        if (userId == null || device.getOwner() == null || !device.getOwner().getId().equals(userId)) {
            throw new RuntimeException("Access denied: This device does not belong to you");
        }

        return device;
    }
    
    public DeviceResponse getDeviceByDeviceId(String deviceId) {
        Device device = deviceRepository.findByDeviceId(deviceId)
            .orElseThrow(() -> new RuntimeException("Device not found"));
        return toResponse(device);
    }
    
    @Transactional
    public DeviceResponse createDevice(DeviceRequest request) {
        Device device = toEntity(request);
        if (device.getDeviceId() != null && deviceRepository.existsByDeviceId(device.getDeviceId())) {
            throw new RuntimeException("Device with this ID already exists");
        }
        
        // Set current user as owner
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new RuntimeException("User must be authenticated to create a device");
        }
        
        String email = auth.getName();
        User owner = authRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        device.setOwner(owner);
        
        device.setCreatedAt(LocalDateTime.now());
        device.setUpdatedAt(LocalDateTime.now());
        Device savedDevice = deviceRepository.save(device);
        log.info("[DEVICE] Created device: id='{}', name='{}', owner='{}'",
            savedDevice.getDeviceId(), savedDevice.getName(), email);
        return toResponse(savedDevice);
    }
    
    @Transactional
    public DeviceResponse updateDevice(Long id, DeviceRequest request) {
        Device device = getDeviceEntityById(id);
        
        if (request.getName() != null) {
            device.setName(request.getName());
        }
        if (request.getDeviceId() != null && !request.getDeviceId().equals(device.getDeviceId())) {
            if (deviceRepository.existsByDeviceId(request.getDeviceId())) {
                throw new RuntimeException("Device with this ID already exists");
            }
            device.setDeviceId(request.getDeviceId());
        }
        if (request.getDescription() != null) {
            device.setDescription(request.getDescription());
        }
        if (request.getDeviceType() != null) {
            device.setDeviceType(request.getDeviceType());
        }
        if (request.getLocation() != null) {
            device.setLocation(request.getLocation());
        }
        if (request.getIsActive() != null) {
            device.setIsActive(request.getIsActive());
        }
        
        device.setUpdatedAt(LocalDateTime.now());
        Device updatedDevice = deviceRepository.save(device);
        log.info("[DEVICE] Updated device: id='{}', name='{}'",
            updatedDevice.getDeviceId(), updatedDevice.getName());
        return toResponse(updatedDevice);
    }
    
    @Transactional
    public void deleteDevice(Long id) {
        Device device = getDeviceEntityById(id);
        deviceRepository.delete(Objects.requireNonNull(device, "Device must not be null"));
        log.info("[DEVICE] Deleted device: id='{}', name='{}'",
            device.getDeviceId(), device.getName());
    }
    
    @Transactional
    public void updateLastSeen(String deviceId) {
        Device device = deviceRepository.findByDeviceId(deviceId)
            .orElse(null);
        if (device != null) {
            device.setLastSeen(LocalDateTime.now());
            deviceRepository.save(device);
        }
    }

    private DeviceResponse toResponse(Device device) {
        return DeviceResponse.builder()
            .id(device.getId())
            .name(device.getName())
            .deviceId(device.getDeviceId())
            .description(device.getDescription())
            .deviceType(device.getDeviceType())
            .location(device.getLocation())
            .isActive(device.getIsActive())
            .lastSeen(device.getLastSeen())
            .createdAt(device.getCreatedAt())
            .build();
    }

    private Device toEntity(DeviceRequest request) {
        Device device = new Device();
        device.setName(request.getName());
        device.setDeviceId(request.getDeviceId());
        device.setDescription(request.getDescription());
        device.setDeviceType(request.getDeviceType());
        device.setLocation(request.getLocation());
        device.setIsActive(request.getIsActive());
        return device;
    }
}

