package com.aliparwiz.microgreens.ai;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PredictionService {
    
    private final PredictionRepository predictionRepository;
    
    @Transactional
    public Prediction savePrediction(Prediction prediction) {
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
        return predictionRepository.findByDevice_DeviceId(deviceId);
    }
    
    public List<Prediction> getPredictionsByDeviceIdAndType(String deviceId, String predictionType) {
        return predictionRepository.findByDevice_DeviceIdAndPredictionType(deviceId, predictionType);
    }
    
    public List<Prediction> getLatestPredictionsByDeviceId(String deviceId) {
        return predictionRepository.findLatestByDeviceId(deviceId); 

    }
    
    public Optional<Prediction> getLatestPredictionByDeviceIdAndType(String deviceId, String predictionType) {
        return predictionRepository.findLatestByDeviceIdAndPredictionType(deviceId, predictionType);
    }
    
    public List<Prediction> getAllPredictions() {
        return predictionRepository.findAll();
    }
}

