package com.aliparwiz.microgreens.ai;

import com.aliparwiz.microgreens.device.Device;
import com.aliparwiz.microgreens.device.DeviceRepository;
import com.aliparwiz.microgreens.security.SecurityContextUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PredictionService {
    
    private final PredictionRepository predictionRepository;
    private final DeviceRepository deviceRepository;
    
    @Transactional
    public Prediction savePrediction(Prediction prediction) {
        Long deviceId = prediction.getDevice() != null ? prediction.getDevice().getId() : null;
        Device device = resolveAccessibleDeviceById(deviceId);
        prediction.setDevice(device);
        if (prediction.getTimestamp() == null) {
            prediction.setTimestamp(LocalDateTime.now());
        }
        prediction.setCreatedAt(LocalDateTime.now());
        Prediction savedPrediction = predictionRepository.save(prediction);
        log.info("[AI] Saved prediction: type='{}', deviceId='{}'",
            savedPrediction.getPredictionType(),
            savedPrediction.getDevice() != null ? savedPrediction.getDevice().getId() : null);
        return savedPrediction;
    }
    
    // TODO: Add method to receive prediction from Python AI service
    // TODO: Implement webhook endpoint for AI service to POST predictions
    // TODO: Add validation for prediction data format
    
    public List<Prediction> getPredictionsByDeviceId(String deviceId) {
        ensureDeviceAccessByExternalId(deviceId);
        return predictionRepository.findByDevice_DeviceId(deviceId);
    }
    
    public List<Prediction> getPredictionsByDeviceIdAndType(String deviceId, String predictionType) {
        ensureDeviceAccessByExternalId(deviceId);
        return predictionRepository.findByDevice_DeviceIdAndPredictionType(deviceId, predictionType);
    }
    
    public List<Prediction> getLatestPredictionsByDeviceId(String deviceId) {
        ensureDeviceAccessByExternalId(deviceId);
        return predictionRepository.findLatestByDeviceId(deviceId); 

    }
    
    public Optional<Prediction> getLatestPredictionByDeviceIdAndType(String deviceId, String predictionType) {
        ensureDeviceAccessByExternalId(deviceId);
        return predictionRepository.findLatestByDeviceIdAndPredictionType(deviceId, predictionType);
    }
    
    public List<Prediction> getAllPredictions() {
        ensureAdmin();
        return predictionRepository.findAll();
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

