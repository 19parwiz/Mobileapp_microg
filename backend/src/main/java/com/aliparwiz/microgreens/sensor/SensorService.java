package com.aliparwiz.microgreens.sensor;

import com.aliparwiz.microgreens.device.Device;
import com.aliparwiz.microgreens.device.DeviceRepository;
import com.aliparwiz.microgreens.security.SecurityContextUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SensorService {
    
    private final SensorRepository sensorRepository;
    private final DeviceRepository deviceRepository;
    
    @Transactional
    public SensorReading saveReading(SensorReading reading) {
        Long deviceId = reading.getDevice() != null ? reading.getDevice().getId() : null;
        Device device = resolveAccessibleDeviceById(deviceId);
        reading.setDevice(device);
        if (reading.getTimestamp() == null) {
            reading.setTimestamp(LocalDateTime.now());
        }
        reading.setCreatedAt(LocalDateTime.now());
        return sensorRepository.save(reading);
    }
    
    @Transactional
    public List<SensorReading> saveReadings(List<SensorReading> readings) {
        readings.forEach(reading -> {
            Long deviceId = reading.getDevice() != null ? reading.getDevice().getId() : null;
            Device device = resolveAccessibleDeviceById(deviceId);
            reading.setDevice(device);
            if (reading.getTimestamp() == null) {
                reading.setTimestamp(LocalDateTime.now());
            }
            reading.setCreatedAt(LocalDateTime.now());
        });
        return sensorRepository.saveAll(readings);
    }
    
    public List<SensorReading> getReadingsByDeviceId(String deviceId) {
        ensureDeviceAccessByExternalId(deviceId);
        return sensorRepository.findByDevice_DeviceId(deviceId);
    }
    
    public List<SensorReading> getReadingsByDeviceIdAndSensorType(String deviceId, String sensorType) {
        ensureDeviceAccessByExternalId(deviceId);
        return sensorRepository.findByDevice_DeviceIdAndSensorType(deviceId, sensorType);
    }

    public List<SensorReading> getReadingsByDeviceIdAndDate(String deviceId, LocalDate date) {
        ensureDeviceAccessByExternalId(deviceId);
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.plusDays(1).atStartOfDay();
        return sensorRepository.findByDevice_DeviceIdAndTimestampBetween(deviceId, start, end);
    }
    
    public List<SensorReading> getLatestReadingsByDeviceId(String deviceId) {
        ensureDeviceAccessByExternalId(deviceId);
        return sensorRepository.findLatestByDeviceId(deviceId);
    }
    
    public Optional<SensorReading> getLatestReadingByDeviceIdAndSensorType(String deviceId, String sensorType) {
        ensureDeviceAccessByExternalId(deviceId);
        return sensorRepository.findLatestByDeviceIdAndSensorType(deviceId, sensorType);
    }
    
    public List<SensorReading> getAllReadings() {
        ensureAdmin();
        return sensorRepository.findAll();
    }

    public List<SensorDailySummary> getDailySummariesByDeviceId(String deviceId) {
        ensureDeviceAccessByExternalId(deviceId);
        return sensorRepository.findDailySummariesByDeviceId(deviceId).stream()
                .map(row -> new SensorDailySummary(
                        (LocalDate) row[0],
                        (String) row[1],
                        row[2] != null ? ((Number) row[2]).doubleValue() : null,
                        row[3] != null ? ((Number) row[3]).doubleValue() : null,
                        row[4] != null ? ((Number) row[4]).doubleValue() : null,
                        row[5] != null ? ((Number) row[5]).longValue() : 0L
                ))
                .toList();
    }

    private Device resolveAccessibleDeviceById(Long id) {
        Device device = deviceRepository.findById(Objects.requireNonNull(id, "Device id is required"))
                .orElseThrow(() -> new RuntimeException("Device not found"));
        ensureDeviceOwnership(device);
        return device;
    }

    private void ensureDeviceAccessByExternalId(String deviceId) {
        Device device = deviceRepository.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));
        ensureDeviceOwnership(device);
    }

    private void ensureDeviceOwnership(Device device) {
        if (isCurrentUserAdmin()) {
            return;
        }
        Long currentUserId = SecurityContextUtils.requireCurrentUserId();
        if (device.getOwner() == null || !currentUserId.equals(device.getOwner().getId())) {
            throw new AccessDeniedException("Access denied for this device");
        }
    }

    private void ensureAdmin() {
        if (!isCurrentUserAdmin()) {
            throw new AccessDeniedException("Admin role required");
        }
    }

    private boolean isCurrentUserAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null
                && auth.isAuthenticated()
                && auth.getAuthorities().stream().anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
    }
}

