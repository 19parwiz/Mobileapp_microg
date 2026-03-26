package com.aliparwiz.microgreens.ai;

import com.aliparwiz.microgreens.ai.dto.PredictionRequest;
import com.aliparwiz.microgreens.ai.dto.PredictionResponse;
import com.aliparwiz.microgreens.device.Device;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PredictionController {
    
    private final PredictionService predictionService;
    private final OpenAiChatService openAiChatService;

    @PostMapping("/chat")
    public ResponseEntity<?> chat(@RequestBody ChatRequest request) {
        try {
            return ResponseEntity.ok(openAiChatService.chat(request));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("message", "Failed to generate AI response: " + e.getMessage()));
        }
    }
    
    @PostMapping("/predictions")
    public ResponseEntity<?> savePrediction(@Valid @RequestBody PredictionRequest request) {
        try {
            Prediction saved = predictionService.savePrediction(toEntity(request));
            return ResponseEntity.ok(toResponse(saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", "Failed to save prediction: " + e.getMessage()));
        }
    }
    
    // TODO: Add webhook endpoint for Python AI service
    // @PostMapping("/predictions/webhook")
    // public ResponseEntity<?> receivePredictionFromAI(@RequestBody Map<String, Object> payload) {
    //     // Parse JSON from Python AI service
    //     // Save prediction to database
    //     // Return success response
    // }
    
    @GetMapping("/predictions/device/{deviceId}")
    public ResponseEntity<List<PredictionResponse>> getPredictionsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(
            predictionService.getPredictionsByDeviceId(deviceId).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/predictions/device/{deviceId}/type/{predictionType}")
    public ResponseEntity<List<PredictionResponse>> getPredictionsByDeviceAndType(
            @PathVariable String deviceId,
            @PathVariable String predictionType) {
        return ResponseEntity.ok(
            predictionService.getPredictionsByDeviceIdAndType(deviceId, predictionType).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/predictions/device/{deviceId}/latest")
    public ResponseEntity<List<PredictionResponse>> getLatestPredictionsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(
            predictionService.getLatestPredictionsByDeviceId(deviceId).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/predictions/device/{deviceId}/type/{predictionType}/latest")
    public ResponseEntity<PredictionResponse> getLatestPredictionByDeviceAndType(
            @PathVariable String deviceId,
            @PathVariable String predictionType) {
        Optional<Prediction> prediction = predictionService.getLatestPredictionByDeviceIdAndType(deviceId, predictionType);
        if (prediction.isPresent()) {
            return ResponseEntity.ok(toResponse(prediction.get()));
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping("/predictions")
    public ResponseEntity<List<PredictionResponse>> getAllPredictions() {
        return ResponseEntity.ok(
            predictionService.getAllPredictions().stream()
                .map(this::toResponse)
                .toList()
        );
    }

    private Prediction toEntity(PredictionRequest request) {
        String predictionPayload = request.getPredictionData();
        if (predictionPayload == null || predictionPayload.isBlank()) {
            predictionPayload = request.getImageBase64();
        }
        if (predictionPayload == null || predictionPayload.isBlank()) {
            throw new IllegalArgumentException("Prediction data is required");
        }

        Device device = new Device();
        device.setId(request.getDeviceId());

        Prediction prediction = new Prediction();
        prediction.setDevice(device);
        prediction.setPredictionType(
            request.getPredictionType() == null || request.getPredictionType().isBlank()
                ? "image_prediction"
                : request.getPredictionType()
        );
        prediction.setPredictionData(predictionPayload);
        prediction.setConfidenceScore(request.getConfidence());
        prediction.setModelVersion(request.getModelVersion());
        return prediction;
    }

    private PredictionResponse toResponse(Prediction prediction) {
        return PredictionResponse.builder()
            .id(prediction.getId())
            .prediction(prediction.getPredictionData())
            .confidence(prediction.getConfidenceScore())
            .message(prediction.getPredictionType())
            .modelVersion(prediction.getModelVersion())
            .timestamp(prediction.getTimestamp())
            .build();
    }
}

