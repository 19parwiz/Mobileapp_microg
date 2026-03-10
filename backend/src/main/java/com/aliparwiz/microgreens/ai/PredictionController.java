package com.aliparwiz.microgreens.ai;

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
    public ResponseEntity<?> savePrediction(@RequestBody Prediction prediction) {
        try {
            Prediction saved = predictionService.savePrediction(prediction);
            return ResponseEntity.ok(saved);
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
    public ResponseEntity<List<Prediction>> getPredictionsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(predictionService.getPredictionsByDeviceId(deviceId));
    }
    
    @GetMapping("/predictions/device/{deviceId}/type/{predictionType}")
    public ResponseEntity<List<Prediction>> getPredictionsByDeviceAndType(
            @PathVariable String deviceId,
            @PathVariable String predictionType) {
        return ResponseEntity.ok(predictionService.getPredictionsByDeviceIdAndType(deviceId, predictionType));
    }
    
    @GetMapping("/predictions/device/{deviceId}/latest")
    public ResponseEntity<List<Prediction>> getLatestPredictionsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(predictionService.getLatestPredictionsByDeviceId(deviceId));
    }
    
    @GetMapping("/predictions/device/{deviceId}/type/{predictionType}/latest")
    public ResponseEntity<?> getLatestPredictionByDeviceAndType(
            @PathVariable String deviceId,
            @PathVariable String predictionType) {
        Optional<Prediction> prediction = predictionService.getLatestPredictionByDeviceIdAndType(deviceId, predictionType);
        if (prediction.isPresent()) {
            return ResponseEntity.ok(prediction.get());
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping("/predictions")
    public ResponseEntity<List<Prediction>> getAllPredictions() {
        return ResponseEntity.ok(predictionService.getAllPredictions());
    }
}

