package com.aliparwiz.microgreens.device;

import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DeviceService {
    
    private final DeviceRepository deviceRepository;
    private final AuthRepository authRepository;
    
    public List<Device> getAllDevices() {
        if (isCurrentUserAdmin()) {
            return deviceRepository.findAll();
        }

        Long userId = getCurrentUserId();
        if (userId == null) {
            return List.of();
        }
        return deviceRepository.findByOwnerId(userId);
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
    
    public Device getDeviceById(Long id) {
        Device device = deviceRepository.findById(id)
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
    
    public Device getDeviceByDeviceId(String deviceId) {
        return deviceRepository.findByDeviceId(deviceId)
            .orElseThrow(() -> new RuntimeException("Device not found"));
    }
    
    @Transactional
    public Device createDevice(Device device) {
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
        return deviceRepository.save(device);
    }
    
    @Transactional
    public Device updateDevice(Long id, Device deviceDetails) {
        Device device = getDeviceById(id);
        
        if (deviceDetails.getName() != null) {
            device.setName(deviceDetails.getName());
        }
        if (deviceDetails.getDescription() != null) {
            device.setDescription(deviceDetails.getDescription());
        }
        if (deviceDetails.getDeviceType() != null) {
            device.setDeviceType(deviceDetails.getDeviceType());
        }
        if (deviceDetails.getLocation() != null) {
            device.setLocation(deviceDetails.getLocation());
        }
        if (deviceDetails.getIsActive() != null) {
            device.setIsActive(deviceDetails.getIsActive());
        }
        
        device.setUpdatedAt(LocalDateTime.now());
        return deviceRepository.save(device);
    }
    
    @Transactional
    public void deleteDevice(Long id) {
        Device device = getDeviceById(id);
        deviceRepository.delete(device);
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
}

